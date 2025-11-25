import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slice/login_page.dart';

void main() {
  testWidgets('LoginPage UI loads and responds', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    expect(find.text('Slice'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('Continue'), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'JDoe001@ucr.edu');
    await tester.enterText(find.byType(TextField).at(1), 'password123');

    await tester.tap(find.text('Continue'));
    await tester.pump();

    expect(find.text('Slice'), findsOneWidget);
  });
}
