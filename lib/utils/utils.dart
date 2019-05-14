import 'dart:io';

import 'package:app_review/app_review.dart';
import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nkust_ap/config/constants.dart';
import 'package:nkust_ap/models/bus_reservations_data.dart';
import 'package:nkust_ap/models/course_data.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;
import 'package:nkust_ap/utils/app_localizations.dart';
import 'package:nkust_ap/utils/firebase_analytics_utils.dart';
import 'package:nkust_ap/widgets/yes_no_dialog.dart';
import 'package:package_info/package_info.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sprintf/sprintf.dart';
import 'package:url_launcher/url_launcher.dart';

class Utils {
  static void handleDioError(DioError dioError, AppLocalizations app) {
    switch (dioError.type) {
      case DioErrorType.DEFAULT:
        showToast(app.noInternet);
        break;
      case DioErrorType.CONNECT_TIMEOUT:
      case DioErrorType.RECEIVE_TIMEOUT:
      case DioErrorType.SEND_TIMEOUT:
        showToast(app.timeoutMessage);
        break;
      case DioErrorType.RESPONSE:
      case DioErrorType.CANCEL:
        break;
    }
  }

  static void handleResponseError(
      BuildContext context, String type, bool mounted, DioError e) {
    var app = AppLocalizations.of(context);
    FA.logApiEvent(type, e.response.statusCode, message: e.message);
    if (e.response.statusCode == 401) {
      Utils.showToast(app.tokenExpiredContent);
      if (mounted)
        Navigator.popUntil(
            context, ModalRoute.withName(Navigator.defaultRouteName));
    } else {
      Utils.showToast(app.somethingError);
    }
  }

  static void showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.grey[300],
        textColor: Colors.black);
  }

  static String getPlatformUpdateContent(AppLocalizations app) {
    if (Platform.isAndroid)
      return app.updateAndroidContent;
    else if (Platform.isIOS)
      return app.updateIOSContent;
    else
      return app.updateContent;
  }

  static void showSnackBarBar(
    ScaffoldState scaffold,
    String contentText,
    String actionText,
    Color actionTextColor,
  ) {
    scaffold.showSnackBar(
      SnackBar(
        content: Text(contentText),
        duration: Duration(days: 1),
        action: SnackBarAction(
          label: actionText,
          onPressed: () {},
          textColor: actionTextColor,
        ),
      ),
    );
  }

  static void initConnectivity(
      BuildContext context, ScaffoldState scaffold) async {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.mobile) {
        scaffold.removeCurrentSnackBar();
      } else if (result == ConnectivityResult.wifi) {
        scaffold.removeCurrentSnackBar();
      } else {
        scaffold.showSnackBar(
          SnackBar(
            content: Text("無網路連線"),
            duration: Duration(days: 1),
            action: SnackBarAction(
              label: "開啟設定",
              onPressed: () {
                //TODO
              },
              textColor: Resource.Colors.yellow,
            ),
          ),
        );
      }
    });
  }

  static Future<void> launchUrl(var url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  static callPhone(String url) async {
    url = url.replaceAll('#', ',');
    url = url.replaceAll('(', '');
    url = url.replaceAll(')', '');
    url = url.replaceAll('-', '');
    url = url.replaceAll(' ', '');
    url = "tel:$url";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  static void shareTo(String content) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    Share.share("$content\n\n"
        "Send from ${packageInfo.appName} ${Platform.operatingSystem}");
  }

  static void clearSetting() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool(Constants.PREF_AUTO_LOGIN, false);
  }

  static void showFCMNotification(
      String title, String body, String payload) async {
    //limit Android and iOS system
    if (Platform.isAndroid || Platform.isIOS) {
      var flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      var initializationSettings = InitializationSettings(
        AndroidInitializationSettings(
            Constants.ANDROID_DEFAULT_NOTIFICATION_NAME),
        IOSInitializationSettings(
          onDidReceiveLocalNotification: (id, title, body, payload) {},
        ),
      );
      flutterLocalNotificationsPlugin.initialize(initializationSettings,
          onSelectNotification: (text) {});
      var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
          Constants.NOTIFICATION_FCM_ID.toString(), '系統通知', '系統通知',
          largeIconBitmapSource: BitmapSource.Drawable,
          importance: Importance.Default,
          largeIcon: '@drawable/ic_launcher',
          style: AndroidNotificationStyle.BigText,
          enableVibration: false);
      var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
      var platformChannelSpecifics = new NotificationDetails(
          androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin.show(
        Constants.NOTIFICATION_FCM_ID,
        title,
        payload,
        platformChannelSpecifics,
        payload: payload,
      );
    } else {
      //TODO implement other platform system local notification
    }
  }

  static Future<void> setBusNotify(
      BuildContext context, List<BusReservation> busReservations) async {
    var app = AppLocalizations.of(context);
    //limit Android and iOS system
    if (Platform.isAndroid || Platform.isIOS) {
      var flutterLocalNotificationsPlugin =
          initFlutterLocalNotificationsPlugin();
      var androidPlatformChannelSpecifics = AndroidNotificationDetails(
          Constants.NOTIFICATION_BUS_ID.toString(),
          app.busNotify,
          app.busNotify,
          largeIconBitmapSource: BitmapSource.Drawable,
          importance: Importance.High,
          largeIcon: '@drawable/ic_launcher',
          style: AndroidNotificationStyle.BigText,
          enableVibration: false);
      var iOSPlatformChannelSpecifics = IOSNotificationDetails();
      var platformChannelSpecifics = NotificationDetails(
          androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin
          .cancel(Constants.NOTIFICATION_BUS_ID);
      for (BusReservation i in busReservations) {
        await flutterLocalNotificationsPlugin.schedule(
          Constants.NOTIFICATION_BUS_ID,
          app.busNotify,
          sprintf(app.busNotifyContent, [i.getStart(app), i.getEnd(app)]),
          i.getDateTime().add(Duration(minutes: -30)),
          platformChannelSpecifics,
          payload:
              sprintf(app.busNotifyContent, [i.getStart(app), i.getEnd(app)]),
        );
      }
    } else {
      //TODO implement other platform system local notification
    }
  }

  static Future<void> cancelBusNotify() async {
    var flutterLocalNotificationsPlugin = initFlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin.cancel(Constants.NOTIFICATION_BUS_ID);
  }

  static Future<void> setCourseNotify(
      BuildContext context, CourseTables courseTables) async {
    var app = AppLocalizations.of(context);
    //limit Android and iOS system
    if (Platform.isAndroid || Platform.isIOS) {
      var flutterLocalNotificationsPlugin =
          initFlutterLocalNotificationsPlugin();
      var androidPlatformChannelSpecifics = AndroidNotificationDetails(
          Constants.NOTIFICATION_COURSE_ID.toString(),
          app.courseNotify,
          app.courseNotify,
          largeIconBitmapSource: BitmapSource.Drawable,
          importance: Importance.High,
          largeIcon: '@drawable/ic_launcher',
          style: AndroidNotificationStyle.BigText,
          enableVibration: false);
      var iOSPlatformChannelSpecifics = IOSNotificationDetails();
      var platformChannelSpecifics = NotificationDetails(
          androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin
          .cancel(Constants.NOTIFICATION_COURSE_ID);
      for (int i = 0; i < Day.values.length; i++) {
        List<Course> course =
            courseTables.getCourseListByDayObject(Day.values[i]);
        List<String> keyList = [];
        List<Course> saveCourseList = [];
        if (course == null) continue;
        for (int j = 0; j < course.length; j++) {
          if (!keyList.contains(course[j].title)) {
            keyList.add(course[j].title);
            saveCourseList.add(course[j]);
          }
        }
        saveCourseList.forEach((Course course) async {
          String content = sprintf(app.courseNotifyContent, [
            course.title,
            course.location.room.isEmpty
                ? app.courseNotifyUnknown
                : course.location.room
          ]);
          await flutterLocalNotificationsPlugin.showWeeklyAtDayAndTime(
            Constants.NOTIFICATION_BUS_ID,
            app.courseNotify,
            content,
            Day.values[i],
            course.getCourseNotifyTimeObject(),
            platformChannelSpecifics,
            payload: content,
          );
        });
      }
    } else {
      //TODO implement other platform system local notification
    }
  }

  static Future<void> cancelCourseNotify() async {
    var flutterLocalNotificationsPlugin = initFlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin
        .cancel(Constants.NOTIFICATION_COURSE_ID);
  }

  static FlutterLocalNotificationsPlugin initFlutterLocalNotificationsPlugin() {
    var flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var initializationSettings = InitializationSettings(
      AndroidInitializationSettings(
          Constants.ANDROID_DEFAULT_NOTIFICATION_NAME),
      IOSInitializationSettings(
        onDidReceiveLocalNotification: (id, title, body, payload) {},
      ),
    );
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (text) {});
    return flutterLocalNotificationsPlugin;
  }

  static void showChoseLanguageDialog(BuildContext context, Function function) {
    var app = AppLocalizations.of(context);
    showDialog<int>(
      context: context,
      builder: (BuildContext context) => SimpleDialog(
              title: Text(app.choseLanguageTitle),
              children: <SimpleDialogOption>[
                SimpleDialogOption(
                    child: Text(app.systemLanguage),
                    onPressed: () async {
                      Navigator.pop(context);
                      if (Platform.isAndroid || Platform.isIOS) {
                        SharedPreferences preference =
                            await SharedPreferences.getInstance();
                        preference.setString(
                            Constants.PREF_LANGUAGE_CODE, 'system');
                        AppLocalizations.locale =
                            Localizations.localeOf(context);
                      }
                      function();
                    }),
                SimpleDialogOption(
                    child: Text(app.traditionalChinese),
                    onPressed: () async {
                      Navigator.pop(context);
                      if (Platform.isAndroid || Platform.isIOS) {
                        SharedPreferences preference =
                            await SharedPreferences.getInstance();
                        preference.setString(
                            Constants.PREF_LANGUAGE_CODE, 'zh');
                        AppLocalizations.locale = Locale('zh');
                      }
                      function();
                    }),
                SimpleDialogOption(
                    child: Text(app.english),
                    onPressed: () async {
                      Navigator.pop(context);
                      if (Platform.isAndroid || Platform.isIOS) {
                        SharedPreferences preference =
                            await SharedPreferences.getInstance();
                        preference.setString(
                            Constants.PREF_LANGUAGE_CODE, 'en');
                        AppLocalizations.locale = Locale('en');
                      }
                      function();
                    })
              ]),
    ).then<void>((int position) {});
  }

  static void showAppReviewDialog(BuildContext context) async {
    await Future.delayed(Duration(seconds: 1));
    var date = DateTime.now();
    if (date.millisecondsSinceEpoch % 3 == 0) return;
    AppLocalizations app = AppLocalizations.of(context);
    if (Platform.isAndroid || Platform.isIOS) {
      showDialog(
        context: context,
        builder: (BuildContext context) => YesNoDialog(
              title: app.ratingDialogTitle,
              contentWidget: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                    style: TextStyle(
                        color: Resource.Colors.grey,
                        height: 1.3,
                        fontSize: 16.0),
                    children: [
                      TextSpan(text: app.ratingDialogContent),
                    ]),
              ),
              leftActionText: app.later,
              rightActionText: app.rateNow,
              leftActionFunction: null,
              rightActionFunction: () {
                AppReview.requestReview.then((onValue) {
                  print(onValue);
                });
              },
            ),
      );
    } else {
      //TODO implement other platform system local notification
    }
  }

  static void showAppReviewSheet(BuildContext context) async {
    // await Future.delayed(Duration(seconds: 1));
    AppLocalizations app = AppLocalizations.of(context);
    if (Platform.isAndroid || Platform.isIOS) {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) => Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      app.ratingDialogTitle,
                      style: TextStyle(
                          color: Resource.Colors.blue, fontSize: 20.0),
                    ),
                  ),
                ),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                      style: TextStyle(
                          color: Resource.Colors.grey,
                          height: 1.3,
                          fontSize: 18.0),
                      children: [
                        TextSpan(text: app.ratingDialogContent),
                      ]),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        app.later,
                        style: TextStyle(
                            color: Resource.Colors.blue, fontSize: 16.0),
                      ),
                    ),
                    FlatButton(
                      onPressed: () {
                        AppReview.requestReview.then((a) {});
                      },
                      child: Text(
                        app.rateNow,
                        style: TextStyle(
                            color: Resource.Colors.blue, fontSize: 16.0),
                      ),
                    ),
                  ],
                )
              ],
            ),
      );
    } else {
      //TODO implement other platform system local notification
    }
  }
}
