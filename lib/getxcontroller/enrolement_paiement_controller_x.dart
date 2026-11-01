
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../konan/model/enrolement_paiement.dart';
import '../konan/repositories/enrolement_paiement_repository.dart';

class EnrolementPaiementController extends GetxController {

  // A t t r i b u t e s  :
  var data = <EnrolementPaiement>[].obs;
  final _repository = EnrolementPaiementRepository();


  // M E T H O D S :
  @override
  void onInit() {
    refreshData();
    super.onInit();
  }

  Future<void> refreshData() async{
    // Clear FIRST :
    var tmp = await _repository.findAll();
    //tmp.sort((a,b) => b.id.compareTo(a.id)); // Reversed
    data.addAll(tmp);
    update();
  }

  void addItem(EnrolementPaiement data) async{
    await _repository.insert(data);
    this.data.add(data);
    update();
  }
}