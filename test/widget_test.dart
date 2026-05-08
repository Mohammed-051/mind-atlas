import 'package:flutter_test/flutter_test.dart';
import 'package:mindmentor/main.dart';

void main() {
  testWidgets('MindMentor app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MindMentorApp());
    // Verify the app renders without crashing
    expect(find.byType(MindMentorApp), findsOneWidget);
  });
}
