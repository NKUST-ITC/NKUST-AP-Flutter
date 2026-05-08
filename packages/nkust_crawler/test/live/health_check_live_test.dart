@Tags(<String>['live', 'live-anonymous'])
@TestOn('vm')
library;

import 'package:dio/dio.dart';
import 'package:test/test.dart';

/// Liveness probes for every NKUST endpoint we depend on. No
/// authentication, no parsing — just a plain GET that asserts the server
/// answered below 500. If any of these fail, the school is having an
/// outage; the parser-shaped tests in `authenticated_live_test.dart`
/// will fail differently when only the HTML structure has drifted.
///
/// Test names start with `Health Check` so the crawler-monitor workflow
/// can classify failures (server-down vs parser-drift) by grepping the
/// reporter output.
void main() {
  final Dio healthDio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      followRedirects: true,
      validateStatus: (int? status) => status != null && status < 500,
    ),
  );

  // `leave.nkust.edu.tw` was retired; the leave flow now goes through
  // `oosaf.nkust.edu.tw` via webap SkyDir SSO. `mobile.nkust.edu.tw` is
  // legacy but still resolves (returns 404 / 302 — fine for liveness).
  const Map<String, String> endpoints = <String, String>{
    'WebAP': 'https://webap.nkust.edu.tw/nkust/index.html',
    'Stdsys': 'https://stdsys.nkust.edu.tw/',
    'Oosaf (Leave)': 'https://oosaf.nkust.edu.tw/',
    'Mobile': 'https://mobile.nkust.edu.tw/',
    'Bus (VMS)': 'https://vms.nkust.edu.tw/',
    'Acad (校務公告)': 'https://acad.nkust.edu.tw/',
  };

  for (final MapEntry<String, String> entry in endpoints.entries) {
    test(
      'Health Check ${entry.key} is reachable',
      () async {
        final Response<dynamic> response =
            await healthDio.get<dynamic>(entry.value);
        print('[live] ${entry.key}: HTTP ${response.statusCode}');
        expect(
          response.statusCode,
          isNotNull,
          reason: '${entry.key} (${entry.value}) returned no status',
        );
        expect(
          response.statusCode! < 500,
          isTrue,
          reason: '${entry.key} returned HTTP ${response.statusCode}',
        );
      },
      timeout: const Timeout(Duration(seconds: 30)),
    );
  }
}
