

import 'dart:convert';

class CodePromo {
  String name;
  String code;
  DateTime startDate;
  DateTime endDate;

  CodePromo({this.name = 'NoName', this.code = 'NONAME', DateTime startDate, DateTime endDate}):
        startDate = startDate ?? DateTime.now(),
        endDate = endDate ?? DateTime.now();

  factory CodePromo.fromJson(Map<String, dynamic> json) {
    return CodePromo(
      name: utf8.decode(json['name'].toString().codeUnits),
      code: utf8.decode(json['code'].toString().codeUnits),
      startDate: DateTime.parse(json["create_time"]),
      endDate: DateTime.parse(json["end_time"]),
    );
  }

  bool get isValide {
    DateTime now = DateTime.now();
    return startDate.isBefore(now) && endDate.isAfter(now);
  }

}