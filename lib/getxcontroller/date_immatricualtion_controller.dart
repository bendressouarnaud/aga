
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class DateImmatricualtionController extends GetxController {

  // A t t r i b u t e s  :
  var data = <String>[].obs;

  // M E T H O D S :
  @override
  void onInit() {
    super.onInit();
  }

  void addData(DateTime dateTime){
    // Clear first :
    data.clear();
    List<String> tp = dateTime.toString().split(" ");
    String tpDate = tp[0] ;
    data.add(tpDate);
    //
    update();
  }

  void clear() {
    data.clear();
  }
}