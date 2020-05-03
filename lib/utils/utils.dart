import 'dart:io';

import 'package:ap_common/models/course_data.dart';
import 'package:ap_common/resources/ap_theme.dart';
import 'package:ap_common/utils/ap_localizations.dart';
import 'package:ap_common/utils/ap_utils.dart';
import 'package:ap_common/utils/dialog_utils.dart';
import 'package:ap_common/utils/preferences.dart';
import 'package:ap_common/widgets/default_dialog.dart';
import 'package:ap_common/widgets/yes_no_dialog.dart';
import 'package:app_review/app_review.dart';
import 'package:dio/dio.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart' show CupertinoPageRoute;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:image/image.dart' as ImageUtils;
import 'package:nkust_ap/api/helper.dart';
import 'package:nkust_ap/config/constants.dart';
import 'package:nkust_ap/models/bus_reservations_data.dart';
import 'package:nkust_ap/pages/home/bus_page.dart';
import 'package:nkust_ap/pages/home/leave_page.dart';
import 'package:nkust_ap/pages/home/study/calculate_units_page.dart';
import 'package:nkust_ap/pages/home/study/course_page.dart';
import 'package:nkust_ap/pages/home/study/midterm_alerts_page.dart';
import 'package:nkust_ap/pages/home/study/reward_and_penalty_page.dart';
import 'package:nkust_ap/pages/home/study/score_page.dart';
import 'package:nkust_ap/utils/app_localizations.dart';
import 'package:nkust_ap/utils/firebase_analytics_utils.dart';
import 'package:nkust_ap/widgets/share_data_widget.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sprintf/sprintf.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

class Utils {
  static void handleDioError(BuildContext context, DioError dioError) {
    switch (dioError.type) {
      case DioErrorType.DEFAULT:
        ApUtils.showToast(context, ApLocalizations.of(context).noInternet);
        break;
      case DioErrorType.CONNECT_TIMEOUT:
      case DioErrorType.RECEIVE_TIMEOUT:
      case DioErrorType.SEND_TIMEOUT:
        ApUtils.showToast(context, ApLocalizations.of(context).timeoutMessage);
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
      ApUtils.showToast(
          context, ApLocalizations.of(context).tokenExpiredContent);
    } else {
      ApUtils.showToast(context, ApLocalizations.of(context).somethingError);
    }
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

  static void clearSetting() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool(Constants.PREF_AUTO_LOGIN, false);
  }

  static void showFCMNotification(
      String title, String body, String payload) async {
    //limit Android and iOS system
    if (Platform.isAndroid || Platform.isIOS) {
//      var flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//      var initializationSettings = InitializationSettings(
//        AndroidInitializationSettings(
//            Constants.ANDROID_DEFAULT_NOTIFICATION_NAME),
//        IOSInitializationSettings(
//          onDidReceiveLocalNotification: (id, title, body, payload) {},
//        ),
//      );
//      flutterLocalNotificationsPlugin.initialize(initializationSettings,
//          onSelectNotification: (text) {});
//      var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
//          Constants.NOTIFICATION_FCM_ID.toString(), '系統通知', '系統通知',
//          largeIconBitmapSource: BitmapSource.Drawable,
//          importance: Importance.Default,
//          largeIcon: '@drawable/ic_launcher',
//          style: AndroidNotificationStyle.BigText,
//          enableVibration: false);
//      var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
//      var platformChannelSpecifics = new NotificationDetails(
//          androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
//      await flutterLocalNotificationsPlugin.show(
//        Constants.NOTIFICATION_FCM_ID,
//        title,
//        payload,
//        platformChannelSpecifics,
//        payload: payload,
//      );
    } else {
      //TODO implement other platform system local notification
    }
  }

  static Future<void> setBusNotify(
      BuildContext context, List<BusReservation> busReservations) async {
    var app = AppLocalizations.of(context);
    //limit Android and iOS system
    if (Platform.isAndroid || Platform.isIOS) {
//      var flutterLocalNotificationsPlugin =
//          initFlutterLocalNotificationsPlugin();
//      var androidPlatformChannelSpecifics = AndroidNotificationDetails(
//          Constants.NOTIFICATION_BUS_ID.toString(),
//          app.busNotify,
//          app.busNotify,
//          largeIconBitmapSource: BitmapSource.Drawable,
//          importance: Importance.High,
//          largeIcon: '@drawable/ic_launcher',
//          style: AndroidNotificationStyle.BigText,
//          enableVibration: false);
//      var iOSPlatformChannelSpecifics = IOSNotificationDetails();
//      var platformChannelSpecifics = NotificationDetails(
//          androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
//      await flutterLocalNotificationsPlugin
//          .cancel(Constants.NOTIFICATION_BUS_ID);
//      for (BusReservation i in busReservations) {
//        await flutterLocalNotificationsPlugin.schedule(
//          Constants.NOTIFICATION_BUS_ID,
//          app.busNotify,
//          sprintf(app.busNotifyContent, [i.getStart(app), i.getEnd(app)]),
//          i.getDateTime().add(Duration(minutes: -30)),
//          platformChannelSpecifics,
//          payload:
//              sprintf(app.busNotifyContent, [i.getStart(app), i.getEnd(app)]),
//        );
//      }
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
//      var flutterLocalNotificationsPlugin =
//          initFlutterLocalNotificationsPlugin();
//      var androidPlatformChannelSpecifics = AndroidNotificationDetails(
//          Constants.NOTIFICATION_COURSE_ID.toString(),
//          app.courseNotify,
//          app.courseNotify,
//          largeIconBitmapSource: BitmapSource.Drawable,
//          importance: Importance.High,
//          largeIcon: '@drawable/ic_launcher',
//          style: AndroidNotificationStyle.BigText,
//          enableVibration: false);
//      var iOSPlatformChannelSpecifics = IOSNotificationDetails();
//      var platformChannelSpecifics = NotificationDetails(
//          androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
//      await flutterLocalNotificationsPlugin
//          .cancel(Constants.NOTIFICATION_COURSE_ID);
//      for (int i = 0; i < Day.values.length; i++) {
//        List<Course> course =
//            courseTables.getCourseListByDayObject(Day.values[i]);
//        List<String> keyList = [];
//        List<Course> saveCourseList = [];
//        if (course == null) continue;
//        for (int j = 0; j < course.length; j++) {
//          if (!keyList.contains(course[j].title)) {
//            keyList.add(course[j].title);
//            saveCourseList.add(course[j]);
//          }
//        }
//        saveCourseList.forEach((Course course) async {
//          String content = sprintf(app.courseNotifyContent, [
//            course.title,
//            course.location.room.isEmpty
//                ? app.courseNotifyUnknown
//                : course.location.room
//          ]);
//          await flutterLocalNotificationsPlugin.showWeeklyAtDayAndTime(
//            Constants.NOTIFICATION_BUS_ID,
//            app.courseNotify,
//            content,
//            Day.values[i],
//            course.getCourseNotifyTimeObject(),
//            platformChannelSpecifics,
//            payload: content,
//          );
//        });
//      }
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

  static void showAppReviewDialog(BuildContext context) async {
    await Future.delayed(Duration(seconds: 1));
    var date = DateTime.now();
    if (date.millisecondsSinceEpoch % 5 != 0) return;
    final app = ApLocalizations.of(context);
    if (Platform.isAndroid || Platform.isIOS) {
      showDialog(
        context: context,
        builder: (BuildContext context) => YesNoDialog(
          title: app.ratingDialogTitle,
          contentWidget: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
                style: TextStyle(
                    color: ApTheme.of(context).grey,
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
    final app = ApLocalizations.of(context);
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
                      color: ApTheme.of(context).blue, fontSize: 20.0),
                ),
              ),
            ),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                  style: TextStyle(
                      color: ApTheme.of(context).grey,
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
                        color: ApTheme.of(context).blue, fontSize: 16.0),
                  ),
                ),
                FlatButton(
                  onPressed: () {
                    AppReview.requestReview.then((a) {});
                  },
                  child: Text(
                    app.rateNow,
                    style: TextStyle(
                        color: ApTheme.of(context).blue, fontSize: 16.0),
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

  static checkRemoteConfig(BuildContext context, Function apiHostUpdate) async {
    await Future.delayed(
      Duration(milliseconds: 50),
    );
    if (kIsWeb) return;
    if (!(Platform.isAndroid || Platform.isIOS)) return;
    final app = AppLocalizations.of(context);
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    var currentVersion =
        Preferences.getString(Constants.PREF_CURRENT_VERSION, '');
    if (currentVersion != packageInfo.buildNumber) {
      DialogUtils.showUpdateContent(
        context,
        AppLocalizations.of(context).updateNoteContent,
      );
      Preferences.setString(
          Constants.PREF_CURRENT_VERSION, packageInfo.buildNumber);
    }
    if (!Constants.isInDebugMode) {
      final RemoteConfig remoteConfig = await RemoteConfig.instance;
      try {
        await remoteConfig.fetch(
          expiration: const Duration(seconds: 10),
        );
        await remoteConfig.activateFetched();
      } on FetchThrottledException catch (exception) {} catch (exception) {}
      String apiHostLocal =
          Preferences.getString(Constants.API_HOST, Helper.HOST);
      String apiHostRemote = remoteConfig.getString(Constants.API_HOST);
      await Preferences.setString(Constants.API_HOST, apiHostRemote);
      if (apiHostLocal != apiHostRemote) {
        Helper.resetInstance();
        apiHostUpdate();
      }
      String url = "";
      int versionDiff = 0, newVersion;
      if (Platform.isAndroid) {
        url = "market://details?id=${packageInfo.packageName}";
        newVersion = remoteConfig.getInt(Constants.ANDROID_APP_VERSION);
      } else if (Platform.isIOS) {
        url =
            "itms-apps://itunes.apple.com/tw/app/apple-store/id1439751462?mt=8";
        newVersion = remoteConfig.getInt(Constants.IOS_APP_VERSION);
      } else {
        url = "https://www.facebook.com/NKUST.ITC/";
        newVersion = remoteConfig.getInt(Constants.APP_VERSION);
      }
      versionDiff = newVersion - int.parse(packageInfo.buildNumber);
      String versionContent =
          "\nv${newVersion ~/ 10000}.${newVersion % 1000 ~/ 100}.${newVersion % 100}\n";
      switch (AppLocalizations.locale.languageCode) {
        case 'zh':
          versionContent +=
              remoteConfig.getString(Constants.NEW_VERSION_CONTENT_ZH);
          break;
        default:
          versionContent +=
              remoteConfig.getString(Constants.NEW_VERSION_CONTENT_EN);
          break;
      }
      DialogUtils.showNewVersionContent(
        context: context,
        newVersionCode: newVersion,
        appName: app.appName,
        iOSAppId: '1439751462',
        defaultUrl: 'https://www.facebook.com/NKUST.ITC/',
        newVersionContent: versionContent,
      );
    }
  }

  static Future<File> resizeImageByDart(File source) async {
    ImageUtils.Image image = ImageUtils.decodeImage(source.readAsBytesSync());
    double sourceSize = source.lengthSync() / 1024 / 1024;
    double rate = sourceSize / Constants.IMAGE_RESIZE_RATE;
    ImageUtils.Image thumbnail = ImageUtils.copyResize(
      image,
      width: (image.width / rate).ceil(),
      height: (image.height / rate).ceil(),
    );
    Directory appDocDir = await getApplicationDocumentsDirectory();
    File result = File('${appDocDir.path}/proof.jpg')
      ..writeAsBytesSync(ImageUtils.encodeJpg(thumbnail));
    return result;
  }

  static Future<File> resizeImageByNative(File file) async {
    Directory appDocDir = await getTemporaryDirectory();
    String tmpPath = '${appDocDir.path}/proof.jpg';
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      tmpPath,
      quality: 70,
    );
    return result;
  }

  static String parserImageFileType(String last) {
    if (last.contains('jpg') || last.contains('jpeg'))
      return 'jpeg';
    else if (last.contains('png'))
      return 'png';
    else if (last.contains('bmp'))
      return 'bmp';
    else if (last.contains('gif'))
      return 'gif';
    else if (last.contains('ico'))
      return 'vnd.microsoft.icon';
    else if (last.contains('svg'))
      return 'svg+xml';
    else if (last.contains('tif') || last.contains('tiff'))
      return 'tiff';
    else if (last.contains('webp'))
      return 'webp';
    else
      return 'unkwon';
  }
}
