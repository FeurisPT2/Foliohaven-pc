import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foliohaven_flutter/main.dart';

void main() {
  testWidgets('FolioHaven basic app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: FolioHavenApp(),
      ),
    );
    expect(find.text('FolioHaven'), findsOneWidget);
  });
}
