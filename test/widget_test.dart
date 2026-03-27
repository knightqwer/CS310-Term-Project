import 'package:flutter_test/flutter_test.dart';

import 'package:quizradar/main.dart';

void main() {
  testWidgets('App renders login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const QuizRadarApp());

    expect(find.text('QuizRadar'), findsOneWidget);
    expect(find.text('Log In'), findsOneWidget);
  });
}
