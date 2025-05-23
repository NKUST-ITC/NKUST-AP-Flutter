import 'dart:async';
import 'dart:io';

import 'package:ap_common/ap_common.dart';
import 'package:ap_common_firebase/ap_common_firebase.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in_dartio/google_sign_in_dartio.dart';
import 'package:nkust_ap/api/helper.dart';
import 'package:nkust_ap/api/mobile_nkust_helper.dart';
import 'package:nkust_ap/app.dart';
import 'package:nkust_ap/config/constants.dart';
import 'package:nkust_ap/models/crawler_selector.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
//  HttpClient.enableTimelineLogging = isInDebugMode;
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  final ByteData data = await PlatformAssetBundle().load(
    'assets/ca/twca_nkust.cer',
  );
  SecurityContext.defaultContext.setTrustedCertificatesBytes(
    data.buffer.asUint8List(),
  );

  /// Register all ap_common injection util
  registerOneForAll();

  await (PreferenceUtil.instance as ApPreferenceUtil).init(
    key: Constants.key,
    iv: Constants.iv,
  );
  MobileNkustHelper.userAgentList = PreferenceUtil.instance.getStringList(
    Constants.mobileNkustUserAgent,
    MobileNkustHelper.userAgentList,
  );
  final String currentVersion =
      PreferenceUtil.instance.getString(Constants.prefCurrentVersion, '0');
  if (int.parse(currentVersion) < 30603) CourseData.migrateFrom0_10();
  if (!kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux)) {
    GoogleSignInDart.register(
      clientId:
          //ignore: lines_longer_than_80_chars
          '141403473068-03ffk4hr8koq260iqvf45rnntnjg4tgc.apps.googleusercontent.com',
    );
  }
  Helper.selector = CrawlerSelector.load();
  if (!kIsWeb && Platform.isAndroid) {
    HttpOverrides.global = MyHttpOverrides();
  }

  AnnouncementHelper.instance.organization = 'nkust';
  if (FirebaseUtils.isSupportCore) {
    await Firebase.initializeApp();
  }
  if (FirebaseCrashlyticsUtils.isSupported) {
    await FirebaseCrashlytics.instance
        .setCrashlyticsCollectionEnabled(kReleaseMode);
  }
  if (FirebasePerformancesUtils.isSupported) {
    await FirebasePerformance.instance
        .setPerformanceCollectionEnabled(kReleaseMode);
  }
  if (!kDebugMode && FirebaseCrashlyticsUtils.isSupported) {
    FlutterError.onError = (FlutterErrorDetails errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      FirebaseCrashlytics.instance.recordError(error, stack);
      return true;
    };
  }
  runApp(const MyApp());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
