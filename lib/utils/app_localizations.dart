import 'package:ap_common/ap_common.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:multiple_localization/multiple_localization.dart';
import 'package:nkust_ap/l10n/intl/messages_all_locales.dart'
    show initializeMessages;
import 'package:nkust_ap/l10n/l10n.dart';

export 'package:nkust_ap/l10n/l10n.dart';

const _AppLocalizationsDelegate appDelegate = _AppLocalizationsDelegate();
const ApLocalizationsDelegateWrapper apLocalizationsDelegateWrapper =
    ApLocalizationsDelegateWrapper();

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return true;
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return MultipleLocalizations.load(
      initializeMessages,
      locale,
      (String l) => AppLocalizations.load(locale),
      setDefaultLocale: true,
    );
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}

class ApLocalizationsDelegateWrapper
    extends LocalizationsDelegate<ApLocalizations> {
  const ApLocalizationsDelegateWrapper();

  @override
  bool isSupported(Locale locale) {
    return true;
  }

  @override
  Future<ApLocalizations> load(Locale locale) {
    final Locale fallbackLocale = ApLocalizations.delegate.isSupported(locale)
        ? locale
        : const Locale('en');
    return ApLocalizations.delegate.load(fallbackLocale);
  }

  @override
  bool shouldReload(LocalizationsDelegate<ApLocalizations> old) {
    return false;
  }
}

extension AppLocalizationsExtension on AppLocalizations {
  List<String> get busSegment => <String>[
        fromJiangong,
        fromYanchao,
      ];

  List<String> get campuses => <String>[
        jiangong,
        yanchao,
        first,
        nanzi,
        qijin,
      ];
}
