import 'package:bon_plant_local_app/model/data_controller_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/nsg_controls.dart';

import 'controllers/irrigation_row_controller.dart';
import 'controllers/student_controller.dart';

class StartPage extends StatefulWidget {
  const StartPage({Key? key}) : super(key: key);

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  var studC = Get.find<StudentController>();
  var irrC = Get.find<IrrigationRowController>();
  int currentDay = -1;

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
                    width: 800,
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
                            child: Text('ДЕНЬ ПОЛИВА'),
                          ),
                          irrigationDays(),
                          irrC.obx((state) => irrigationList())
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
    for (var i = 0; i < studC.currentItem.experimentDays; i++) {
      var onhover = currentDay == i;
      list.add(StatefulBuilder(builder: (context, setstate) {
        return InkWell(
          onTap: () {
            currentDay = i;
            setState(() {});
          },
          onHover: (value) {
            if (currentDay != i) {
              onhover = value;
            }
            setstate(() {});
          },
          child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(border: Border.all(width: 1, color: nsgtheme.colorMain), color: onhover ? nsgtheme.colorMain : Colors.transparent),
              width: 20,
              height: 20,
              child: Center(
                  child: Text(
                '$i',
                style: TextStyle(color: onhover ? nsgtheme.colorMainText : nsgtheme.colorText),
              ))),
        );
      }));
    }
    return Row(key: GlobalKey(), mainAxisAlignment: MainAxisAlignment.center, children: list);
  }

  Widget irrigationList() {
    List<Widget> list = [];
    for (var row in irrC.items) {
      list.add(Row(
        children: [
          Expanded(
            child: NsgInput(
              label: 'День',
              dataItem: irrC.currentItem,
              fieldName: IrrigationRowGenerated.nameDay,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: NsgInput(
              label: 'Час',
              dataItem: irrC.currentItem,
              fieldName: IrrigationRowGenerated.nameHour,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: NsgInput(
              label: 'Ирригация',
              dataItem: irrC.currentItem,
              fieldName: IrrigationRowGenerated.nameIrrigation,
            ),
          ),
        ],
      ));
    }
    return Column(children: list);
  }
}
