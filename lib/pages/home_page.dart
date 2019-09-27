import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/models/announcements_data.dart';
import 'package:nkust_ap/models/login_response.dart';
import 'package:nkust_ap/models/models.dart';
import 'package:nkust_ap/res/app_icon.dart';
import 'package:nkust_ap/res/colors.dart' as Resource;
import 'package:nkust_ap/utils/cache_utils.dart';
import 'package:nkust_ap/utils/global.dart';
import 'package:nkust_ap/utils/preferences.dart';
import 'package:nkust_ap/widgets/drawer_body.dart';
import 'package:nkust_ap/widgets/hint_content.dart';
import 'package:nkust_ap/widgets/progress_dialog.dart';
import 'package:nkust_ap/widgets/share_data_widget.dart';
import 'package:nkust_ap/widgets/yes_no_dialog.dart';

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
    Utils.checkUpdate(context);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    app = AppLocalizations.of(context);
    if (state != _State.offline) _setupBusNotify(context);
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
            )
          ],
        ),
        drawer: DrawerBody(
            userInfo: ShareDataWidget.of(context).data.userInfo,
            onClickLogout: () {
              checkLogin();
            }),
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
      ),
      onWillPop: () async {
        if (Platform.isAndroid) _showLogoutDialog();
        return false;
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
              ? announcement.title
              : announcement.title.substring(0, 12);
          FA.logAction('news_image', 'click', message: message);
        },
        child: Hero(
          tag: announcement.hashCode,
          child: (Platform.isIOS || Platform.isAndroid)
              ? CachedNetworkImage(
                  imageUrl: announcement.imgUrl,
                  errorWidget: (context, url, error) => Icon(Icons.error),
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
                  return _newsImage(announcementsResponse.data[currentIndex],
                      orientation, active);
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
          icon: Icons.offline_bolt,
          content: app.offlineMode,
        );
      default:
        return Container();
    }
  }

  void onTabTapped(int index) async {
    switch (index) {
      case 0:
//        if (bus)
        Utils.pushCupertinoStyle(context, BusPage());
//        else
//          Utils.showToast(context, app.canNotUseFeature);
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
        this.announcementsResponse.data.sort((a, b) {
          return b.weight.compareTo(a.weight);
        });
        setState(() {
          state = announcementsResponse.data.length == 0
              ? _State.empty
              : _State.finish;
        });
      }).catchError((e) {
        if (e is DioError) {
          switch (e.type) {
            case DioErrorType.RESPONSE:
              Utils.handleResponseError(context, 'getAllNews', mounted, e);
              break;
            case DioErrorType.CANCEL:
              break;
            default:
              state = _State.error;
              Utils.handleDioError(context, e);
              break;
          }
        } else {
          throw e;
        }
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
        title: app.logout,
        contentWidget: Text(app.logoutCheck,
            textAlign: TextAlign.center,
            style: TextStyle(color: Resource.Colors.greyText)),
        leftActionText: app.cancel,
        rightActionText: app.ok,
        rightActionFunction: () {
          ShareDataWidget.of(context).data.logout();
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
    showDialog(
      context: context,
      builder: (BuildContext context) => WillPopScope(
          child: ProgressDialog(app.logining),
          onWillPop: () async {
            return false;
          }),
      barrierDismissible: false,
    );
    Helper.instance
        .login(username, password)
        .then((LoginResponse response) async {
      if (Navigator.canPop(context))
        Navigator.of(context, rootNavigator: true).pop();
      ShareDataWidget.of(context).data.loginResponse = response;
      ShareDataWidget.of(context).data.isLogin = true;
      _getUserInfo();
    }).catchError((e) {
      if (Navigator.canPop(context))
        Navigator.of(context, rootNavigator: true).pop();
      if (e is DioError) {
        switch (e.type) {
          case DioErrorType.RESPONSE:
            Utils.showToast(context, app.loginFail);
            Utils.handleResponseError(context, 'login', mounted, e);
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

  void checkLogin() async {
    await Future.delayed(Duration(microseconds: 30));
    print(ShareDataWidget.of(context).data.isLogin);
    if (ShareDataWidget.of(context).data.isLogin) {
      // _scaffoldKey.currentState.hideCurrentSnackBar();
    } else {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text(app.notLogin),
          duration: Duration(days: 1),
          action: SnackBarAction(
            onPressed: () async {
              var result = await Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (_) => LoginPage(),
                ),
              );
              if (result ?? false) {
                _getUserInfo();
                setState(() {
                  ShareDataWidget.of(context).data.isLogin = true;
                });
              } else {
                checkLogin();
              }
            },
            label: app.login,
          ),
        ),
      );
    }
  }
}
