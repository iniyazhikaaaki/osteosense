// test/widget_test.dart
// Basic Flutter widget test verifying app launch.

import 'package:flutter_test/flutter_test.dart';
import 'package:osteosense/main.dart';

void main() {
  testWidgets('OsteoSense App Launch Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const OsteoSenseApp(initialLang: 'en'));

    // Verify that OsteoSense app title is rendered.
    expect(find.text('OsteoSense'), findsOneWidget);
  });
}
