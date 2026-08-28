import 'package:cnmci/konan/model/co_gerant.dart';
import 'package:cnmci/konan/model/requete_sql.dart';
import 'package:cnmci/konan/repositories/co_gerant_repository.dart';
import 'package:cnmci/konan/repositories/requete_sql_repository.dart';
import 'package:get/get.dart';


class RequeteSqlControllerX extends GetxController {

  // A t t r i b u t e s  :
  var data = <RequeteSql>[].obs;
  final _repository = RequeteSqlRepository();


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

  void addItem(RequeteSql data) async{
    this.data.add(data);
    this.data.sort((a,b) => b.id.compareTo(a.id)); // Reversed
    await _repository.insert(data);
    update();
  }
}