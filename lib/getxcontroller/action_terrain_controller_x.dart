import 'package:cnmci/konan/model/artisan.dart';
import 'package:get/get.dart';

import '../konan/model/action_terrain.dart';
import '../konan/repositories/action_terrain_repository.dart';
import '../konan/repositories/artisan_repository.dart';


class ActionTerrainControllerX extends GetxController {

  // A t t r i b u t e s  :
  var data = <ActionTerrain>[].obs;
  final _repository = ActionTerrainRepository();


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

  void addItem(ActionTerrain data) async{
    this.data.add(data);
    this.data.sort((a,b) => b.id.compareTo(a.id)); // Reversed
    await _repository.insert(data);
    update();
  }

  void updateData(ActionTerrain data) async {
    // Remove
    this.data.removeWhere((d) => d.id == data.id);
    // Add it :
    this.data.add(data);
    this.data.sort((a,b) => b.id.compareTo(a.id));
    await _repository.update(data);
    update();
  }
}