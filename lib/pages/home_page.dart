import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:ap_common/ap_common.dart';
import 'package:ap_common_flutter_ui/ap_common_flutter_ui.dart';
import 'package:ap_common_firebase/ap_common_firebase.dart';
import 'package:ap_common_plugin/ap_common_plugin.dart';
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
  CourseData? courseData;
  BusReservationsData? busReservationsData;

  StreamSubscription<void>? _reloginSub;
  bool _userInfoFetchFailed = false;
  bool _userInfoFetchInProgress = false;

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
      _loadCourseData();
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
    _reloginSub = Helper.instance.onReloginSuccess.listen((_) {
      if (!mounted) return;
      // Only retry when a previous fetch actually failed. The initial
      // login flow calls `_getUserInfo()` directly, so no retry is needed
      // just because the stream fired.
      if (_userInfoFetchFailed) {
        _getUserInfo();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _reloginSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    app = AppLocalizations.of(context);
    ap = context.ap;
    return HomePageScaffold(
      title: app.appName,
      key: _homeKey,
      state: state,
      announcements: announcements,
      isLogin: isLogin,
      content: content,
      dashboardWidgets: _buildDashboardWidgets(),
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
    return ApDrawer(
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
          DrawerMenuItem(
            icon: ApIcon.home,
            title: ap.home,
            onTap: () {
              setState(() => content = null);
            },
          ),
        DrawerMenuSection(
          initiallyExpanded: isStudyExpanded,
          onExpansionChanged: (bool bool) {
            setState(() {
              isStudyExpanded = bool;
            });
          },
          icon: ApIcon.school,
          title: ap.courseInfo,
          children: <DrawerSubMenuItem>[
            DrawerSubMenuItem(
              icon: ApIcon.classIcon,
              title: ap.course,
              onTap: () => _openPage(
                CoursePage(),
                needLogin: true,
              ),
            ),
            DrawerSubMenuItem(
              icon: ApIcon.assignment,
              title: ap.score,
              onTap: () => _openPage(
                ScorePage(),
                needLogin: true,
              ),
            ),
            DrawerSubMenuItem(
              icon: ApIcon.apps,
              title: ap.calculateCredits,
              onTap: () => _openPage(
                CalculateUnitsPage(),
                needLogin: true,
              ),
            ),
            DrawerSubMenuItem(
              icon: ApIcon.warning,
              title: ap.midtermAlerts,
              onTap: () => _openPage(
                MidtermAlertsPage(),
                needLogin: true,
              ),
            ),
            DrawerSubMenuItem(
              icon: ApIcon.folder,
              title: ap.rewardAndPenalty,
              onTap: () => _openPage(
                RewardAndPenaltyPage(),
                needLogin: true,
              ),
            ),
            DrawerSubMenuItem(
              icon: ApIcon.room,
              title: ap.classroomCourseTableSearch,
              onTap: () => _openPage(
                RoomListPage(),
                needLogin: true,
              ),
            ),
            DrawerSubMenuItem(
              icon: enrollmentLetter,
              title: app.enrollmentLetter,
              onTap: () => _openPage(
                const EnrollmentLetterPage(),
                needLogin: true,
              ),
            ),
          ],
        ),
        if (leaveEnable)
          DrawerMenuSection(
            initiallyExpanded: isLeaveExpanded,
            onExpansionChanged: (bool bool) {
              setState(() {
                isLeaveExpanded = bool;
              });
            },
            icon: ApIcon.calendarToday,
            title: ap.leave,
            children: <DrawerSubMenuItem>[
              DrawerSubMenuItem(
                icon: ApIcon.edit,
                title: ap.leaveApply,
                onTap: () => _openPage(
                  const LeavePage(),
                  needLogin: true,
                  useCupertinoRoute: false,
                ),
              ),
              DrawerSubMenuItem(
                icon: ApIcon.assignment,
                title: ap.leaveRecords,
                onTap: () => _openPage(
                  const LeavePage(initIndex: 1),
                  needLogin: true,
                  useCupertinoRoute: false,
                ),
              ),
              DrawerSubMenuItem(
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
          DrawerMenuItem(
            icon: ApIcon.calendarToday,
            title: ap.leave,
            onTap: () => PlatformUtil.instance.launchUrl(
              'https://mobile.nkust.edu.tw/Student/Leave',
            ),
          ),
        if (canUseBus)
          DrawerMenuSection(
            initiallyExpanded: isBusExpanded,
            onExpansionChanged: (bool bool) {
              setState(() {
                isBusExpanded = bool;
              });
            },
            icon: ApIcon.directionsBus,
            title: app.bus,
            children: <DrawerSubMenuItem>[
              DrawerSubMenuItem(
                icon: ApIcon.dateRange,
                title: app.busReserve,
                onTap: () => _openPage(
                  const BusPage(),
                  needLogin: true,
                ),
              ),
              DrawerSubMenuItem(
                icon: ApIcon.assignment,
                title: app.busReservations,
                onTap: () => _openPage(
                  const BusPage(initIndex: 1),
                  needLogin: true,
                ),
              ),
              DrawerSubMenuItem(
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
          DrawerMenuItem(
            icon: ApIcon.directionsBus,
            title: ap.bus,
            onTap: () => PlatformUtil.instance.launchUrl(
              'https://mobile.nkust.edu.tw/Bus/Timetable',
            ),
          ),
        DrawerMenuItem(
          icon: ApIcon.info,
          title: ap.schoolInfo,
          onTap: () => _openPage(SchoolInfoPage()),
        ),
        DrawerMenuItem(
          icon: report,
          title: app.reportProblem,
          onTap: () => _openPage(ReportPage()),
        ),
        DrawerMenuItem(
          icon: ApIcon.face,
          title: ap.about,
          onTap: () => _openPage(
            aboutPage(
              context,
              assetImage: sectionImage,
            ),
          ),
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
            iconColor: Theme.of(context).colorScheme.error,
            onTap: () async {
              await PreferenceUtil.instance
                  .setBool(Constants.prefAutoLogin, false);
              if (!mounted) return;
              ShareDataWidget.of(context)!.data.logout();
              setState(() {
                isLogin = false;
                userInfo = null;
                content = null;
              });
              if (isMobile) Navigator.of(context).pop();
              checkLogin();
            },
          ),
        ],
      ],
    );
  }

  Future<void> onTabTapped(int index) async {
    if (isLogin) {
      switch (canUseBus ? index : index + 1) {
        case 0:
          if (canUseBus) {
            await _pushAndReload(const BusPage());
          } else {
            UiUtil.instance.showToast(context, ap.platformError);
          }
        case 1:
          await _pushAndReload(CoursePage());
        case 2:
          await _pushAndReload(ScorePage());
      }
    } else {
      UiUtil.instance.showToast(context, ap.notLogin);
    }
  }

  Future<void> _pushAndReload(Widget page) async {
    await Navigator.push(
      context,
      CupertinoPageRoute<void>(builder: (_) => page),
    );
    _loadCourseData();
  }

  BusReservation? get _nextBusReservation {
    if (busReservationsData == null) return null;
    final DateTime now = DateTime.now();
    final List<BusReservation> future = busReservationsData!.reservations
        .where((BusReservation r) => r.getDateTime().isAfter(now))
        .toList()
      ..sort(
        (BusReservation a, BusReservation b) =>
            a.getDateTime().compareTo(b.getDateTime()),
      );
    return future.isEmpty ? null : future.first;
  }

  List<Widget>? _buildDashboardWidgets() {
    if (courseData == null && !canUseBus) return null;
    return <Widget>[
      if (canUseBus)
        QuickInfoRow(
          items: <QuickInfoItem>[
            if (_nextBusReservation != null)
              QuickInfoItem(
                icon: ApIcon.directionsBus,
                label: app.busReserve,
                subtitle:
                    '${_nextBusReservation!.getDate()} ${_nextBusReservation!.getStart(app)} → ${_nextBusReservation!.getEnd(app)} ${_nextBusReservation!.getTime()}',
                onTap: () {
                  if (isLogin) {
                    _pushAndReload(const BusPage());
                  } else {
                    UiUtil.instance.showToast(context, ap.notLogin);
                  }
                },
              ),
            if (_nextBusReservation == null)
              QuickInfoItem(
                icon: ApIcon.directionsBus,
                label: app.bus,
                subtitle: app.busReservations,
                onTap: () {
                  if (isLogin) {
                    _pushAndReload(const BusPage());
                  } else {
                    UiUtil.instance.showToast(context, ap.notLogin);
                  }
                },
              ),
          ],
        ),
      if (canUseBus) const SizedBox(height: 16),
      if (courseData != null)
        TodayScheduleCard(
          courseData: courseData!,
          onTap: () {
            _pushAndReload(CoursePage());
          },
        ),
      if (courseData == null) _buildEmptyScheduleCard(),
    ];
  }

  Widget _buildEmptyScheduleCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: InkWell(
          onTap: () {
            if (isLogin) {
              ApUtils.pushCupertinoStyle(context, CoursePage());
            } else {
              openLoginPage();
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.today_rounded,
                  size: 32,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    isLogin ? ap.courseEmpty : ap.notLogin,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _loadCourseData() async {
    final String username = Helper.username ??
        PreferenceUtil.instance
            .getString(Constants.prefUsername, '')
            .toUpperCase();
    if (username.isEmpty) return;
    final SemesterData? semesterData = SemesterData.load();
    if (semesterData != null) {
      final String tag = '${username}_${semesterData.defaultSemester.code}';
      final CourseData? data = CourseData.load(tag);
      if (data != null && mounted) {
        setState(() => courseData = data);
      }
    }
    final BusReservationsData? busData = BusReservationsData.load(username);
    if (busData != null && mounted) {
      setState(() => busReservationsData = busData);
    }
  }

  Future<void> _getAnnouncements() async {
    final result = await AnnouncementHelper.instance.getAnnouncements(
      tags: <String>['nkust'],
    );
    switch (result) {
      case ApiSuccess<List<Announcement>>(:final data):
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
      case ApiFailure<List<Announcement>>():
      case ApiError<List<Announcement>>():
        setState(() => state = HomeState.error);
    }
  }

  Future<void> _setupBusNotify(BuildContext context) async {
    try {
      final BusReservationsData response =
          await Helper.instance.getBusReservations();
      response.save(Helper.username);
      if (mounted) {
        setState(() {
          busReservationsData = response;
        });
      }
      if (PreferenceUtil.instance.getBool(Constants.prefBusNotify, false)) {
        await Utils.setBusNotify(context, response.reservations);
      }
    } on DioException catch (e) {
      if (e.hasResponse) {
        AnalyticsUtil.instance.logApiEvent(
          'getBusReservations',
          e.response!.statusCode!,
          message: e.message ?? '',
        );
      }
    } catch (e, s) {
      CrashlyticsUtil.instance.recordError(e, s);
    }
  }

  Future<void> _getUserInfo() async {
    if (_userInfoFetchInProgress) return;
    _userInfoFetchInProgress = true;
    try {
      if (PreferenceUtil.instance
          .getBool(Constants.prefIsOfflineLogin, false)) {
        userInfo = UserInfo.load(Helper.username!);
        return;
      }
      try {
        final UserInfo data = await Helper.instance.getUsersInfo();
        _userInfoFetchFailed = false;
        if (mounted) {
          setState(() {
            userInfo = data;
          });
          if (userInfo != null) {
            AnalyticsUtil.instance.logUserInfo(userInfo!);
            userInfo!.save(Helper.username!);
            ApCommonPlugin.updateUserInfoWidget(userInfo!);
          }
          _checkData();
          if (PreferenceUtil.instance
              .getBool(Constants.prefDisplayPicture, true)) {
            _getUserPicture();
          }
        }
      } on DioException catch (e) {
        _userInfoFetchFailed = true;
        if (e.hasResponse) {
          AnalyticsUtil.instance.logApiEvent(
            'getUserInfo',
            e.response!.statusCode!,
            message: e.message ?? '',
          );
        }
      } catch (e, s) {
        _userInfoFetchFailed = true;
        CrashlyticsUtil.instance.recordError(e, s);
      }
    } finally {
      _userInfoFetchInProgress = false;
    }
  }

  Future<void> _getUserPicture() async {
    try {
      if (userInfo != null && userInfo!.pictureUrl != null) {
        final Uint8List? response =
            await Helper.instance.getUserPicture(userInfo!.pictureUrl!);
        if (mounted) {
          setState(() {
            userInfo = userInfo!.copyWith(pictureBytes: response);
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
          text: context.ap.logining,
          actionText: context.ap.offlineLogin,
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
    try {
      final LoginResponse? response = await Helper.instance.login(
        username: username,
        password: password,
      );
      if (!mounted) return;
      if (isLogin) return;
      ShareDataWidget.of(context)!.data.loginResponse = response;
      setState(() {
        isLogin = true;
      });
      PreferenceUtil.instance.setBool(Constants.prefIsOfflineLogin, false);
      _getUserInfo();
      _loadCourseData();
      _setupBusNotify(context);
      if (state != HomeState.finish) {
        _getAnnouncements();
      }
      _homeKey.currentState
        ?..hideSnackBar()
        ..showBasicHint(text: ap.loginSuccess);
    } on GeneralResponse catch (response) {
      if (isLogin) return;
      String message = '';
      if (response.statusCode == ApStatusCode.userDataError ||
          response.statusCode == ApStatusCode.passwordFiveTimesError) {
        Toast.show(ap.passwordError, context);
        await PreferenceUtil.instance.setBool(Constants.prefAutoLogin, false);
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
    } on DioException catch (e) {
      if (isLogin) return;
      final String text = e.i18nMessage!;
      _homeKey.currentState!.showSnackBar(
        text: text,
        actionText: ap.retry,
        onSnackBarTapped: _login,
      );
      offLineLogin();
    }
  }

  void offLineLogin() {
    if (!mounted) return;
    PreferenceUtil.instance.setBool(Constants.prefIsOfflineLogin, true);
    UiUtil.instance.showToast(context, ap.loadOfflineData);
    setState(() {
      isLogin = true;
    });
    _getUserInfo();
    _homeKey.currentState?.hideSnackBar();
  }

  void handleLoginSuccess(String? username, String? password) {
    if (!mounted) return;
    setState(() {
      isLogin = true;
    });
    PreferenceUtil.instance.setBool(Constants.prefIsOfflineLogin, false);
    _getUserInfo();
    _loadCourseData();
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
            text: context.ap.notLogin,
            actionText: context.ap.login,
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
        context.ap.notLoginHint,
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
      final Map<String, dynamic>? entry =
          rawData?[packageInfo.buildNumber] as Map<String, dynamic>?;
      if (entry != null && mounted) {
        final dynamic localeValue = entry[ap.locale];
        String? updateNoteContent;
        if (localeValue is List) {
          if (localeValue.isNotEmpty) {
            updateNoteContent =
                localeValue.map((dynamic e) => '\u2022 $e').join('\n');
          }
        } else if (localeValue is String && localeValue.isNotEmpty) {
          updateNoteContent = localeValue;
        }
        if (updateNoteContent != null) {
          DialogUtils.showUpdateContent(
            context,
            'v${packageInfo.version}\n$updateNoteContent',
          );
        }
      }
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
        try {
          final Response<dynamic> changelogResponse = await Dio().get(
            'https://raw.githubusercontent.com/NKUST-ITC/NKUST-AP-Flutter/master/changelog.json',
            options: Options(responseType: ResponseType.plain),
          );
          final Map<String, dynamic> changelogJson =
              jsonDecode(changelogResponse.data as String)
                  as Map<String, dynamic>;
          final Map<String, dynamic>? versionMap =
              changelogJson['${versionInfo.code}'] as Map<String, dynamic>?;
          if (versionMap != null) {
            final dynamic localeValue = versionMap[ap.locale];
            String? content;
            if (localeValue is List) {
              content = localeValue.map((dynamic e) => '\u2022 $e').join('\n');
            } else if (localeValue is String) {
              content = localeValue;
            }
            if (content != null) {
              versionInfo = versionInfo.copyWith(content: content);
            }
          }
        } catch (_) {}
        if (!mounted) return;
        DialogUtils.showNewVersionContent(
          context: context,
          appName: app.appName,
          iOSAppId: '1439751462',
          defaultUrl: 'https://www.facebook.com/NKUST.ITC/',
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
