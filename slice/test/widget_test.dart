import 'package:flutter_test/flutter_test.dart';
import 'package:slice/main.dart';

void main() {
  testWidgets('App navigates from LoginPage to SignUpPage and back', (WidgetTester tester) async {
    await tester.pumpWidget(const SliceApp());

    expect(find.text('Login'), findsOneWidget);

    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();
    expect(find.text('Create an account'), findsOneWidget);

    await tester.tap(find.byTooltip('Back to Login'));
    await tester.pumpAndSettle();

    await tester.pumpAndSettle();

    expect(find.text('Login'), findsOneWidget);
  });
}
