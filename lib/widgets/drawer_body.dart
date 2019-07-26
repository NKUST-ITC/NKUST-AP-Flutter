import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nkust_ap/api/helper.dart';
import 'package:nkust_ap/config/constants.dart';
import 'package:nkust_ap/models/models.dart';
import 'package:nkust_ap/pages/page.dart';
import 'package:nkust_ap/res/assets.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;
import 'package:nkust_ap/utils/app_localizations.dart';
import 'package:nkust_ap/utils/cache_utils.dart';
import 'package:nkust_ap/utils/preferences.dart';
import 'package:nkust_ap/utils/utils.dart';

Uint8List pictureBytes;

class DrawerBody extends StatefulWidget {
  final UserInfo userInfo;

  const DrawerBody({Key key, @required this.userInfo}) : super(key: key);

  @override
  DrawerBodyState createState() => DrawerBodyState();
}

class DrawerBodyState extends State<DrawerBody> {
  AppLocalizations app;

  bool displayPicture = true;
  bool isStudyExpanded = false;
  bool isBusExpanded = false;
  bool isLeaveExpanded = false;

  TextStyle get _defaultStyle =>
      TextStyle(color: Resource.Colors.grey, fontSize: 16.0);

  @override
  void initState() {
    _getPreference();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    app = AppLocalizations.of(context);
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            GestureDetector(
              onTap: () {
                if (widget.userInfo == null) return;
                if ((widget.userInfo.status == null
                        ? 200
                        : widget.userInfo.status) ==
                    200)
                  Navigator.of(context)
                      .push(UserInfoPageRoute(widget.userInfo));
                else
                  Utils.showToast(context, widget.userInfo.message);
              },
              child: Stack(
                children: <Widget>[
                  UserAccountsDrawerHeader(
                    margin: const EdgeInsets.all(0),
                    currentAccountPicture:
                        pictureBytes != null && displayPicture
                            ? Hero(
                                tag: Constants.TAG_STUDENT_PICTURE,
                                child: Container(
                                  width: 72.0,
                                  height: 72.0,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      fit: BoxFit.fitWidth,
                                      image: MemoryImage(
                                        pictureBytes,
                                      ),
                                    ),
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
                    accountName: Text(
                      '${widget.userInfo?.studentNameCht}',
                      style: TextStyle(color: Colors.white),
                    ),
                    accountEmail: Text(
                      '${widget.userInfo?.studentId}',
                      style: TextStyle(color: Colors.white),
                    ),
                    decoration: BoxDecoration(
                      color: Resource.Colors.blue500,
                      image: DecorationImage(
                          image: AssetImage(ImageAssets.drawerBackground),
                          fit: BoxFit.fitWidth,
                          alignment: Alignment.bottomCenter),
                    ),
                  ),
                  Positioned(
                    bottom: 20.0,
                    right: 20.0,
                    child: Image.asset(
                      ImageAssets.drawerIcon,
                      width: 90.0,
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
                Icons.school,
                color: isStudyExpanded
                    ? Resource.Colors.blueAccent
                    : Resource.Colors.grey,
              ),
              title: Text(app.courseInfo, style: _defaultStyle),
              children: <Widget>[
                _subItem(
                  icon: Icons.class_,
                  title: app.course,
                  route: CoursePageRoute(),
                ),
                _subItem(
                  icon: Icons.assignment,
                  title: app.score,
                  route: ScorePageRoute(),
                ),
                _subItem(
                  icon: Icons.apps,
                  title: app.calculateUnits,
                  route: CalculateUnitsPageRoute(),
                ),
              ],
            ),
            ExpansionTile(
              onExpansionChanged: (bool) {
                setState(() {
                  isLeaveExpanded = bool;
                });
              },
              leading: Icon(
                Icons.calendar_today,
                color: isLeaveExpanded
                    ? Resource.Colors.blueAccent
                    : Resource.Colors.grey,
              ),
              title: Text(app.leave, style: _defaultStyle),
              children: <Widget>[
                _subItem(
                  icon: Icons.edit,
                  title: app.leaveApply,
                  route: LeavePageRoute(initIndex: 0),
                ),
                _subItem(
                  icon: Icons.assignment,
                  title: app.leaveRecords,
                  route: LeavePageRoute(initIndex: 1),
                ),
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
                color: isBusExpanded
                    ? Resource.Colors.blueAccent
                    : Resource.Colors.grey,
              ),
              title: Text(app.bus, style: _defaultStyle),
              children: <Widget>[
                _subItem(
                  icon: Icons.date_range,
                  title: app.busReserve,
                  route: BusPageRoute(initIndex: 0),
                ),
                _subItem(
                  icon: Icons.assignment,
                  title: app.busReservations,
                  route: BusPageRoute(initIndex: 1),
                ),
              ],
            ),
            _item(
              icon: Icons.info,
              title: app.schoolInfo,
              route: SchoolInfoPageRoute(),
            ),
            _item(
              icon: Icons.face,
              title: app.about,
              route: AboutUsPageRoute(),
            ),
            _item(
              icon: Icons.settings,
              title: app.settings,
              route: SettingPageRoute(),
            ),
            ListTile(
              leading: Icon(
                Icons.power_settings_new,
                color: Resource.Colors.grey,
              ),
              onTap: () {
                Navigator.popUntil(
                    context, ModalRoute.withName(Navigator.defaultRouteName));
              },
              title: Text(app.logout, style: _defaultStyle),
            ),
          ],
        ),
      ),
    );
  }

  _item({
    @required IconData icon,
    @required String title,
    @required MaterialPageRoute route,
  }) =>
      ListTile(
        leading: Icon(icon, color: Resource.Colors.grey),
        title: Text(title, style: _defaultStyle),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(context, route);
        },
      );

  _subItem({
    @required IconData icon,
    @required String title,
    @required MaterialPageRoute route,
  }) =>
      ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 72.0),
        leading: Icon(icon, color: Resource.Colors.grey),
        title: Text(title, style: _defaultStyle),
        onTap: () async {
          if (Platform.isAndroid || Platform.isIOS) {
            if (route is BusPageRoute) {
              bool bus = Preferences.getBool(Constants.PREF_BUS_ENABLE, true);
              if (!bus) {
                Utils.showToast(context, app.canNotUseFeature);
                return;
              }
            } else if (route is LeavePageRoute) {
              bool leave = Preferences.getBool(Constants.PREF_BUS_ENABLE, true);
              if (!leave) {
                Utils.showToast(context, app.canNotUseFeature);
                return;
              }
            }
          }
          Navigator.of(context).pop();
          Navigator.of(context).push(route);
        },
      );

  _getUserPicture() {
    Helper.instance.getUsersPicture().then((url) async {
      try {
        var response = await http.get(url);
        if (!response.body.contains('html')) {
          if (mounted) {
            setState(() {
              pictureBytes = response.bodyBytes;
            });
          }
          CacheUtils.savePictureData(response.bodyBytes);
        } else {
          var bytes = await CacheUtils.loadPictureData();
          if (mounted) {
            setState(() {
              pictureBytes = bytes;
            });
          }
        }
      } catch (e) {}
    }).catchError((e) {
      if (e is DioError) {
        switch (e.type) {
          case DioErrorType.RESPONSE:
            Utils.handleResponseError(context, 'getUserPicture', mounted, e);
            break;
          default:
            break;
        }
      } else {
        throw e;
      }
    });
  }

  _getPreference() async {
    if (!Preferences.getBool(Constants.PREF_IS_OFFLINE_LOGIN, false)) {
      _getUserPicture();
    }
    setState(() {
      displayPicture =
          Preferences.getBool(Constants.PREF_DISPLAY_PICTURE, true);
    });
  }
}
