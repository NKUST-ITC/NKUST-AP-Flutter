import 'dart:io';

import 'package:ap_common/pages/announcement_content_page.dart';
import 'package:ap_common/scaffold/home_page_scaffold.dart';
import 'package:ap_common/utils/ap_utils.dart';
import 'package:ap_common/widgets/default_dialog.dart';
import 'package:ap_common/widgets/dialog_option.dart';
import 'package:ap_common/widgets/yes_no_dialog.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:barcode_scan/platform_wrapper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
import 'package:nkust_ap/widgets/drawer_body.dart';
import 'package:nkust_ap/widgets/share_data_widget.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class HomePage extends StatefulWidget {
  static const String routerName = "/home";

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  var state = HomeState.loading;

  AppLocalizations app;

  AnnouncementData announcementData;

  var isLogin = false;

  @override
  void initState() {
    FA.setCurrentScreen("HomePage", "home_page.dart");
    _getAnnouncements();
    if (Preferences.getBool(Constants.PREF_AUTO_LOGIN, false)) {
      _login();
    } else {
      checkLogin();
    }
    Utils.checkRemoteConfig(context, () {
      _getAnnouncements();
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
    return HomePageScaffold(
      title: app.appName,
      key: _scaffoldKey,
      state: state,
      announcements: announcementData?.data,
      isLogin: isLogin,
      actions: <Widget>[
        IconButton(
          icon: Icon(AppIcon.info),
          onPressed: _showInformationDialog,
        ),
        if (ShareDataWidget.of(context).data.loginResponse?.isAdmin ?? false)
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
      drawer: DrawerBody(
        userInfo: ShareDataWidget.of(context).data.userInfo,
        onClickLogin: () {
          openLoginPage();
        },
        onClickLogout: () {
          checkLogin();
        },
      ),
      onImageTapped: (Announcement announcement) {
        ApUtils.pushCupertinoStyle(
          context,
          AnnouncementContentPage(announcement: announcement),
        );
        String message = announcement.description.length > 12
            ? announcement.description
            : announcement.description.substring(0, 12);
//        FirebaseAnalyticsUtils.instance.logAction(
//          'news_image',
//          'click',
//          message: message,
//        );
      },
      onTabTapped: onTabTapped,
      bottomNavigationBarItems: [
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
    );
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

  _getAnnouncements() async {
    if (Preferences.getBool(Constants.PREF_IS_OFFLINE_LOGIN, false)) {
      setState(() {
        state = HomeState.offline;
      });
    } else
      Helper.instance.getAllAnnouncements().then((announcementsResponse) {
        this.announcementData = announcementsResponse;
        setState(() {
          state = announcementsResponse.data.length == 0
              ? HomeState.empty
              : HomeState.finish;
        });
      }).catchError((e) {
        setState(() {
          state = HomeState.error;
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
        state = HomeState.offline;
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
      if (state != HomeState.finish) {
        _getAnnouncements();
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
      if (state != HomeState.finish) {
        _getAnnouncements();
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
