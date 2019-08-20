import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nkust_ap/config/constants.dart';
import 'package:nkust_ap/models/models.dart';
import 'package:nkust_ap/pages/home/midterm_alerts_page.dart';
import 'package:nkust_ap/pages/page.dart';
import 'package:nkust_ap/res/app_icon.dart';
import 'package:nkust_ap/res/app_theme.dart';
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
                if (widget.userInfo != null)
                  Utils.pushCupertinoStyle(
                    context,
                    UserInfoPage(userInfo: widget.userInfo),
                  );
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
                                  AppIcon.accountCircle,
                                  color: Colors.white,
                                  size: 72.0,
                                ),
                              ),
                    accountName: Text(
                      '${widget.userInfo?.name}',
                      style: TextStyle(color: Colors.white),
                    ),
                    accountEmail: Text(
                      '${widget.userInfo?.id}',
                      style: TextStyle(color: Colors.white),
                    ),
                    decoration: BoxDecoration(
                      color: Resource.Colors.blue,
                      image: DecorationImage(
                          image: AssetImage(ImageAssets.drawerBackground),
                          fit: BoxFit.fitWidth,
                          alignment: Alignment.bottomCenter),
                    ),
                  ),
                  Positioned(
                    bottom: 20.0,
                    right: 20.0,
                    child: Opacity(
                      opacity: AppTheme.drawerIconOpacity,
                      child: Image.asset(
                        ImageAssets.drawerIcon,
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
                AppIcon.school,
                color: isStudyExpanded
                    ? Resource.Colors.blueAccent
                    : Resource.Colors.grey,
              ),
              title: Text(app.courseInfo, style: _defaultStyle),
              children: <Widget>[
                _subItem(
                  icon: AppIcon.classIcon,
                  title: app.course,
                  page: CoursePage(),
                ),
                _subItem(
                  icon: AppIcon.assignment,
                  title: app.score,
                  page: ScorePage(),
                ),
                _subItem(
                  icon: AppIcon.apps,
                  title: app.calculateUnits,
                  page: CalculateUnitsPage(),
                ),
                _subItem(
                  icon: Icons.warning,
                  title: app.midtermAlerts,
                  page: MidtermAlertsPage(),
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
                AppIcon.calendarToday,
                color: isLeaveExpanded
                    ? Resource.Colors.blueAccent
                    : Resource.Colors.grey,
              ),
              title: Text(app.leave, style: _defaultStyle),
              children: <Widget>[
                _subItem(
                  icon: AppIcon.edit,
                  title: app.leaveApply,
                  page: LeavePage(initIndex: 0),
                ),
                _subItem(
                  icon: AppIcon.assignment,
                  title: app.leaveRecords,
                  page: LeavePage(initIndex: 1),
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
                AppIcon.directionsBus,
                color: isBusExpanded
                    ? Resource.Colors.blueAccent
                    : Resource.Colors.grey,
              ),
              title: Text(app.bus, style: _defaultStyle),
              children: <Widget>[
                _subItem(
                  icon: AppIcon.dateRange,
                  title: app.busReserve,
                  page: BusPage(initIndex: 0),
                ),
                _subItem(
                  icon: AppIcon.assignment,
                  title: app.busReservations,
                  page: BusPage(initIndex: 1),
                ),
              ],
            ),
            _item(
              icon: AppIcon.info,
              title: app.schoolInfo,
              page: SchoolInfoPage(),
            ),
            _item(
              icon: AppIcon.face,
              title: app.about,
              page: AboutUsPage(),
            ),
            _item(
              icon: AppIcon.settings,
              title: app.settings,
              page: SettingPage(),
            ),
            ListTile(
              leading: Icon(
                AppIcon.powerSettingsNew,
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
    @required Widget page,
  }) =>
      ListTile(
        leading: Icon(icon, color: Resource.Colors.grey),
        title: Text(title, style: _defaultStyle),
        onTap: () {
          Navigator.pop(context);
          Utils.pushCupertinoStyle(context, page);
        },
      );

  _subItem({
    @required IconData icon,
    @required String title,
    @required Widget page,
  }) =>
      ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 72.0),
        leading: Icon(icon, color: Resource.Colors.grey),
        title: Text(title, style: _defaultStyle),
        onTap: () async {
          if (Platform.isAndroid || Platform.isIOS) {
            if (page is BusPage) {
              bool bus = Preferences.getBool(Constants.PREF_BUS_ENABLE, true);
              if (!bus) {
                Utils.showToast(context, app.canNotUseFeature);
                return;
              }
            } else if (page is LeavePage) {
              bool leave = Preferences.getBool(Constants.PREF_BUS_ENABLE, true);
              if (!leave) {
                Utils.showToast(context, app.canNotUseFeature);
                return;
              }
            }
          }
          Navigator.of(context).pop();
          Utils.pushCupertinoStyle(context, page);
        },
      );

  _getUserPicture() async {
    try {
      var response = await http.get(widget.userInfo.pictureUrl);
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
    } catch (e) {
      throw e;
    }
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
