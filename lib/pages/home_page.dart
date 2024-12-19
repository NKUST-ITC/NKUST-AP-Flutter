import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:ap_common/ap_common.dart';
import 'package:ap_common_firebase/ap_common_firebase.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nkust_ap/api/ap_status_code.dart';
import 'package:nkust_ap/api/mobile_nkust_helper.dart';
import 'package:nkust_ap/models/crawler_selector.dart';
import 'package:nkust_ap/models/login_response.dart';
import 'package:nkust_ap/models/models.dart';
import 'package:nkust_ap/pages/study/midterm_alerts_page.dart';
import 'package:nkust_ap/pages/study/reward_and_penalty_page.dart';
import 'package:nkust_ap/pages/study/room_list_page.dart';
import 'package:nkust_ap/res/assets.dart';
import 'package:nkust_ap/utils/global.dart';
import 'package:nkust_ap/widgets/share_data_widget.dart';
import 'package:package_info_plus/package_info_plus.dart';

class HomePage extends StatefulWidget {
  static const String routerName = '/home';

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final GlobalKey<HomePageScaffoldState> _homeKey =
      GlobalKey<HomePageScaffoldState>();

  bool get isMobile => MediaQuery.of(context).size.shortestSide < 680;

  HomeState state = HomeState.loading;

  late AppLocalizations app;
  late ApLocalizations ap;

  Widget? content;

  List<Announcement> announcements = <Announcement>[];

  bool isLogin = false;
  bool displayPicture = true;
  bool isStudyExpanded = false;
  bool isBusExpanded = false;
  bool isLeaveExpanded = false;

  bool leaveEnable = true;
  bool busEnable = true;

  UserInfo? userInfo;

  TextStyle get _defaultStyle => TextStyle(
        color: ApTheme.of(context).grey,
        fontSize: 16.0,
      );

  String get sectionImage {
    final String department = userInfo?.department ?? '';
    final bool halfSnapFingerChance = Random().nextInt(2000).isEven;
    if (department.contains('建工') || department.contains('燕巢')) {
      return halfSnapFingerChance
          ? ImageAssets.sectionJiangong
          : ImageAssets.sectionYanchao;
    } else if (department.contains('第一')) {
      return halfSnapFingerChance
          ? ImageAssets.sectionFirst1
          : ImageAssets.sectionFirst2;
    } else if (department.contains('旗津') || department.contains('楠梓')) {
      return halfSnapFingerChance
          ? ImageAssets.sectionQijin
          : ImageAssets.sectionNanzi;
    } else {
      return ImageAssets.kuasap2;
    }
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

  IconData get report {
    switch (ApIcon.code) {
      case ApIcon.filled:
        return Icons.flag_circle;
      case ApIcon.outlined:
      default:
        return Icons.flag_circle_outlined;
    }
  }

  IconData get enrollmentLetter {
    switch (ApIcon.code) {
      case ApIcon.filled:
        return Icons.description;
      case ApIcon.outlined:
      default:
        return Icons.description_outlined;
    }
  }

  bool get canUseBus => busEnable && MobileNkustHelper.isSupport;

  static Widget aboutPage(BuildContext context, {String? assetImage}) {
    return AboutUsPage(
      assetImage: assetImage ?? ImageAssets.kuasap2,
      githubName: 'NKUST-ITC',
      email: 'nkust.itc@gmail.com',
      appLicense: AppLocalizations.of(context).aboutOpenSourceContent,
      fbFanPageId: '735951703168873',
      fbFanPageUrl: 'https://www.facebook.com/NKUST.ITC/',
      githubUrl: 'https://github.com/NKUST-ITC',
    );
  }

  @override
  void initState() {
    AnalyticsUtil.instance.setCurrentScreen(
      'HomePage',
      'home_page.dart',
    );
    Future<void>.microtask(() async {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          systemNavigationBarContrastEnforced: true,
          systemNavigationBarColor: Colors.transparent,
        ),
      );
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      _getAnnouncements();
      if (PreferenceUtil.instance.getBool(Constants.prefAutoLogin, false)) {
        _login();
      } else {
        checkLogin();
      }
      if (await AppStoreUtil.instance.trackingAuthorizationStatus ==
          GeneralPermissionStatus.notDetermined) {
        //ignore: use_build_context_synchronously
        if (!mounted) return;
        AppTrackingUtils.show(context: context);
      }
      await _checkData(first: true);
    });
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
    return HomePageScaffold(
      title: app.appName,
      key: _homeKey,
      state: state,
      announcements: announcements,
      isLogin: isLogin,
      content: content,
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.fiber_new_rounded),
          tooltip: ap.announcementReviewSystem,
          onPressed: () async {
            ApUtils.pushCupertinoStyle(
              context,
              const AnnouncementHomePage(
                organizationDomain: Constants.mailDomain,
              ),
            );
            if (FirebaseMessagingUtils.isSupported) {
              try {
                final FirebaseMessaging messaging = FirebaseMessaging.instance;
                final NotificationSettings settings =
                    await messaging.getNotificationSettings();
                if (settings.authorizationStatus ==
                        AuthorizationStatus.authorized ||
                    settings.authorizationStatus ==
                        AuthorizationStatus.provisional) {
                  final String? token = await messaging.getToken(
                    vapidKey: Constants.fcmWebVapidKey,
                  );
                  AnnouncementHelper.instance.fcmToken = token;
                }
              } catch (_) {}
            }
          },
        ),
      ],
      drawer: ApDrawer(
        userInfo: userInfo,
        displayPicture:
            PreferenceUtil.instance.getBool(Constants.prefDisplayPicture, true),
        imageAsset: drawerIcon,
        onTapHeader: () {
          if (isLogin) {
            if (userInfo != null && isLogin) {
              ApUtils.pushCupertinoStyle(
                context,
                UserInfoPage(userInfo: userInfo!),
              );
            }
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
            onExpansionChanged: (bool bool) {
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
                title: ap.calculateCredits,
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
                onTap: () => _openPage(
                  RoomListPage(),
                  needLogin: true,
                ),
              ),
              DrawerSubItem(
                icon: enrollmentLetter,
                title: '在學證明',
                onTap: () => _openPage(
                  const EnrollmentLetterPage(),
                  needLogin: true,
                ),
              ),
            ],
          ),
          if (leaveEnable)
            ExpansionTile(
              initiallyExpanded: isLeaveExpanded,
              onExpansionChanged: (bool bool) {
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
                    const LeavePage(),
                    needLogin: true,
                    useCupertinoRoute: false,
                  ),
                ),
                DrawerSubItem(
                  icon: ApIcon.assignment,
                  title: ap.leaveRecords,
                  onTap: () => _openPage(
                    const LeavePage(initIndex: 1),
                    needLogin: true,
                    useCupertinoRoute: false,
                  ),
                ),
                DrawerSubItem(
                  icon: ApIcon.folder,
                  title: app.leaveApplyRecord,
                  onTap: () => _openPage(
                    const LeavePage(initIndex: 2),
                    needLogin: true,
                    useCupertinoRoute: false,
                  ),
                ),
              ],
            )
          else
            DrawerItem(
              icon: ApIcon.calendarToday,
              title: ap.leave,
              onTap: () => PlatformUtil.instance.launchUrl(
                'https://mobile.nkust.edu.tw/Student/Leave',
              ),
            ),
          if (canUseBus)
            ExpansionTile(
              initiallyExpanded: isBusExpanded,
              onExpansionChanged: (bool bool) {
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
                    const BusPage(),
                    needLogin: true,
                  ),
                ),
                DrawerSubItem(
                  icon: ApIcon.assignment,
                  title: app.busReservations,
                  onTap: () => _openPage(
                    const BusPage(initIndex: 1),
                    needLogin: true,
                  ),
                ),
                DrawerSubItem(
                  icon: ApIcon.monetizationOn,
                  title: app.busViolationRecords,
                  onTap: () => _openPage(
                    const BusPage(initIndex: 2),
                    needLogin: true,
                  ),
                ),
              ],
            )
          else
            DrawerItem(
              icon: ApIcon.directionsBus,
              title: ap.bus,
              onTap: () => PlatformUtil.instance.launchUrl(
                'https://mobile.nkust.edu.tw/Bus/Timetable',
              ),
            ),
          DrawerItem(
            icon: ApIcon.info,
            title: ap.schoolInfo,
            onTap: () => _openPage(SchoolInfoPage()),
          ),
          DrawerItem(
            icon: report,
            title: app.reportProblem,
            onTap: () => _openPage(ReportPage()),
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
                await PreferenceUtil.instance
                    .setBool(Constants.prefAutoLogin, false);
                if (!context.mounted) return;
                ShareDataWidget.of(context)!.data.logout();
                isLogin = false;
                userInfo = null;
                content = null;
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
      },
      onTabTapped: onTabTapped,
      bottomNavigationBarItems: <BottomNavigationBarItem>[
        if (canUseBus)
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
  }

  void onTabTapped(int index) {
    if (isLogin) {
      switch (canUseBus ? index : index + 1) {
        case 0:
          if (canUseBus) {
            ApUtils.pushCupertinoStyle(context, const BusPage());
          } else {
            UiUtil.instance.showToast(context, ap.platformError);
          }
        case 1:
          ApUtils.pushCupertinoStyle(context, CoursePage());
        case 2:
          ApUtils.pushCupertinoStyle(context, ScorePage());
      }
    } else {
      UiUtil.instance.showToast(context, ap.notLogin);
    }
  }

  void _getAnnouncements() {
    AnnouncementHelper.instance.getAnnouncements(
      tags: <String>['nkust'],
      callback: GeneralCallback<List<Announcement>>(
        onFailure: (_) => setState(() => state = HomeState.error),
        onError: (_) => setState(() => state = HomeState.error),
        onSuccess: (List<Announcement> data) {
          announcements = data;
          if (mounted) {
            setState(() {
              if (data.isEmpty) {
                state = HomeState.empty;
              } else {
                state = HomeState.finish;
              }
            });
          }
        },
      ),
    );
  }

  void _setupBusNotify(BuildContext context) {
    if (PreferenceUtil.instance.getBool(Constants.prefBusNotify, false)) {
      Helper.instance.getBusReservations(
        callback: GeneralCallback<BusReservationsData>(
          onSuccess: (BusReservationsData response) async {
            await Utils.setBusNotify(context, response.reservations);
          },
          onFailure: (DioException e) {
            if (e.hasResponse) {
              AnalyticsUtil.instance.logApiEvent(
                'getBusReservations',
                e.response!.statusCode!,
                message: e.message ?? '',
              );
            }
          },
          onError: (GeneralResponse e) => null,
        ),
      );
    }
  }

  Future<void> _getUserInfo() async {
    if (PreferenceUtil.instance.getBool(Constants.prefIsOfflineLogin, false)) {
      userInfo = UserInfo.load(Helper.username!);
    } else {
      Helper.instance.getUsersInfo(
        callback: GeneralCallback<UserInfo>(
          onSuccess: (UserInfo data) {
            if (mounted) {
              setState(() {
                userInfo = data;
              });
              if (userInfo != null) {
                AnalyticsUtil.instance.logUserInfo(userInfo!);
                userInfo!.save(Helper.username!);
              }
              _checkData();
              if (PreferenceUtil.instance
                  .getBool(Constants.prefDisplayPicture, true)) {
                _getUserPicture();
              }
            }
          },
          onFailure: (DioException e) {
            if (e.hasResponse) {
              AnalyticsUtil.instance.logApiEvent(
                'getUserInfo',
                e.response!.statusCode!,
                message: e.message ?? '',
              );
            }
          },
          onError: (GeneralResponse e) => null,
        ),
      );
    }
  }

  Future<void> _getUserPicture() async {
    try {
      if (userInfo != null && userInfo!.pictureUrl != null) {
        final Uint8List? response = await Helper.instance.getUserPicture();
        if (mounted) {
          setState(() {
            userInfo!.pictureBytes = response;
          });
        }
        // CacheUtils.savePictureData(response);
      }
    } catch (e) {
      rethrow;
    }
  }

  void showLoginingSnackBar() {
    if (isLogin) return;
    _homeKey.currentState
        ?.showSnackBar(
          text: ApLocalizations.of(context).logining,
          actionText: ApLocalizations.of(context).offlineLogin,
          onSnackBarTapped: offLineLogin,
        )
        ?.closed
        .then(
      (SnackBarClosedReason reason) {
        showLoginingSnackBar();
      },
    );
  }

  Future<void> _login() async {
    await Future<void>.delayed(const Duration(microseconds: 30));
    if (!mounted) return;
    showLoginingSnackBar();
    final String username =
        PreferenceUtil.instance.getString(Constants.prefUsername, '');
    final String password =
        PreferenceUtil.instance.getStringSecurity(Constants.prefPassword, '');

    if (!mounted) return;
    Helper.instance.login(
      context: context,
      username: username,
      password: password,
      callback: GeneralCallback<LoginResponse?>(
        onSuccess: (LoginResponse? response) {
          if (isLogin) return;
          ShareDataWidget.of(context)!.data.loginResponse = response;
          isLogin = true;
          PreferenceUtil.instance.setBool(Constants.prefIsOfflineLogin, false);
          _getUserInfo();
          _setupBusNotify(context);
          if (state != HomeState.finish) {
            _getAnnouncements();
          }
          _homeKey.currentState
            ?..hideSnackBar()
            ..showBasicHint(text: ap.loginSuccess);
        },
        onFailure: (DioException e) {
          if (isLogin) return;
          final String text = e.i18nMessage!;
          _homeKey.currentState!.showSnackBar(
            text: text,
            actionText: ap.retry,
            onSnackBarTapped: _login,
          );
          offLineLogin();
        },
        onError: (GeneralResponse response) async {
          if (isLogin) return;
          String message = '';
          if (response.statusCode == ApStatusCode.userDataError ||
              response.statusCode == ApStatusCode.passwordFiveTimesError) {
            Toast.show(ap.passwordError, context);
            await PreferenceUtil.instance
                .setBool(Constants.prefAutoLogin, false);
            checkLogin();
          } else {
            switch (response.statusCode) {
              case ApStatusCode.schoolServerError:
                message = ap.schoolServerError;
              case ApStatusCode.apiServerError:
                message = ap.apiServerError;
              case ApStatusCode.unknownError:
              case ApStatusCode.cancel:
                message = ap.loginFail;
              default:
                message = ap.somethingError;
            }
            _homeKey.currentState!.showSnackBar(
              text: message,
              actionText: ap.retry,
              onSnackBarTapped: _login,
            );
            offLineLogin();
          }
        },
      ),
    );
  }

  void offLineLogin() {
    PreferenceUtil.instance.setBool(Constants.prefIsOfflineLogin, true);
    UiUtil.instance.showToast(context, ap.loadOfflineData);
    isLogin = true;
    _getUserInfo();
    _homeKey.currentState?.hideSnackBar();
  }

  void handleLoginSuccess(String? username, String? password) {
    isLogin = true;
    PreferenceUtil.instance.setBool(Constants.prefIsOfflineLogin, false);
    _getUserInfo();
    _setupBusNotify(context);
    if (state != HomeState.finish) {
      _getAnnouncements();
    }
    _homeKey.currentState!.showBasicHint(text: ap.loginSuccess);
  }

  Future<void> openLoginPage() async {
    final bool? result = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => LoginPage()),
    );
    checkLogin();
    if (result ?? false) {
      handleLoginSuccess(
        Helper.username,
        Helper.password,
      );
    }
  }

  Future<void> checkLogin() async {
    await Future<void>.delayed(const Duration(microseconds: 30));
    if (isLogin) {
      _homeKey.currentState!.hideSnackBar();
    } else {
      if (!mounted) return;
      _homeKey.currentState!
          .showSnackBar(
            text: ApLocalizations.of(context).notLogin,
            actionText: ApLocalizations.of(context).login,
            onSnackBarTapped: openLoginPage,
          )!
          .closed
          .then(
        (SnackBarClosedReason reason) {
          checkLogin();
        },
      );
    }
  }

  Future<void> _openPage(
    Widget page, {
    bool needLogin = false,
    bool useCupertinoRoute = true,
  }) async {
    if (isMobile) Navigator.of(context).pop();
    if (needLogin && !isLogin) {
      UiUtil.instance.showToast(
        context,
        ApLocalizations.of(context).notLoginHint,
      );
    } else {
      if (isMobile) {
        if (useCupertinoRoute) {
          ApUtils.pushCupertinoStyle(context, page);
        } else {
          await Navigator.push(
            context,
            CupertinoPageRoute<void>(builder: (_) => page),
          );
        }
        checkLogin();
      } else {
        setState(() => content = page);
      }
    }
  }

  static const String prefApiKey = 'inkust_api_key';

  Future<void> _checkData({bool first = false}) async {
    final AppLocalizations app = AppLocalizations.of(context);
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final String currentVersion =
        PreferenceUtil.instance.getString(Constants.prefCurrentVersion, '');
    AnalyticsUtil.instance.setUserProperty(
      Constants.versionCode,
      packageInfo.buildNumber,
    );
    if (currentVersion != packageInfo.buildNumber && first) {
      final Map<String, dynamic>? rawData = await FileAssets.changelogData;
      final String updateNoteContent = (rawData![packageInfo.buildNumber]
          as Map<String, dynamic>)[ApLocalizations.current.locale] as String;
      if (!mounted) return;
      DialogUtils.showUpdateContent(
        context,
        'v${packageInfo.version}\n'
        '$updateNoteContent',
      );
      PreferenceUtil.instance.setString(
        Constants.prefCurrentVersion,
        packageInfo.buildNumber,
      );
    }
    VersionInfo versionInfo;
    try {
      final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(seconds: 10),
        ),
      );
      await remoteConfig.fetchAndActivate();
      final List<String> leaveTimeCode = List<String>.from(
        jsonDecode(remoteConfig.getString(Constants.leavesTimeCode))
            as List<dynamic>,
      );
      final List<String> mobileNkustUserAgent = List<String>.from(
        jsonDecode(
          remoteConfig.getString(Constants.mobileNkustUserAgent),
        ) as List<dynamic>,
      );
      busEnable = remoteConfig.getBool(Constants.busEnable);
      leaveEnable = remoteConfig.getBool(Constants.leaveEnable);
      PreferenceUtil.instance.setBool(Constants.busEnable, busEnable);
      PreferenceUtil.instance.setBool(Constants.leaveEnable, leaveEnable);
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        Helper.selector = CrawlerSelector.fromRawJson(
          remoteConfig.getString(Constants.crawlerSelector),
        );
        Helper.selector!.save();
      }
      final SemesterData semesterData = SemesterData.fromRawJson(
        remoteConfig.getString(Constants.semesterData),
      );
      semesterData.save();
      PreferenceUtil.instance
          .setStringList(Constants.leavesTimeCode, leaveTimeCode);
      PreferenceUtil.instance.setStringList(
        Constants.mobileNkustUserAgent,
        mobileNkustUserAgent,
      );
      MobileNkustHelper.userAgentList = mobileNkustUserAgent;
      versionInfo = VersionInfo(
        code: remoteConfig.getInt(ApConstants.appVersion),
        isForceUpdate: remoteConfig.getBool(ApConstants.isForceUpdate),
        content: remoteConfig.getString(ApConstants.newVersionContent),
      );
      if (first) {
        if (!mounted) return;
        DialogUtils.showNewVersionContent(
          context: context,
          appName: app.appName,
          iOSAppId: '1439751462',
          defaultUrl: 'https://www.facebook.com/NKUST.ITC/',
          githubRepositoryName: 'NKUST-ITC/NKUST-AP-Flutter',
          windowsPath:
              'https://github.com/NKUST-ITC/NKUST-AP-Flutter/releases/download/%s/nkust_ap_windows.zip',
          snapStoreId: 'nkust-ap',
          versionInfo: versionInfo,
        );
      }
    } catch (e) {
      Helper.selector = CrawlerSelector.load();
      busEnable = PreferenceUtil.instance.getBool(Constants.busEnable, true);
      leaveEnable =
          PreferenceUtil.instance.getBool(Constants.leaveEnable, true);
    }
    setState(() {});
  }
}
