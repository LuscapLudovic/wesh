import 'package:test/test.dart';
import 'package:wesh/models/codePromo.dart';

void main() {
  group('CodePromo', () {
    test('default should be NoName', () {
      expect(CodePromo().name, 'NoName');
      expect(CodePromo().code, 'NONAME');
    });

    test('values should be inicialised', () {
      final codePromo = CodePromo(
          name: 'Name',
          code: 'CODE',
          startDate: DateTime.utc(2019, 02, 20, 8),
          endDate: DateTime.utc(2019, 02, 21)
      );
      expect(codePromo.name, 'Name');
      expect(codePromo.code, 'CODE');
      expect(codePromo.startDate, DateTime.utc(2019, 02, 20, 8));
      expect(codePromo.endDate, DateTime.utc(2019, 02, 21));
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