import 'package:get/get.dart';

import '../konan/model/compagnon.dart';
import '../konan/repositories/compagnon_repository.dart';


class CompagnonControllerX extends GetxController {

  // A t t r i b u t e s  :
  var data = <Compagnon>[].obs;
  final _repository = CompagnonRepository();


  // M E T H O D S :
  @override
  void onInit() {
    refreshData();
    super.onInit();
  }

  Future<void> refreshData() async{
    // Clear FIRST :
    var tmp = await _repository.findAll();
    data.addAll(tmp);
    update();
  }

  void addItem(Compagnon data) async{
    this.data.add(data);
    await _repository.insert(data);
    update();
  }

  void addItemWithNoNotification(Compagnon data) async{
    this.data.add(data);
    await _repository.insert(data);
  }

  void deleteItem(Compagnon data){
    this.data.removeWhere((d) => d.id == data.id);
    update();
  }

  void updateData(Compagnon data) async {
    // Remove
    this.data.removeWhere((d) => d.id == data.id);
    // Add it :
    this.data.add(data);
    await _repository.update(data);
    update();
  }
}