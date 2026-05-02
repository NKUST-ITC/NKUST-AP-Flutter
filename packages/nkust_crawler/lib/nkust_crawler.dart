/// Pure-Dart NKUST scraping toolkit.
///
/// This package contains the crawler logic (helpers, parsers, models,
/// captcha algorithm) extracted from the nkust_ap Flutter app so it can be
/// reused from server-side / CLI / future native clients without dragging
/// in the Flutter SDK.
///
/// The Flutter app composes this package with adapter implementations
/// (see `lib/integrations/crawler/` in nkust_ap) that satisfy the
/// abstractions exported below — [CaptchaTemplateProvider] backed by
/// `rootBundle`, [CrashReporter] backed by Firebase Crashlytics, etc.
library;

export 'src/abstractions/captcha_template_provider.dart';
export 'src/abstractions/crash_reporter.dart';
