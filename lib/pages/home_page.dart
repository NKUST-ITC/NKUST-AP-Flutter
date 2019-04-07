import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/models/models.dart';
import 'package:nkust_ap/res/colors.dart' as Resource;
import 'package:nkust_ap/utils/cache_utils.dart';
import 'package:nkust_ap/utils/global.dart';
import 'package:nkust_ap/widgets/drawer_body.dart';
import 'package:nkust_ap/widgets/hint_content.dart';
import 'package:nkust_ap/widgets/yes_no_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum _State { loading, finish, error, empty, offline }

class HomePageRoute extends MaterialPageRoute {
  HomePageRoute() : super(builder: (BuildContext context) => new HomePage());

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return new FadeTransition(opacity: animation, child: new HomePage());
  }
}

class HomePage extends StatefulWidget {
  static const String routerName = "/home";

  @override
  HomePageState createState() => new HomePageState();
}

class HomePageState extends State<HomePage> {
  _State state = _State.loading;
  AppLocalizations app;

  int _currentTabIndex = 0;
  int _currentNewsIndex = 0;
  UserInfo userInfo = UserInfo();

  List<Widget> newsWidgets = [];
  List<News> newsList = [];

  CarouselSlider cardSlider;

  @override
  void initState() {
    super.initState();
    FA.setCurrentScreen("HomePage", "home_page.dart");
    _getAllNews();
    _getUserInfo();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _newImage(News news) {
    return Container(
      margin: EdgeInsets.all(5.0),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(NewsContentPageRoute(news));
          String message = news.content.length > 12
              ? news.content
              : news.content.substring(0, 12);
          FA.logAction('news_image', 'click', message: message);
        },
        child: Hero(
          tag: news.hashCode,
          child: CachedNetworkImage(
            imageUrl: news.image,
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
        ),
      ),
    );
  }

  Widget _homebody(Orientation orientation) {
    var rate =
        MediaQuery.of(context).size.width / MediaQuery.of(context).size.height;
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
                  newsList[_currentNewsIndex].title,
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
            cardSlider = CarouselSlider(
              items: newsWidgets,
              viewportFraction:
                  orientation == Orientation.portrait ? 0.65 : 0.5,
              aspectRatio: orientation == Orientation.portrait
                  ? 7 / 6
                  : (rate > 1.5 ? 21 / 4 : 21 / 9),
              autoPlay: false,
              enlargeCenterPage: true,
              enableInfiniteScroll: false,
              onPageChanged: (int current) {
                setState(() {
                  _currentNewsIndex = current;
                });
                FA.logAction('news_image', 'swipe');
              },
            ),
            SizedBox(height: orientation == Orientation.portrait ? 16.0 : 4.0),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                  style: TextStyle(color: Resource.Colors.grey, fontSize: 24.0),
                  children: [
                    TextSpan(
                        text:
                            "${newsWidgets.length >= 10 && _currentNewsIndex < 9 ? "0" : ""}"
                            "${_currentNewsIndex + 1}",
                        style: TextStyle(color: Resource.Colors.red)),
                    TextSpan(text: ' / ${newsWidgets.length}'),
                  ]),
            ),
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

  @override
  Widget build(BuildContext context) {
    app = AppLocalizations.of(context);
    if (state == _State.offline) _setupBusNotify(context);
    return WillPopScope(
        child: Scaffold(
          appBar: AppBar(
            title: Text(app.appName),
            backgroundColor: Resource.Colors.blue,
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.exit_to_app),
                onPressed: _showLogoutDialog,
              )
            ],
          ),
          drawer: DrawerBody(userInfo: userInfo),
          body: OrientationBuilder(builder: (_, orientation) {
            return Container(
              padding: EdgeInsets.symmetric(
                  vertical: orientation == Orientation.portrait ? 32.0 : 4.0),
              child: Center(
                child: _homebody(orientation),
              ),
            );
          }),
          bottomNavigationBar: BottomNavigationBar(
            fixedColor: Color(0xff737373),
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentTabIndex,
            onTap: onTabTapped,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.directions_bus),
                title: Text(app.bus),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.class_),
                title: Text(app.course),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.assignment),
                title: Text(app.score),
              ),
            ],
          ),
        ),
        onWillPop: () async {
          if (Platform.isAndroid) _showLogoutDialog();
          return false;
        });
  }

  void onTabTapped(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool bus = prefs.getBool(Constants.PREF_BUS_ENABLE) ?? true;
    setState(() {
      _currentTabIndex = index;
      switch (_currentTabIndex) {
        case 0:
          if (bus)
            Navigator.of(context).push(BusPageRoute());
          else
            Utils.showToast(app.canNotUseFeature);
          break;
        case 1:
          Navigator.of(context).push(CoursePageRoute());
          break;
        case 2:
          Navigator.of(context).push(ScorePageRoute());
          break;
      }
    });
  }

  _getAllNews() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(Constants.PREF_IS_OFFLINE_LOGIN)) {
      setState(() {
        state = _State.offline;
      });
      return;
    }
    state = _State.loading;
    Helper.instance.getAllNews().then((newsList) {
      this.newsList = newsList;
      this.newsList.sort((a, b) {
        return b.weight.compareTo(a.weight);
      });
      this.newsList.forEach((news) {
        newsWidgets.add(_newImage(news));
      });
      setState(() {
        state = newsList.length == 0 ? _State.empty : _State.finish;
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
            Utils.handleDioError(e, app);
            break;
        }
      } else {
        throw e;
      }
    });
  }

  _setupBusNotify(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(Constants.PREF_BUS_NOTIFY) ?? false)
      Helper.instance
          .getBusReservations()
          .then((BusReservationsData response) async {
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(Constants.PREF_IS_OFFLINE_LOGIN)) {
      userInfo = await CacheUtils.loadUserInfo();
      setState(() {
        state = _State.offline;
      });
      return;
    }
    Helper.instance.getUsersInfo().then((response) {
      if (this.mounted) {
        setState(() {
          userInfo = response;
        });
        FA.setUserProperty('department', userInfo.department);
        FA.setUserId(userInfo.studentId);
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
                style: TextStyle(color: Resource.Colors.grey)),
            leftActionText: app.cancel,
            rightActionText: app.ok,
            rightActionFunction: () {
              Navigator.popUntil(
                  context, ModalRoute.withName(Navigator.defaultRouteName));
            },
          ),
    );
  }
}
