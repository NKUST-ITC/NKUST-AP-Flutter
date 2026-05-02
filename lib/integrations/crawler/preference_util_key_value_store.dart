import 'package:ap_common/ap_common.dart';
import 'package:nkust_crawler/nkust_crawler.dart';

/// [KeyValueStore] adapter routing through the app's [PreferenceUtil]
/// (encrypted SharedPreferences). Wired into [configureCrawlerStorage]
/// at app bootstrap so models can use their `.save()` / `.load()` helpers
/// without knowing about Flutter's preference plumbing.
class PreferenceUtilKeyValueStore implements KeyValueStore {
  const PreferenceUtilKeyValueStore();

  @override
  String getString(String key, String fallback) =>
      PreferenceUtil.instance.getString(key, fallback);

  @override
  void setString(String key, String value) =>
      PreferenceUtil.instance.setString(key, value);
}
