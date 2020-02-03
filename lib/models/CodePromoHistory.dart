class CodePromoHistory {
  String code;
  DateTime dateScan;

  CodePromoHistory({this.code = 'NONAME', DateTime dateScan}):
      dateScan = dateScan ?? DateTime.now();

  factory CodePromoHistory.fromJson(Map<String, dynamic> json) {
    return CodePromoHistory(
      code: json["code"],
      dateScan: DateTime.parse(json["time"]),
    );
  }

}