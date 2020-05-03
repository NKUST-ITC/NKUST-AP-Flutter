import 'dart:io';

import 'package:ap_common/models/ap_support_language.dart';
import 'package:ap_common/models/course_data.dart';
import 'package:ap_common/resources/ap_icon.dart';
import 'package:ap_common/resources/ap_theme.dart';
import 'package:ap_common/utils/ap_localizations.dart';
import 'package:ap_common/utils/ap_utils.dart';
import 'package:ap_common/utils/preferences.dart';
import 'package:ap_common/widgets/dialog_option.dart';
import 'package:ap_common/widgets/option_dialog.dart';
import 'package:ap_common/widgets/progress_dialog.dart';
import 'package:ap_common/widgets/setting_page_widgets.dart';
import 'package:app_review/app_review.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/models/bus_reservations_data.dart';
import 'package:nkust_ap/models/item.dart';
import 'package:nkust_ap/models/semester_data.dart';
import 'package:nkust_ap/utils/cache_utils.dart';
import 'package:nkust_ap/utils/global.dart';
import 'package:nkust_ap/widgets/share_data_widget.dart';
import 'package:package_info/package_info.dart';

class SettingPage extends StatefulWidget {
  static const String routerName = "/setting";

  @override
  SettingPageState createState() => SettingPageState();
}

class SettingPageState extends State<SettingPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  ApLocalizations ap;

  String appVersion = "1.0.0";
  bool busNotify = false, courseNotify = false, displayPicture = true;
  bool isOffline = false;

  var autoSendEvent = false;

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
    ap = ApLocalizations.of(context);
    final languageTextList = [
      ApLocalizations.of(context).systemLanguage,
      ApLocalizations.of(context).traditionalChinese,
      ApLocalizations.of(context).english,
    ];
    final themeTextList = [
      ApLocalizations.of(context).systemTheme,
      ApLocalizations.of(context).light,
      ApLocalizations.of(context).dark,
    ];
    final code = Preferences.getString(
        Constants.PREF_LANGUAGE_CODE, ApSupportLanguageConstants.SYSTEM);
    final languageIndex = ApSupportLanguageExtension.fromCode(code);
    final themeModeIndex = ApTheme.of(context).themeMode.index;
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
            SettingSwitch(
              text: ap.courseNotify,
              subText: ap.courseNotifySubTitle,
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
            SettingSwitch(
              text: ap.busNotify,
              subText: ap.busNotifySubTitle,
              value: busNotify,
              onChanged: (b) async {
                FA.logAction('notify_bus', 'create');
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
                FA.logAction('head_photo', 'click');
              },
            ),
            SettingSwitch(
              text: '打卡自動送出',
              subText: '不選擇直接送出目前位置資料',
              value: autoSendEvent,
              onChanged: (b) {
                setState(() {
                  autoSendEvent = !autoSendEvent;
                });
                Preferences.setBool(
                    Constants.PREF_AUTO_SEND_EVENT, autoSendEvent);
                FA.logAction('auto_send_event', 'click');
              },
            ),
            SettingItem(
              text: ap.language,
              subText: languageTextList[languageIndex],
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => SimpleOptionDialog(
                    title: ap.language,
                    items: languageTextList,
                    index: languageIndex,
                    onSelected: (int index) async {
                      Locale locale;
                      String code = ApSupportLanguage.values[index].code;
                      switch (index) {
                        case 0:
                          locale = Localizations.localeOf(context);
                          break;
                        default:
                          locale = Locale(
                            code,
                            code == ApSupportLanguageConstants.ZH ? 'TW' : null,
                          );
                          break;
                      }
                      Preferences.setString(Constants.PREF_LANGUAGE_CODE, code);
                      ShareDataWidget.of(context).data.loadLocale(locale);
//                      FirebaseAnalyticsUtils.instance.logAction(
//                        'change_language',
//                        code,
//                      );
//                      FirebaseAnalyticsUtils.instance.setUserProperty(
//                        FirebaseConstants.LANGUAGE,
//                        AppLocalizations.locale.languageCode,
//                      );
                    },
                  ),
                );
              },
            ),
            SettingItem(
              text: ap.iconStyle,
              subText: ap.iconText,
              onTap: () {
                showDialog<int>(
                  context: context,
                  builder: (_) => SimpleDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(16),
                        ),
                      ),
                      title: Text(ap.iconStyle),
                      children: [
                        for (var item in [
                          Item(ap.outlined, ApIcon.OUTLINED),
                          Item(ap.filled, ApIcon.FILLED),
                        ])
                          DialogOption(
                              text: item.text,
                              check: ApIcon.code == item.value,
                              onPressed: () {
                                if (ApIcon.code != item.value)
                                  FA.logAction('change_icon_style', item.value);
                                setState(() {
                                  ApIcon.code = item.value;
                                });
                                Preferences.setString(
                                    Constants.PREF_ICON_STYLE_CODE, item.value);
                                Navigator.pop(context);
                              }),
                      ]),
                ).then<void>((int position) {});
                FA.logAction('pick_icon_style', 'click');
              },
            ),
            SettingItem(
              text: ap.theme,
              subText: themeTextList[themeModeIndex],
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => SimpleOptionDialog(
                    title: ap.theme,
                    items: themeTextList,
                    index: themeModeIndex,
                    onSelected: (int index) {
                      Preferences.getInt(
                        Constants.PREF_THEME_MODE_INDEX,
                        index,
                      );
                      ShareDataWidget.of(context)
                          .data
                          .update(ThemeMode.values[index]);
                      Preferences.setInt(
                          Constants.PREF_THEME_MODE_INDEX, index);
//                      FirebaseAnalyticsUtils.instance.logAction(
//                        'change_theme',
//                        ThemeMode.values[index].toString(),
//                      );
                    },
                  ),
                );
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
                            ApUtils.showToast(context, ap.platformError));
                  }
                  FA.logAction('feedback', 'click');
                }),
            SettingItem(
                text: ap.appVersion,
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
    PackageInfo packageInfo;
    if (kIsWeb) {
    } else if (Platform.isAndroid || Platform.isIOS)
      packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      isOffline = Preferences.getBool(Constants.PREF_IS_OFFLINE_LOGIN, false);
      appVersion = packageInfo?.version ?? '1.0.0';
      courseNotify = Preferences.getBool(Constants.PREF_COURSE_NOTIFY, false);
      displayPicture =
          Preferences.getBool(Constants.PREF_DISPLAY_PICTURE, true);
      busNotify = Preferences.getBool(Constants.PREF_BUS_NOTIFY, false);
      autoSendEvent =
          Preferences.getBool(Constants.PREF_AUTO_SEND_EVENT, false);
    });
  }

  void _setupCourseNotify(BuildContext context) async {
    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(ap.loading),
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
          ApUtils.showToast(context, ap.noOfflineData);
        }
      } else {
        setState(() {
          courseNotify = false;
          Preferences.setBool(Constants.PREF_COURSE_NOTIFY, courseNotify);
        });
        ApUtils.showToast(context, ap.noOfflineData);
      }
      return;
    }
    Helper.instance.getSemester().then((SemesterData semesterData) {
      Helper.instance
          .getCourseTables(semesterData.defaultSemester.year,
              semesterData.defaultSemester.value)
          .then((CourseData courseData) {
        if (Navigator.canPop(context))
          Navigator.of(context, rootNavigator: true).pop();
        _setCourseData(courseData);
      }).catchError((e) {
        setState(() {
          courseNotify = false;
          Preferences.setBool(Constants.PREF_COURSE_NOTIFY, courseNotify);
        });
        if (e is DioError) {
          switch (e.type) {
            case DioErrorType.RESPONSE:
              Utils.handleResponseError(context, 'getCourseTables', mounted, e);
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
    try {
      if (courseData == null) {
        ApUtils.showToast(context, ap.courseNotifyEmpty);
      } else {
        await Utils.setCourseNotify(context, courseData.courseTables);
        ApUtils.showToast(context, ap.courseNotifyHint);
      }
    } on Exception catch (e) {
      ApUtils.showToast(context, ap.courseNotifyError);
      setState(() {
        courseNotify = false;
        Preferences.setBool(Constants.PREF_COURSE_NOTIFY, courseNotify);
      });
      throw e;
    }
  }

  _setupBusNotify(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) => ProgressDialog(ap.loading),
      barrierDismissible: false,
    );
    if (isOffline) {
      BusReservationsData response = await CacheUtils.loadBusReservationsData();
      if (Navigator.canPop(context))
        Navigator.of(context, rootNavigator: true).pop();
      if (response == null) {
        setState(() {
          busNotify = false;
        });
        ApUtils.showToast(context, ap.noOfflineData);
      } else {
        await Utils.setBusNotify(context, response.reservations);
        ApUtils.showToast(context, ap.busNotifyHint);
      }
      return;
    }
    Helper.instance
        .getBusReservations()
        .then((BusReservationsData response) async {
      if (Navigator.canPop(context))
        Navigator.of(context, rootNavigator: true).pop();
      if (response != null) {
        await Utils.setBusNotify(context, response.reservations);
      }
      ApUtils.showToast(context, ap.busNotifyHint);
    }).catchError((e) {
      setState(() {
        busNotify = false;
      });
      Preferences.setBool(Constants.PREF_BUS_NOTIFY, busNotify);
      if (Navigator.canPop(context))
        Navigator.of(context, rootNavigator: true).pop();
      if (e is DioError) {
        switch (e.type) {
          case DioErrorType.RESPONSE:
            Utils.handleResponseError(
                context, 'getBusReservations', mounted, e);
            break;
          case DioErrorType.DEFAULT:
            if (e.message.contains("HttpException")) {
              ApUtils.showToast(context, ap.busFailInfinity);
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
                  ap.ratingDialogTitle,
                  style: TextStyle(
                      color: ApTheme.of(context).blueText, fontSize: 20.0),
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
                    TextSpan(text: ap.ratingDialogContent),
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
                    ap.later,
                    style: TextStyle(
                        color: ApTheme.of(context).blue, fontSize: 16.0),
                  ),
                ),
                FlatButton(
                  onPressed: () {
                    AppReview.requestReview;
                  },
                  child: Text(
                    ap.rateNow,
                    style: TextStyle(
                        color: ApTheme.of(context).blue, fontSize: 16.0),
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
