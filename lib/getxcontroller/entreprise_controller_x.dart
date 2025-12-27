import 'package:cnmci/konan/model/entreprise.dart';
import 'package:get/get.dart';

import '../konan/repositories/entreprise_repository.dart';


class EntrepriseControllerX extends GetxController {

  // A t t r i b u t e s  :
  var data = <Entreprise>[].obs;
  final _repository = EntrepriseRepository();


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

  void addItem(Entreprise data) async{
    this.data.add(data);
    await _repository.insert(data);
    update();
  }

  void addItemWithNoNotification(Entreprise data) async{
    this.data.add(data);
    await _repository.insert(data);
  }

  void deleteItem(Entreprise data){
    this.data.removeWhere((d) => d.id == data.id);
    update();
  }

  void updateData(Entreprise data) async {
    // Remove
    this.data.removeWhere((d) => d.id == data.id);
    // Add it :
    this.data.add(data);
    update();
  }
}