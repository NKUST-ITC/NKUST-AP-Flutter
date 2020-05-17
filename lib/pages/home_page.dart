import 'dart:io';
import 'dart:math';

import 'package:ap_common/callback/general_callback.dart';
import 'package:ap_common/models/user_info.dart';
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
import 'package:ap_common/widgets/default_dialog.dart';
import 'package:ap_common/widgets/dialog_option.dart';
import 'package:ap_common/widgets/yes_no_dialog.dart';
import 'package:ap_common_firebase/constants/fiirebase_constants.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:barcode_scan/platform_wrapper.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/models/event_callback.dart';
import 'package:nkust_ap/models/event_info_response.dart';
import 'package:nkust_ap/models/login_response.dart';
import 'package:nkust_ap/models/models.dart';
import 'package:nkust_ap/pages/announcement/news_admin_page.dart';
import 'package:nkust_ap/pages/study/room_list_page.dart';
import 'package:nkust_ap/res/assets.dart';
import 'package:nkust_ap/utils/cache_utils.dart';
import 'package:nkust_ap/utils/global.dart';
import 'package:nkust_ap/widgets/share_data_widget.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

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

  var state = HomeState.loading;

  AppLocalizations app;
  ApLocalizations ap;

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

  @override
  void initState() {
    FirebaseAnalyticsUtils.instance
        .setCurrentScreen("HomePage", "home_page.dart");
    _getAnnouncements();
    if (Preferences.getBool(Constants.PREF_AUTO_LOGIN, false)) {
      _login();
    } else {
      checkLogin();
    }
    Utils.checkRemoteConfig(
      context,
      () => initState(),
    );
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
      actions: <Widget>[
        IconButton(
          icon: Icon(ApIcon.info),
          onPressed: _showInformationDialog,
        ),
        if (ShareDataWidget.of(context).data.loginResponse?.isAdmin ?? false)
          IconButton(
            icon: Icon(Icons.add_to_queue),
            onPressed: () {
              ApUtils.pushCupertinoStyle(
                context,
                NewsAdminPage(isAdmin: true),
              );
            },
          )
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
            Navigator.of(context).pop();
            openLoginPage();
          }
        },
        widgets: <Widget>[
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
                page: CoursePage(),
              ),
              DrawerSubItem(
                icon: ApIcon.assignment,
                title: ap.score,
                page: ScorePage(),
              ),
              DrawerSubItem(
                icon: ApIcon.apps,
                title: ap.calculateUnits,
                page: CalculateUnitsPage(),
              ),
              DrawerSubItem(
                icon: ApIcon.warning,
                title: ap.midtermAlerts,
                page: MidtermAlertsPage(),
              ),
              DrawerSubItem(
                icon: ApIcon.folder,
                title: ap.rewardAndPenalty,
                page: RewardAndPenaltyPage(),
              ),
              DrawerSubItem(
                icon: ApIcon.room,
                title: ap.classroomCourseTableSearch,
                page: RoomListPage(),
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
                page: LeavePage(initIndex: 0),
              ),
              DrawerSubItem(
                icon: ApIcon.assignment,
                title: ap.leaveRecords,
                page: LeavePage(initIndex: 1),
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
            title: Text(ap.bus, style: _defaultStyle),
            children: <Widget>[
              DrawerSubItem(
                icon: ApIcon.dateRange,
                title: ap.busReserve,
                page: BusPage(initIndex: 0),
              ),
              DrawerSubItem(
                icon: ApIcon.assignment,
                title: ap.busReservations,
                page: BusPage(initIndex: 1),
              ),
              DrawerSubItem(
                icon: ApIcon.monetizationOn,
                title: app.busViolationRecords,
                page: BusPage(initIndex: 2),
              ),
            ],
          ),
          DrawerItem(
            icon: ApIcon.info,
            title: ap.schoolInfo,
            page: SchoolInfoPage(),
          ),
          DrawerItem(
            icon: ApIcon.face,
            title: ap.about,
            page: aboutPage(context, assetImage: sectionImage),
          ),
          DrawerItem(
            icon: ApIcon.settings,
            title: ap.settings,
            page: SettingPage(),
          ),
          if (isLogin)
            ListTile(
              leading: Icon(
                ApIcon.powerSettingsNew,
                color: ApTheme.of(context).grey,
              ),
              onTap: () async {
                await Preferences.setBool(Constants.PREF_AUTO_LOGIN, false);
                ShareDataWidget.of(context).data.logout();
                isLogin = false;
                userInfo = null;
                Navigator.of(context).pop();
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
          title: Text(ap.bus),
        ),
        BottomNavigationBarItem(
          icon: Icon(ApIcon.classIcon),
          title: Text(ap.course),
        ),
        BottomNavigationBarItem(
          icon: Icon(ApIcon.assignment),
          title: Text(ap.score),
        ),
      ],
      floatingActionButton: (!kIsWeb && (Platform.isAndroid || Platform.isIOS))
          ? FloatingActionButton.extended(
              onPressed: () async {
                if (isLogin) {
                  var result = await BarcodeScanner.scan(
                    options: ScanOptions(
                      restrictFormat: [BarcodeFormat.qr],
                    ),
                  );
                  if (result.type == ResultType.Barcode) {
                    if (Preferences.getBool(
                        Constants.PREF_AUTO_SEND_EVENT, false))
                      _sendEvent(result.rawContent, null);
                    else
                      _getEventInfo(result.rawContent);
                  } else
                    ApUtils.showToast(context, ap.cancel);
                } else
                  ApUtils.showToast(context, ap.notLogin);
              },
              label: Text(
                app.punch,
                style: TextStyle(color: Colors.white),
              ),
              icon: Icon(
                OMIcons.camera,
                color: Colors.white,
              ),
            )
          : null,
    );
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
    if (Preferences.getBool(Constants.PREF_IS_OFFLINE_LOGIN, false)) {
      setState(() {
        state = HomeState.offline;
      });
    } else
      Helper.instance.getAllAnnouncements(
        callback: GeneralCallback(
          onSuccess: (List<Announcement> data) {
            announcements = data;
            setState(() {
              if (announcements.length == null || announcements.length == 0)
                state = HomeState.empty;
              else
                state = HomeState.finish;
            });
          },
          onFailure: (_) => setState(() => state = HomeState.error),
          onError: (_) => setState(() => state = HomeState.error),
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
      setState(() {
        state = HomeState.offline;
      });
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
          final text = ApLocalizations.dioError(context, e);
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
          Navigator.of(context, rootNavigator: true).pop();
          String message = '';
          switch (response.statusCode) {
            case Helper.SCHOOL_SERVER_ERROR:
              message = ap.schoolSeverError;
              break;
            case Helper.API_SERVER_ERROR:
              message = ap.apiSeverError;
              break;
            case Helper.USER_DATA_ERROR:
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
      CupertinoPageRoute(
        builder: (_) => LoginPage(),
      ),
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

  _getEventInfo(String data) {
    Helper.instance.getEventInfo(
      data: data,
      callback: GeneralCallback<EventInfoResponse>(
        onFailure: (DioError e) => ApUtils.handleDioError(context, e),
        onError: (GeneralResponse generalResponse) {
          switch (generalResponse.statusCode) {
            case 403:
              ApUtils.showToast(context, ap.canNotUseFeature);
              break;
            case 401:
              ApUtils.showToast(context, ap.tokenExpiredContent);
              break;
            default:
              ApUtils.showToast(context, generalResponse.message);
              break;
          }
        },
        onSuccess: (EventInfoResponse eventInfoResponse) =>
            _showEventInfoDialog(data, eventInfoResponse),
      ),
    );
  }

  _showEventInfoDialog(String data, EventInfoResponse eventInfo) {
    showDialog(
      context: context,
      builder: (_) => EventPickDialog(
        eventInfo: eventInfo,
        onSubmit: (index) {
          _sendEvent(
            data,
            eventInfo.data[index].id,
          );
        },
      ),
    );
  }

  _sendEvent(String data, String busId) {
    Helper.instance.sendEvent(
      data: data,
      busId: busId,
      callback: EventSendCallback<EventSendResponse>(
        onFailure: (DioError e) => ApUtils.handleDioError(context, e),
        onError: (GeneralResponse response) {
          switch (response.statusCode) {
            case 403:
              ApUtils.showToast(context, ap.canNotUseFeature);
              break;
            default:
              ApUtils.showToast(context, response.message);
              break;
          }
          FirebaseAnalyticsUtils.instance.logEvent('event_send_error');
        },
        onNeedPick: (EventInfoResponse eventInfoResponse) {
          _showEventInfoDialog(data, eventInfoResponse);
        },
        onSuccess: (EventSendResponse eventSendResponse) {
          final time = (eventSendResponse.data.start == null)
              ? ''
              : '${eventSendResponse.data.start.substring(0, 5)} ';
          showDialog(
            context: context,
            builder: (_) => DefaultDialog(
              title: app.punchSuccess,
              contentWidget: Text(
                '${eventSendResponse.title}\n\n'
                '$time'
                '${eventSendResponse.data.name}',
                style: TextStyle(color: ApTheme.of(context).greyText),
              ),
              actionFunction: () {
                Navigator.of(context).pop();
              },
              actionText: ap.ok,
            ),
          );
          FirebaseAnalyticsUtils.instance.logEvent('event_send_success');
        },
      ),
    );
  }
}

class EventPickDialog extends StatefulWidget {
  final EventInfoResponse eventInfo;
  final Function(int index) onSubmit;

  const EventPickDialog({
    Key key,
    this.eventInfo,
    this.onSubmit,
  }) : super(key: key);

  @override
  _EventPickDialogState createState() => _EventPickDialogState();
}

class _EventPickDialogState extends State<EventPickDialog> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return YesNoDialog(
      title: widget.eventInfo.title,
      contentWidgetPadding: EdgeInsets.all(0.0),
      contentWidget: (widget.eventInfo?.data?.length ?? 0) == 0
          ? Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(ApLocalizations.of(context).noData),
            )
          : Container(
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.height * 0.3,
              child: Column(
                children: <Widget>[
                  SizedBox(height: 8.0),
                  Text(
                    '請選擇欲送出的項目',
                    style: TextStyle(color: ApTheme.of(context).greyText),
                  ),
                  SizedBox(height: 8.0),
                  Expanded(
                    child: ListView.separated(
                      itemBuilder: (_, i) {
                        final time = (widget.eventInfo.data[i].start == null)
                            ? ''
                            : '${widget.eventInfo.data[i].start.substring(0, 5)} ';
                        return DialogOption(
                          check: (i == index),
                          text: '$time'
                              '${widget.eventInfo.data[i].name}',
                          onPressed: () {
                            setState(() {
                              index = i;
                            });
                          },
                        );
                      },
                      itemCount: widget.eventInfo?.data?.length ?? 0,
                      separatorBuilder: (BuildContext context, int index) =>
                          Divider(height: 6.0),
                    ),
                  ),
                ],
              ),
            ),
      leftActionText: ApLocalizations.of(context).cancel,
      rightActionText: ApLocalizations.of(context).submit,
      rightActionFunction: () {
        if ((widget.eventInfo?.data?.length ?? 0) != 0)
          widget.onSubmit(index);
        else
          ApUtils.showToast(context, '無資料無法送出');
      },
    );
  }
}
