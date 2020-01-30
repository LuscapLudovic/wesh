

class CodePromo {

  String name = '';
  String code = '';
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  CodePromo({this.name, this.code, this.startDate, this.endDate});

  factory CodePromo.fromJson(Map<String, dynamic> json) {
    return CodePromo(
      name: json["name"],
      code: json["code"],
      startDate: DateTime.parse(json["create_time"]),
      endDate: DateTime.parse(json["end_time"]),
    );
  }

}