import 'dart:convert';
import 'dart:math';

import 'package:ap_common/api/announcement_helper.dart';
import 'package:ap_common/api/imgur_helper.dart';
import 'package:ap_common/callback/general_callback.dart';
import 'package:ap_common/models/user_info.dart';
import 'package:ap_common/pages/announcement/home_page.dart';
import 'package:ap_common/pages/announcement_content_page.dart';
import 'package:ap_common/pages/about_us_page.dart';
import 'package:ap_common/pages/open_source_page.dart';
import 'package:ap_common/resources/ap_icon.dart';
import 'package:ap_common/resources/ap_theme.dart';
import 'package:ap_common/scaffold/home_page_scaffold.dart';
import 'package:ap_common/utils/ap_localizations.dart';
import 'package:ap_common/utils/ap_utils.dart';
import 'package:ap_common/utils/dialog_utils.dart';
import 'package:ap_common/utils/preferences.dart';
import 'package:ap_common/widgets/ap_drawer.dart';
import 'package:ap_common_firebase/utils/firebase_remote_config_utils.dart';
import 'package:ap_common_firebase/utils/firebase_utils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/api/ap_status_code.dart';
import 'package:nkust_ap/api/inkust_helper.dart';
import 'package:nkust_ap/models/login_response.dart';
import 'package:nkust_ap/models/models.dart';
import 'package:nkust_ap/pages/study/room_list_page.dart';
import 'package:nkust_ap/res/assets.dart';
import 'package:nkust_ap/utils/cache_utils.dart';
import 'package:nkust_ap/utils/global.dart';
import 'package:nkust_ap/widgets/share_data_widget.dart';

import 'study/midterm_alerts_page.dart';
import 'study/reward_and_penalty_page.dart';

class HomePage extends StatefulWidget {
  static const String routerName = "/home";

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final GlobalKey<HomePageScaffoldState> _homeKey =
      GlobalKey<HomePageScaffoldState>();

  bool get isMobile => MediaQuery.of(context).size.shortestSide < 680;

  var state = HomeState.loading;

  AppLocalizations app;
  ApLocalizations ap;

  Widget content;

  List<Announcement> announcements;

  var isLogin = false;
  bool displayPicture = true;
  bool isStudyExpanded = false;
  bool isBusExpanded = false;
  bool isLeaveExpanded = false;

  UserInfo userInfo;

  TextStyle get _defaultStyle => TextStyle(
        color: ApTheme.of(context).grey,
        fontSize: 16.0,
      );

  String get sectionImage {
    final department = userInfo?.department ?? '';
    bool halfSnapFingerChance = Random().nextInt(2000) % 2 == 0;
    if (department.contains('建工') || department.contains('燕巢'))
      return halfSnapFingerChance
          ? ImageAssets.sectionJiangong
          : ImageAssets.sectionYanchao;
    else if (department.contains('第一'))
      return halfSnapFingerChance
          ? ImageAssets.sectionFirst1
          : ImageAssets.sectionFirst2;
    else if (department.contains('旗津') || department.contains('楠梓'))
      return halfSnapFingerChance
          ? ImageAssets.sectionQijin
          : ImageAssets.sectionNanzi;
    else
      return ImageAssets.kuasap2;
  }

  String get drawerIcon {
    switch (ApTheme.of(context).brightness) {
      case Brightness.light:
        return ImageAssets.drawerIconLight;
      case Brightness.dark:
      default:
        return ImageAssets.drawerIconDark;
    }
  }

  static aboutPage(BuildContext context, {String assetImage}) {
    return AboutUsPage(
      assetImage: assetImage ?? ImageAssets.kuasap2,
      githubName: 'NKUST-ITC',
      email: 'abc873693@gmail.com',
      appLicense: AppLocalizations.of(context).aboutOpenSourceContent,
      fbFanPageId: '735951703168873',
      fbFanPageUrl: 'https://www.facebook.com/NKUST.ITC/',
      githubUrl: 'https://github.com/NKUST-ITC',
      logEvent: (name, value) =>
          FirebaseAnalyticsUtils.instance.logAction(name, value),
      setCurrentScreen: () => FirebaseAnalyticsUtils.instance
          .setCurrentScreen("AboutUsPage", "about_us_page.dart"),
      actions: <Widget>[
        IconButton(
          icon: Icon(ApIcon.codeIcon),
          onPressed: () {
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (_) => OpenSourcePage(
                  setCurrentScreen: () => FirebaseAnalyticsUtils.instance
                      .setCurrentScreen(
                          "OpenSourcePage", "open_source_page.dart"),
                ),
              ),
            );
            FirebaseAnalyticsUtils.instance.logAction('open_source', 'click');
          },
        )
      ],
    );
  }

  Future<void> future;

  @override
  void initState() {
    FirebaseAnalyticsUtils.instance
        .setCurrentScreen("HomePage", "home_page.dart");
    future = getData();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    app = AppLocalizations.of(context);
    ap = ApLocalizations.of(context);
    return FutureBuilder(
        future: future,
        builder: (_, __) {
          return HomePageScaffold(
            title: app.appName,
            key: _homeKey,
            state: state,
            announcements: announcements,
            isLogin: isLogin,
            content: content,
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.fiber_new_rounded),
                tooltip: ap.announcementReviewSystem,
                onPressed: () async {
                  ImgurHelper.clientId = 'bf8e32144d00b04';
                  ApUtils.pushCupertinoStyle(
                    context,
                    AnnouncementHomePage(),
                  );
                  if (FirebaseUtils.isSupportCloudMessage) {
                    try {
                      final messaging = FirebaseMessaging.instance;
                      NotificationSettings settings =
                          await messaging.getNotificationSettings();
                      if (settings.authorizationStatus ==
                              AuthorizationStatus.authorized ||
                          settings.authorizationStatus ==
                              AuthorizationStatus.provisional) {
                        String token = await messaging.getToken(
                            vapidKey: Constants.FCM_WEB_VAPID_KEY);
                        AnnouncementHelper.fcmToken = token;
                      }
                    } catch (_) {}
                  }
                },
              ),
            ],
            drawer: ApDrawer(
              userInfo: userInfo,
              displayPicture:
                  Preferences.getBool(Constants.PREF_DISPLAY_PICTURE, true),
              imageAsset: drawerIcon,
              onTapHeader: () {
                if (isLogin) {
                  if (userInfo != null && isLogin)
                    ApUtils.pushCupertinoStyle(
                      context,
                      UserInfoPage(userInfo: userInfo),
                    );
                } else {
                  if (isMobile) Navigator.of(context).pop();
                  openLoginPage();
                }
              },
              widgets: <Widget>[
                if (!isMobile)
                  DrawerItem(
                    icon: ApIcon.home,
                    title: ap.home,
                    onTap: () {
                      setState(() => content = null);
                    },
                  ),
                ExpansionTile(
                  initiallyExpanded: isStudyExpanded,
                  onExpansionChanged: (bool) {
                    setState(() {
                      isStudyExpanded = bool;
                    });
                  },
                  leading: Icon(
                    ApIcon.school,
                    color: isStudyExpanded
                        ? ApTheme.of(context).blueAccent
                        : ApTheme.of(context).grey,
                  ),
                  title: Text(ap.courseInfo, style: _defaultStyle),
                  children: <Widget>[
                    DrawerSubItem(
                      icon: ApIcon.classIcon,
                      title: ap.course,
                      onTap: () => _openPage(
                        CoursePage(),
                        needLogin: true,
                      ),
                    ),
                    DrawerSubItem(
                      icon: ApIcon.assignment,
                      title: ap.score,
                      onTap: () => _openPage(
                        ScorePage(),
                        needLogin: true,
                      ),
                    ),
                    DrawerSubItem(
                      icon: ApIcon.apps,
                      title: ap.calculateUnits,
                      onTap: () => _openPage(
                        CalculateUnitsPage(),
                        needLogin: true,
                      ),
                    ),
                    DrawerSubItem(
                      icon: ApIcon.warning,
                      title: ap.midtermAlerts,
                      onTap: () => _openPage(
                        MidtermAlertsPage(),
                        needLogin: true,
                      ),
                    ),
                    DrawerSubItem(
                      icon: ApIcon.folder,
                      title: ap.rewardAndPenalty,
                      onTap: () => _openPage(
                        RewardAndPenaltyPage(),
                        needLogin: true,
                      ),
                    ),
                    DrawerSubItem(
                      icon: ApIcon.room,
                      title: ap.classroomCourseTableSearch,
                      onTap: () => _openPage(RoomListPage()),
                    ),
                  ],
                ),
                ExpansionTile(
                  initiallyExpanded: isLeaveExpanded,
                  onExpansionChanged: (bool) {
                    setState(() {
                      isLeaveExpanded = bool;
                    });
                  },
                  leading: Icon(
                    ApIcon.calendarToday,
                    color: isLeaveExpanded
                        ? ApTheme.of(context).blueAccent
                        : ApTheme.of(context).grey,
                  ),
                  title: Text(ap.leave, style: _defaultStyle),
                  children: <Widget>[
                    DrawerSubItem(
                      icon: ApIcon.edit,
                      title: ap.leaveApply,
                      onTap: () => _openPage(
                        LeavePage(initIndex: 0),
                        needLogin: true,
                      ),
                    ),
                    DrawerSubItem(
                      icon: ApIcon.assignment,
                      title: ap.leaveRecords,
                      onTap: () => _openPage(
                        LeavePage(initIndex: 1),
                        needLogin: true,
                      ),
                    ),
                  ],
                ),
                ExpansionTile(
                  initiallyExpanded: isBusExpanded,
                  onExpansionChanged: (bool) {
                    setState(() {
                      isBusExpanded = bool;
                    });
                  },
                  leading: Icon(
                    ApIcon.directionsBus,
                    color: isBusExpanded
                        ? ApTheme.of(context).blueAccent
                        : ApTheme.of(context).grey,
                  ),
                  title: Text(app.bus, style: _defaultStyle),
                  children: <Widget>[
                    DrawerSubItem(
                      icon: ApIcon.dateRange,
                      title: app.busReserve,
                      onTap: () => _openPage(
                        BusPage(initIndex: 0),
                        needLogin: true,
                      ),
                    ),
                    DrawerSubItem(
                      icon: ApIcon.assignment,
                      title: app.busReservations,
                      onTap: () => _openPage(
                        BusPage(initIndex: 1),
                        needLogin: true,
                      ),
                    ),
                    DrawerSubItem(
                      icon: ApIcon.monetizationOn,
                      title: app.busViolationRecords,
                      onTap: () => _openPage(
                        BusPage(initIndex: 2),
                        needLogin: true,
                      ),
                    ),
                  ],
                ),
                DrawerItem(
                  icon: ApIcon.info,
                  title: ap.schoolInfo,
                  onTap: () => _openPage(SchoolInfoPage()),
                ),
                DrawerItem(
                  icon: ApIcon.face,
                  title: ap.about,
                  onTap: () => _openPage(
                    aboutPage(
                      context,
                      assetImage: sectionImage,
                    ),
                  ),
                ),
                DrawerItem(
                  icon: ApIcon.settings,
                  title: ap.settings,
                  onTap: () => _openPage(SettingPage()),
                ),
                if (isLogin)
                  ListTile(
                    leading: Icon(
                      ApIcon.powerSettingsNew,
                      color: ApTheme.of(context).grey,
                    ),
                    onTap: () async {
                      await Preferences.setBool(
                          Constants.PREF_AUTO_LOGIN, false);
                      ShareDataWidget.of(context).data.logout();
                      isLogin = false;
                      userInfo = null;
                      if (isMobile) Navigator.of(context).pop();
                      checkLogin();
                    },
                    title: Text(ap.logout, style: _defaultStyle),
                  ),
              ],
            ),
            onImageTapped: (Announcement announcement) {
              ApUtils.pushCupertinoStyle(
                context,
                AnnouncementContentPage(announcement: announcement),
              );
              String message = announcement.description.length > 12
                  ? announcement.description
                  : announcement.description.substring(0, 12);
              FirebaseAnalyticsUtils.instance.logAction(
                'news_image',
                'click',
                message: message,
              );
            },
            onTabTapped: onTabTapped,
            bottomNavigationBarItems: [
              BottomNavigationBarItem(
                icon: Icon(ApIcon.directionsBus),
                label: app.bus,
              ),
              BottomNavigationBarItem(
                icon: Icon(ApIcon.classIcon),
                label: ap.course,
              ),
              BottomNavigationBarItem(
                icon: Icon(ApIcon.assignment),
                label: ap.score,
              ),
            ],
          );
        });
  }

  void onTabTapped(int index) async {
    if (isLogin) {
      switch (index) {
        case 0:
          ApUtils.pushCupertinoStyle(context, BusPage());
          break;
        case 1:
          ApUtils.pushCupertinoStyle(context, CoursePage());
          break;
        case 2:
          ApUtils.pushCupertinoStyle(context, ScorePage());
          break;
      }
    } else
      ApUtils.showToast(context, ap.notLogin);
  }

  _getAnnouncements() async {
    AnnouncementHelper.instance.getAllAnnouncements(
      callback: GeneralCallback(
        onFailure: (_) => setState(() => state = HomeState.error),
        onError: (_) => setState(() => state = HomeState.error),
        onSuccess: (List<Announcement> data) {
          announcements = data;
          if (mounted)
            setState(() {
              if (announcements == null || announcements.length == 0)
                state = HomeState.empty;
              else
                state = HomeState.finish;
            });
        },
      ),
    );
  }

  _setupBusNotify(BuildContext context) async {
    if (Preferences.getBool(Constants.PREF_BUS_NOTIFY, false))
      Helper.instance.getBusReservations(
        callback: GeneralCallback(
          onSuccess: (BusReservationsData response) async {
            if (response != null)
              await Utils.setBusNotify(context, response.reservations);
          },
          onFailure: (DioError e) {
            if (e.hasResponse)
              FirebaseAnalyticsUtils.instance.logApiEvent(
                  'getBusReservations', e.response.statusCode,
                  message: e.message);
          },
          onError: (GeneralResponse e) => null,
        ),
      );
  }

  _getUserInfo() async {
    if (Preferences.getBool(Constants.PREF_IS_OFFLINE_LOGIN, false)) {
      userInfo = UserInfo.load(Helper.username);
    } else
      Helper.instance.getUsersInfo(
        callback: GeneralCallback(
          onSuccess: (UserInfo data) {
            if (mounted) {
              setState(() {
                this.userInfo = data;
              });
              FirebaseAnalyticsUtils.instance.logUserInfo(userInfo);
              userInfo.save(Helper.username);
              if (Preferences.getBool(Constants.PREF_DISPLAY_PICTURE, true))
                _getUserPicture();
            }
          },
          onFailure: (DioError e) {
            if (e.hasResponse)
              FirebaseAnalyticsUtils.instance.logApiEvent(
                  'getUserInfo', e.response.statusCode,
                  message: e.message);
          },
          onError: (GeneralResponse e) => null,
        ),
      );
  }

  _getUserPicture() async {
    try {
      if ((userInfo?.pictureUrl) == null) return;
      var response = await http.get(userInfo.pictureUrl);
      if (!response.body.contains('html')) {
        if (mounted) {
          setState(() {
            userInfo.pictureBytes = response.bodyBytes;
          });
        }
        CacheUtils.savePictureData(response.bodyBytes);
      } else {
        var bytes = await CacheUtils.loadPictureData();
        if (mounted) {
          setState(() {
            userInfo.pictureBytes = bytes;
          });
        }
      }
    } catch (e) {
      throw e;
    }
  }

  void _showInformationDialog() {
    FirebaseAnalyticsUtils.instance.logAction('news_rule', 'click');
    DialogUtils.showAnnouncementRule(
      context: context,
      onRightButtonClick: () {
        ApUtils.launchFbFansPage(context, Constants.FANS_PAGE_ID);
        FirebaseAnalyticsUtils.instance.logAction('contact_fans_page', 'click');
      },
    );
  }

  Future _login() async {
    await Future.delayed(Duration(microseconds: 30));
    var username = Preferences.getString(Constants.PREF_USERNAME, '');
    var password = Preferences.getStringSecurity(Constants.PREF_PASSWORD, '');
    Helper.instance.login(
      username: username,
      password: password,
      callback: GeneralCallback(
        onSuccess: (LoginResponse response) {
          ShareDataWidget.of(context).data.loginResponse = response;
          isLogin = true;
          Preferences.setBool(Constants.PREF_IS_OFFLINE_LOGIN, false);
          _getUserInfo();
          _setupBusNotify(context);
          if (state != HomeState.finish) {
            _getAnnouncements();
          }
          _homeKey.currentState.showBasicHint(text: ap.loginSuccess);
        },
        onFailure: (DioError e) {
          final text = ApLocalizations.of(context).dioError(e);
          _homeKey.currentState.showSnackBar(
            text: text,
            actionText: ap.retry,
            onSnackBarTapped: _login,
          );
          Preferences.setBool(Constants.PREF_IS_OFFLINE_LOGIN, true);
          ApUtils.showToast(context, ap.loadOfflineData);
          isLogin = true;
        },
        onError: (GeneralResponse response) {
          String message = '';
          switch (response.statusCode) {
            case ApStatusCode.SCHOOL_SERVER_ERROR:
              message = ap.schoolServerError;
              break;
            case ApStatusCode.API_SERVER_ERROR:
              message = ap.apiServerError;
              break;
            case ApStatusCode.USER_DATA_ERROR:
              message = ap.loginFail;
              break;
            default:
              message = ap.somethingError;
              break;
          }
          _homeKey.currentState.showSnackBar(
            text: message,
            actionText: ap.retry,
            onSnackBarTapped: _login,
          );
          Preferences.setBool(Constants.PREF_IS_OFFLINE_LOGIN, true);
          ApUtils.showToast(context, ap.loadOfflineData);
          isLogin = true;
        },
      ),
    );
  }

  Future openLoginPage() async {
    var result = await Navigator.of(context).push(
      CupertinoPageRoute(builder: (_) => LoginPage()),
    );
    checkLogin();
    if (result ?? false) {
      _getUserInfo();
      _setupBusNotify(context);
      if (state != HomeState.finish) {
        _getAnnouncements();
      }
      setState(() {
        isLogin = true;
      });
    }
  }

  void checkLogin() async {
    await Future.delayed(Duration(microseconds: 30));
    if (isLogin) {
      _homeKey.currentState.hideSnackBar();
    } else {
      _homeKey.currentState
          .showSnackBar(
            text: ApLocalizations.of(context).notLogin,
            actionText: ApLocalizations.of(context).login,
            onSnackBarTapped: openLoginPage,
          )
          .closed
          .then(
        (SnackBarClosedReason reason) {
          checkLogin();
        },
      );
    }
  }

  _openPage(Widget page, {needLogin = false}) {
    if (isMobile) Navigator.of(context).pop();
    if (needLogin && !isLogin)
      ApUtils.showToast(
        context,
        ApLocalizations.of(context).notLoginHint,
      );
    else {
      if (isMobile) {
        ApUtils.pushCupertinoStyle(context, page);
      } else
        setState(() => content = page);
    }
  }

  static const PREF_API_KEY = 'inkust_api_key';

  Future<void> _checkFeatureEnable() async {
    await Future.delayed(Duration(milliseconds: 100));
    try {
      final RemoteConfig remoteConfig = await RemoteConfig.instance;
      await remoteConfig.fetch(expiration: const Duration(seconds: 10));
      await remoteConfig.activateFetched();
      final leaveTimeCode = List<String>.from(
          jsonDecode(remoteConfig.getString(Constants.LEAVES_TIME_CODE)));
      InkustHelper.loginApiKey = remoteConfig.getString(PREF_API_KEY);
      Preferences.setString(PREF_API_KEY, InkustHelper.loginApiKey);
      Preferences.setStringList(Constants.LEAVES_TIME_CODE, leaveTimeCode);
      InkustHelper.leavesTimeCode = leaveTimeCode;
    } catch (e) {
      InkustHelper.loginApiKey = Preferences.getString(PREF_API_KEY, '');
      InkustHelper.leavesTimeCode = Preferences.getStringList(
        Constants.LEAVES_TIME_CODE,
        InkustHelper.leavesTimeCode,
      );
    }
  }

  Future<void> getData() async {
    _getAnnouncements();
    if (Preferences.getBool(Constants.PREF_AUTO_LOGIN, false)) {
      _login();
    } else {
      checkLogin();
    }
    await _checkFeatureEnable();
    Utils.checkRemoteConfig(
      context,
      () => initState(),
    );
  }
}
