
import 'package:get/get.dart';

import '../konan/model/derniere_operation.dart';
import '../konan/repositories/derniere_operation_repository.dart';

class DerniereOperationControllerX extends GetxController {

  // A t t r i b u t e s  :
  var data = <DerniereOperation>[].obs;
  final _repository = DerniereOperationRepository();


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

  void addItem(DerniereOperation data) async{
    await _repository.insert(data);
    var derniereOperation = await _repository.findOneByMilliseconde(data.millisecondes);
    if(derniereOperation != null){
      this.data.add(derniereOperation);
      this.data.sort((a,b) => b.id.compareTo(a.id));
      update();
    }
  }
}