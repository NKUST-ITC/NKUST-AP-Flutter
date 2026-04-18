/// Enum representing available scraper data sources.
///
/// Used by [CrawlerSelector] for type-safe runtime switching and by
/// [ScraperRegistry] for capability resolution.
///
/// Values match the JSON strings from Firebase Remote Config for backward
/// compatibility (e.g., `"webap"`, `"stdsys"`, `"config"`). Legacy value
/// `"mobile"` is accepted on parse (maps to [webap]) so that installed
/// apps with a stored `"mobile"` config keep working after #301 removed
/// the mobile.nkust.edu.tw crawler.
enum ScraperSource {
  webap,
  stdsys,
  remoteConfig;

  /// Parses a string value (e.g., from Remote Config JSON) into a
  /// [ScraperSource]. Falls back to [webap] for unknown values.
  static ScraperSource fromString(String value) {
    // Handle the legacy "config" value used in Remote Config JSON.
    if (value == 'config') return ScraperSource.remoteConfig;
    return ScraperSource.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ScraperSource.webap,
    );
  }

  /// Converts back to the JSON-compatible string representation.
  String toJsonString() {
    if (this == ScraperSource.remoteConfig) return 'config';
    return name;
  }
}

/// Registry that maps capability interfaces to their provider implementations,
/// keyed by [ScraperSource].
///
/// This replaces the manual `switch` statements in `Helper` that routed
/// requests based on `CrawlerSelector` string fields.
///
/// Usage:
/// ```dart
/// registry.register<CourseProvider>(ScraperSource.webap, WebApHelper.instance);
/// registry.register<CourseProvider>(ScraperSource.stdsys, StdsysHelper.instance);
///
/// final provider = registry.resolve<CourseProvider>(ScraperSource.stdsys);
/// ```
class ScraperRegistry {
  final Map<Type, Map<ScraperSource, Object>> _providers = {};

  /// Registers a [provider] for capability type [T] under [source].
  void register<T>(ScraperSource source, T provider) {
    _providers.putIfAbsent(T, () => {})[source] = provider as Object;
  }

  /// Resolves a provider for capability type [T].
  ///
  /// If [preferred] is provided and a matching provider exists, returns it.
  /// If [fallbacks] is provided, tries each source in order.
  /// Otherwise, returns the first registered provider as fallback.
  ///
  /// Throws [StateError] if no provider is registered for [T].
  T resolve<T>(ScraperSource? preferred, {List<ScraperSource>? fallbacks}) {
    final map = _providers[T];
    if (map == null || map.isEmpty) {
      throw StateError('No provider registered for $T');
    }

    // Try preferred source.
    if (preferred != null && map.containsKey(preferred)) {
      return map[preferred]! as T;
    }

    // Try fallback sources in order.
    if (fallbacks != null) {
      for (final source in fallbacks) {
        if (map.containsKey(source)) {
          return map[source]! as T;
        }
      }
    }

    // Last resort: first registered provider.
    return map.values.first as T;
  }

  /// Returns the list of [ScraperSource]s that have a registered provider
  /// for capability type [T].
  ///
  /// Useful for settings UI to show which sources are available for each
  /// data type.
  List<ScraperSource> availableSources<T>() {
    return _providers[T]?.keys.toList() ?? [];
  }
}
