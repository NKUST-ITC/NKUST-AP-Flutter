import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nkust_crawler/nkust_crawler.dart';

void main() {
  group('splitMalformedSetCookie', () {
    test('splits Max-Age=N,name=val into two parsable segments', () {
      final List<String> parts = splitMalformedSetCookie(
        'first=alpha; Path=/; Max-Age=3600,jsessionid=aaakmpr9y1lhidnpzaqeqa',
      );

      expect(parts, hasLength(2));
      // Each segment must round-trip through Cookie.fromSetCookieValue
      // without the FormatException that the unsafe path hit in prod.
      final Cookie first = Cookie.fromSetCookieValue(parts[0]);
      final Cookie second = Cookie.fromSetCookieValue(parts[1]);
      expect(first.name, 'first');
      expect(first.value, 'alpha');
      expect(second.name, 'jsessionid');
      expect(second.value, 'aaakmpr9y1lhidnpzaqeqa');
    });

    test('does not split commas inside Expires= dates', () {
      final List<String> parts = splitMalformedSetCookie(
        'sid=xyz; Expires=Wed, 09 Jun 2021 10:18:14 GMT; Path=/',
      );

      expect(parts, hasLength(1));
      final Cookie c = Cookie.fromSetCookieValue(parts.single);
      expect(c.name, 'sid');
      expect(c.value, 'xyz');
    });

    test('handles plain RFC-compliant Set-Cookie unchanged', () {
      final List<String> parts = splitMalformedSetCookie('a=1; Path=/');
      expect(parts, <String>['a=1; Path=/']);
    });

    test('splits three comma-joined cookies', () {
      final List<String> parts = splitMalformedSetCookie(
        'a=1; Max-Age=10,b=2; Path=/,c=3',
      );
      expect(parts, hasLength(3));
      expect(Cookie.fromSetCookieValue(parts[0]).name, 'a');
      expect(Cookie.fromSetCookieValue(parts[1]).name, 'b');
      expect(Cookie.fromSetCookieValue(parts[2]).name, 'c');
    });

    test('does not split on a trailing comma with no following name', () {
      // Defensive: a stray comma at the very end shouldn't produce an
      // empty segment that downstream parsing would choke on.
      final List<String> parts = splitMalformedSetCookie('a=1; Path=/,');
      // Only commas followed by `<name>=` count as boundaries; this
      // trailing comma has nothing after it, so we keep the value intact.
      expect(parts, hasLength(1));
    });
  });
}
