import 'package:bon_plant_local_app/model/data_controller_model.dart';
import 'package:flutter/material.dart';
import 'package:hovering/hovering.dart';
import 'package:nsg_controls/dialog/show_nsg_dialog.dart';
import 'package:nsg_controls/nsg_controls.dart';

class InteractiveWatering extends StatelessWidget {
  final List<int> values;
  final Function(int, int) onChanged;
  const InteractiveWatering({super.key, required this.values, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    List<Widget> list = [];
    for (var i = 0; i < 24; i++) {
      list.add(InteractiveWateringSlider(
        onChanged: onChanged,
        hour: i,
        value: values[i],
      ));
    }
    return Stack(
      children: [
        grid(),
        Padding(
          padding: const EdgeInsets.only(top: 0, left: 60),
          child: Row(children: list),
        ),
      ],
    );
  }

  Widget grid() {
    List<Widget> list = [];
    for (var i = 0; i <= 10; i++) {
      list.add(SizedBox(
        height: 40,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 30,
              height: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${(10 - i) * 10}',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: nsgtheme.sizeXL),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                height: 1,
                decoration: BoxDecoration(border: Border(top: BorderSide(width: 1, color: nsgtheme.colorMain.withOpacity(0.5)))),
              ),
            ),
          ],
        ),
      ));
    }
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(children: list),
    );
  }
}

class InteractiveWateringSlider extends StatefulWidget {
  const InteractiveWateringSlider({super.key, required this.hour, required this.value, required this.onChanged});
  final int hour;
  final int value;
  final Function(int, int) onChanged;

  @override
  State<InteractiveWateringSlider> createState() => _InteractiveWateringSliderState();
}

class _InteractiveWateringSliderState extends State<InteractiveWateringSlider> {
  int val = 0;
  double w = 1100 / 24;
  IrrigationRow wateringItem = IrrigationRow();

  @override
  void initState() {
    val = widget.value;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.topCenter,
          children: [
            // Вертикальная линия в сетке
            SizedBox(
              width: w,
              child: Center(
                child: Container(
                    height: 440,
                    width: w,
                    decoration: const BoxDecoration(),
                    child: Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 40),
                        height: 400,
                        width: 2,
                        decoration: BoxDecoration(color: nsgtheme.colorMain.withOpacity(0.2)),
                      ),
                    )),
              ),
            ),
            // Жирная вертикальная линия
            Transform.translate(
              offset: Offset(0, 440 - val.toDouble() * 4),
              child: Container(
                height: val.toDouble() * 4,
                width: 10,
                decoration: BoxDecoration(color: nsgtheme.colorMain),
              ),
            ),
            // Кружочек
            Transform.translate(
              offset: Offset(0, 430 - val.toDouble() * 4),
              child: Container(
                width: w,
                height: 20,
                decoration: BoxDecoration(shape: BoxShape.circle, color: nsgtheme.colorMain),
              ),
            ),
            // Обработчик нажатия на любое место линии
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: SizedBox(
                width: w,
                child: Center(
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onVerticalDragEnd: (details) => widget.onChanged(widget.hour, val),
                      onVerticalDragStart: (details) {
                        var dy = details.localPosition.dy;
                        updateDrag(dy);
                      },
                      onVerticalDragUpdate: (details) {
                        var dy = details.localPosition.dy;
                        updateDrag(dy);
                      },
                      child: Container(
                        height: 420,
                        width: w,
                        decoration: const BoxDecoration(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Transform.translate(
              offset: Offset(0, 400 - val.toDouble() * 4),
              child: InkWell(
                onTap: () {
                  wateringItem.irrigation = val;
                  showNsgDialog(
                      context: context,
                      title: 'Уровень ирригации',
                      child: SizedBox(
                        width: 200,
                        child: Column(
                          children: [
                            NsgInput(
                              autofocus: true,
                              margin: const EdgeInsets.only(bottom: 10),
                              textAlign: TextAlign.center,
                              showDeleteIcon: false,
                              showLabel: false,
                              dataItem: wateringItem,
                              fieldName: IrrigationRowGenerated.nameIrrigation,
                              onEditingComplete: (p0, p1) {
                                val = wateringItem.irrigation.toInt();
                                if (val > 100) {
                                  val = 100;
                                } else if (val < 0) {
                                  val = 0;
                                }
                                Navigator.of(context).pop();
                                setState(() {});
                                widget.onChanged(widget.hour, val);
                              },
                            ),
                          ],
                        ),
                      ),
                      buttons: [
                        SizedBox(
                          width: 200,
                          child: NsgButton(
                            margin: const EdgeInsets.only(bottom: 10),
                            text: 'Применить',
                            onPressed: () {
                              val = wateringItem.irrigation.toInt();
                              if (val > 100) {
                                val = 100;
                              } else if (val < 0) {
                                val = 0;
                              }
                              Navigator.of(context).pop();
                              setState(() {});
                              widget.onChanged(widget.hour, val);
                            },
                          ),
                        )
                      ]);
                },
                child: HoverWidget(
                  hoverChild: Container(
                      padding: const EdgeInsets.all(2),
                      width: 40,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(3), color: nsgtheme.colorMain),
                      child: Center(
                          child: Text(
                        '$val',
                        style: TextStyle(color: nsgtheme.colorMainText),
                      ))),
                  onHover: (event) {},
                  child: Container(
                      padding: const EdgeInsets.all(2),
                      width: 40,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(3), color: nsgtheme.colorGreyLight),
                      child: Center(child: Text('$val'))),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          '${widget.hour}',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: nsgtheme.sizeXL),
        )
      ],
    );
  }

  void updateDrag(double dy) {
    dy = (dy / 20).floor() * 20;

    if (dy < 0) {
      dy = 0;
    } else if (dy > 400) {
      dy = 400;
    }

    val = (400 - dy) ~/ 4;
    //widget.onChanged(widget.hour, val);
    setState(() {});
  }
}
