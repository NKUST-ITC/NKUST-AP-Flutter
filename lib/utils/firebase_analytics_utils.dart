import 'dart:async';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:package_info/package_info.dart';

class FA {
  static FirebaseAnalytics analytics;

  static Future<void> setCurrentScreen(
      String screenName, String screenClassOverride) async {
    if (Platform.isIOS || Platform.isAndroid)
      await analytics?.setCurrentScreen(
        screenName: screenName,
        screenClassOverride: screenClassOverride,
      );
  }

  static Future<void> setUserId(String id) async {
    if (Platform.isIOS || Platform.isAndroid) await analytics?.setUserId(id);
    print('setUserId succeeded');
  }

  static Future<void> setUserProperty(String name, String value) async {
    if (Platform.isIOS || Platform.isAndroid)
      await analytics?.setUserProperty(
        name: name,
        value: value,
      );
    print('setUserProperty succeeded');
  }

  static Future<void> logUserInfo(String department) async {
    if (Platform.isIOS || Platform.isAndroid)
      await analytics?.logEvent(
        name: 'user_info',
        parameters: <String, dynamic>{
          'department': department ?? '',
          'platform': Platform.operatingSystem,
        },
      );
  }

  static Future<void> logApiEvent(String type, int status,
      {String message = ''}) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    if (Platform.isIOS || Platform.isAndroid)
      await analytics?.logEvent(
        name: 'ap_api',
        parameters: <String, dynamic>{
          'type': type,
          'status': status,
          'message': message,
          'version': packageInfo.version,
          'platform': Platform.operatingSystem,
        },
      );
    print('logEvent succeeded');
  }

  static Future<void> logAESErrorEvent(String encryptPassword) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    if (Platform.isIOS || Platform.isAndroid)
      await analytics?.logEvent(
        name: 'aes_error',
        parameters: <String, dynamic>{
          'encryptPassword': encryptPassword,
          'version': packageInfo.version,
          'platform': Platform.operatingSystem,
        },
      );
    print('log encryptPassword succeeded');
  }

  static Future<void> logCalculateUnits(double seconds) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    if (Platform.isIOS || Platform.isAndroid)
      await analytics?.logEvent(
        name: 'calculate_units_time',
        parameters: <String, dynamic>{
          'time': seconds,
          'version': packageInfo.version,
          'platform': Platform.operatingSystem,
        },
      );
    print('log CalculateUnits succeeded');
  }

  static Future<void> logAction(String name, String action,
      {String message = ''}) async {
    if (Platform.isIOS || Platform.isAndroid) {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      await analytics?.logEvent(
        name: name ?? '',
        parameters: <String, dynamic>{
          'action': action ?? '',
          'message': message ?? '',
          'version': packageInfo.version,
          'platform': Platform.operatingSystem,
        },
      );
    }
  }
}
