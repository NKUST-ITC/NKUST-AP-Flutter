import 'package:ap_common/resources/ap_theme.dart';
import 'package:ap_common/utils/analytics_utils.dart';
import 'package:ap_common/utils/ap_localizations.dart';
import 'package:ap_common/utils/ap_utils.dart';
import 'package:ap_common/utils/preferences.dart';
import 'package:ap_common/widgets/progress_dialog.dart';
import 'package:ap_common/widgets/setting_page_widgets.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/models/bus_reservations_data.dart';
import 'package:nkust_ap/utils/global.dart';
import 'package:nkust_ap/widgets/share_data_widget.dart';

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
    FirebaseAnalyticsUtils.instance
        .setCurrentScreen('SettingPage', 'setting_page.dart');
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
                FirebaseAnalyticsUtils.instance.logEvent('notify_bus_create');
                setState(() {
                  busNotify = !busNotify;
                });
                if (busNotify) {
                  _setupBusNotify(context);
                } else {
                  await Utils.cancelBusNotify();
                }
                Preferences.setBool(Constants.prefBusNotify, busNotify);
                FirebaseAnalyticsUtils.instance.logEvent('notify_bus_click');
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
                Preferences.setBool(
                  Constants.prefDisplayPicture,
                  displayPicture,
                );
                FirebaseAnalyticsUtils.instance.logEvent('head_photo_click');
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
                AnalyticsUtils.instance?.logEvent('feedback_click');
              },
            ),
            SettingItem(
              text: ap.appVersion,
              subText: 'v$appVersion',
              onTap: () {
                AnalyticsUtils.instance?.logEvent('app_version_click');
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
      isOffline = Preferences.getBool(Constants.prefIsOfflineLogin, false);
      appVersion = packageInfo.version;
      courseNotify = Preferences.getBool(Constants.prefCourseNotify, false);
      displayPicture = Preferences.getBool(Constants.prefDisplayPicture, true);
      busNotify = Preferences.getBool(Constants.prefBusNotify, false);
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
        ApUtils.showToast(context, ap.noOfflineData);
      } else {
        await Utils.setBusNotify(context, response.reservations);
        if (!context.mounted) return;
        ApUtils.showToast(context, AppLocalizations.of(context).busNotifyHint);
      }
      Preferences.setBool(Constants.prefBusNotify, busNotify);
      return;
    }
    Helper.instance.getBusReservations(
      callback: GeneralCallback<BusReservationsData>(
        onSuccess: (BusReservationsData data) async {
          Navigator.of(context, rootNavigator: true).pop();
          if (data.reservations.isEmpty) {
            await Utils.setBusNotify(context, data.reservations);
            if (!context.mounted) return;
            ApUtils.showToast(
              context,
              AppLocalizations.of(context).busNotifyHint,
            );
          } else {
            ApUtils.showToast(
              context,
              AppLocalizations.of(context).busReservationEmpty,
            );
          }
          Preferences.setBool(Constants.prefBusNotify, busNotify);
        },
        onFailure: (DioException e) {
          Navigator.of(context, rootNavigator: true).pop();
          setState(() => busNotify = false);
          Preferences.setBool(Constants.prefBusNotify, busNotify);
          if (e.hasResponse) {
            if (e.response!.statusCode == 401) {
              ApUtils.showToast(context, ap.userNotSupport);
            } else if (e.response!.statusCode == 403) {
              ApUtils.showToast(context, ap.campusNotSupport);
            } else {
              ApUtils.showToast(context, e.message);
              FirebaseAnalyticsUtils.instance.logApiEvent(
                'getBusReservations',
                e.response!.statusCode!,
                message: e.message ?? '',
              );
            }
          } else if (e.type == DioExceptionType.unknown) {
            ApUtils.showToast(context, ap.busFailInfinity);
          } else {
            ApUtils.showToast(context, e.i18nMessage);
          }
        },
        onError: (GeneralResponse response) {
          Navigator.of(context, rootNavigator: true).pop();
          setState(() => busNotify = false);
          Preferences.setBool(Constants.prefBusNotify, busNotify);
          ApUtils.showToast(context, response.getGeneralMessage(context));
        },
      ),
    );
  }
}
