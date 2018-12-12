import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nkust_ap/pages/page.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;
import 'package:nkust_ap/api/helper.dart';
import 'package:nkust_ap/models/models.dart';
import 'package:nkust_ap/utils/app_localizations.dart';
import 'package:nkust_ap/config/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

var pictureUrl = "";
UserInfo userInfo;

class DrawerBody extends StatefulWidget {
  @override
  DrawerBodyState createState() => new DrawerBodyState();
}

class DrawerBodyState extends State<DrawerBody> {
  SharedPreferences prefs;
  bool displayPicture = true;

  AppLocalizations app;

  bool isStudyExpanded = false;
  bool isBusExpanded = false;

  @override
  void initState() {
    super.initState();
    _getPreference();
    _getUserPicture();
    _getUserInfo();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _defaultStyle() => TextStyle(color: Resource.Colors.grey, fontSize: 16.0);

  @override
  Widget build(BuildContext context) {
    app = AppLocalizations.of(context);
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              color: Color(0xff0071FF),
              width: double.infinity,
              child: Stack(
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    decoration: new BoxDecoration(
                      image: new DecorationImage(
                          image: new AssetImage(
                              "assets/images/drawer-backbroud.png"),
                          fit: BoxFit.fitWidth,
                          alignment: Alignment.bottomCenter),
                    ),
                    padding: EdgeInsets.all(20.0),
                    child: Flex(
                      direction: Axis.vertical,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(height: 40.0),
                        pictureUrl != "" && displayPicture
                            ? Container(
                                width: 72.0,
                                height: 72.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: new DecorationImage(
                                    fit: BoxFit.fill,
                                    image: NetworkImage(pictureUrl),
                                  ),
                                ),
                              )
                            : Container(
                                width: 72.0,
                                height: 72.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.account_circle,
                                  color: Colors.white,
                                  size: 72.0,
                                ),
                              ),
                        SizedBox(height: 16.0),
                        Text(
                          userInfo == null
                              ? ""
                              : "${userInfo.nameCht}\n"
                              "${userInfo.id}",
                          style: TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 20.0,
                    right: 20.0,
                    child: Container(
                      child: Image.asset(
                        "assets/images/drawer-icon.png",
                        width: 90.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ExpansionTile(
              onExpansionChanged: (bool) {
                setState(() {
                  isStudyExpanded = bool;
                });
              },
              leading: Icon(
                Icons.class_,
                color: isStudyExpanded
                    ? Resource.Colors.blue
                    : Resource.Colors.grey,
              ),
              title: Text(app.course, style: _defaultStyle()),
              children: <Widget>[
                _subItem(Icons.class_, app.course, CoursePageRoute()),
                _subItem(Icons.assignment, app.score, ScorePageRoute()),
              ],
            ),
            ExpansionTile(
              onExpansionChanged: (bool) {
                setState(() {
                  isBusExpanded = bool;
                });
              },
              leading: Icon(
                Icons.directions_bus,
                color:
                    isBusExpanded ? Resource.Colors.blue : Resource.Colors.grey,
              ),
              title: Text(app.bus, style: _defaultStyle()),
              children: <Widget>[
                _subItem(Icons.date_range, app.busReserve,
                    BusPageRoute(initIndex: 0)),
                _subItem(Icons.assignment, app.busReservations,
                    BusPageRoute(initIndex: 1)),
              ],
            ),
            _item(Icons.info, app.schoolInfo, SchoolInfoPageRoute()),
            _item(Icons.face, app.about, AboutUsPageRoute()),
            _item(Icons.settings, app.settings, SettingPageRoute()),
            ListTile(
              leading: Icon(
                Icons.power_settings_new,
                color: Resource.Colors.grey,
              ),
              onTap: () {
                Navigator.popUntil(
                    context, ModalRoute.withName(Navigator.defaultRouteName));
              },
              title: Text(app.logout, style: _defaultStyle()),
            ),
          ],
        ),
      ),
    );
  }

  _item(IconData icon, String title, MaterialPageRoute route) => ListTile(
        leading: Icon(icon, color: Resource.Colors.grey),
        title: Text(title, style: _defaultStyle()),
        onTap: () {
          Navigator.of(context).pop();
          Navigator.of(context).push(route);
        },
      );

  _subItem(IconData icon, String title, MaterialPageRoute route) => ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 72.0),
        leading: Icon(icon, color: Resource.Colors.grey),
        title: Text(title, style: _defaultStyle()),
        onTap: () {
          Navigator.of(context).pop();
          Navigator.of(context).push(route);
        },
      );

  _getUserPicture() {
    Helper.instance.getUsersPicture().then((url) {
      if (this.mounted) {
        setState(() {
          pictureUrl = url;
        });
      }
    }).catchError((e) {
      assert(e is DioError);
      DioError dioError = e as DioError;
      switch (dioError.type) {
        case DioErrorType.RESPONSE:
          Utils.showToast(app.tokenExpiredContent);
          Navigator.popUntil(
              context, ModalRoute.withName(LoginPage.routerName));
          break;
        default:
          break;
      }
    });
  }

  _getUserInfo() {
    Helper.instance.getUsersInfo().then((response) {
      if (this.mounted) {
        setState(() {
          userInfo = response;
        });
      }
    }).catchError((e) {
      assert(e is DioError);
      DioError dioError = e as DioError;
      switch (dioError.type) {
        case DioErrorType.RESPONSE:
          Utils.showToast(app.tokenExpiredContent);
          Navigator.popUntil(
              context, ModalRoute.withName(LoginPage.routerName));
          break;
        default:
          break;
      }
    });
  }

  _getPreference() async {
    prefs = await SharedPreferences.getInstance();
    displayPicture = prefs.getBool(Constants.PREF_DISPLAY_PICTURE) ?? true;
    setState(() {});
  }
}
