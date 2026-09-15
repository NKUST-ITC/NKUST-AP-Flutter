// Runs the real crawler stack on a real iOS/macOS runtime to answer two
// questions a host-side `dart test` cannot: whether the app's trust anchors
// work where the platform store actually applies, and whether Cloudflare
// accepts the TLS fingerprint of the stack the app now uses on Apple
// platforms (`dart:io` / BoringSSL rather than NSURLSession).
//
//     flutter test integration_test/tls_trust_test.dart -d <simulator-id>
//
// NOTE(2026-09-12): a simulator build currently dies in the FlutterFire
// `upload-crashlytics-symbols` phase, which fails when no dSYM exists —
// unrelated to this test, and it breaks any simulator build. Until the
// script phase is guarded, add this to `ios/Flutter/Debug.xcconfig` for the
// run and take it out afterwards (it slows every debug build):
//
//     DEBUG_INFORMATION_FORMAT=dwarf-with-dsym
import 'package:ap_common/ap_common.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nkust_ap/config/constants.dart';
import 'package:nkust_ap/integrations/crawler/crawler_bootstrap.dart';
import 'package:nkust_crawler/nkust_crawler.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Same order as `main()`: the injector has to be populated before
    // anything touches `PreferenceUtil.instance`.
    registerOneForAll();
    await (PreferenceUtil.instance as ApPreferenceUtil)
        .init(key: Constants.key, iv: Constants.iv);
    await bootstrapCrawler();
  });

  testWidgets('every NKUST host validates against the app trust anchors',
      (WidgetTester tester) async {
    const Map<String, String> hosts = <String, String>{
      'webap': 'https://webap.nkust.edu.tw/nkust/index.html',
      'stdsys': 'https://stdsys.nkust.edu.tw/',
      'oosaf': 'https://oosaf.nkust.edu.tw/',
      'vms': 'https://vms.nkust.edu.tw/',
      'acad': 'https://acad.nkust.edu.tw/',
      'www': 'https://www.nkust.edu.tw/',
    };
    final List<String> failures = <String>[];
    for (final MapEntry<String, String> e in hosts.entries) {
      final Dio dio = ApiConfig.createDio();
      try {
        final Response<dynamic> r = await dio.get<dynamic>(e.value);
        debugPrint('[tls] ${e.key}: HTTP ${r.statusCode}');
      } catch (error) {
        debugPrint('[tls] ${e.key}: FAIL $error');
        failures.add('${e.key}: $error');
      }
      dio.close(force: true);
    }
    expect(failures, isEmpty, reason: failures.join('\n'));
  });

  testWidgets('Cloudflare serves the Turnstile page to this TLS stack',
      (WidgetTester tester) async {
    // stdsys sits behind Cloudflare. A bot-scoring rejection of the new
    // fingerprint would show up as a challenge interstitial or a 403 here,
    // not as a TLS error.
    final String? html =
        await StudentIdQueryHelper.instance.fetchQueryPage();

    expect(html, isNotNull);
    debugPrint('[tls] query page: ${html!.length} bytes');

    final String? token =
        StdsysParser.instance.queryStudentIdFormTokenParser(html);
    debugPrint('[tls] antiforgery token: '
        '${token == null ? "<missing>" : "<set>"}');
    debugPrint('[tls] turnstile placeholder: ${html.contains("cf-turnstile")}');
    final bool challenged = html.contains('cf-browser-verification') ||
        html.contains('Just a moment');
    debugPrint('[tls] cloudflare challenge interstitial: $challenged');

    expect(token, isNotNull,
        reason: 'Cloudflare did not serve the real form to this TLS stack');
  });
}
