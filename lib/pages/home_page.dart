import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/pages/page.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;
import 'package:nkust_ap/api/helper.dart';
import 'package:nkust_ap/models/models.dart';
import 'package:nkust_ap/utils/app_localizations.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:nkust_ap/widgets/drawer_body.dart';
import 'package:nkust_ap/utils/utils.dart';

enum _Status { loading, finish, error, empty }

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
  _Status state = _Status.loading;
  AppLocalizations app;

  int _currentTabIndex = 0;
  int _currentNewsIndex = 0;

  List<Widget> newsWidgets = [];
  List<News> news = [];

  double contentHeight;

  @override
  void initState() {
    super.initState();
    _getAllNews();
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
            Utils.launchUrl(news.url);
          },
          child: Image.network(news.image)),
    );
  }

  Widget _homebody() {
    switch (state) {
      case _Status.loading:
        return Center(
          child: CircularProgressIndicator(),
        );
      case _Status.finish:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              news[_currentNewsIndex].title,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 20.0,
                  color: Resource.Colors.grey,
                  fontWeight: FontWeight.w500),
            ),
            Icon(Icons.arrow_drop_down),
            CarouselSlider(
              items: newsWidgets,
              viewportFraction: 0.65,
              aspectRatio: 7 / 6,
              autoPlay: false,
              updateCallback: (int current) {
                setState(() {
                  _currentNewsIndex = current;
                });
              },
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "${newsWidgets.length >= 10 && _currentNewsIndex < 9 ? "0" : ""}"
                      "${_currentNewsIndex + 1}",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Resource.Colors.red, fontSize: 32.0),
                ),
                Text(
                  " / ${newsWidgets.length}",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Resource.Colors.grey, fontSize: 32.0),
                )
              ],
            ),
          ],
        );
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          appBar: new AppBar(
            title: new Text(AppLocalizations.of(context).appName),
            backgroundColor: Resource.Colors.blue,
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.exit_to_app),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          ),
          drawer: DrawerBody(),
          body: Container(
            padding: EdgeInsets.symmetric(vertical: 32.0),
            child: Center(
              child: _homebody(),
            ),
          ),
          bottomNavigationBar: new BottomNavigationBar(
            fixedColor: Color(0xff737373),
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentTabIndex,
            onTap: onTabTapped,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.directions_bus),
                title: Text(AppLocalizations.of(context).bus),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.class_),
                title: Text(AppLocalizations.of(context).course),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.assignment),
                title: Text(AppLocalizations.of(context).score),
              ),
            ],
          ),
        ),
        onWillPop: () async {
          return false;
        });
  }

  void onTabTapped(int index) {
    setState(() {
      _currentTabIndex = index;
      switch (_currentTabIndex) {
        case 0:
          Navigator.of(context).push(BusPageRoute());
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

  _getAllNews() {
    state = _Status.loading;
    Helper.instance.getAllNews().then((news) {
      this.news = news;
      setState(() {
        news.forEach((news) {
          newsWidgets.add(_newImage(news));
        });
        state = news.length == 0 ? _Status.empty : _Status.finish;
      });
    }).catchError((e) {
      assert(e is DioError);
      DioError dioError = e as DioError;
      switch (dioError.type) {
        case DioErrorType.RESPONSE:
          Utils.showToast(AppLocalizations.of(context).tokenExpiredContent);
          Navigator.popUntil(
              context, ModalRoute.withName(Navigator.defaultRouteName));
          break;
        case DioErrorType.CANCEL:
          break;
        default:
          state = _Status.error;
          Utils.handleDioError(dioError, app);
          break;
      }
    });
  }
}
