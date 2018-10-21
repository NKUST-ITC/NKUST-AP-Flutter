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
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(AppLocalizations
            .of(context)
            .settings),
        backgroundColor: Resource.Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _titleItem("通知設定"),
              _itemSwitch("上課體醒", notifyCourse, () {
                notifyCourse = !notifyCourse;
                prefs.setBool(Constants.PREF_NOTIFY_COURSE, notifyCourse);
                Utils.showToast("功能尚未開放\n私密粉絲團 小編會告訴你何時開放");
                //setState(() {});
              }),
              _itemSwitch("校車提醒", notifyBus, () {
                notifyBus = !notifyBus;
                prefs.setBool(Constants.PREF_NOTIFY_BUS, notifyBus);
                Utils.showToast("功能尚未開放\n私密粉絲團 小編會告訴你何時開放");
                //setState(() {});
              }),
              Container(
                color: Colors.grey,
                height: 0.5,
              ),
              _titleItem("一般設定"),
              _itemSwitch("顯示大頭貼", displayPicture, () {
                displayPicture = !displayPicture;
                prefs.setBool(Constants.PREF_DISPLAY_PICTURE, displayPicture);
                setState(() {});
              }),
              _itemSwitch("上課震動", vibrateCourse, () {
                vibrateCourse = !vibrateCourse;
                prefs.setBool(Constants.PREF_VIBRATE_COURSE, vibrateCourse);
                Utils.showToast("功能尚未開放\n私密粉絲團 小編會告訴你何時開放");
                //setState(() {});
              }),
              Container(
                color: Colors.grey,
                height: 0.5,
              ),
              _titleItem("其他資訊"),
              _item("回饋意見", "私訊給粉絲專頁", () {
                Utils.launchUrl('https://www.facebook.com/954175941266264/');
              }),
              _item("Donate", "貢獻一點心力支持作者，\n可以提早使用未開放功能！", () {
                Utils.launchUrl(
                    "https://payment.ecpay.com.tw/QuickCollect/PayData?mLM7iy8RpUGk%2fyBotSDMdvI0qGI5ToToqBW%2bOQbOE80%3d");
              }),
              _item("App版本", Constants.APP_VERSION, () {}),
            ]),
      ),
    );
  }

  _titleItem(String text) =>
      Container(
        padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
        child: Text(
          text,
          style: TextStyle(color: Resource.Colors.blue, fontSize: 14.0),
          textAlign: TextAlign.start,
        ),
      );

  _itemSwitch(String text, bool value, Function function) =>
      FlatButton(
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
    displayPicture = prefs.getBool(Constants.PREF_DISPLAY_PICTURE) ?? true;
    setState(() {});
  }

  _item(String text, String subText, Function function) =>
      FlatButton(
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
