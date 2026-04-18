import 'package:ap_common/ap_common.dart';
import 'package:ap_common_flutter_ui/ap_common_flutter_ui.dart';
import 'package:ap_common_plugin/ap_common_plugin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/api/exceptions/api_exception.dart';
import 'package:nkust_ap/api/exceptions/api_exception_l10n.dart';
import 'package:nkust_ap/models/bus_reservations_data.dart';
import 'package:nkust_ap/utils/global.dart';
import 'package:nkust_ap/widgets/share_data_widget.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingPage extends StatefulWidget {
  static const String routerName = '/setting';

  @override
  SettingPageState createState() => SettingPageState();
}

class SettingPageState extends State<SettingPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late ApLocalizations ap;

  String? appVersion;
  bool busNotify = false;
  bool courseNotify = false;
  bool displayPicture = true;
  bool isOffline = false;

  bool autoSendEvent = false;

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
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ap = context.ap;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(ap.settings),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SettingTitle(text: ap.notificationItem),
            SettingCard(
              children: <Widget>[
                const CheckCourseNotifyItem(),
                const ClearAllNotifyItem(),
                SettingSwitch(
                  text: AppLocalizations.of(context).busNotify,
                  subText: AppLocalizations.of(context).busNotifySubTitle,
                  value: busNotify,
                  onChanged: (bool b) async {
                    AnalyticsUtil.instance.logEvent('notify_bus_create');
                    setState(() {
                      busNotify = !busNotify;
                    });
                    if (busNotify) {
                      _setupBusNotify(context);
                    } else {
                      await Utils.cancelBusNotify();
                    }
                    PreferenceUtil.instance
                        .setBool(Constants.prefBusNotify, busNotify);
                    AnalyticsUtil.instance.logEvent('notify_bus_click');
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            SettingTitle(text: ap.otherSettings),
            SettingCard(
              children: <Widget>[
                SettingSwitch(
                  text: ap.headPhotoSetting,
                  subText: ap.headPhotoSettingSubTitle,
                  value: displayPicture,
                  onChanged: (bool b) {
                    setState(() {
                      displayPicture = !displayPicture;
                    });
                    PreferenceUtil.instance.setBool(
                      Constants.prefDisplayPicture,
                      displayPicture,
                    );
                    AnalyticsUtil.instance.logEvent('head_photo_click');
                  },
                ),
                ChangeLanguageItem(
                  onChange: (Locale locale) {
                    ShareDataWidget.of(context)!.data.loadLocale(locale);
                  },
                ),
                ChangeThemeModeItem(
                  onChange: (ThemeMode themeMode) {
                    ShareDataWidget.of(context)!.data.loadTheme(themeMode);
                  },
                ),
                ChangeThemeColorItem(
                  onChanged: (Color color) {
                    final int index = ApTheme.themeColors.indexWhere(
                      (ThemeColor tc) =>
                          tc.color.toARGB32() == color.toARGB32(),
                    );
                    final int newIndex =
                        (index != -1) ? index : ApTheme.customColorIndex;
                    final Color? newCustomColor = (index != -1) ? null : color;
                    ShareDataWidget.of(context)!
                        .data
                        .loadThemeColor(newIndex, newCustomColor);
                    ApTheme.of(context).saveSettings(
                      index: newIndex,
                      customColor: newCustomColor,
                    );
                  },
                ),
                ChangeIconStyleItem(
                  onChange: (String code) {
                    ShareDataWidget.of(context)!.data.update();
                  },
                ),
              ],
            ),
            if (kDebugMode) ...<Widget>[
              const SizedBox(height: 16),
              const SettingTitle(text: 'Debug'),
              SettingCard(
                children: <Widget>[
                  SettingItem(
                    text: '設定測試課表 Widget',
                    subText: '注入 30 分鐘後的假課程資料',
                    onTap: () async {
                      await ApCommonPlugin.setFakeCourseWidget();
                      if (!context.mounted) return;
                      UiUtil.instance.showToast(
                        context,
                        '已設定測試課表 Widget',
                      );
                    },
                  ),
                  SettingItem(
                    text: '清除課表 Widget',
                    subText: '移除 Widget 中的課程資料',
                    onTap: () async {
                      await ApCommonPlugin.clearCourseWidget();
                      if (!context.mounted) return;
                      UiUtil.instance.showToast(
                        context,
                        '已清除課表 Widget',
                      );
                    },
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            SettingTitle(text: ap.otherInfo),
            SettingCard(
              children: <Widget>[
                SettingItem(
                  text: ap.feedback,
                  subText: ap.feedbackViaFacebook,
                  onTap: () {
                    ApUtils.launchFbFansPage(context, Constants.fansPageId);
                    AnalyticsUtil.instance.logEvent('feedback_click');
                  },
                ),
                SettingItem(
                  text: ap.appVersion,
                  subText: 'v$appVersion',
                  onTap: () {
                    AnalyticsUtil.instance.logEvent('app_version_click');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getPreference() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      isOffline =
          PreferenceUtil.instance.getBool(Constants.prefIsOfflineLogin, false);
      appVersion = packageInfo.version;
      courseNotify =
          PreferenceUtil.instance.getBool(Constants.prefCourseNotify, false);
      displayPicture =
          PreferenceUtil.instance.getBool(Constants.prefDisplayPicture, true);
      busNotify =
          PreferenceUtil.instance.getBool(Constants.prefBusNotify, false);
    });
  }

  Future<void> _setupBusNotify(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) => ProgressDialog(ap.loading),
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
        if (!context.mounted) return;
        UiUtil.instance
            .showToast(context, AppLocalizations.of(context).busNotifyHint);
      }
      PreferenceUtil.instance.setBool(Constants.prefBusNotify, busNotify);
      return;
    }
    try {
      final BusReservationsData data =
          await Helper.instance.getBusReservations();
      Navigator.of(context, rootNavigator: true).pop();
      if (data.reservations.isEmpty) {
        await Utils.setBusNotify(context, data.reservations);
        if (!context.mounted) return;
        UiUtil.instance.showToast(
          context,
          AppLocalizations.of(context).busNotifyHint,
        );
      } else {
        UiUtil.instance.showToast(
          context,
          AppLocalizations.of(context).busReservationEmpty,
        );
      }
      PreferenceUtil.instance.setBool(Constants.prefBusNotify, busNotify);
    } on ApException catch (e) {
      if (e is CancelledException) return;
      Navigator.of(context, rootNavigator: true).pop();
      setState(() => busNotify = false);
      PreferenceUtil.instance.setBool(Constants.prefBusNotify, busNotify);
      if (e is ServerException && e.httpStatusCode == 401) {
        UiUtil.instance.showToast(context, ap.userNotSupport);
      } else if (e is ServerException && e.httpStatusCode == 403) {
        UiUtil.instance.showToast(context, ap.campusNotSupport);
      } else {
        UiUtil.instance.showToast(context, e.toLocalizedMessage(context));
        if (e is ServerException && e.httpStatusCode != null) {
          AnalyticsUtil.instance.logApiEvent(
            'getBusReservations',
            e.httpStatusCode!,
            message: e.message,
          );
        }
      }
    }
  }
}
