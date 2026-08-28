import 'package:cnmci/konan/model/gerant_entreprise.dart';
import 'package:cnmci/konan/repositories/gerant_entreprise_repository.dart';
import 'package:get/get.dart';


class GerantEntrepriseControllerX extends GetxController {

  // A t t r i b u t e s  :
  var data = <GerantEntreprise>[].obs;
  final _repository = GerantEntrepriseRepository();


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

  void addItem(GerantEntreprise data) async{
    this.data.add(data);
    this.data.sort((a,b) => b.id.compareTo(a.id)); // Reversed
    await _repository.insert(data);
    update();
  }
}