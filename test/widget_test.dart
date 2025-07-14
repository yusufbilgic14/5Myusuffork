// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:medipolapp/main.dart';

void main() {
  testWidgets('Medipol app starts with loading screen', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MedipolApp());

    // Verify that our app starts with the initial loading screen
    // Check for copyright text which should always be present
    expect(find.text('Copyrighted 2025® Tüm Hakları Saklıdır'), findsOneWidget);

    // Wait for the loading screen timer and check if login screen appears
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // Verify that we've navigated to the login screen
    expect(find.text('Login'), findsWidgets);
    expect(find.text('Student ID'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Back'), findsOneWidget);
  });
}
