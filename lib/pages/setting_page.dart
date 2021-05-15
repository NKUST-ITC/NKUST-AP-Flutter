import 'package:ap_common/callback/general_callback.dart';
import 'package:ap_common/resources/ap_theme.dart';
import 'package:ap_common/utils/analytics_utils.dart';
import 'package:ap_common/utils/ap_localizations.dart';
import 'package:ap_common/utils/ap_utils.dart';
import 'package:ap_common/utils/preferences.dart';
import 'package:ap_common/widgets/progress_dialog.dart';
import 'package:ap_common/widgets/setting_page_widgets.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/models/bus_reservations_data.dart';
import 'package:nkust_ap/utils/global.dart';
import 'package:nkust_ap/widgets/share_data_widget.dart';

class SettingPage extends StatefulWidget {
  static const String routerName = "/setting";

  @override
  SettingPageState createState() => SettingPageState();
}

class SettingPageState extends State<SettingPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  ApLocalizations ap;

  String appVersion;
  bool busNotify = false, courseNotify = false, displayPicture = true;
  bool isOffline = false;

  var autoSendEvent = false;

  @override
  void initState() {
    FirebaseAnalyticsUtils.instance
        .setCurrentScreen("SettingPage", "setting_page.dart");
    _getPreference();
    if (DateTime.now().millisecondsSinceEpoch % 5 == 0)
      ApUtils.showAppReviewDialog(context, Constants.PLAY_STORE_URL);
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
            CheckCourseNotifyItem(),
            ClearAllNotifyItem(),
            SettingSwitch(
              text: ap.busNotify,
              subText: ap.busNotifySubTitle,
              value: busNotify,
              onChanged: (b) async {
                FirebaseAnalyticsUtils.instance.logEvent('notify_bus_create');
                setState(() {
                  busNotify = !busNotify;
                });
                if (busNotify)
                  _setupBusNotify(context);
                else {
                  await Utils.cancelBusNotify();
                }
                Preferences.setBool(Constants.PREF_BUS_NOTIFY, busNotify);
                FirebaseAnalyticsUtils.instance.logEvent('notify_bus_click');
              },
            ),
            Divider(
              color: Colors.grey,
              height: 0.5,
            ),
            SettingTitle(text: ap.otherSettings),
            SettingSwitch(
              text: ap.headPhotoSetting,
              subText: ap.headPhotoSettingSubTitle,
              value: displayPicture,
              onChanged: (b) {
                setState(() {
                  displayPicture = !displayPicture;
                });
                Preferences.setBool(
                    Constants.PREF_DISPLAY_PICTURE, displayPicture);
                FirebaseAnalyticsUtils.instance
                    .logAction('head_photo', 'click');
              },
            ),
            ChangeLanguageItem(
              onChange: (locale) {
                ShareDataWidget.of(context).data.loadLocale(locale);
              },
            ),
            ChangeThemeModeItem(
              onChange: (themeMode) {
                ShareDataWidget.of(context).data.loadTheme(themeMode);
              },
            ),
            ChangeIconStyleItem(
              onChange: (String code) {
                ShareDataWidget.of(context).data.update();
              },
            ),
            Divider(
              color: Colors.grey,
              height: 0.5,
            ),
            SettingTitle(text: ap.otherInfo),
            SettingItem(
              text: ap.feedback,
              subText: ap.feedbackViaFacebook,
              onTap: () {
                ApUtils.launchFbFansPage(context, Constants.FANS_PAGE_ID);
                AnalyticsUtils.instance?.logEvent('feedback_click');
              },
            ),
            SettingItem(
              text: ap.appVersion,
              subText: "v$appVersion",
              onTap: () {
                AnalyticsUtils.instance?.logEvent('app_version_click');
              },
            ),
          ],
        ),
      ),
    );
  }

  _getPreference() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      isOffline = Preferences.getBool(Constants.PREF_IS_OFFLINE_LOGIN, false);
      appVersion = packageInfo?.version;
      courseNotify = Preferences.getBool(Constants.PREF_COURSE_NOTIFY, false);
      displayPicture =
          Preferences.getBool(Constants.PREF_DISPLAY_PICTURE, true);
      busNotify = Preferences.getBool(Constants.PREF_BUS_NOTIFY, false);
    });
  }

  _setupBusNotify(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) => ProgressDialog(ap.loading),
      barrierDismissible: false,
    );
    if (isOffline) {
      BusReservationsData response = BusReservationsData.load(Helper.username);
      Navigator.of(context, rootNavigator: true).pop();
      if (response == null) {
        setState(() => busNotify = false);
        ApUtils.showToast(context, ap.noOfflineData);
      } else {
        await Utils.setBusNotify(context, response.reservations);
        ApUtils.showToast(context, ap.busNotifyHint);
      }
      Preferences.setBool(Constants.PREF_BUS_NOTIFY, busNotify);
      return;
    }
    Helper.instance.getBusReservations(
      callback: GeneralCallback(
        onSuccess: (BusReservationsData data) async {
          Navigator.of(context, rootNavigator: true).pop();
          if (data != null) {
            await Utils.setBusNotify(context, data.reservations);
            ApUtils.showToast(context, ap.busNotifyHint);
          } else
            ApUtils.showToast(context, ap.busReservationEmpty);
          Preferences.setBool(Constants.PREF_BUS_NOTIFY, busNotify);
        },
        onFailure: (DioError e) {
          Navigator.of(context, rootNavigator: true).pop();
          setState(() => busNotify = false);
          Preferences.setBool(Constants.PREF_BUS_NOTIFY, busNotify);
          if (e.hasResponse) {
            if (e.response.statusCode == 401)
              ApUtils.showToast(context, ap.userNotSupport);
            else if (e.response.statusCode == 403)
              ApUtils.showToast(context, ap.campusNotSupport);
            else {
              ApUtils.showToast(context, e.message);
              FirebaseAnalyticsUtils.instance.logApiEvent(
                  'getBusReservations', e.response.statusCode,
                  message: e.message);
            }
          } else if (e.type == DioErrorType.other) {
            ApUtils.showToast(context, ap.busFailInfinity);
          } else
            ApUtils.handleDioError(context, e);
        },
        onError: (GeneralResponse response) {
          Navigator.of(context, rootNavigator: true).pop();
          setState(() => busNotify = false);
          Preferences.setBool(Constants.PREF_BUS_NOTIFY, busNotify);
          ApUtils.showToast(context, response.getGeneralMessage(context));
        },
      ),
    );
  }
}
