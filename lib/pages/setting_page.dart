import 'package:ap_common/ap_common.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/config/app_theme.dart';
import 'package:nkust_ap/models/bus_reservations_data.dart';
import 'package:nkust_ap/utils/global.dart';
import 'package:nkust_ap/widgets/setting_widgets.dart';
import 'package:nkust_ap/widgets/share_data_widget.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingPage extends StatefulWidget {
  static const String routerName = '/setting';

  @override
  SettingPageState createState() => SettingPageState();
}

class SettingPageState extends State<SettingPage> {
  late ApLocalizations ap;
  late AppLocalizations app;

  String? appVersion;
  bool busNotify = false;
  bool courseNotify = false;
  bool displayPicture = true;
  bool isOffline = false;

  ThemeMode _themeMode = ThemeMode.system;
  String _languageCode = ApSupportLanguageConstants.system;
  String _iconStyle = ApIcon.filled;
  int _themeColorIndex = 0;

  @override
  void initState() {
    AnalyticsUtil.instance.setCurrentScreen('SettingPage', 'setting_page.dart');
    _getPreference();
    if (DateTime.now().millisecondsSinceEpoch % 5 == 0) {
      ApUtils.showAppReviewDialog(context, Constants.playStoreUrl);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ap = ApLocalizations.of(context);
    app = AppLocalizations.of(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(ap.settings),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SettingSectionTitle(
              title: ap.notificationItem,
              icon: Icons.notifications_outlined,
            ),
            SettingCard(
              children: <Widget>[
                SettingSwitchTile(
                  icon: Icons.school_outlined,
                  title: ap.courseNotify,
                  subtitle: ap.courseNotifySubTitle,
                  value: courseNotify,
                  onChanged: _onCourseNotifyChanged,
                ),
                SettingTile(
                  icon: Icons.notifications_off_outlined,
                  title: ap.cancelAllNotify,
                  subtitle: ap.cancelAllNotifySubTitle,
                  onTap: _cancelAllNotifications,
                ),
                SettingSwitchTile(
                  icon: Icons.directions_bus_outlined,
                  title: app.busNotify,
                  subtitle: app.busNotifySubTitle,
                  value: busNotify,
                  onChanged: _onBusNotifyChanged,
                ),
              ],
            ),
            SettingSectionTitle(
              title: ap.otherSettings,
              icon: Icons.tune_outlined,
            ),
            SettingCard(
              children: <Widget>[
                SettingSwitchTile(
                  icon: Icons.person_outline,
                  title: ap.headPhotoSetting,
                  subtitle: ap.headPhotoSettingSubTitle,
                  value: displayPicture,
                  onChanged: _onDisplayPictureChanged,
                ),
                SettingTile(
                  icon: Icons.language_outlined,
                  title: ap.language,
                  subtitle: _getLanguageName(),
                  onTap: _showLanguageDialog,
                ),
                SettingTile(
                  icon: Icons.dark_mode_outlined,
                  title: ap.theme,
                  subtitle: _getThemeModeName(),
                  onTap: _showThemeModeDialog,
                ),
                SettingTile(
                  icon: Icons.palette_outlined,
                  title: '主題色',
                  subtitle: AppTheme.currentColorName,
                  trailing: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppTheme.seedColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colorScheme.outline,
                        width: 1,
                      ),
                    ),
                  ),
                  onTap: _showThemeColorDialog,
                ),
                SettingTile(
                  icon: Icons.style_outlined,
                  title: ap.iconStyle,
                  subtitle: _getIconStyleName(),
                  onTap: _showIconStyleDialog,
                ),
              ],
            ),
            SettingSectionTitle(
              title: ap.otherInfo,
              icon: Icons.info_outline,
            ),
            SettingCard(
              children: <Widget>[
                SettingTile(
                  icon: Icons.feedback_outlined,
                  title: ap.feedback,
                  subtitle: ap.feedbackViaFacebook,
                  isExternalLink: true,
                  onTap: () {
                    ApUtils.launchFbFansPage(context, Constants.fansPageId);
                    AnalyticsUtil.instance.logEvent('feedback_click');
                  },
                ),
                SettingInfoTile(
                  icon: Icons.info_outline,
                  title: ap.appVersion,
                  value: 'v${appVersion ?? ''}',
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String _getLanguageName() {
    switch (_languageCode) {
      case ApSupportLanguageConstants.en:
        return 'English';
      case ApSupportLanguageConstants.zh:
        return '繁體中文';
      default:
        return ap.systemLanguage;
    }
  }

  String _getThemeModeName() {
    switch (_themeMode) {
      case ThemeMode.light:
        return ap.light;
      case ThemeMode.dark:
        return ap.dark;
      default:
        return '跟隨系統';
    }
  }

  String _getIconStyleName() {
    switch (_iconStyle) {
      case ApIcon.outlined:
        return ap.outlined;
      default:
        return ap.filled;
    }
  }

  Future<void> _showLanguageDialog() async {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final String? result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(ap.language),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _buildDialogOption(
              title: ap.systemLanguage,
              value: ApSupportLanguageConstants.system,
              groupValue: _languageCode,
              colorScheme: colorScheme,
              onChanged: (String? v) => Navigator.pop(context, v),
            ),
            _buildDialogOption(
              title: '繁體中文',
              value: ApSupportLanguageConstants.zh,
              groupValue: _languageCode,
              colorScheme: colorScheme,
              onChanged: (String? v) => Navigator.pop(context, v),
            ),
            _buildDialogOption(
              title: 'English',
              value: ApSupportLanguageConstants.en,
              groupValue: _languageCode,
              colorScheme: colorScheme,
              onChanged: (String? v) => Navigator.pop(context, v),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      setState(() => _languageCode = result);
      PreferenceUtil.instance.setString(Constants.prefLanguageCode, result);
      final Locale locale = Locale(
        result == ApSupportLanguageConstants.system ? 'zh' : result,
        result == ApSupportLanguageConstants.zh ? 'TW' : null,
      );
      ShareDataWidget.of(context)!.data.loadLocale(locale);
      AnalyticsUtil.instance.logEvent('language_change');
    }
  }

  Future<void> _showThemeModeDialog() async {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final ThemeMode? result = await showDialog<ThemeMode>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(ap.theme),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _buildDialogOption<ThemeMode>(
              title: '跟隨系統',
              value: ThemeMode.system,
              groupValue: _themeMode,
              colorScheme: colorScheme,
              onChanged: (ThemeMode? v) => Navigator.pop(context, v),
            ),
            _buildDialogOption<ThemeMode>(
              title: ap.light,
              value: ThemeMode.light,
              groupValue: _themeMode,
              colorScheme: colorScheme,
              onChanged: (ThemeMode? v) => Navigator.pop(context, v),
            ),
            _buildDialogOption<ThemeMode>(
              title: ap.dark,
              value: ThemeMode.dark,
              groupValue: _themeMode,
              colorScheme: colorScheme,
              onChanged: (ThemeMode? v) => Navigator.pop(context, v),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      setState(() => _themeMode = result);
      PreferenceUtil.instance.setInt(
        Constants.prefThemeModeIndex,
        result.index,
      );
      ShareDataWidget.of(context)!.data.loadTheme(result);
      AnalyticsUtil.instance.logEvent('theme_change');
    }
  }

  Future<void> _showThemeColorDialog() async {
    final Color? result = await showDialog<Color>(
      context: context,
      builder: (BuildContext context) => ColorPickerDialog(
        initialColor: AppTheme.seedColor,
      ),
    );

    if (result != null) {
      final int matchedIndex = AppTheme.themeColors.indexWhere(
        (ThemeColor tc) => tc.color.value == result.value,
      );

      setState(() {
        if (matchedIndex >= 0) {
          _themeColorIndex = matchedIndex;
          AppTheme.currentColorIndex = matchedIndex;
          AppTheme.customColor = null;
        } else {
          _themeColorIndex = AppTheme.customColorIndex;
          AppTheme.currentColorIndex = AppTheme.customColorIndex;
          AppTheme.customColor = result;
        }
      });

      PreferenceUtil.instance.setInt(
        Constants.prefThemeColorIndex,
        AppTheme.currentColorIndex,
      );
      if (AppTheme.customColor != null) {
        PreferenceUtil.instance.setInt(
          Constants.prefCustomThemeColor,
          AppTheme.customColor!.value,
        );
      }

      ShareDataWidget.of(context)!.data.update();
      AnalyticsUtil.instance.logEvent('theme_color_change');
    }
  }

  Future<void> _showIconStyleDialog() async {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final String? result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(ap.iconStyle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _buildDialogOption(
              title: ap.filled,
              value: ApIcon.filled,
              groupValue: _iconStyle,
              colorScheme: colorScheme,
              onChanged: (String? v) => Navigator.pop(context, v),
            ),
            _buildDialogOption(
              title: ap.outlined,
              value: ApIcon.outlined,
              groupValue: _iconStyle,
              colorScheme: colorScheme,
              onChanged: (String? v) => Navigator.pop(context, v),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      setState(() => _iconStyle = result);
      ApIcon.code = result;
      PreferenceUtil.instance.setString(Constants.prefIconStyleCode, result);
      ShareDataWidget.of(context)!.data.update();
      AnalyticsUtil.instance.logEvent('icon_style_change');
    }
  }

  Widget _buildDialogOption<T>({
    required String title,
    required T value,
    required T groupValue,
    required ColorScheme colorScheme,
    required ValueChanged<T?> onChanged,
  }) {
    final bool isSelected = value == groupValue;

    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: <Widget>[
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onCourseNotifyChanged(bool value) {
    setState(() => courseNotify = value);
    PreferenceUtil.instance.setBool(Constants.prefCourseNotify, courseNotify);
    AnalyticsUtil.instance.logEvent('course_notify_click');
  }

  void _onDisplayPictureChanged(bool value) {
    setState(() => displayPicture = value);
    PreferenceUtil.instance.setBool(
      Constants.prefDisplayPicture,
      displayPicture,
    );
    AnalyticsUtil.instance.logEvent('head_photo_click');
  }

  void _onBusNotifyChanged(bool value) async {
    AnalyticsUtil.instance.logEvent('notify_bus_create');
    setState(() => busNotify = value);
    if (busNotify) {
      await _setupBusNotify(context);
    } else {
      await Utils.cancelBusNotify();
    }
    PreferenceUtil.instance.setBool(Constants.prefBusNotify, busNotify);
    AnalyticsUtil.instance.logEvent('notify_bus_click');
  }

  void _cancelAllNotifications() async {
    await NotificationUtil.instance.cancelAll();
    if (!mounted) return;
    UiUtil.instance.showToast(context, ap.cancelNotifySuccess);
    AnalyticsUtil.instance.logEvent('cancel_all_notify');
  }

  Future<void> _getPreference() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      isOffline = PreferenceUtil.instance.getBool(
        Constants.prefIsOfflineLogin,
        false,
      );
      appVersion = packageInfo.version;
      courseNotify = PreferenceUtil.instance.getBool(
        Constants.prefCourseNotify,
        false,
      );
      displayPicture = PreferenceUtil.instance.getBool(
        Constants.prefDisplayPicture,
        true,
      );
      busNotify = PreferenceUtil.instance.getBool(
        Constants.prefBusNotify,
        false,
      );
      _themeMode = ThemeMode.values[PreferenceUtil.instance.getInt(
        Constants.prefThemeModeIndex,
        0,
      )];
      _languageCode = PreferenceUtil.instance.getString(
        Constants.prefLanguageCode,
        ApSupportLanguageConstants.system,
      );
      _iconStyle = PreferenceUtil.instance.getString(
        Constants.prefIconStyleCode,
        ApIcon.filled,
      );
      _themeColorIndex = PreferenceUtil.instance.getInt(
        Constants.prefThemeColorIndex,
        0,
      );
      AppTheme.currentColorIndex = _themeColorIndex;
      final int? customColorValue = PreferenceUtil.instance.getInt(
        Constants.prefCustomThemeColor,
        0,
      );
      if (_themeColorIndex == AppTheme.customColorIndex &&
          customColorValue != 0) {
        AppTheme.customColor = Color(customColorValue!);
      }
    });
  }

  Future<void> _setupBusNotify(BuildContext context) async {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        content: Row(
          children: <Widget>[
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(ap.loading),
          ],
        ),
      ),
      barrierDismissible: false,
    );

    if (isOffline) {
      final BusReservationsData? response =
          BusReservationsData.load(Helper.username);
      Navigator.of(context, rootNavigator: true).pop();
      if (response == null) {
        setState(() => busNotify = false);
        UiUtil.instance.showToast(context, ap.noOfflineData);
      } else {
        await Utils.setBusNotify(context, response.reservations);
        if (!mounted) return;
        UiUtil.instance.showToast(context, app.busNotifyHint);
      }
      PreferenceUtil.instance.setBool(Constants.prefBusNotify, busNotify);
      return;
    }

    Helper.instance.getBusReservations(
      callback: GeneralCallback<BusReservationsData>(
        onSuccess: (BusReservationsData data) async {
          Navigator.of(context, rootNavigator: true).pop();
          if (data.reservations.isEmpty) {
            await Utils.setBusNotify(context, data.reservations);
            if (!mounted) return;
            UiUtil.instance.showToast(context, app.busNotifyHint);
          } else {
            UiUtil.instance.showToast(context, app.busReservationEmpty);
          }
          PreferenceUtil.instance.setBool(Constants.prefBusNotify, busNotify);
        },
        onFailure: (DioException e) {
          Navigator.of(context, rootNavigator: true).pop();
          setState(() => busNotify = false);
          PreferenceUtil.instance.setBool(Constants.prefBusNotify, busNotify);
          _handleBusError(e);
        },
        onError: (GeneralResponse response) {
          Navigator.of(context, rootNavigator: true).pop();
          setState(() => busNotify = false);
          PreferenceUtil.instance.setBool(Constants.prefBusNotify, busNotify);
          UiUtil.instance.showToast(
            context,
            response.getGeneralMessage(context),
          );
        },
      ),
    );
  }

  void _handleBusError(DioException e) {
    if (e.hasResponse) {
      if (e.response!.statusCode == 401) {
        UiUtil.instance.showToast(context, ap.userNotSupport);
      } else if (e.response!.statusCode == 403) {
        UiUtil.instance.showToast(context, ap.campusNotSupport);
      } else if (e.message != null) {
        UiUtil.instance.showToast(context, e.message!);
        AnalyticsUtil.instance.logApiEvent(
          'getBusReservations',
          e.response!.statusCode!,
          message: e.message ?? '',
        );
      }
    } else if (e.type == DioExceptionType.unknown) {
      UiUtil.instance.showToast(context, ap.busFailInfinity);
    } else if (e.i18nMessage != null) {
      UiUtil.instance.showToast(context, e.i18nMessage!);
    }
  }
}
