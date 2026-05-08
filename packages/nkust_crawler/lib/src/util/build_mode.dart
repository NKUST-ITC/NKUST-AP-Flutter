/// Build-mode constants compatible with Flutter's `package:flutter/foundation.dart`,
/// reimplemented in pure Dart so the crawler can stay platform-agnostic.
///
/// Values are derived from the same `dart.vm.product` / `dart.vm.profile`
/// environment markers Flutter uses, so debug / release decisions match
/// what the host app sees.
library;

const bool kReleaseMode = bool.fromEnvironment('dart.vm.product');
const bool kProfileMode = bool.fromEnvironment('dart.vm.profile');
const bool kDebugMode = !kReleaseMode && !kProfileMode;
