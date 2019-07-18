import 'dart:io';

import 'package:app_review/app_review.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/models/bus_reservations_data.dart';
import 'package:nkust_ap/models/course_data.dart';
import 'package:nkust_ap/models/semester_data.dart';
import 'package:nkust_ap/res/app_theme.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;
import 'package:nkust_ap/utils/cache_utils.dart';
import 'package:nkust_ap/utils/global.dart';
import 'package:nkust_ap/utils/preferences.dart';
import 'package:nkust_ap/widgets/progress_dialog.dart';
import 'package:nkust_ap/widgets/share_data_widget.dart';
import 'package:package_info/package_info.dart';

class SettingPageRoute extends MaterialPageRoute {
  SettingPageRoute()
      : super(
          builder: (BuildContext context) => SettingPage(),
        );

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return FadeTransition(
      opacity: animation,
      child: SettingPage(),
    );
  }
}

class SettingPage extends StatefulWidget {
  static const String routerName = "/setting";

  @override
  SettingPageState createState() => SettingPageState();
}

class SettingPageState extends State<SettingPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  AppLocalizations app;

  String appVersion = "1.0.0";
  bool busNotify = false, courseNotify = false, displayPicture = true;
  bool isOffline = false;

  @override
  void initState() {
    FA.setCurrentScreen("SettingPage", "setting_page.dart");
    _getPreference();
    Utils.showAppReviewDialog(context);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    app = AppLocalizations.of(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(app.settings),
        backgroundColor: Resource.Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _titleItem(app.notificationItem),
            _itemSwitch(
              app.courseNotify,
              app.courseNotifySubTitle,
              courseNotify,
              (b) async {
                FA.logAction('notify_course', 'create');
                setState(() {
                  courseNotify = !courseNotify;
                });
                if (courseNotify)
                  _setupCourseNotify(context);
                else {
                  await Utils.cancelCourseNotify();
                }
                FA.logAction('notify_course', 'create',
                    message: '$courseNotify');
                Preferences.setBool(Constants.PREF_COURSE_NOTIFY, courseNotify);
              },
            ),
            _itemSwitch(
              app.busNotify,
              app.busNotifySubTitle,
              busNotify,
              (b) async {
                FA.logAction('notify_bus', 'create');
                bool bus =
                    await Preferences.getBool(Constants.PREF_BUS_ENABLE, true);
                if (bus) {
                  setState(() {
                    busNotify = !busNotify;
                  });
                  if (busNotify)
                    _setupBusNotify(context);
                  else {
                    await Utils.cancelBusNotify();
                  }
                  Preferences.setBool(Constants.PREF_BUS_NOTIFY, busNotify);
                  FA.logAction('notify_bus', 'click', message: '$busNotify');
                } else {
                  Utils.showToast(context, app.canNotUseFeature);
                  FA.logAction('notify_bus', 'staus',
                      message: 'can\'t use feature');
                }
              },
            ),
            Divider(
              color: Colors.grey,
              height: 0.5,
            ),
            _titleItem(app.otherSettings),
            _itemSwitch(
              app.headPhotoSetting,
              app.headPhotoSettingSubTitle,
              displayPicture,
              (b) {
                setState(() {
                  displayPicture = !displayPicture;
                });
                Preferences.setBool(
                    Constants.PREF_DISPLAY_PICTURE, displayPicture);
                FA.logAction('head_photo', 'click');
              },
            ),
            _item(
              app.language,
              app.localeText,
              () {
                Utils.showChoseLanguageDialog(context, (languageCode) {
                  setState(() {
                    AppLocalizations.languageCode = languageCode;
                  });
                });
                FA.logAction('pick_language', 'click');
              },
            ),
            _item(
              app.theme,
              app.themeText,
              () {
                showDialog<int>(
                  context: context,
                  builder: (BuildContext context) => SimpleDialog(
                      title: Text(app.theme),
                      children: <SimpleDialogOption>[
                        SimpleDialogOption(
                            child: Text(app.light),
                            onPressed: () {
                              AppTheme.code = AppTheme.LIGHT;
                              ShareDataWidget.of(context)
                                  .data
                                  .setThemeData(AppTheme.light);
                              setState(() {
                                AppLocalizations.themeCode = AppTheme.LIGHT;
                              });
                              if (Platform.isAndroid || Platform.isIOS)
                                Preferences.setString(
                                    Constants.PREF_THEME_CODE, AppTheme.LIGHT);
                              Navigator.pop(context);
                            }),
                        SimpleDialogOption(
                            child: Text(app.dark),
                            onPressed: () {
                              AppTheme.code = AppTheme.DARK;
                              ShareDataWidget.of(context)
                                  .data
                                  .setThemeData(AppTheme.dark);
                              setState(() {
                                AppLocalizations.themeCode = AppTheme.DARK;
                              });
                              if (Platform.isAndroid || Platform.isIOS)
                                Preferences.setString(
                                    Constants.PREF_THEME_CODE, AppTheme.DARK);
                              Navigator.pop(context);
                            })
                      ]),
                ).then<void>((int position) {});
                FA.logAction('pick_theme', 'click');
              },
            ),
            Divider(
              color: Colors.grey,
              height: 0.5,
            ),
            _titleItem(app.otherInfo),
            _item(app.feedback, app.feedbackViaFacebook, () {
              if (Platform.isAndroid)
                Utils.launchUrl('fb://messaging/${Constants.FANS_PAGE_ID}')
                    .catchError((onError) => Utils.launchUrl(
                        'https://www.facebook.com/${Constants.FANS_PAGE_ID}/'));
              else if (Platform.isIOS)
                Utils.launchUrl(
                        'fb-messenger://user-thread/${Constants.FANS_PAGE_ID}')
                    .catchError((onError) => Utils.launchUrl(
                        'https://www.facebook.com/${Constants.FANS_PAGE_ID}/'));
              else {
                Utils.launchUrl(
                        'https://www.facebook.com/${Constants.FANS_PAGE_ID}/')
                    .catchError((onError) =>
                        Utils.showToast(context, app.platformError));
              }
              FA.logAction('feedback', 'click');
            }),
            _item(app.donateTitle, app.donateContent, () {
              Utils.launchUrl(
                      "https://payment.ecpay.com.tw/QuickCollect/PayData?mLM7iy8RpUGk%2fyBotSDMdvI0qGI5ToToqBW%2bOQbOE80%3d")
                  .catchError(
                      (onError) => Utils.showToast(context, app.platformError));
              FA.logAction('donate', 'click');
            }),
            _item(app.appVersion, "v$appVersion", () {
              //FA.logAction('donate', 'click');
            }),
          ],
        ),
      ),
    );
  }

  _getPreference() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      isOffline = Preferences.getBool(Constants.PREF_IS_OFFLINE_LOGIN, false);
      appVersion = packageInfo.version;
      courseNotify = Preferences.getBool(Constants.PREF_COURSE_NOTIFY, false);
      displayPicture =
          Preferences.getBool(Constants.PREF_DISPLAY_PICTURE, true);
      busNotify = Preferences.getBool(Constants.PREF_BUS_NOTIFY, false);
    });
  }

  Widget _titleItem(String text) => Container(
        padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
        child: Text(
          text,
          style: TextStyle(color: Resource.Colors.blueText, fontSize: 14.0),
          textAlign: TextAlign.start,
        ),
      );

  Widget _itemSwitch(
          String text, String subText, bool value, Function function) =>
      SwitchListTile(
        title: Text(
          text,
          style: TextStyle(fontSize: 16.0),
        ),
        subtitle: Text(
          subText,
          style: TextStyle(fontSize: 14.0, color: Resource.Colors.greyText),
        ),
        value: value,
        onChanged: function,
        activeColor: Resource.Colors.blueAccent,
      );

  Widget _item(String text, String subText, Function function) => ListTile(
        title: Text(
          text,
          style: TextStyle(fontSize: 16.0),
        ),
        subtitle: Text(
          subText,
          style: TextStyle(fontSize: 14.0, color: Resource.Colors.greyText),
        ),
        onTap: function,
      );

  void _setupCourseNotify(BuildContext context) async {
    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(app.loading),
        barrierDismissible: false);
    if (isOffline) {
      if (Navigator.canPop(context)) Navigator.pop(context, 'dialog');
      SemesterData semesterData = await CacheUtils.loadSemesterData();
      if (semesterData != null) {
        CourseData courseData =
            await CacheUtils.loadCourseData(semesterData.defaultSemester.value);
        if (courseData != null)
          _setCourseData(courseData);
        else {
          setState(() {
            courseNotify = false;
            Preferences.setBool(Constants.PREF_COURSE_NOTIFY, courseNotify);
          });
          Utils.showToast(context, app.noOfflineData);
        }
      } else {
        setState(() {
          courseNotify = false;
          Preferences.setBool(Constants.PREF_COURSE_NOTIFY, courseNotify);
        });
        Utils.showToast(context, app.noOfflineData);
      }
      return;
    }
    Helper.instance.getSemester().then((SemesterData semesterData) {
      var textList = semesterData.defaultSemester.value.split(",");
      if (textList.length == 2) {
        Helper.instance
            .getCourseTables(textList[0], textList[1])
            .then((CourseData courseData) {
          if (Navigator.canPop(context)) Navigator.pop(context, 'dialog');
          _setCourseData(courseData);
        }).catchError((e) {
          setState(() {
            courseNotify = false;
            Preferences.setBool(Constants.PREF_COURSE_NOTIFY, courseNotify);
          });
          if (e is DioError) {
            switch (e.type) {
              case DioErrorType.RESPONSE:
                Utils.handleResponseError(
                    context, 'getCourseTables', mounted, e);
                break;
              case DioErrorType.CANCEL:
                break;
              default:
                Utils.handleDioError(context, e);
                break;
            }
          } else {
            throw e;
          }
        });
      }
    }).catchError((e) {
      setState(() {
        courseNotify = false;
      });
      Preferences.setBool(Constants.PREF_COURSE_NOTIFY, courseNotify);
      if (e is DioError) {
        switch (e.type) {
          case DioErrorType.RESPONSE:
            Utils.handleResponseError(context, 'getSemester', mounted, e);
            break;
          case DioErrorType.CANCEL:
            break;
          default:
            Utils.handleDioError(context, e);
            break;
        }
      } else {
        throw e;
      }
    });
  }

  _setCourseData(CourseData courseData) async {
    switch (courseData.status) {
      case 200:
        await Utils.setCourseNotify(context, courseData.courseTables);
        Utils.showToast(context, app.courseNotifyHint);
        break;
      case 204:
        Utils.showToast(context, app.courseNotifyEmpty);
        break;
      default:
        Utils.showToast(context, app.courseNotifyError);
        break;
    }
    if (courseData.status != 200) {
      setState(() {
        courseNotify = false;
        Preferences.setBool(Constants.PREF_COURSE_NOTIFY, courseNotify);
      });
    }
  }

  _setupBusNotify(BuildContext context) async {
    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(app.loading),
        barrierDismissible: false);
    if (isOffline) {
      BusReservationsData response = await CacheUtils.loadBusReservationsData();
      if (Navigator.canPop(context)) Navigator.pop(context, 'dialog');
      if (response == null) {
        setState(() {
          busNotify = false;
        });
        Utils.showToast(context, app.noOfflineData);
      } else {
        await Utils.setBusNotify(context, response.reservations);
        Utils.showToast(context, app.busNotifyHint);
      }
      return;
    }
    Helper.instance
        .getBusReservations()
        .then((BusReservationsData response) async {
      await Utils.setBusNotify(context, response.reservations);
      Utils.showToast(context, app.busNotifyHint);
      if (Navigator.canPop(context)) Navigator.pop(context, 'dialog');
    }).catchError((e) {
      setState(() {
        busNotify = false;
      });
      Preferences.setBool(Constants.PREF_BUS_NOTIFY, busNotify);
      if (Navigator.canPop(context)) Navigator.pop(context, 'dialog');
      if (e is DioError) {
        switch (e.type) {
          case DioErrorType.RESPONSE:
            Utils.handleResponseError(
                context, 'getBusReservations', mounted, e);
            break;
          case DioErrorType.DEFAULT:
            if (e.message.contains("HttpException")) {
              Utils.showToast(context, app.busFailInfinity);
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

  _showBottomSheet(BuildContext context) async {
    _scaffoldKey.currentState.showBottomSheet<Null>((context) {
      return Material(
        elevation: 20,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  app.ratingDialogTitle,
                  style: TextStyle(
                      color: Resource.Colors.blueText, fontSize: 20.0),
                ),
              ),
            ),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                  style: TextStyle(
                      color: Resource.Colors.grey, height: 1.3, fontSize: 18.0),
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
                    style:
                        TextStyle(color: Resource.Colors.blue, fontSize: 16.0),
                  ),
                ),
                FlatButton(
                  onPressed: () {
                    AppReview.requestReview;
                  },
                  child: Text(
                    app.rateNow,
                    style:
                        TextStyle(color: Resource.Colors.blue, fontSize: 16.0),
                  ),
                ),
              ],
            )
          ],
        ),
      );
    });
  }
}
