import 'dart:async';
import 'dart:io';

import 'package:ap_common/api/announcement_helper.dart';
import 'package:ap_common/models/course_data.dart';
import 'package:ap_common/utils/ap_hive_utils.dart';
import 'package:ap_common/utils/preferences.dart';
import 'package:ap_common_firebase/utils/firebase_crashlytics_utils.dart';
import 'package:ap_common_firebase/utils/firebase_performance_utils.dart';
import 'package:ap_common_firebase/utils/firebase_utils.dart';
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
  await Preferences.init(key: Constants.key, iv: Constants.iv);
  await ApHiveUtils.instance.init();
  MobileNkustHelper.userAgentList = Preferences.getStringList(
    Constants.mobileNkustUserAgent,
    MobileNkustHelper.userAgentList,
  );
  final String currentVersion =
      Preferences.getString(Constants.prefCurrentVersion, '0');
  if (int.parse(currentVersion) < 30603) CourseData.migrateFrom0_10();
  if (!kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux)) {
    GoogleSignInDart.register(
      clientId:
          //ignore: lines_longer_than_80_chars
          '141403473068-03ffk4hr8koq260iqvf45rnntnjg4tgc.apps.googleusercontent.com',
    );
  }
  Helper.selector = CrawlerSelector.load();
  AnnouncementHelper.instance.organization = 'nkust';
  if (FirebaseUtils.isSupportCore) await Firebase.initializeApp();
  if (kDebugMode) {
    if (FirebaseCrashlyticsUtils.isSupported) {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
    }
    if (FirebasePerformancesUtils.isSupported) {
      await FirebasePerformance.instance.setPerformanceCollectionEnabled(false);
    }
  }
  if (!kDebugMode && FirebaseCrashlyticsUtils.isSupported) {
    runZonedGuarded(() {
      runApp(const MyApp());
    }, (Object error, StackTrace stackTrace) {
      FirebaseCrashlytics.instance.recordError(error, stackTrace);
    });
  } else {
    runApp(const MyApp());
  }
}
