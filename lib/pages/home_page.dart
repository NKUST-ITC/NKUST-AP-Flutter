import 'dart:io';

import 'package:ap_common/widgets/default_dialog.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:barcode_scan/platform_wrapper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nkust_ap/models/announcements_data.dart';
import 'package:nkust_ap/models/event_callback.dart';
import 'package:nkust_ap/models/event_info_response.dart';
import 'package:nkust_ap/models/general_response.dart';
import 'package:nkust_ap/models/login_response.dart';
import 'package:nkust_ap/models/models.dart';
import 'package:nkust_ap/pages/home/news/news_admin_page.dart';
import 'package:nkust_ap/res/app_icon.dart';
import 'package:nkust_ap/res/colors.dart' as Resource;
import 'package:nkust_ap/utils/cache_utils.dart';
import 'package:nkust_ap/utils/global.dart';
import 'package:nkust_ap/utils/preferences.dart';
import 'package:nkust_ap/widgets/dialog_option.dart';
import 'package:nkust_ap/widgets/drawer_body.dart';
import 'package:nkust_ap/widgets/hint_content.dart';
import 'package:nkust_ap/widgets/share_data_widget.dart';
import 'package:nkust_ap/widgets/yes_no_dialog.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:share/share.dart';

enum _State { loading, finish, error, empty, offline }

class HomePage extends StatefulWidget {
  static const String routerName = "/home";

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  _State state = _State.loading;
  AppLocalizations app;

  int _currentNewsIndex = 0;

  AnnouncementsData announcementsResponse;

  @override
  void initState() {
    FA.setCurrentScreen("HomePage", "home_page.dart");
    _getNewsAll();
    if (Preferences.getBool(Constants.PREF_AUTO_LOGIN, false)) {
      _login();
    } else {
      checkLogin();
    }
    Utils.checkRemoteConfig(context, () {
      _getNewsAll();
      if (Preferences.getBool(Constants.PREF_AUTO_LOGIN, false)) {
        _login();
      }
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
    return WillPopScope(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(app.appName),
          backgroundColor: Resource.Colors.blue,
          actions: <Widget>[
            IconButton(
              icon: Icon(AppIcon.info),
              onPressed: _showInformationDialog,
            ),
            if (ShareDataWidget.of(context).data.loginResponse?.isAdmin ??
                false)
              IconButton(
                icon: Icon(Icons.add_to_queue),
                onPressed: () {
                  Utils.pushCupertinoStyle(
                    context,
                    NewsAdminPage(isAdmin: true),
                  );
                },
              )
          ],
        ),
        drawer: DrawerBody(
          userInfo: ShareDataWidget.of(context).data.userInfo,
          onClickLogin: () {
            openLoginPage();
          },
          onClickLogout: () {
            checkLogin();
          },
        ),
        body: OrientationBuilder(
          builder: (_, orientation) {
            return Container(
              padding: EdgeInsets.symmetric(
                vertical: orientation == Orientation.portrait ? 32.0 : 4.0,
              ),
              alignment: Alignment.center,
              child: _homebody(orientation),
            );
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          elevation: 12.0,
          fixedColor: Resource.Colors.bottomNavigationSelect,
          unselectedItemColor: Resource.Colors.bottomNavigationSelect,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 12.0,
          unselectedFontSize: 12.0,
          selectedIconTheme: IconThemeData(size: 24.0),
          onTap: onTabTapped,
          items: [
            BottomNavigationBarItem(
              icon: Icon(AppIcon.directionsBus),
              title: Text(app.bus),
            ),
            BottomNavigationBarItem(
              icon: Icon(AppIcon.classIcon),
              title: Text(app.course),
            ),
            BottomNavigationBarItem(
              icon: Icon(AppIcon.assignment),
              title: Text(app.score),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            if (ShareDataWidget.of(context).data.isLogin) {
              var result = await BarcodeScanner.scan(
                options: ScanOptions(
                  restrictFormat: [BarcodeFormat.qr],
                ),
              );
              if (result.type == ResultType.Barcode) {
                if (Preferences.getBool(Constants.PREF_AUTO_SEND_EVENT, false))
                  _sendEvent(result.rawContent, null);
                else
                  _getEventInfo(result.rawContent);
              } else
                Utils.showToast(context, app.cancel);
            } else
              Utils.showToast(context, app.notLogin);
          },
          label: Text(
            app.punch,
            style: TextStyle(color: Colors.white),
          ),
          icon: Icon(
            OMIcons.camera,
            color: Colors.white,
          ),
        ),
      ),
      onWillPop: () async {
        if (Platform.isAndroid) {
          _showLogoutDialog();
          return false;
        }
        return true;
      },
    );
  }

  Widget _newsImage(
      Announcements announcement, Orientation orientation, bool active) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOutQuint,
      margin: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * (active ? 0.05 : 0.15),
          horizontal: MediaQuery.of(context).size.width * 0.02),
      child: GestureDetector(
        onTap: () {
          Utils.pushCupertinoStyle(
            context,
            NewsContentPage(announcement),
          );
          String message = announcement.title.length > 12
              ? announcement.title.substring(0, 12)
              : announcement.title;
          FA.logAction('news_image', 'click', message: message);
        },
        child: Hero(
          tag: announcement.hashCode,
          child: kIsWeb
              ? Image.network(announcement.imgUrl)
              : (Platform.isIOS || Platform.isAndroid)
                  ? CachedNetworkImage(
                      imageUrl: announcement.imgUrl,
                      errorWidget: (context, url, error) => Icon(AppIcon.error),
                    )
                  : Image.network(announcement.imgUrl),
        ),
      ),
    );
  }

  Widget _homebody(Orientation orientation) {
    double viewportFraction = 0.65;
    if (orientation == Orientation.portrait) {
      viewportFraction = 0.65;
    } else if (orientation == Orientation.landscape) {
      viewportFraction = 0.5;
    }
    final PageController pageController =
        PageController(viewportFraction: viewportFraction);
    pageController.addListener(() {
      int next = pageController.page.round();
      if (_currentNewsIndex != next) {
        setState(() {
          _currentNewsIndex = next;
        });
      }
    });
    switch (state) {
      case _State.loading:
        return Center(
          child: CircularProgressIndicator(),
        );
      case _State.finish:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Hero(
              tag: Constants.TAG_NEWS_TITLE,
              child: Material(
                color: Colors.transparent,
                child: Text(
                  announcementsResponse.data[_currentNewsIndex].title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 20.0,
                      color: Resource.Colors.grey,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ),
            Hero(
              tag: Constants.TAG_NEWS_ICON,
              child: Icon(Icons.arrow_drop_down),
            ),
            Expanded(
              child: PageView.builder(
                controller: pageController,
                itemCount: announcementsResponse.data.length,
                itemBuilder: (context, int currentIndex) {
                  bool active = (currentIndex == _currentNewsIndex);
                  return _newsImage(
                    announcementsResponse.data[currentIndex],
                    orientation,
                    active,
                  );
                },
              ),
            ),
            SizedBox(height: orientation == Orientation.portrait ? 16.0 : 4.0),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(color: Resource.Colors.grey, fontSize: 24.0),
                children: [
                  TextSpan(
                      text:
                          '${announcementsResponse.data.length >= 10 && _currentNewsIndex < 9 ? '0' : ''}'
                          '${_currentNewsIndex + 1}',
                      style: TextStyle(color: Resource.Colors.red)),
                  TextSpan(text: ' / ${announcementsResponse.data.length}'),
                ],
              ),
            ),
            SizedBox(height: orientation == Orientation.portrait ? 24.0 : 0.0),
          ],
        );
      case _State.offline:
        return HintContent(
          icon: AppIcon.offlineBolt,
          content: app.offlineMode,
        );
      case _State.error:
        return HintContent(
          icon: AppIcon.offlineBolt,
          content: app.somethingError,
        );
      default:
        return Container();
    }
  }

  void onTabTapped(int index) async {
    switch (index) {
      case 0:
        Utils.pushCupertinoStyle(context, BusPage());
        break;
      case 1:
        Utils.pushCupertinoStyle(context, CoursePage());
        break;
      case 2:
        Utils.pushCupertinoStyle(context, ScorePage());
        break;
    }
  }

  _getNewsAll() async {
    if (Preferences.getBool(Constants.PREF_IS_OFFLINE_LOGIN, false)) {
      setState(() {
        state = _State.offline;
      });
    } else
      Helper.instance.getAllAnnouncements().then((announcementsResponse) {
        this.announcementsResponse = announcementsResponse;
        setState(() {
          state = announcementsResponse.data.length == 0
              ? _State.empty
              : _State.finish;
        });
      }).catchError((e) {
        setState(() {
          state = _State.error;
        });
      });
  }

  _setupBusNotify(BuildContext context) async {
    if (Preferences.getBool(Constants.PREF_BUS_NOTIFY, false))
      Helper.instance
          .getBusReservations()
          .then((BusReservationsData response) async {
        if (response != null)
          await Utils.setBusNotify(context, response.reservations);
      }).catchError((e) {
        if (e is DioError) {
          switch (e.type) {
            case DioErrorType.RESPONSE:
              break;
            case DioErrorType.DEFAULT:
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

  _getUserInfo() async {
    if (Preferences.getBool(Constants.PREF_IS_OFFLINE_LOGIN, false)) {
      ShareDataWidget.of(context).data.userInfo =
          await CacheUtils.loadUserInfo();
      setState(() {
        state = _State.offline;
      });
    } else
      Helper.instance.getUsersInfo().then((userInfo) {
        if (this.mounted) {
          setState(() {
            ShareDataWidget.of(context).data.userInfo = userInfo;
          });
          FA.setUserProperty('department', userInfo.department);
          FA.setUserProperty('student_id', userInfo.id);
          FA.setUserId(userInfo.id);
          FA.logUserInfo(userInfo.department);
          ShareDataWidget.of(context).data.userInfo = userInfo;
          CacheUtils.saveUserInfo(userInfo);
        }
      }).catchError((e) {
        if (e is DioError) {
          switch (e.type) {
            case DioErrorType.RESPONSE:
              Utils.handleResponseError(context, 'getUserInfo', mounted, e);
              break;
            default:
              break;
          }
        } else {
          throw e;
        }
      });
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => YesNoDialog(
        title: app.closeAppTitle,
        contentWidget: Text(
          app.closeAppHint,
          textAlign: TextAlign.center,
          style: TextStyle(color: Resource.Colors.greyText),
        ),
        leftActionText: app.cancel,
        rightActionText: app.confirm,
        rightActionFunction: () {
          SystemNavigator.pop();
        },
      ),
    );
  }

  void _showInformationDialog() {
    FA.logAction('news_rule', 'click');
    showDialog(
      context: context,
      builder: (BuildContext context) => YesNoDialog(
        title: app.newsRuleTitle,
        contentWidget: RichText(
          text: TextSpan(
              style: TextStyle(color: Resource.Colors.grey, fontSize: 16.0),
              children: [
                TextSpan(
                    text: '${app.newsRuleDescription1}',
                    style: TextStyle(fontWeight: FontWeight.normal)),
                TextSpan(
                    text: '${app.newsRuleDescription2}',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(
                    text: '${app.newsRuleDescription3}',
                    style: TextStyle(fontWeight: FontWeight.normal)),
              ]),
        ),
        leftActionText: app.cancel,
        rightActionText: app.contactFansPage,
        leftActionFunction: () {},
        rightActionFunction: () {
          if (Platform.isAndroid)
            Utils.launchUrl('fb://messaging/${Constants.FANS_PAGE_ID}')
                .catchError(
                    (onError) => Utils.launchUrl(Constants.FANS_PAGE_URL));
          else if (Platform.isIOS)
            Utils.launchUrl(
                    'fb-messenger://user-thread/${Constants.FANS_PAGE_ID}')
                .catchError(
                    (onError) => Utils.launchUrl(Constants.FANS_PAGE_URL));
          else {
            Utils.launchUrl(Constants.FANS_PAGE_URL).catchError(
                (onError) => Utils.showToast(context, app.platformError));
          }
          FA.logAction('contact_fans_page', 'click');
        },
      ),
    );
  }

  Future _login() async {
    await Future.delayed(Duration(microseconds: 30));
    var username = Preferences.getString(Constants.PREF_USERNAME, '');
    var password = Preferences.getStringSecurity(Constants.PREF_PASSWORD, '');
    Helper.instance
        .login(username, password)
        .then((LoginResponse response) async {
      ShareDataWidget.of(context).data.loginResponse = response;
      ShareDataWidget.of(context).data.isLogin = true;
      Preferences.setBool(Constants.PREF_IS_OFFLINE_LOGIN, false);
      _getUserInfo();
      _setupBusNotify(context);
      if (state != _State.finish) {
        _getNewsAll();
      }
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text(app.loginSuccess),
          duration: Duration(seconds: 2),
        ),
      );
    }).catchError((e) {
      String text = app.loginFail;
      if (e is DioError) {
        switch (e.type) {
          case DioErrorType.DEFAULT:
            text = app.noInternet;
            break;
          case DioErrorType.CONNECT_TIMEOUT:
          case DioErrorType.RECEIVE_TIMEOUT:
          case DioErrorType.SEND_TIMEOUT:
            text = app.timeoutMessage;
            break;
          default:
            break;
        }
        Preferences.setBool(Constants.PREF_IS_OFFLINE_LOGIN, true);
        Utils.showToast(context, app.loadOfflineData);
        ShareDataWidget.of(context).data.isLogin = true;
      }
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text(text),
          duration: Duration(days: 1),
          action: SnackBarAction(
            onPressed: _login,
            label: app.retry,
            textColor: Resource.Colors.snackBarActionTextColor,
          ),
        ),
      );
      if (!(e is DioError)) throw e;
    });
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
      if (state != _State.finish) {
        _getNewsAll();
      }
      setState(() {
        ShareDataWidget.of(context).data.isLogin = true;
      });
    }
  }

  void checkLogin() async {
    await Future.delayed(Duration(microseconds: 30));
    if (ShareDataWidget.of(context).data.isLogin) {
      _scaffoldKey.currentState.hideCurrentSnackBar();
    } else {
      _scaffoldKey.currentState
          .showSnackBar(
            SnackBar(
              content: Text(app.notLogin),
              duration: Duration(days: 1),
              action: SnackBarAction(
                onPressed: openLoginPage,
                label: app.login,
                textColor: Resource.Colors.snackBarActionTextColor,
              ),
            ),
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
      callback: EventInfoCallback(
        onFailure: (DioError e) => Utils.handleDioError(context, e),
        onError: (GeneralResponse generalResponse) {
          switch (generalResponse.code) {
            case 403:
              Utils.showToast(context, app.canNotUseFeature);
              break;
            case 401:
              Utils.showToast(context, app.tokenExpiredContent);
              break;
            default:
              Utils.showToast(context, generalResponse.description);
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
      callback: EventSendCallback(
        onFailure: (DioError e) => Utils.handleDioError(context, e),
        onError: (EventInfoResponse response) {
          switch (response.code) {
            case 403:
              Utils.showToast(context, app.canNotUseFeature);
              break;
            case 401:
              _showEventInfoDialog(data, response);
              break;
            default:
              Utils.showToast(context, response.description);
              break;
          }
        },
        onSuccess: (eventSendResponse) {
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
                style: TextStyle(color: Resource.Colors.greyText),
              ),
              actionFunction: () {
                Navigator.of(context).pop();
              },
              actionText: app.ok,
            ),
          );
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
              child: Text(AppLocalizations.of(context).noData),
            )
          : Container(
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.height * 0.3,
              child: Column(
                children: <Widget>[
                  SizedBox(height: 8.0),
                  Text(
                    '請選擇欲送出的項目',
                    style: TextStyle(color: Resource.Colors.greyText),
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
      leftActionText: AppLocalizations.of(context).cancel,
      rightActionText: AppLocalizations.of(context).submit,
      rightActionFunction: () {
        if ((widget.eventInfo?.data?.length ?? 0) != 0)
          widget.onSubmit(index);
        else
          Utils.showToast(context, '無資料無法送出');
      },
    );
  }
}
