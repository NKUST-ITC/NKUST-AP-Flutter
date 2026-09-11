@Tags(<String>['live', 'live-anonymous'])
@TestOn('vm')
library;

import 'dart:io';

import 'package:dio/io.dart';
import 'package:nkust_crawler/nkust_crawler.dart';
import 'package:test/test.dart';

import '_helpers.dart';

/// Covers the read-only half of the student-id lookup: fetching the query
/// page and finding its antiforgery token. No credentials, no submission —
/// the Turnstile token can only be minted by a browser engine, so the POST
/// itself is not reachable from `dart test`.
///
/// This is also the regression test for the TLS anchor work: the page is
/// fetched through [ApiConfig]'s adapter with verification on, exactly as
/// the host app does on Apple platforms, so a certificate chain the app
/// cannot validate fails here rather than in the field.
void main() {
  setUpAll(() {
    print('[live] trusting TWCA roots from assets/ca/twca_roots.pem');
    trustNkustRoots();

    // Mirror the host app's Apple-platform wiring: dart:io with the bundle's
    // anchors, rather than Dio's default adapter.
    print('[live] platform adapter = IOHttpClientAdapter + bundled anchors');
    final SecurityContext context = SecurityContext(withTrustedRoots: true);
    try {
      context.setTrustedCertificatesBytes(findCaBundle().readAsBytesSync());
    } on TlsException {
      // Already in the platform store — nothing to add.
    }
    ApiConfig.platformAdapterFactory = () => IOHttpClientAdapter(
          createHttpClient: () => HttpClient(context: context),
        );
  });

  tearDownAll(() => ApiConfig.platformAdapterFactory = null);

  test(
    'fetchQueryPage returns the form with its antiforgery token',
    () async {
      print('[live] GET ${StudentIdQueryHelper.queryUrl}');
      final String? html = await StudentIdQueryHelper.instance.fetchQueryPage();

      expect(html, isNotNull);
      print('[live]   ← ${html!.length} bytes');

      final String? token =
          StdsysParser.instance.queryStudentIdFormTokenParser(html);
      print('[live]   antiforgery token: ${token == null ? "<missing>" : "<set>"}');
      print('[live]   turnstile placeholder: ${html.contains("cf-turnstile")}');

      expect(
        token,
        isNotNull,
        reason: 'the query page no longer carries __RequestVerificationToken',
      );
    },
    timeout: const Timeout(Duration(seconds: 30)),
  );
}
