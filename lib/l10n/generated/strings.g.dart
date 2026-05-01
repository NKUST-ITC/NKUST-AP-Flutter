/// Generated file. Do not edit.
///
/// Source: lib/l10n
/// To regenerate, run: `dart run slang`
///
/// Locales: 3
/// Strings: 621 (207 per locale)
///
/// Built on 2026-05-01 at 05:59 UTC

// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:slang/generated.dart';
import 'package:slang_flutter/slang_flutter.dart';
export 'package:slang_flutter/slang_flutter.dart';

import 'strings_en.g.dart' as l_en;
import 'strings_ja.g.dart' as l_ja;
part 'strings_zh_Hant_TW.g.dart';

/// Supported locales.
///
/// Usage:
/// - LocaleSettings.setLocale(NkustLocale.zhHantTw) // set locale
/// - Locale locale = NkustLocale.zhHantTw.flutterLocale // get flutter locale from enum
/// - if (LocaleSettings.currentLocale == NkustLocale.zhHantTw) // locale check
enum NkustLocale with BaseAppLocale<NkustLocale, NkustLocalizations> {
	zhHantTw(languageCode: 'zh', scriptCode: 'Hant', countryCode: 'TW'),
	en(languageCode: 'en'),
	ja(languageCode: 'ja');

	const NkustLocale({
		required this.languageCode,
		this.scriptCode, // ignore: unused_element, unused_element_parameter
		this.countryCode, // ignore: unused_element, unused_element_parameter
	});

	@override final String languageCode;
	@override final String? scriptCode;
	@override final String? countryCode;

	@override
	Future<NkustLocalizations> build({
		Map<String, Node>? overrides,
		PluralResolver? cardinalResolver,
		PluralResolver? ordinalResolver,
	}) async {
		return buildSync(
			overrides: overrides,
			cardinalResolver: cardinalResolver,
			ordinalResolver: ordinalResolver,
		);
	}

	@override
	NkustLocalizations buildSync({
		Map<String, Node>? overrides,
		PluralResolver? cardinalResolver,
		PluralResolver? ordinalResolver,
	}) {
		switch (this) {
			case NkustLocale.zhHantTw:
				return NkustLocalizationsZhHantTw(
					overrides: overrides,
					cardinalResolver: cardinalResolver,
					ordinalResolver: ordinalResolver,
				);
			case NkustLocale.en:
				return l_en.NkustLocalizationsEn(
					overrides: overrides,
					cardinalResolver: cardinalResolver,
					ordinalResolver: ordinalResolver,
				);
			case NkustLocale.ja:
				return l_ja.NkustLocalizationsJa(
					overrides: overrides,
					cardinalResolver: cardinalResolver,
					ordinalResolver: ordinalResolver,
				);
		}
	}
}

/// Provides utility functions without any side effects.
class AppLocaleUtils extends BaseAppLocaleUtils<NkustLocale, NkustLocalizations> {
	AppLocaleUtils._() : super(
		baseLocale: NkustLocale.zhHantTw,
		locales: NkustLocale.values,
	);

	static final instance = AppLocaleUtils._();

	// static aliases (checkout base methods for documentation)
	static NkustLocale parse(String rawLocale) => instance.parse(rawLocale);
	static NkustLocale parseLocaleParts({required String languageCode, String? scriptCode, String? countryCode}) => instance.parseLocaleParts(languageCode: languageCode, scriptCode: scriptCode, countryCode: countryCode);
	static NkustLocale findDeviceLocale() => instance.findDeviceLocale();
	static List<Locale> get supportedLocales => instance.supportedLocales;
	static List<String> get supportedLocalesRaw => instance.supportedLocalesRaw;
}
