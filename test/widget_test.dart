import 'package:flutter_test/flutter_test.dart';

import 'package:gatherup/main.dart';

void main() {
  testWidgets('App renders login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const GatherUpApp());
    await tester.pumpAndSettle();

    expect(find.text('GatherUp'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
