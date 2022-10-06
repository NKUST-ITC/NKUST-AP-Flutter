import 'package:flutter_test/flutter_test.dart';
import 'package:nkust_ap/app.dart';

void main() {
  testWidgets('smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
  });
}
