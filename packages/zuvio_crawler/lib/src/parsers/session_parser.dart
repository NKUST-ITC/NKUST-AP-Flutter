import 'package:zuvio_crawler/src/models/models.dart';

final RegExp _userId = RegExp(r'''var\s+user_id\s*=\s*['"]?(\d+)['"]?''');
final RegExp _accessToken =
    RegExp(r'''var\s+accessToken\s*=\s*['"]([0-9a-zA-Z]+)['"]''');

/// Pulls `var user_id` + `var accessToken` out of any logged-in Zuvio
/// HTML page. Returns null when the page is the login screen (i.e. the
/// session is not valid).
ZuvioSession? parseSession(String html) {
  final RegExpMatch? uid = _userId.firstMatch(html);
  final RegExpMatch? token = _accessToken.firstMatch(html);
  if (uid == null || token == null) return null;
  return ZuvioSession(
    userId: uid.group(1)!,
    accessToken: token.group(1)!,
  );
}
