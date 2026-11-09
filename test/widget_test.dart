import 'package:flutter_test/flutter_test.dart';
import 'package:mien_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const BrickTaskApp());
    expect(find.byType(BrickTaskApp), findsOneWidget);
  });
}
