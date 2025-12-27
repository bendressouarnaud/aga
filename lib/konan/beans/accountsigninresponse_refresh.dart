import 'package:cnmci/konan/beans/user_response_record.dart';
import 'package:cnmci/konan/model/apprenti.dart';
import 'package:cnmci/konan/model/compagnon.dart';
import 'package:cnmci/konan/model/entreprise.dart';

import '../model/artisan.dart';

class AccountSignInResponseRefresh {

  // A t t r i b u t e s  :
  final int code;
  final UserResponseRecord data;

  // M e t h o d s  :
  AccountSignInResponseRefresh({required this.code, required this.data});
  factory AccountSignInResponseRefresh.fromJson(Map<String, dynamic> json) {
    return AccountSignInResponseRefresh(
      code: json['code'],
      data: UserResponseRecord.fromJson(json['data'])
    );
  }
}