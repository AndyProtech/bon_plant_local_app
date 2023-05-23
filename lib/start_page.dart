import 'package:bon_plant_local_app/model/data_controller_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/nsg_controls.dart';

import 'controllers/irrigation_row_controller.dart';
import 'controllers/student_controller.dart';
import 'interactive_watering.dart';
import 'model/data_controller.dart';

class StartPage extends StatefulWidget {
  const StartPage({Key? key}) : super(key: key);

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  var studC = Get.find<StudentController>();
  var irrC = Get.find<IrrigationRowController>();
  var dataC = Get.find<DataController>();
  int currentDay = 1;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BodyWrap(
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 1200,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text('УЧЕНИК'),
                          studC.obx((state) => Row(
                                children: [
                                  Expanded(
                                    child: NsgInput(
                                      label: 'Фамилия Имя',
                                      dataItem: studC.currentItem,
                                      fieldName: StudentGenerated.nameName,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: NsgInput(
                                      label: 'Класс',
                                      dataItem: studC.currentItem,
                                      fieldName: StudentGenerated.nameStudentClass,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: NsgInput(
                                      label: 'Дней эксперимента',
                                      dataItem: studC.currentItem,
                                      fieldName: StudentGenerated.nameExperimentDays,
                                      onEditingComplete: (p0, p1) {
                                        if (studC.currentItem.experimentDays > 30) {
                                          studC.currentItem.experimentDays = 30;
                                        }
                                        setState(() {});
                                      },
                                    ),
                                  )
                                ],
                              )),

                          // NsgButton(
                          //   text: 'Создать таблицу полива',
                          //   onPressed: () {},
                          // ),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text('Дни полива'),
                          ),
                          dataC.obx((state) => irrigationDays()),
                          dataC.obx((state) => irrigationList())
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget irrigationDays() {
    List<Widget> list = [];
    for (var i = 1; i <= studC.currentItem.experimentDays; i++) {
      var onhover = currentDay == i;
      var ml = getIrrigationAmount(day: i);
      list.add(StatefulBuilder(builder: (context, setstate) {
        return Column(
          children: [
            InkWell(
              onTap: () {
                currentDay = i;
                dataC.sendNotify();
              },
              onHover: (value) {
                if (currentDay != i) {
                  onhover = value;
                }
                setstate(() {});
              },
              child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                      border: Border.all(width: 1, color: nsgtheme.colorMain),
                      color: currentDay == i
                          ? nsgtheme.colorMain
                          : onhover
                              ? nsgtheme.colorMain.withOpacity(0.5)
                              : Colors.transparent),
                  width: 40,
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$i',
                        style: TextStyle(color: onhover ? nsgtheme.colorMainText : nsgtheme.colorText),
                      ),
                      if (ml == 0)
                        Icon(
                          Icons.water_drop,
                          size: 14,
                          color: nsgtheme.colorError,
                        )
                    ],
                  )),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '$mlмл',
                style: TextStyle(fontSize: nsgtheme.sizeS),
              ),
            )
          ],
        );
      }));
    }
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: list);
  }

  Widget irrigationList() {
    List<int> values = [];
    for (var i = 0; i < 24; i++) {
      var item = irrC.items.firstWhereOrNull((element) => element.day == currentDay && element.hour == i);
      values.add(item == null ? 0 : item.irrigation);
    }
    return InteractiveWatering(
      key: GlobalKey(),
      values: values,
      onChanged: (bar, value) async {
        var item = irrC.items.firstWhereOrNull((element) => element.day == currentDay && element.hour == bar);
        if (item != null) {
          item.irrigation = value;
        } else {
          await irrC.createNewItemAsync();
          irrC.currentItem.day = currentDay;
          irrC.currentItem.hour = bar;
          irrC.currentItem.irrigation = value;
          //expC.currentItem.wateringMode.addRow(irrC.currentItem);
          await irrC.itemPagePost(goBack: false);
        }
        dataC.sendNotify();
      },
    );
  }
}

bool checkIrrigation() {
  bool watering = true;
  var irrC = Get.find<IrrigationRowController>();
  var studC = Get.find<StudentController>();
  var count = studC.currentItem.experimentDays;
  for (var i = 1; i <= count; i++) {
    var item = irrC.items.firstWhereOrNull((element) => element.day == i && element.irrigation > 0);
    if (item == null) watering = false;
  }
  return watering;
}

int getIrrigationAmount({required int day}) {
  var irrC = Get.find<IrrigationRowController>();
  int ml = 0;
  var irrigation = irrC.items.where((element) => element.day == day && element.irrigation > 0);
  for (var el in irrigation) {
    ml += el.irrigation.toInt();
  }
  return ml;
}
