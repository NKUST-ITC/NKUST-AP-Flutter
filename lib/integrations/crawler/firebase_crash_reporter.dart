import 'package:ap_common/ap_common.dart';
import 'package:ap_common_firebase/ap_common_firebase.dart';
import 'package:nkust_ap/api/crash_reporter.dart';

/// [CrashReporter] adapter that forwards to Firebase Crashlytics via
/// [CrashlyticsUtil]. Wired at app bootstrap so the pure-Dart parser /
/// helper layer can stay unaware of Firebase.
class FirebaseCrashReporter implements CrashReporter {
  const FirebaseCrashReporter();

  @override
  void recordError(
    Object error,
    StackTrace stack, {
    String? reason,
  }) {
    if (!FirebaseCrashlyticsUtils.isSupported) return;
    CrashlyticsUtil.instance.recordError(error, stack, reason: reason);
  }
}
