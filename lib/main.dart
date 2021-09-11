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
import 'package:google_sign_in_dartio/google_sign_in_dartio.dart';
import 'package:nkust_ap/app.dart';
import 'package:nkust_ap/config/constants.dart';

import 'api/helper.dart';
import 'api/mobile_nkust_helper.dart';
import 'models/crawler_selector.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
//  HttpClient.enableTimelineLogging = isInDebugMode;
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await Preferences.init(key: Constants.key, iv: Constants.iv);
  await ApHiveUtils.instance.init();
  MobileNkustHelper.userAgentList = Preferences.getStringList(
    Constants.MOBILE_NKUST_USER_AGENT,
    MobileNkustHelper.userAgentList,
  );
  var currentVersion =
      Preferences.getString(Constants.PREF_CURRENT_VERSION, '0');
  if (int.parse(currentVersion) < 30603) CourseData.migrateFrom0_10();
  if (!kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux))
    GoogleSignInDart.register(
        clientId:
            '141403473068-03ffk4hr8koq260iqvf45rnntnjg4tgc.apps.googleusercontent.com');
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
      runApp(MyApp());
    }, (error, stackTrace) {
      FirebaseCrashlytics.instance.recordError(error, stackTrace);
    });
  } else {
    runApp(MyApp());
  }
}
