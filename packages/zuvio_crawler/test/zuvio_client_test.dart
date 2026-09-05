import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:test/test.dart';
import 'package:zuvio_crawler/src/models/models.dart';
import 'package:zuvio_crawler/src/zuvio_client.dart';
import 'package:zuvio_crawler/src/zuvio_exception.dart';

/// Records every request it sees and answers `irs/submitLogin` /
/// `student5/irs/allCourses` with canned bodies. A configurable delay on
/// the login response lets tests force two `login()` calls to actually
/// overlap instead of resolving one before the other even starts.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter({this.loginDelay = Duration.zero});

  final Duration loginDelay;
  int loginRequests = 0;
  int allCoursesRequests = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final String url = options.uri.toString();
    if (url.contains('irs/submitLogin')) {
      loginRequests++;
      if (loginDelay > Duration.zero) await Future<void>.delayed(loginDelay);
      return ResponseBody.fromString('logged in', 200);
    }
    if (url.contains('student5/irs/allCourses')) {
      allCoursesRequests++;
      return ResponseBody.fromString(
        "var user_id = '9001'; var accessToken = 'tokabc123';",
        200,
      );
    }
    if (url.contains('irs/logout')) {
      return ResponseBody.fromString('', 200);
    }
    return ResponseBody.fromString('not found', 404);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('login', () {
    test('concurrent callers share one in-flight attempt', () async {
      final _FakeAdapter adapter =
          _FakeAdapter(loginDelay: const Duration(milliseconds: 30));
      final ZuvioClient client =
          ZuvioClient(dio: Dio()..httpClientAdapter = adapter);

      final List<ZuvioSession> sessions = await Future.wait(<Future<ZuvioSession>>[
        client.login(email: 'a@nkust.edu.tw', password: 'p'),
        client.login(email: 'a@nkust.edu.tw', password: 'p'),
      ]);

      expect(adapter.loginRequests, 1);
      expect(sessions[0].accessToken, 'tokabc123');
      expect(sessions[1].accessToken, 'tokabc123');
    });

    test('a later login can run once the first has settled', () async {
      final _FakeAdapter adapter = _FakeAdapter();
      final ZuvioClient client =
          ZuvioClient(dio: Dio()..httpClientAdapter = adapter);

      await client.login(email: 'a@nkust.edu.tw', password: 'p');
      await client.login(email: 'a@nkust.edu.tw', password: 'p');

      expect(adapter.loginRequests, 2);
    });

    test('a logout that lands mid-login wins: no resurrected session', () async {
      final _FakeAdapter adapter =
          _FakeAdapter(loginDelay: const Duration(milliseconds: 30));
      final ZuvioClient client =
          ZuvioClient(dio: Dio()..httpClientAdapter = adapter);

      final Future<ZuvioSession> pending =
          client.login(email: 'a@nkust.edu.tw', password: 'p');
      // Let the login's POST start, then log out before it resolves —
      // e.g. switching campus accounts while Zuvio auto-login is still
      // in flight.
      await Future<void>.delayed(const Duration(milliseconds: 5));
      await client.logout();

      await expectLater(pending, throwsA(isA<ZuvioSessionExpiredException>()));
      expect(client.isLogin, isFalse);
    });
  });

  group('downloadBytes', () {
    test('returns the response body bytes', () async {
      final _FakeAdapter adapter = _FakeAdapter();
      final ZuvioClient client =
          ZuvioClient(dio: Dio()..httpClientAdapter = adapter);
      await client.login(email: 'a@nkust.edu.tw', password: 'p');

      final List<int> bytes =
          await client.downloadBytes('${ZuvioClient.baseUrl}not found');
      expect(String.fromCharCodes(bytes), 'not found');
    });
  });
}
