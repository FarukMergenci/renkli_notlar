import 'package:flutter_test/flutter_test.dart';
import 'package:renkli_notlar/main.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('RenkliNotlarApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const RenkliNotlarApp());
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Renkli Notlar'), findsOneWidget);
  });
}
