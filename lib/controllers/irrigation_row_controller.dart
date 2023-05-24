import 'package:bon_plant_local_app/model/data_controller_model.dart';
import 'package:nsg_data/nsg_data.dart';

class IrrigationRowController extends NsgDataController<IrrigationRow> {
  IrrigationRowController() : super(requestOnInit: false, autoRepeate: true, autoRepeateCount: 10);

  int selectedWateringDay = 0;
}
