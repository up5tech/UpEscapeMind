import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:up_escape_mind/data/database/app_database.dart';
import 'package:up_escape_mind/main.dart';

void main() {
  testWidgets('app launches and shows the main menu', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(UpEscapeMindApp(prefs: prefs, database: db));
    await tester.pumpAndSettle();

    // Splash hands off to the menu; both render the app name.
    expect(find.text('Up Escape Mind'), findsWidgets);
    expect(find.text('Tiếp tục'), findsOneWidget); // vi is the default locale
    expect(find.text('Chơi mới'), findsOneWidget);
  });
}
