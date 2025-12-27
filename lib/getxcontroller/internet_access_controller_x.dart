
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';


class InternetAccessController extends GetxController {

  // A t t r i b u t e s  :
  var data = <bool>[].obs;

  // M E T H O D S :
  @override
  void onInit() {
    data.add(false);
    super.onInit();
  }

  Future<void> refreshData(bool value) async{
    data[0] = value;
    update();
  }

}