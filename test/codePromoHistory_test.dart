import 'package:test/test.dart';
import 'package:wesh/models/codePromo.dart';
import 'package:wesh/models/codePromoHistory.dart';

void main() {
  group('CodePromoHistory', () {
    test('default should be NoName', () {
      CodePromo defaultCode = CodePromoHistory().code;
      expect(defaultCode.name, 'NoName');
      expect(defaultCode.code, 'NONAME');
    });

    test('values should be inicialised', () {
      final codePromoHistory = CodePromoHistory(
          code: CodePromo(
              name: 'Name',
              code: 'CODE',
              startDate: DateTime.utc(2019, 02, 20, 8),
              endDate: DateTime.utc(2019, 02, 21)
          ),
          dateScan: DateTime.utc(2019, 02, 20, 8)
      );
    });

    test('isValide should be true or false', () {
      final codePromo = CodePromo(
          startDate: DateTime.utc(2019, 02, 20, 8),
          endDate: DateTime.utc(2019, 02, 21)
      );
      expect(codePromo.isValide, false);

      codePromo.endDate = DateTime.now().add(new Duration(hours: 2));
      expect(codePromo.isValide, true);

      codePromo.startDate = DateTime.now().add(new Duration(hours: 1));
      expect(codePromo.isValide, false);
    });
  });
}