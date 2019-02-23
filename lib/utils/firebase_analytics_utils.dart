import 'package:firebase_analytics/firebase_analytics.dart';

class FA {
  static FirebaseAnalytics analytics;

  static Future<void> setCurrentScreen(
      String screenName, String screenClassOverride) async {
    await analytics.setCurrentScreen(
      screenName: screenName,
      screenClassOverride: screenClassOverride,
    );
  }

  static Future<void> _testSetUserProperty(String name, String value) async {
    await analytics.setUserProperty(
      name: name,
      value: value,
    );
  }
}
