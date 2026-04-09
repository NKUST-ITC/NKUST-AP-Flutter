import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/l10n/intl/messages_all.dart';
import 'package:nkust_ap/l10n/l10n.dart';

export 'package:nkust_ap/l10n/l10n.dart';

const _AppLocalizationsDelegate appDelegate = _AppLocalizationsDelegate();

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return true;
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    await initializeMessages(locale.toString());
    return AppLocalizations.load(locale);
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) {
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
