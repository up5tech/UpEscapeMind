import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:up_escape_mind/data/content/content_loader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads the bundled content catalog from assets', () async {
    final catalog = await const ContentLoader().load(
      assetExists: (path) async {
        try {
          await rootBundle.load(path);
          return true;
        } catch (_) {
          return false;
        }
      },
    );

    expect(catalog.chapters, isNotEmpty);
    expect(catalog.rooms, isNotEmpty);
    expect(catalog.puzzles, isNotEmpty);
    expect(catalog.items, isNotEmpty);
  });
}
