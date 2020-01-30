

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
      name: json["name"],
      code: json["code"],
      startDate: DateTime.parse(json["create_time"]),
      endDate: DateTime.parse(json["end_time"]),
    );
  }

  bool get isValide {
    DateTime now = DateTime.now();
    return startDate.isBefore(now) && endDate.isAfter(now);
  }

}