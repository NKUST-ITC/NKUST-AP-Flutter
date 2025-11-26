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
import 'package:nkust_ap/pages/about_page.dart';
import 'package:nkust_ap/pages/study/midterm_alerts_page.dart';
import 'package:nkust_ap/pages/study/reward_and_penalty_page.dart';
import 'package:nkust_ap/pages/study/room_list_page.dart';
import 'package:nkust_ap/res/assets.dart';
import 'package:nkust_ap/utils/global.dart';
import 'package:nkust_ap/widgets/app_drawer.dart';
import 'package:nkust_ap/widgets/share_data_widget.dart';
import 'package:package_info_plus/package_info_plus.dart';

class HomePage extends StatefulWidget {
  static const String routerName = '/home';

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final GlobalKey<HomePageScaffoldState> _homeKey = GlobalKey<HomePageScaffoldState>();

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

  String get sectionImage {
    final String department = userInfo?.department ?? '';
    final bool halfSnapFingerChance = Random().nextInt(2000).isEven;
    if (department.contains('建工') || department.contains('燕巢')) {
      return halfSnapFingerChance ? ImageAssets.sectionJiangong : ImageAssets.sectionYanchao;
    } else if (department.contains('第一')) {
      return halfSnapFingerChance ? ImageAssets.sectionFirst1 : ImageAssets.sectionFirst2;
    } else if (department.contains('旗津') || department.contains('楠梓')) {
      return halfSnapFingerChance ? ImageAssets.sectionQijin : ImageAssets.sectionNanzi;
    }
    return ImageAssets.kuasap2;
  }

  String get drawerIcon => ImageAssets.drawerIconLight;

  IconData get reportIcon => ApIcon.code == ApIcon.filled ? Icons.flag_circle : Icons.flag_circle_outlined;

  IconData get enrollmentLetterIcon => ApIcon.code == ApIcon.filled ? Icons.description : Icons.description_outlined;

  bool get canUseBus => busEnable && MobileNkustHelper.isSupport;

  static Widget aboutPage(BuildContext context, {String? assetImage}) {
    return CustomAboutPage(
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
    AnalyticsUtil.instance.setCurrentScreen('HomePage', 'home_page.dart');
    Future.microtask(() async {
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
      if (await AppStoreUtil.instance.trackingAuthorizationStatus == GeneralPermissionStatus.notDetermined) {
        if (!mounted) return;
        AppTrackingUtils.show(context: context);
      }
      await _checkData(first: true);
    });
    super.initState();
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
          onPressed: _openAnnouncementPage,
        ),
      ],
      drawer: _buildDrawer(),
      onImageTapped: (Announcement announcement) {
        ApUtils.pushCupertinoStyle(
          context,
          AnnouncementContentPage(announcement: announcement),
        );
      },
      onTabTapped: onTabTapped,
      bottomNavigationBarItems: <NavigationDestination>[
        if (canUseBus)
          NavigationDestination(
            icon: Icon(ApIcon.directionsBus),
            label: app.bus,
          ),
        NavigationDestination(
          icon: Icon(ApIcon.classIcon),
          label: ap.course,
        ),
        NavigationDestination(
          icon: Icon(ApIcon.assignment),
          label: ap.score,
        ),
      ],
    );
  }

  Widget _buildDrawer() {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return AppDrawer(
      userInfo: userInfo,
      displayPicture: PreferenceUtil.instance.getBool(
        Constants.prefDisplayPicture,
        true,
      ),
      imageAsset: drawerIcon,
      onTapHeader: _onDrawerHeaderTap,
      children: <Widget>[
        if (!isMobile)
          DrawerMenuItem(
            icon: ApIcon.home,
            title: ap.home,
            onTap: () => setState(() => content = null),
          ),
        _buildStudySection(),
        if (leaveEnable) _buildLeaveSection() else _buildLeaveMenuItem(),
        if (canUseBus) _buildBusSection() else _buildBusMenuItem(),
        const DrawerDivider(),
        DrawerMenuItem(
          icon: ApIcon.info,
          title: ap.schoolInfo,
          onTap: () => _openPage(SchoolInfoPage()),
        ),
        DrawerMenuItem(
          icon: reportIcon,
          title: app.reportProblem,
          onTap: () => _openPage(ReportPage()),
        ),
        DrawerMenuItem(
          icon: ApIcon.face,
          title: ap.about,
          onTap: () => _openPage(aboutPage(context, assetImage: sectionImage)),
        ),
        DrawerMenuItem(
          icon: ApIcon.settings,
          title: ap.settings,
          onTap: () => _openPage(SettingPage()),
        ),
        if (isLogin) ...<Widget>[
          const DrawerDivider(),
          DrawerMenuItem(
            icon: ApIcon.powerSettingsNew,
            title: ap.logout,
            iconColor: colorScheme.error,
            onTap: _handleLogout,
          ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildStudySection() {
    return DrawerMenuSection(
      icon: ApIcon.school,
      title: ap.courseInfo,
      initiallyExpanded: isStudyExpanded,
      enabled: isLogin,
      onExpansionChanged: (bool v) => setState(() => isStudyExpanded = v),
      children: <DrawerSubMenuItem>[
        DrawerSubMenuItem(
          icon: ApIcon.classIcon,
          title: ap.course,
          enabled: isLogin,
          onTap: () => _openPage(CoursePage(), needLogin: true),
        ),
        DrawerSubMenuItem(
          icon: ApIcon.assignment,
          title: ap.score,
          enabled: isLogin,
          onTap: () => _openPage(ScorePage(), needLogin: true),
        ),
        DrawerSubMenuItem(
          icon: ApIcon.apps,
          title: ap.calculateCredits,
          enabled: isLogin,
          onTap: () => _openPage(CalculateUnitsPage(), needLogin: true),
        ),
        DrawerSubMenuItem(
          icon: ApIcon.warning,
          title: ap.midtermAlerts,
          enabled: isLogin,
          onTap: () => _openPage(MidtermAlertsPage(), needLogin: true),
        ),
        DrawerSubMenuItem(
          icon: ApIcon.folder,
          title: ap.rewardAndPenalty,
          enabled: isLogin,
          onTap: () => _openPage(RewardAndPenaltyPage(), needLogin: true),
        ),
        DrawerSubMenuItem(
          icon: ApIcon.room,
          title: ap.classroomCourseTableSearch,
          enabled: isLogin,
          onTap: () => _openPage(RoomListPage(), needLogin: true),
        ),
        DrawerSubMenuItem(
          icon: enrollmentLetterIcon,
          title: app.enrollmentLetter,
          enabled: isLogin,
          onTap: () => _openPage(
            const EnrollmentLetterPage(),
            needLogin: true,
          ),
        ),
      ],
    );
  }

  Widget _buildLeaveSection() {
    return DrawerMenuSection(
      icon: ApIcon.calendarToday,
      title: ap.leave,
      initiallyExpanded: isLeaveExpanded,
      enabled: isLogin,
      onExpansionChanged: (bool v) => setState(() => isLeaveExpanded = v),
      children: <DrawerSubMenuItem>[
        DrawerSubMenuItem(
          icon: ApIcon.edit,
          title: ap.leaveApply,
          enabled: isLogin,
          onTap: () => _openPage(
            const LeavePage(),
            needLogin: true,
            useCupertinoRoute: false,
          ),
        ),
        DrawerSubMenuItem(
          icon: ApIcon.assignment,
          title: ap.leaveRecords,
          enabled: isLogin,
          onTap: () => _openPage(
            const LeavePage(initIndex: 1),
            needLogin: true,
            useCupertinoRoute: false,
          ),
        ),
        DrawerSubMenuItem(
          icon: ApIcon.folder,
          title: app.leaveApplyRecord,
          enabled: isLogin,
          onTap: () => _openPage(
            const LeavePage(initIndex: 2),
            needLogin: true,
            useCupertinoRoute: false,
          ),
        ),
      ],
    );
  }

  Widget _buildLeaveMenuItem() {
    return DrawerMenuItem(
      icon: ApIcon.calendarToday,
      title: ap.leave,
      isExternalLink: true,
      onTap: () => PlatformUtil.instance.launchUrl(
        'https://mobile.nkust.edu.tw/Student/Leave',
      ),
    );
  }

  Widget _buildBusSection() {
    return DrawerMenuSection(
      icon: ApIcon.directionsBus,
      title: app.bus,
      initiallyExpanded: isBusExpanded,
      enabled: isLogin,
      onExpansionChanged: (bool v) => setState(() => isBusExpanded = v),
      children: <DrawerSubMenuItem>[
        DrawerSubMenuItem(
          icon: ApIcon.dateRange,
          title: app.busReserve,
          enabled: isLogin,
          onTap: () => _openPage(const BusPage(), needLogin: true),
        ),
        DrawerSubMenuItem(
          icon: ApIcon.assignment,
          title: app.busReservations,
          enabled: isLogin,
          onTap: () => _openPage(
            const BusPage(initIndex: 1),
            needLogin: true,
          ),
        ),
        DrawerSubMenuItem(
          icon: ApIcon.monetizationOn,
          title: app.busViolationRecords,
          enabled: isLogin,
          onTap: () => _openPage(
            const BusPage(initIndex: 2),
            needLogin: true,
          ),
        ),
      ],
    );
  }

  Widget _buildBusMenuItem() {
    return DrawerMenuItem(
      icon: ApIcon.directionsBus,
      title: ap.bus,
      isExternalLink: true,
      onTap: () => PlatformUtil.instance.launchUrl(
        'https://mobile.nkust.edu.tw/Bus/Timetable',
      ),
    );
  }

  Future<void> _handleLogout() async {
    await PreferenceUtil.instance.setBool(Constants.prefAutoLogin, false);
    if (!context.mounted) return;
    ShareDataWidget.of(context)!.data.logout();
    isLogin = false;
    userInfo = null;
    content = null;
    if (isMobile) Navigator.of(context).pop();
    checkLogin();
  }

  void _onDrawerHeaderTap() {
    if (isLogin) {
      if (userInfo != null) {
        ApUtils.pushCupertinoStyle(
          context,
          UserInfoPage(userInfo: userInfo!),
        );
      }
    } else {
      if (isMobile) Navigator.of(context).pop();
      openLoginPage();
    }
  }

  Future<void> _openAnnouncementPage() async {
    ApUtils.pushCupertinoStyle(
      context,
      const AnnouncementHomePage(organizationDomain: Constants.mailDomain),
    );
    if (FirebaseMessagingUtils.isSupported) {
      try {
        final FirebaseMessaging messaging = FirebaseMessaging.instance;
        final NotificationSettings settings = await messaging.getNotificationSettings();
        if (settings.authorizationStatus == AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional) {
          final String? token = await messaging.getToken(
            vapidKey: Constants.fcmWebVapidKey,
          );
          AnnouncementHelper.instance.fcmToken = token;
        }
      } catch (_) {}
    }
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
              state = data.isEmpty ? HomeState.empty : HomeState.finish;
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
          onError: (_) => null,
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
              setState(() => userInfo = data);
              if (userInfo != null) {
                AnalyticsUtil.instance.logUserInfo(userInfo!);
                userInfo!.save(Helper.username!);
              }
              _checkData();
              if (PreferenceUtil.instance.getBool(
                Constants.prefDisplayPicture,
                true,
              )) {
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
          onError: (_) => null,
        ),
      );
    }
  }

  Future<void> _getUserPicture() async {
    try {
      if (userInfo != null && userInfo!.pictureUrl != null) {
        final Uint8List? response = await Helper.instance.getUserPicture();
        if (mounted) {
          setState(() => userInfo!.pictureBytes = response);
        }
      }
    } catch (_) {}
  }

  void showLoginingSnackBar() {
    if (isLogin) return;
    _homeKey.currentState
        ?.showSnackBar(
          text: ap.logining,
          actionText: ap.offlineLogin,
          onSnackBarTapped: offLineLogin,
        )
        ?.closed
        .then((_) => showLoginingSnackBar());
  }

  Future<void> _login() async {
    await Future.delayed(const Duration(microseconds: 30));
    if (!mounted) return;
    showLoginingSnackBar();
    final String username = PreferenceUtil.instance.getString(
      Constants.prefUsername,
      '',
    );
    final String password = PreferenceUtil.instance.getStringSecurity(
      Constants.prefPassword,
      '',
    );

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
          if (state != HomeState.finish) _getAnnouncements();
          _homeKey.currentState
            ?..hideSnackBar()
            ..showBasicHint(text: ap.loginSuccess);
        },
        onFailure: (DioException e) {
          if (isLogin) return;
          _homeKey.currentState!.showSnackBar(
            text: e.i18nMessage!,
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
            await PreferenceUtil.instance.setBool(
              Constants.prefAutoLogin,
              false,
            );
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
    if (state != HomeState.finish) _getAnnouncements();
    _homeKey.currentState!.showBasicHint(text: ap.loginSuccess);
  }

  Future<void> openLoginPage() async {
    final bool? result = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => LoginPage()),
    );
    checkLogin();
    if (result ?? false) {
      handleLoginSuccess(Helper.username, Helper.password);
    }
  }

  Future<void> checkLogin() async {
    await Future.delayed(const Duration(microseconds: 30));
    if (isLogin) {
      _homeKey.currentState!.hideSnackBar();
    } else {
      if (!mounted) return;
      _homeKey.currentState!
          .showSnackBar(
            text: ap.notLogin,
            actionText: ap.login,
            onSnackBarTapped: openLoginPage,
          )!
          .closed
          .then((_) => checkLogin());
    }
  }

  Future<void> _openPage(
    Widget page, {
    bool needLogin = false,
    bool useCupertinoRoute = true,
  }) async {
    if (isMobile) Navigator.of(context).pop();
    if (needLogin && !isLogin) {
      UiUtil.instance.showToast(context, ap.notLoginHint);
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

  Future<void> _checkData({bool first = false}) async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final String currentVersion = PreferenceUtil.instance.getString(
      Constants.prefCurrentVersion,
      '',
    );
    AnalyticsUtil.instance.setUserProperty(
      Constants.versionCode,
      packageInfo.buildNumber,
    );
    if (currentVersion != packageInfo.buildNumber && first) {
      final Map<String, dynamic>? rawData = await FileAssets.changelogData;
      final String updateNoteContent =
          (rawData![packageInfo.buildNumber] as Map<String, dynamic>)[ApLocalizations.current.locale] as String;
      if (!mounted) return;
      DialogUtils.showUpdateContent(
        context,
        'v${packageInfo.version}\n$updateNoteContent',
      );
      PreferenceUtil.instance.setString(
        Constants.prefCurrentVersion,
        packageInfo.buildNumber,
      );
    }
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
        jsonDecode(remoteConfig.getString(Constants.leavesTimeCode)) as List<dynamic>,
      );
      final List<String> mobileNkustUserAgent = List<String>.from(
        jsonDecode(remoteConfig.getString(Constants.mobileNkustUserAgent)) as List<dynamic>,
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
      PreferenceUtil.instance.setStringList(
        Constants.leavesTimeCode,
        leaveTimeCode,
      );
      PreferenceUtil.instance.setStringList(
        Constants.mobileNkustUserAgent,
        mobileNkustUserAgent,
      );
      MobileNkustHelper.userAgentList = mobileNkustUserAgent;
      final VersionInfo versionInfo = VersionInfo(
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
          windowsPath: 'https://github.com/NKUST-ITC/NKUST-AP-Flutter/releases/download/%s/nkust_ap_windows.zip',
          snapStoreId: 'nkust-ap',
          versionInfo: versionInfo,
        );
      }
    } catch (_) {
      Helper.selector = CrawlerSelector.load();
      busEnable = PreferenceUtil.instance.getBool(Constants.busEnable, true);
      leaveEnable = PreferenceUtil.instance.getBool(
        Constants.leaveEnable,
        true,
      );
    }
    setState(() {});
  }
}
