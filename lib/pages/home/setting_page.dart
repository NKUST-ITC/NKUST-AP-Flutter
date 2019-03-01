import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/models/bus_reservations_data.dart';
import 'package:nkust_ap/models/course_data.dart';
import 'package:nkust_ap/models/semester_data.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;
import 'package:nkust_ap/utils/global.dart';
import 'package:nkust_ap/widgets/progress_dialog.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingPageRoute extends MaterialPageRoute {
  SettingPageRoute()
      : super(builder: (BuildContext context) => new SettingPage());

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return new FadeTransition(opacity: animation, child: new SettingPage());
  }
}

class SettingPage extends StatefulWidget {
  static const String routerName = "/setting";

  @override
  SettingPageState createState() => new SettingPageState();
}

class SettingPageState extends State<SettingPage>
    with SingleTickerProviderStateMixin {
  SharedPreferences prefs;

  var busNotify = false, courseNotify = false, displayPicture = true;

  AppLocalizations app;

  String appVersion = "1.0.0";

  @override
  void initState() {
    super.initState();
    FA.setCurrentScreen("SettingPage", "setting_page.dart");
    _getPreference();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    app = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(app.settings),
        backgroundColor: Resource.Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _titleItem(app.notificationItem),
              _itemSwitch(app.courseNotify, courseNotify, () async {
                if (!courseNotify)
                  _setupCourseNotify(context);
                else {
                  await Utils.cancelCourseNotify();
                }
                setState(() {
                  courseNotify = !courseNotify;
                });
                prefs.setBool(Constants.PREF_COURSE_NOTIFY, courseNotify);
              }),
              _itemSwitch(app.busNotify, busNotify, () async {
                bool bus = prefs.getBool(Constants.PREF_BUS_ENABLE) ?? true;
                if (bus) {
                  if (!busNotify)
                    _setupBusNotify(context);
                  else {
                    await Utils.cancelBusNotify();
                  }
                  setState(() {
                    busNotify = !busNotify;
                  });
                  prefs.setBool(Constants.PREF_BUS_NOTIFY, busNotify);
                } else {
                  Utils.showToast(app.canNotUseBus);
                }
              }),
              Container(
                color: Colors.grey,
                height: 0.5,
              ),
              _titleItem(app.otherSettings),
              _itemSwitch(app.headPhotoSetting, displayPicture, () {
                displayPicture = !displayPicture;
                prefs.setBool(Constants.PREF_DISPLAY_PICTURE, displayPicture);
                setState(() {});
              }),
              Container(
                color: Colors.grey,
                height: 0.5,
              ),
              _titleItem(app.otherInfo),
              _item(app.feedback, app.feedbackViaFacebook, () {
                if (Platform.isAndroid)
                  Utils.launchUrl('fb://messaging/954175941266264').catchError(
                      (onError) => Utils.launchUrl(
                          'https://www.facebook.com/954175941266264/'));
                else
                  Utils.launchUrl('https://www.facebook.com/954175941266264/');
              }),
              _item(app.donateTitle, app.donateContent, () {
                Utils.launchUrl(
                    "https://payment.ecpay.com.tw/QuickCollect/PayData?mLM7iy8RpUGk%2fyBotSDMdvI0qGI5ToToqBW%2bOQbOE80%3d");
              }),
              _item(app.appVersion, "v$appVersion", () {}),
            ]),
      ),
    );
  }

  _titleItem(String text) => Container(
        padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
        child: Text(
          text,
          style: TextStyle(color: Resource.Colors.blue, fontSize: 14.0),
          textAlign: TextAlign.start,
        ),
      );

  _itemSwitch(String text, bool value, Function function) => FlatButton(
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              text,
              style: TextStyle(fontSize: 16.0),
            ),
            Switch(
              value: value,
              activeColor: Resource.Colors.blue,
              activeTrackColor: Resource.Colors.blue,
              onChanged: (b) {
                function();
              },
            ),
          ],
        ),
        onPressed: function,
      );

  _getPreference() async {
    prefs = await SharedPreferences.getInstance();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appVersion = packageInfo.version;
    courseNotify = prefs.getBool(Constants.PREF_COURSE_NOTIFY) ?? false;
    displayPicture = prefs.getBool(Constants.PREF_DISPLAY_PICTURE) ?? true;
    busNotify = prefs.getBool(Constants.PREF_BUS_NOTIFY) ?? false;
    setState(() {});
  }

  _item(String text, String subText, Function function) => FlatButton(
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Container(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                text,
                style: TextStyle(fontSize: 16.0),
              ),
              Text(
                subText,
                style: TextStyle(fontSize: 14.0, color: Resource.Colors.grey),
              ),
            ],
          ),
        ),
        onPressed: function,
      );

  void _setupCourseNotify(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(app.loading),
        barrierDismissible: false);
    Helper.instance.getSemester().then((SemesterData semesterData) {
      var textList = semesterData.defaultSemester.value.split(",");
      if (textList.length == 2) {
        Helper.instance
            .getCourseTables(textList[0], textList[1])
            .then((CourseData courseData) async {
          switch (courseData.status) {
            case 200:
              await Utils.setCourseNotify(context, courseData.courseTables);
              Utils.showToast(app.courseNotifyHint);
              break;
            case 204:
              Utils.showToast(app.courseNotifyEmpty);
              break;
            default:
              Utils.showToast(app.courseNotifyError);
              break;
          }
          if (courseData.status != 200) {
            setState(() {
              busNotify = false;
              prefs.setBool(Constants.PREF_BUS_NOTIFY, busNotify);
            });
          }
          if (Navigator.canPop(context)) Navigator.pop(context, 'dialog');
        }).catchError((e) {
          setState(() {
            busNotify = false;
            prefs.setBool(Constants.PREF_BUS_NOTIFY, busNotify);
          });
          if (e is DioError) {
            switch (e.type) {
              case DioErrorType.RESPONSE:
                Utils.handleResponseError(context, mounted, e);
                break;
              case DioErrorType.CANCEL:
                break;
              default:
                Utils.handleDioError(e, app);
                break;
            }
          } else {
            throw e;
          }
        });
      }
    }).catchError((e) {
      setState(() {
        busNotify = false;
        prefs.setBool(Constants.PREF_BUS_NOTIFY, busNotify);
      });
      if (e is DioError) {
        switch (e.type) {
          case DioErrorType.RESPONSE:
            Utils.handleResponseError(context, mounted, e);
            break;
          case DioErrorType.CANCEL:
            break;
          default:
            Utils.handleDioError(e, app);
            break;
        }
      } else {
        throw e;
      }
    });
  }

  _setupBusNotify(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(app.loading),
        barrierDismissible: false);
    Helper.instance
        .getBusReservations()
        .then((BusReservationsData response) async {
      await Utils.setBusNotify(context, response.reservations);
      Utils.showToast(app.busNotifyHint);
      if (Navigator.canPop(context)) Navigator.pop(context, 'dialog');
    }).catchError((e) {
      setState(() {
        busNotify = false;
        prefs.setBool(Constants.PREF_BUS_NOTIFY, busNotify);
      });
      if (Navigator.canPop(context)) Navigator.pop(context, 'dialog');
      if (e is DioError) {
        switch (e.type) {
          case DioErrorType.RESPONSE:
            Utils.handleResponseError(context, mounted, e);
            break;
          case DioErrorType.DEFAULT:
            if (e.message.contains("HttpException")) {
              Utils.showToast(app.busFailInfinity);
            }
            break;
          case DioErrorType.CANCEL:
            break;
          default:
            break;
        }
      } else {
        throw e;
      }
    });
  }
}
