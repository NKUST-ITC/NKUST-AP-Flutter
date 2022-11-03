import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nkust_ap/api/parser/ap_parser.dart';

//ignore_for_file: lines_longer_than_80_chars

void main() {
  testWidgets('Login Error Response Parser', (WidgetTester t) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final String rawHtml =
        File('assets_test/login/server_busy.html').readAsStringSync();
    final int result = WebApParser.instance.apLoginParser(rawHtml);
    expect(result, 500);
  });
  testWidgets('Login Password Error Response Parser', (WidgetTester t) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final String rawHtml =
        File('assets_test/login/password_error.html').readAsStringSync();
    final int result = WebApParser.instance.apLoginParser(rawHtml);
    expect(result, 1);
  });
}
