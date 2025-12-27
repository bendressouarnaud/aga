
import 'package:flutter/cupertino.dart';

class UserResponseRecord {
  final int id;
  final String name;
  final String firstname;
  final String email;
  final String contact;
  final String profil;
  final String token;

  UserResponseRecord({
    required this.id,
    required this.name,
    required this.firstname,
    required this.email,
    required this.contact,
    required this.profil,
    required this.token
  });

  factory UserResponseRecord.fromJson(Map<String, dynamic> json) {
    return UserResponseRecord(
        id: json['id'],
        name: json['name'],
        firstname: json['firstname'],
        email: json['email'],
        contact: json['contact'],
        profil: json['profil'],
        token: json['token']
    );
  }
}