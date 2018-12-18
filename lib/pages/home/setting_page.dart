import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;
import 'package:nkust_ap/utils/global.dart';
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

  AppLocalizations app;

  String appVersion = "1.0.0";

  @override
  void initState() {
    super.initState();
    FA.setCurrentScreen("SettingPage", "setting_page.dart");
    _getPreference();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    app = AppLocalizations.of(context);
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(app.settings),
        backgroundColor: Resource.Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _titleItem(app.notificationItem),
              _itemSwitch(app.courseNotify, notifyCourse, () {
                notifyCourse = !notifyCourse;
                prefs.setBool(Constants.PREF_NOTIFY_COURSE, notifyCourse);
                Utils.showToast(app.functionNotOpen);
                //setState(() {});
              }),
              _itemSwitch(app.busNotify, notifyBus, () {
                notifyBus = !notifyBus;
                prefs.setBool(Constants.PREF_NOTIFY_BUS, notifyBus);
                Utils.showToast(app.functionNotOpen);
                //setState(() {});
              }),
              Container(
                color: Colors.grey,
                height: 0.5,
              ),
              _titleItem(app.otherSettings),
              _itemSwitch(app.headPhotoSetting, displayPicture, () {
                displayPicture = !displayPicture;
                prefs.setBool(Constants.PREF_DISPLAY_PICTURE, displayPicture);
                setState(() {});
              }),
              _itemSwitch(app.courseVibrate, vibrateCourse, () {
                vibrateCourse = !vibrateCourse;
                prefs.setBool(Constants.PREF_VIBRATE_COURSE, vibrateCourse);
                Utils.showToast(app.functionNotOpen);
                //setState(() {});
              }),
              Container(
                color: Colors.grey,
                height: 0.5,
              ),
              _titleItem(app.otherInfo),
              _item(app.feedback, app.feedbackViaFacebook, () {
                if (Platform.isAndroid)
                  Utils.launchUrl('fb://messaging/954175941266264').catchError(
                      (onError) => Utils.launchUrl(
                          'https://www.facebook.com/954175941266264/'));
                else
                  Utils.launchUrl('https://www.facebook.com/954175941266264/');
              }),
              _item(app.donateTitle, app.donateContent, () {
                Utils.launchUrl(
                    "https://payment.ecpay.com.tw/QuickCollect/PayData?mLM7iy8RpUGk%2fyBotSDMdvI0qGI5ToToqBW%2bOQbOE80%3d");
              }),
              _item(app.appVersion, "v$appVersion", () {}),
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
