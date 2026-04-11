import 'package:ap_common/ap_common.dart'
    show AppLocale, LocaleSettings, TranslationProvider;
import 'package:flutter/widgets.dart';

import 'generated/strings.g.dart';

export 'generated/strings.g.dart' show NkustLocalizations;

final _instances = <AppLocale, NkustLocalizations>{};

NkustLocalizations _resolve(AppLocale locale) {
  return _instances.putIfAbsent(locale, () {
    switch (locale) {
      case AppLocale.zhHantTw:
        return NkustLocale.zhHantTw.buildSync();
      case AppLocale.en:
        return NkustLocale.en.buildSync();
    }
  });
}

/// Top-level getter synced with ap_common's current locale.
NkustLocalizations get t =>
    _resolve(LocaleSettings.instance.currentLocale);

/// BuildContext extension for reactive locale changes.
extension NkustTranslationsExtension on BuildContext {
  NkustLocalizations get t =>
      _resolve(TranslationProvider.of(this).locale);
}

extension NkustLocalizationsListExtension on NkustLocalizations {
  List<String> get busSegment => <String>[fromJiangong, fromYanchao];

  List<String> get campuses => <String>[
        jiangong,
        yanchao,
        first,
        nanzi,
        qijin,
      ];
}
