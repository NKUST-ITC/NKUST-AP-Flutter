import 'dart:io' show HttpClient, Platform;

import 'package:ap_common/ap_common.dart';
import 'package:ap_common_plugin/ap_common_plugin.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:native_dio_adapter/native_dio_adapter.dart';
import 'package:nkust_crawler/nkust_crawler.dart';
import 'package:nkust_ap/config/constants.dart';
import 'package:nkust_ap/integrations/crawler/asset_captcha_template_provider.dart';
import 'package:nkust_ap/integrations/crawler/firebase_crash_reporter.dart';
import 'package:nkust_ap/integrations/crawler/preference_util_key_value_store.dart';
import 'package:nkust_ap/integrations/crawler/syncfusion_pdf_text_extractor.dart';
import 'package:nkust_ap/integrations/security/ca_trust_bundle.dart';

/// Wires every host-side dependency the [nkust_crawler] package needs into
/// the shared [Helper] singleton. Call exactly once from `main()` after
/// [PreferenceUtil] has been initialised — the order matters for
/// [Helper.bootstrap] (apiHost lookup) and for the storage-backed models.
Future<void> bootstrapCrawler() async {
  await _configurePlatformAdapter();

  configureCrawlerStorage(const PreferenceUtilKeyValueStore());

  Helper.bootstrap(
    apiHost: PreferenceUtil.instance.getString(
      Constants.apiHost,
      Helper.host,
    ),
  );

  const FirebaseCrashReporter firebaseReporter = FirebaseCrashReporter();
  Helper.instance.reporter = firebaseReporter;
  WebApHelper.instance.reporter = firebaseReporter;
  WebApParser.instance.reporter = firebaseReporter;
  StdsysParser.instance.reporter = firebaseReporter;

  final EuclideanCaptchaSolver captchaSolver =
      EuclideanCaptchaSolver(const AssetCaptchaTemplateProvider());
  WebApHelper.instance.captchaSolver = captchaSolver;

  StdsysHelper.instance.pdfTextExtractor = const SyncfusionPdfTextExtractor();

  Helper.instance.onLogout = () {
    ApCommonPlugin.clearCourseWidget();
    ApCommonPlugin.clearUserInfoWidget();
  };
}

/// Picks the HTTP stack every crawler [Dio] runs on, and — on Apple
/// platforms — the root CAs it validates against.
///
/// Android keeps Cronet, which validates against the Chrome Root Store and
/// already trusts every TWCA root the school has used. Apple platforms drop
/// to `dart:io`: NSURLSession rejects the current NKUST chain (see
/// [CaTrustBundle]) and `cupertino_http` exposes no `didReceiveChallenge`
/// hook, so `dart:io` is the only stack where the missing anchor can be
/// supplied from Dart. Validation stays on either way.
Future<void> _configurePlatformAdapter() async {
  if (kIsWeb) return;

  if (Platform.isAndroid) {
    ApiConfig.platformAdapterFactory = NativeAdapter.new;
    return;
  }

  if (!Platform.isIOS && !Platform.isMacOS) return;

  final CaTrustBundle bundle = await CaTrustBundle.load();
  ApiConfig.platformAdapterFactory = () => IOHttpClientAdapter(
        createHttpClient: () => HttpClient(context: bundle.securityContext),
      );
}
