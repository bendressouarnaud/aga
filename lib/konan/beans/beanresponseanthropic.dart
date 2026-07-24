import 'package:cnmci/konan/beans/user_response_record.dart';
import 'package:cnmci/konan/model/apprenti.dart';
import 'package:cnmci/konan/model/compagnon.dart';
import 'package:cnmci/konan/model/entreprise.dart';

import '../model/action_terrain.dart';
import '../model/artisan.dart';

class BeanResponseAnthropic {

  // A t t r i b u t e s  :
  final List<dynamic> result;
  final List<String> colonnes;

  // M e t h o d s  :
  BeanResponseAnthropic({required this.result, required this.colonnes});
  factory BeanResponseAnthropic.fromJson(Map<String, dynamic> json) {
    return BeanResponseAnthropic(
      result: json['result'].cast<dynamic>(),
      colonnes: List<String>.from(json["colonnes"].map((x) => x))
    );
  }
}