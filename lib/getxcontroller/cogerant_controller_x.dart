import 'package:cnmci/konan/model/co_gerant.dart';
import 'package:cnmci/konan/repositories/co_gerant_repository.dart';
import 'package:get/get.dart';


class CogerantControllerX extends GetxController {

  // A t t r i b u t e s  :
  var data = <CoGerant>[].obs;
  final _repository = CoGerantRepository();


  // M E T H O D S :
  @override
  void onInit() {
    refreshData();
    super.onInit();
  }

  Future<void> refreshData() async{
    // Clear FIRST :
    var tmp = await _repository.findAll();
    tmp.sort((a,b) => b.id.compareTo(a.id)); // Reversed
    data.addAll(tmp);
    update();
  }

  void addItem(CoGerant data) async{
    this.data.add(data);
    this.data.sort((a,b) => b.id.compareTo(a.id)); // Reversed
    await _repository.insert(data);
    update();
  }

  void updateData(CoGerant data) async {
    // Remove
    this.data.removeWhere((d) => d.id == data.id);
    // Add it :
    this.data.add(data);
    update();
  }
}