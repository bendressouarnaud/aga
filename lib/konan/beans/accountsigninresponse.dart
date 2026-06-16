import 'package:cnmci/konan/beans/user_response_record.dart';
import 'package:cnmci/konan/model/apprenti.dart';
import 'package:cnmci/konan/model/compagnon.dart';
import 'package:cnmci/konan/model/entreprise.dart';

import '../model/action_terrain.dart';
import '../model/artisan.dart';

class AccountSignInResponse {

  // A t t r i b u t e s  :
  final int code;
  final UserResponseRecord data;
  final List<Artisan> artisans;
  final List<Apprenti> apprentis;
  final List<Compagnon> compagnons;
  final List<Entreprise> entreprises;
  final List<ActionTerrain> actionterrains;

  // M e t h o d s  :
  AccountSignInResponse({required this.code, required this.data, required this.artisans, required this.apprentis,
    required this.compagnons, required this.entreprises, required this.actionterrains});
  factory AccountSignInResponse.fromJson(Map<String, dynamic> json) {
    return AccountSignInResponse(
      code: json['code'],
      data: UserResponseRecord.fromJson(json['data']),
      artisans: List<dynamic>.from(json['artisans']).map((i) => Artisan.fromDatabaseJson(i)).toList(),
      apprentis: List<dynamic>.from(json['apprentis']).map((i) => Apprenti.fromDatabaseJson(i)).toList(),
      compagnons: List<dynamic>.from(json['compagnons']).map((i) => Compagnon.fromDatabaseJson(i)).toList(),
      entreprises: List<dynamic>.from(json['entreprises']).map((i) => Entreprise.fromDatabaseJson(i)).toList(),
      actionterrains: List<dynamic>.from(json['actionterrains']).map((i) => ActionTerrain.fromDatabaseJson(i)).toList(),
    );
  }
}