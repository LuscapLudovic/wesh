import 'package:wesh/models/codePromo.dart';

class CodePromoHistory {
  CodePromo code;
  DateTime dateScan;

  CodePromoHistory({CodePromo code, DateTime dateScan}):
      code = code ?? CodePromo(name: 'Name', code: 'Code'),
      dateScan = dateScan ?? DateTime.now();

  factory CodePromoHistory.fromJson(Map<String, dynamic> json) {
    return CodePromoHistory(
      code: CodePromo.fromJson(json["code"]),
      dateScan: DateTime.parse(json["time"]),
    );
  }

}