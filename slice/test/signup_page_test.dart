import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slice/signup_page.dart';

void main() {
  testWidgets('SignUpPage UI loads correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SignUpPage()));

    expect(find.text('Slice'), findsOneWidget);
    expect(find.text('Create an account'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(4));
    expect(find.text('Sign Up'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'JohnDoe');
    await tester.enterText(find.byType(TextField).at(1), 'JDoe001@ucr.edu');
    await tester.enterText(find.byType(TextField).at(2), 'password123');
    await tester.enterText(find.byType(TextField).at(3), 'password123');

    await tester.tap(find.text('Sign Up'));
    await tester.pump();

    expect(find.text('Slice'), findsOneWidget);
  });
}
