import 'dart:io';

import 'package:app_review/app_review.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/models/bus_reservations_data.dart';
import 'package:nkust_ap/models/course_data.dart';
import 'package:nkust_ap/models/item.dart';
import 'package:nkust_ap/models/semester_data.dart';
import 'package:nkust_ap/res/app_icon.dart';
import 'package:nkust_ap/res/app_theme.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;
import 'package:nkust_ap/utils/cache_utils.dart';
import 'package:nkust_ap/utils/global.dart';
import 'package:nkust_ap/utils/preferences.dart';
import 'package:nkust_ap/widgets/dialog_option.dart';
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
            _title(text: app.notificationItem),
            _switch(
              text: app.courseNotify,
              subText: app.courseNotifySubTitle,
              value: courseNotify,
              onChanged: (b) async {
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
            _switch(
              text: app.busNotify,
              subText: app.busNotifySubTitle,
              value: busNotify,
              onChanged: (b) async {
                FA.logAction('notify_bus', 'create');
                bool bus = Preferences.getBool(Constants.PREF_BUS_ENABLE, true);
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
            _title(text: app.otherSettings),
            _switch(
              text: app.headPhotoSetting,
              subText: app.headPhotoSettingSubTitle,
              value: displayPicture,
              onChanged: (b) {
                setState(() {
                  displayPicture = !displayPicture;
                });
                Preferences.setBool(
                    Constants.PREF_DISPLAY_PICTURE, displayPicture);
                FA.logAction('head_photo', 'click');
              },
            ),
            _item(
              text: app.language,
              subText: app.localeText,
              onTap: () {
                showDialog<int>(
                  context: context,
                  builder: (BuildContext context) => SimpleDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(16),
                        ),
                      ),
                      title: Text(app.choseLanguageTitle),
                      children: [
                        for (var item in [
                          Item(app.systemLanguage, AppLocalizations.SYSTEM),
                          Item(app.traditionalChinese, AppLocalizations.ZH),
                          Item(app.english, AppLocalizations.EN),
                        ])
                          DialogOption(
                              text: item.text,
                              check:
                                  AppLocalizations.languageCode == item.value,
                              onPressed: () {
                                AppLocalizations.locale =
                                    (item.value == AppLocalizations.SYSTEM)
                                        ? Localizations.localeOf(context)
                                        : Locale(item.value);
                                if (AppLocalizations.languageCode != item.value)
                                  FA.logAction('change_language', item.value);
                                setState(() {
                                  AppLocalizations.languageCode = item.value;
                                });
                                if (Platform.isAndroid || Platform.isIOS) {
                                  Preferences.setString(
                                      Constants.PREF_LANGUAGE_CODE, item.value);
                                }
                                Navigator.pop(context);
                              }),
                      ]),
                ).then<void>((int position) {});
                FA.logAction('pick_language', 'click');
              },
            ),
            _item(
              text: app.iconStyle,
              subText: app.iconText,
              onTap: () {
                showDialog<int>(
                  context: context,
                  builder: (_) => SimpleDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(16),
                        ),
                      ),
                      title: Text(app.iconStyle),
                      children: [
                        for (var item in [
                          Item(app.outlined, AppIcon.OUTLINED),
                          Item(app.filled, AppIcon.FILLED),
                        ])
                          DialogOption(
                              text: item.text,
                              check: AppIcon.code == item.value,
                              onPressed: () {
                                if (AppIcon.code != item.value)
                                  FA.logAction('change_icon_style', item.value);
                                setState(() {
                                  AppIcon.code = item.value;
                                });
                                if (Platform.isAndroid || Platform.isIOS)
                                  Preferences.setString(
                                      Constants.PREF_ICON_STYLE_CODE,
                                      item.value);
                                Navigator.pop(context);
                              }),
                      ]),
                ).then<void>((int position) {});
                FA.logAction('pick_icon_style', 'click');
              },
            ),
            _item(
              text: app.theme,
              subText: app.themeText,
              onTap: () {
                showDialog<int>(
                  context: context,
                  builder: (_) => SimpleDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(16),
                        ),
                      ),
                      title: Text(app.theme),
                      children: [
                        for (var item in [
                          Item(app.light, AppTheme.LIGHT),
                          Item(app.dark, AppTheme.DARK),
                        ])
                          DialogOption(
                              text: item.text,
                              check: AppTheme.code == item.value,
                              onPressed: () {
                                if (AppTheme.code != item.value)
                                  FA.logAction('change_theme', item.value);
                                setState(() {
                                  AppTheme.code = item.value;
                                  ShareDataWidget.of(context)
                                      .data
                                      .setThemeData(AppTheme.data);
                                });
                                if (Platform.isAndroid || Platform.isIOS)
                                  Preferences.setString(
                                      Constants.PREF_THEME_CODE, item.value);
                                Navigator.pop(context);
                              }),
                      ]),
                ).then<void>((int position) {});
                FA.logAction('pick_theme', 'click');
              },
            ),
            Divider(
              color: Colors.grey,
              height: 0.5,
            ),
            _title(text: app.otherInfo),
            _item(
                text: app.feedback,
                subText: app.feedbackViaFacebook,
                onTap: () {
                  if (Platform.isAndroid)
                    Utils.launchUrl(Constants.FANS_PAGE_URL_SCHEME_ANDROID)
                        .catchError((onError) =>
                            Utils.launchUrl(Constants.FANS_PAGE_URL));
                  else if (Platform.isIOS)
                    Utils.launchUrl(Constants.FANS_PAGE_URL_SCHEME_IOS)
                        .catchError((onError) =>
                            Utils.launchUrl(Constants.FANS_PAGE_URL));
                  else {
                    Utils.launchUrl(Constants.FANS_PAGE_URL).catchError(
                        (onError) =>
                            Utils.showToast(context, app.platformError));
                  }
                  FA.logAction('feedback', 'click');
                }),
            _item(
                text: app.donateTitle,
                subText: app.donateContent,
                onTap: () {
                  Utils.launchUrl(Constants.DONATE_URL).catchError(
                      (onError) => Utils.showToast(context, app.platformError));
                  FA.logAction('donate', 'click');
                }),
            _item(
                text: app.appVersion,
                subText: "v$appVersion",
                onTap: () {
                  FA.logAction('app_version', 'click');
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

  Widget _title({@required String text}) => Padding(
        padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
        child: Text(
          text,
          style: TextStyle(color: Resource.Colors.blueText, fontSize: 14.0),
          textAlign: TextAlign.start,
        ),
      );

  Widget _switch({
    @required String text,
    @required String subText,
    @required bool value,
    @required Function onChanged,
  }) =>
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
        onChanged: onChanged,
        activeColor: Resource.Colors.blueAccent,
      );

  Widget _item({
    @required String text,
    @required String subText,
    @required Function onTap,
  }) =>
      ListTile(
        title: Text(
          text,
          style: TextStyle(fontSize: 16.0),
        ),
        subtitle: Text(
          subText,
          style: TextStyle(fontSize: 14.0, color: Resource.Colors.greyText),
        ),
        onTap: onTap,
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
