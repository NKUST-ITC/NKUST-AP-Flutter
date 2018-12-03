import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;
import 'package:nkust_ap/api/helper.dart';
import 'package:nkust_ap/models/models.dart';
import 'package:flutter/cupertino.dart';
import 'package:nkust_ap/pages/page.dart';
import 'package:nkust_ap/utils/app_localizations.dart';
import 'package:nkust_ap/utils/utils.dart';
import 'package:nkust_ap/config/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info/package_info.dart';

class SettingPageRoute extends MaterialPageRoute {
  SettingPageRoute()
      : super(builder: (BuildContext context) => new SettingPage());

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return new FadeTransition(opacity: animation, child: new SettingPage());
  }
}

class SettingPage extends StatefulWidget {
  static const String routerName = "/setting";

  @override
  SettingPageState createState() => new SettingPageState();
}

class SettingPageState extends State<SettingPage>
    with SingleTickerProviderStateMixin {
  SharedPreferences prefs;

  var notifyBus = false,
      notifyCourse = false,
      displayPicture = true,
      vibrateCourse = false;

  AppLocalizations local;

  String appVersion = "1.0.0";

  @override
  void initState() {
    super.initState();
    _getPreference();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    local = AppLocalizations.of(context);
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(local.settings),
        backgroundColor: Resource.Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _titleItem(local.notificationItem),
              _itemSwitch(local.courseNotify, notifyCourse, () {
                notifyCourse = !notifyCourse;
                prefs.setBool(Constants.PREF_NOTIFY_COURSE, notifyCourse);
                Utils.showToast(local.functionNotOpen);
                //setState(() {});
              }),
              _itemSwitch(local.busNotify, notifyBus, () {
                notifyBus = !notifyBus;
                prefs.setBool(Constants.PREF_NOTIFY_BUS, notifyBus);
                Utils.showToast(local.functionNotOpen);
                //setState(() {});
              }),
              Container(
                color: Colors.grey,
                height: 0.5,
              ),
              _titleItem(local.otherSettings),
              _itemSwitch(local.headPhotoSetting, displayPicture, () {
                displayPicture = !displayPicture;
                prefs.setBool(Constants.PREF_DISPLAY_PICTURE, displayPicture);
                setState(() {});
              }),
              _itemSwitch(local.courseVibrate, vibrateCourse, () {
                vibrateCourse = !vibrateCourse;
                prefs.setBool(Constants.PREF_VIBRATE_COURSE, vibrateCourse);
                Utils.showToast(local.functionNotOpen);
                //setState(() {});
              }),
              Container(
                color: Colors.grey,
                height: 0.5,
              ),
              _titleItem(local.otherInfo),
              _item(local.feedback, local.feedbackViaFacebook, () {
                if (Platform.isAndroid)
                  Utils.launchUrl('fb://messaging/954175941266264').catchError(
                      (onError) => Utils.launchUrl(
                          'https://www.facebook.com/954175941266264/'));
                else
                  Utils.launchUrl('https://www.facebook.com/954175941266264/');
              }),
              _item(local.donateTitle, local.donateContent, () {
                Utils.launchUrl(
                    "https://payment.ecpay.com.tw/QuickCollect/PayData?mLM7iy8RpUGk%2fyBotSDMdvI0qGI5ToToqBW%2bOQbOE80%3d");
              }),
              _item(local.appVersion, "v$appVersion", () {}),
            ]),
      ),
    );
  }

  _titleItem(String text) => Container(
        padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
        child: Text(
          text,
          style: TextStyle(color: Resource.Colors.blue, fontSize: 14.0),
          textAlign: TextAlign.start,
        ),
      );

  _itemSwitch(String text, bool value, Function function) => FlatButton(
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              text,
              style: TextStyle(fontSize: 16.0),
            ),
            Switch(
              value: value,
              activeColor: Resource.Colors.blue,
              activeTrackColor: Resource.Colors.blue,
              onChanged: (b) {
                function();
              },
            ),
          ],
        ),
        onPressed: function,
      );

  _getPreference() async {
    prefs = await SharedPreferences.getInstance();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appVersion = packageInfo.version;
    displayPicture = prefs.getBool(Constants.PREF_DISPLAY_PICTURE) ?? true;
    setState(() {});
  }

  _item(String text, String subText, Function function) => FlatButton(
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Container(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                text,
                style: TextStyle(fontSize: 16.0),
              ),
              Text(
                subText,
                style: TextStyle(fontSize: 14.0, color: Resource.Colors.grey),
              ),
            ],
          ),
        ),
        onPressed: function,
      );
}
