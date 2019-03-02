import 'dart:io';

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
        showToast(app.timeoutMessage);
        break;
      case DioErrorType.RESPONSE:
      case DioErrorType.CANCEL:
        break;
    }
  }

  static void handleResponseError(
      BuildContext context, bool mounted, DioError e) {
    var app = AppLocalizations.of(context);
    if (e.response.statusCode == 401) {
      Utils.showToast(app.tokenExpiredContent);
      if (mounted)
        Navigator.popUntil(
            context, ModalRoute.withName(Navigator.defaultRouteName));
    } else
      Utils.showToast(app.somethingError);
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

  static void showDefaultDialog(BuildContext context, String title,
      String content, String actionText, Function function) {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Text(title,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Resource.Colors.blue)),
              content: Text(content,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Resource.Colors.grey)),
              actions: <Widget>[
                FlatButton(
                  child: Text(actionText,
                      style: TextStyle(color: Resource.Colors.blue)),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop('dialog');
                    function();
                  },
                )
              ],
            ));
  }

  static void showYesNoDialog(
      BuildContext context, String title, String content, Function function) {
    var app = AppLocalizations.of(context);
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Text(title,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Resource.Colors.blue)),
              content: Text(content,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Resource.Colors.grey)),
              actions: <Widget>[
                FlatButton(
                  child: Text(app.cancel,
                      style: TextStyle(color: Resource.Colors.blue)),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop('dialog');
                  },
                ),
                FlatButton(
                  child: Text(app.determine,
                      style: TextStyle(color: Resource.Colors.blue)),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop('dialog');
                    function();
                  },
                )
              ],
            ));
  }

  static void showForceUpdateDialog(
      BuildContext context, String url, String versionContent) {
    var app = AppLocalizations.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => WillPopScope(
            child: AlertDialog(
              title: Text(app.updateTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Resource.Colors.blue)),
              content: Text(
                  '${_getPlatformUpdateContent(app)}\n${versionContent.replaceAll('\\n', '\n')}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Resource.Colors.grey)),
              actions: <Widget>[
                FlatButton(
                  child: Text(app.update,
                      style: TextStyle(color: Resource.Colors.blue)),
                  onPressed: () {
                    launchUrl(url);
                  },
                )
              ],
            ),
            onWillPop: () async {
              return false;
            },
          ),
    );
  }

  static void showUpdateDialog(
      BuildContext context, String url, String versionContent) {
    var app = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
            title: Text(app.updateTitle,
                textAlign: TextAlign.center,
                style: TextStyle(color: Resource.Colors.blue)),
            content: Text(
                '${_getPlatformUpdateContent(app)}\n${versionContent.replaceAll('\\n', '\n')}',
                textAlign: TextAlign.center,
                style: TextStyle(color: Resource.Colors.grey)),
            actions: <Widget>[
              FlatButton(
                child: Text(app.skip,
                    style: TextStyle(color: Resource.Colors.blue)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text(app.update,
                    style: TextStyle(color: Resource.Colors.blue)),
                onPressed: () {
                  launchUrl(url);
                },
              )
            ],
          ),
    );
  }

  static String _getPlatformUpdateContent(AppLocalizations app) {
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
}
