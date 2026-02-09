import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:regional_shorts_app/screens/health/health_tips_screen.dart';

void main() {
  testWidgets('HealthTipsScreen displays loading and tabs',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HealthTipsScreen()));
    // Initial loading
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    // Wait for data to load
    await tester.pumpAndSettle();
    // Tabs should be present
    expect(find.text('Tip of the Day'), findsOneWidget);
    expect(find.text('Categories'), findsOneWidget);
    expect(find.text('Alerts'), findsOneWidget);
  });
}
