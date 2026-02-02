import 'package:get/get.dart';

import '../konan/model/apprenti.dart';
import '../konan/repositories/apprenti_repository.dart';


class ApprentiControllerX extends GetxController {

  // A t t r i b u t e s  :
  var data = <Apprenti>[].obs;
  final _repository = ApprentiRepository();


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

  void addItem(Apprenti data) async{
    this.data.add(data);
    this.data.sort((a,b) => b.id.compareTo(a.id)); // Reversed
    await _repository.insert(data);
    update();
  }

  void addItemWithNoNotification(Apprenti data) async{
    this.data.add(data);
    await _repository.insert(data);
  }

  void deleteItem(Apprenti data){
    this.data.removeWhere((d) => d.id == data.id);
    update();
  }

  void updateData(Apprenti data) async {
    // Remove
    this.data.removeWhere((d) => d.id == data.id);
    // Add it :
    this.data.add(data);
    await _repository.update(data);
    update();
  }
}