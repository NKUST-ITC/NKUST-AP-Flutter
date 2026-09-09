import 'package:test/test.dart';
import 'package:zuvio_crawler/src/models/models.dart';
import 'package:zuvio_crawler/src/parsers/session_parser.dart';

import 'support.dart';

void main() {
  test('reads user_id and accessToken from a logged-in page', () {
    final ZuvioSession? session = parseSession(fixture('session_page.html'));
    expect(session, isNotNull);
    expect(session!.userId, '999001');
    expect(session.accessToken, '0000000000000000000000000000000000000000');
  });

  test('returns null for the login screen', () {
    expect(parseSession(fixture('login_page.html')), isNull);
  });
}
