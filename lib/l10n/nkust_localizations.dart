import 'package:ap_common/ap_common.dart'
    show AppLocale, LocaleSettings, TranslationProvider;
import 'package:flutter/widgets.dart';

import 'generated/strings.g.dart';

export 'generated/strings.g.dart' show NkustLocalizations;

final Map<AppLocale, NkustLocalizations> _instances =
    <AppLocale, NkustLocalizations>{};

NkustLocalizations _resolve(AppLocale locale) {
  return _instances.putIfAbsent(locale, () {
    switch (locale) {
      case AppLocale.zhHantTw:
        return NkustLocale.zhHantTw.buildSync();
      case AppLocale.en:
        return NkustLocale.en.buildSync();
      case AppLocale.ja:
        return NkustLocale.ja.buildSync();
    }
  });
}

NkustLocalizations get t => _resolve(LocaleSettings.instance.currentLocale);

extension NkustTranslationsExtension on BuildContext {
  NkustLocalizations get t => _resolve(TranslationProvider.of(this).locale);
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
