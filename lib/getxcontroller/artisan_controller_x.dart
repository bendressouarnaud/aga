import 'package:cnmci/konan/model/artisan.dart';
import 'package:get/get.dart';

import '../konan/repositories/artisan_repository.dart';


class ArtisanControllerX extends GetxController {

  // A t t r i b u t e s  :
  var data = <Artisan>[].obs;
  final _repository = ArtisanRepository();


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

  void addItem(Artisan data) async{
    this.data.add(data);
    this.data.sort((a,b) => b.id.compareTo(a.id)); // Reversed
    await _repository.insert(data);
    update();
  }

  void addItemWithNoNotification(Artisan data) async{
    this.data.add(data);
    await _repository.insert(data);
  }

  void justNotify(){
    update();
  }

  void deleteItem(Artisan data){
    this.data.removeWhere((d) => d.id == data.id);
    update();
  }

  void updateData(Artisan data) async {
    // Remove
    this.data.removeWhere((d) => d.id == data.id);
    // Add it :
    this.data.add(data);
    await _repository.update(data);
    update();
  }
}