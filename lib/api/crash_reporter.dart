/// Abstraction over crash-reporting backends so the crawler / parser layer
/// can stay platform-agnostic.
///
/// Default is [NoOpCrashReporter]; the main app's bootstrap swaps in a
/// Firebase-backed implementation that respects
/// `FirebaseCrashlyticsUtils.isSupported`. Tests and pure-Dart contexts
/// (server-side, CLI) can leave the no-op default in place.
abstract interface class CrashReporter {
  void recordError(
    Object error,
    StackTrace stack, {
    String? reason,
  });
}

class NoOpCrashReporter implements CrashReporter {
  const NoOpCrashReporter();

  @override
  void recordError(
    Object error,
    StackTrace stack, {
    String? reason,
  }) {}
}
