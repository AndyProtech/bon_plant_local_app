import 'dart:convert';
import 'dart:io';

import 'package:bon_plant_local_app/model/data_controller_model.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nsg_controls/nsg_controls.dart';
import 'package:nsg_data/helpers/nsg_data_format.dart';
import 'package:nsg_data/helpers/nsg_data_guid.dart';
import 'package:translit/translit.dart';

import 'controllers/irrigation_row_controller.dart';
import 'controllers/student_controller.dart';
import 'interactive_watering.dart';

class StartPage extends StatefulWidget {
  const StartPage({Key? key}) : super(key: key);

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  var studC = Get.find<StudentController>();
  var irrC = Get.find<IrrigationRowController>();
  int currentDay = 1;
  String nameValidate = '', classValidate = '', daysValidate = '';

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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: NsgInput(
                                      label: 'Фамилия Имя',
                                      dataItem: studC.currentItem,
                                      fieldName: StudentGenerated.nameName,
                                      validateText: nameValidate,
                                      onEditingComplete: (p0, p1) {
                                        if (studC.currentItem.name.isNotEmpty) {
                                          nameValidate = '';
                                          setState(() {});
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: NsgInput(
                                      label: 'Класс',
                                      dataItem: studC.currentItem,
                                      fieldName: StudentGenerated.nameStudentClass,
                                      validateText: classValidate,
                                      onEditingComplete: (p0, p1) {
                                        if (studC.currentItem.studentClass.isNotEmpty) {
                                          classValidate = '';
                                          setState(() {});
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: NsgInput(
                                      label: 'Дней эксперимента',
                                      dataItem: studC.currentItem,
                                      fieldName: StudentGenerated.nameExperimentDays,
                                      validateText: daysValidate,
                                      onEditingComplete: (p0, p1) {
                                        if (studC.currentItem.experimentDays > 30) {
                                          studC.currentItem.experimentDays = 30;
                                        } else if (studC.currentItem.experimentDays < 1) {
                                          studC.currentItem.experimentDays = 1;
                                        }
                                        if (studC.currentItem.experimentDays > 0) {
                                          daysValidate = '';
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
                          irrC.obx((state) => irrigationDays()),
                          irrC.obx((state) => irrigationWidget()),
                          exportButton()
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
      bool hovered = false;
      bool copied = irrC.selectedWateringDay == i;
      list.add(StatefulBuilder(builder: (context, setstate) {
        return Column(
          children: [
            InkWell(
              onTap: () {
                currentDay = i;
                irrC.sendNotify();
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
              padding: const EdgeInsets.only(top: 4, bottom: 4),
              child: Text(
                '$mlмл',
                style: TextStyle(fontSize: nsgtheme.sizeS),
              ),
            ),
            StatefulBuilder(builder: (context, state) {
              return InkWell(
                onTap: () async {
                  if (irrC.selectedWateringDay == 0) {
                    irrC.selectedWateringDay = i;
                    copied = true;
                  } else if (irrC.selectedWateringDay == i) {
                    irrC.selectedWateringDay = 0;
                    copied = false;
                  } else {
                    var watering = irrC.items.where((element) => element.day == irrC.selectedWateringDay && element.irrigation > 0);
                    irrC.items.removeWhere((element) => element.day == i && element.irrigation > 0);
                    List<IrrigationRow> newrows = [];
                    for (var row in watering) {
                      IrrigationRow newrow = IrrigationRow();
                      newrow.irrigation = row.irrigation;
                      newrow.day = i;
                      newrow.hour = row.hour;
                      newrow.id = Guid.newGuid();
                      newrows.add(newrow);
                    }
                    for (var newrow in newrows) {
                      irrC.items.add(newrow);
                    }
                    irrC.sendNotify();
                  }

                  state(() {});
                },
                onHover: (hover) {
                  hovered = hover;
                  state(() {});
                },
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: Icon(
                    copied ? Icons.close : Icons.copy,
                    size: hovered ? 24 : 16,
                    color: copied
                        ? nsgtheme.colorError
                        : hovered
                            ? nsgtheme.colorMain
                            : nsgtheme.colorGrey,
                  ),
                ),
              );
            })
          ],
        );
      }));
    }
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: list);
  }

  Widget irrigationWidget() {
    List<int> values = [];
    for (var i = 0; i < 24; i++) {
      var item = irrC.items.firstWhereOrNull((element) => element.day == currentDay && element.hour == i);
      values.add(item == null ? 0 : item.irrigation);
    }
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 1000),
      firstChild: const SizedBox(width: 1200),
      secondChild: InteractiveWatering(
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
            await irrC.itemPagePost(goBack: false);
          }
          irrC.sendNotify();
        },
      ),
      crossFadeState: studC.currentItem.experimentDays == 0 ? CrossFadeState.showFirst : CrossFadeState.showSecond,
    );
  }

  Widget exportButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        NsgButton(
          width: 200,
          margin: const EdgeInsets.only(top: 30),
          text: 'Импорт из CSV',
          onPressed: () async {
            FilePickerResult? result = await FilePicker.platform.pickFiles(
              withData: true,
              type: FileType.custom,
              allowedExtensions: ['csv'],
            );
            //print(result);
            if (result != null) {
              PlatformFile file = result.files.first;

              final input = File(file.name).openRead();
              final fields = await input.transform(utf8.decoder).transform(const CsvToListConverter()).toList();
              var appName = fields[0][0];
              if (appName != 'BonPlant') {
                Get.dialog(NsgPopUp(
                  showCloseButton: true,
                  hideBackButton: true,
                  title: 'Ошибка',
                  text: 'CSV файл не соответствует формату данного приложения',
                  contentBottom: Center(
                    child: NsgButton(
                      margin: EdgeInsets.zero,
                      width: 100,
                      text: 'Ок',
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ));
                return;
              }
              var fileVersion = double.parse(fields[0][1].replaceAll('v', ''));
              if (fileVersion != nsgtheme.fileExchangeVersion) {
                Get.dialog(NsgPopUp(
                  showCloseButton: true,
                  hideBackButton: true,
                  title: 'Ошибка',
                  text: 'Версия CSV файла не соответствует версии данного приложения',
                  contentBottom: Center(
                    child: NsgButton(
                      margin: EdgeInsets.zero,
                      width: 100,
                      text: 'Ок',
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ));
                return;
              }
              irrC.items.clear();
              // print(irrC.items);
              // print(fields);
              fields.asMap().forEach((key, value) async {
                if (key == 0) {
                  studC.currentItem.name = value[2];
                  studC.currentItem.studentClass = value[3];
                  studC.currentItem.experimentDays = value[4];
                } else {
                  // var item = irrC.items.firstWhereOrNull((element) => element.day == value[0] && element.hour == value[1]);
                  // print(item);
                  // if (item != null) {
                  //   item.irrigation = int.parse(value[2]);
                  // } else {
                  await irrC.createNewItemAsync();
                  irrC.currentItem.day = value[0];
                  irrC.currentItem.hour = value[1];
                  irrC.currentItem.irrigation = value[2];
                  irrC.items.add(irrC.currentItem);
                  await irrC.itemPagePost(goBack: false);
                  // }
                }
              });
              //await irrC.refreshData();
              //print(irrC.items.length);

              irrC.sendNotify();
              studC.sendNotify();
            }

            // Get.dialog(picker, barrierDismissible: true);
          },
        ),
        const SizedBox(width: 15),
        NsgButton(
          width: 200,
          margin: const EdgeInsets.only(top: 30),
          text: 'Экспорт в CSV',
          onPressed: () async {
            bool validate = true;
            if (studC.currentItem.name.isEmpty) {
              nameValidate = 'Введите Фамилию и Имя';
              validate = false;
            }
            if (studC.currentItem.studentClass.isEmpty) {
              classValidate = 'Введите класс ученика';
              validate = false;
            }
            if (studC.currentItem.experimentDays == 0) {
              daysValidate = 'Введите количество дней эксперимента';
              validate = false;
            }
            if (!validate) {
              setState(() {});
              return;
            }
            List<List<dynamic>> doc = [];
            doc.add([
              'BonPlant',
              'v${nsgtheme.fileExchangeVersion}',
              studC.currentItem.name,
              studC.currentItem.studentClass,
              '${studC.currentItem.experimentDays}',
              '${NsgDateFormat.dateFormat(DateTime.now(), format: 'dd MMM yyyy / HH:mm')}',
            ]);
            for (var row in irrC.items) {
              doc.add([row.day, row.hour, row.irrigation]);
            }
            final csvData = const ListToCsvConverter().convert(doc);
            //assert(csvData == '",b",3.1,42\r\n"n\n"');

            String? outputFile = await FilePicker.platform.saveFile(
              dialogTitle: 'Укажите директорию и название файла для экспорта в CSV:',
              fileName:
                  '${Translit().toTranslit(source: studC.currentItem.name.replaceAll(' ', '_'))}-Irrigation-${NsgDateFormat.dateFormat(DateTime.now(), format: 'dd-MM-yyyy_HH-mm')}.csv',
            );
            try {
              File returnedFile = File('$outputFile');
              await returnedFile.writeAsString(csvData);
            } catch (e) {}
          },
        ),
      ],
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
