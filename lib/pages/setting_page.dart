import 'package:ap_common/ap_common.dart';
import 'package:flutter/material.dart';
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
    ap = ApLocalizations.of(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(ap.settings),
        backgroundColor: ApTheme.of(context).blue,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SettingTitle(text: ap.notificationItem),
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
            const Divider(
              color: Colors.grey,
              height: 0.5,
            ),
            SettingTitle(text: ap.otherSettings),
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
            ChangeIconStyleItem(
              onChange: (String code) {
                ShareDataWidget.of(context)!.data.update();
              },
            ),
            const Divider(
              color: Colors.grey,
              height: 0.5,
            ),
            SettingTitle(text: ap.otherInfo),
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
    Helper.instance.getBusReservations(
      callback: GeneralCallback<BusReservationsData>(
        onSuccess: (BusReservationsData data) async {
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
        },
        onFailure: (DioException e) {
          Navigator.of(context, rootNavigator: true).pop();
          setState(() => busNotify = false);
          PreferenceUtil.instance.setBool(Constants.prefBusNotify, busNotify);
          if (e.hasResponse) {
            if (e.response!.statusCode == 401) {
              UiUtil.instance.showToast(context, ap.userNotSupport);
            } else if (e.response!.statusCode == 403) {
              UiUtil.instance.showToast(context, ap.campusNotSupport);
            } else {
              if (e.message != null) {
                UiUtil.instance.showToast(context, e.message!);
                AnalyticsUtil.instance.logApiEvent(
                  'getBusReservations',
                  e.response!.statusCode!,
                  message: e.message ?? '',
                );
              }
            }
          } else if (e.type == DioExceptionType.unknown) {
            UiUtil.instance.showToast(context, ap.busFailInfinity);
          } else {
            if (e.i18nMessage != null) {
              UiUtil.instance.showToast(context, e.i18nMessage!);
            }
          }
        },
        onError: (GeneralResponse response) {
          Navigator.of(context, rootNavigator: true).pop();
          setState(() => busNotify = false);
          PreferenceUtil.instance.setBool(Constants.prefBusNotify, busNotify);
          UiUtil.instance
              .showToast(context, response.getGeneralMessage(context));
        },
      ),
    );
  }
}
