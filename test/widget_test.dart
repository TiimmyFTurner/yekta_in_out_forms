import 'package:flutter_test/flutter_test.dart';
import 'package:yekta_in_out_forms/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const YektaInOutApp());
    expect(find.byType(YektaInOutApp), findsOneWidget);
  });
}
