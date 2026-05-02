/// Persistent string-keyed storage abstraction used by data models that
/// cache themselves between launches (e.g. `BusReservationsData`,
/// `CrawlerSelector`, `LeaveData`). The Flutter app supplies a
/// `PreferenceUtil`-backed implementation; tests / CLI plug in an
/// in-memory map.
///
/// Configure once at startup via [configureCrawlerStorage]. Reading
/// `crawlerStorage` before configuration throws — saving / loading is a
/// host-app responsibility, not part of the crawler's core flow.
abstract interface class KeyValueStore {
  String getString(String key, String fallback);
  void setString(String key, String value);
}

KeyValueStore? _crawlerStorage;

/// Returns the configured [KeyValueStore]. Throws [StateError] if
/// [configureCrawlerStorage] has not been called yet — this is a
/// programmer error: the app should wire storage at bootstrap before any
/// model `.save()` / `.load()` runs.
KeyValueStore get crawlerStorage {
  final store = _crawlerStorage;
  if (store == null) {
    throw StateError(
      'crawlerStorage is not configured. '
      'Call configureCrawlerStorage(store) at app startup.',
    );
  }
  return store;
}

/// Wires the [KeyValueStore] used by models that persist themselves.
/// Call once at app startup.
void configureCrawlerStorage(KeyValueStore store) {
  _crawlerStorage = store;
}
