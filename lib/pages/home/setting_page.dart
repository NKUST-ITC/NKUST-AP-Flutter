import 'package:flutter/material.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;
import 'package:nkust_ap/api/helper.dart';
import 'package:nkust_ap/models/models.dart';
import 'package:flutter/cupertino.dart';
import 'package:nkust_ap/pages/page.dart';
import 'package:nkust_ap/utils/app_localizations.dart';
import 'package:nkust_ap/utils/utils.dart';

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
  var displayIcon = false,
      notifyBus = false,
      notifyCourse = false,
      vibrateCourse = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(AppLocalizations.of(context).settings),
        backgroundColor: Resource.Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _titleItem("通知設定"),
              _itemSwitch("上課體醒", notifyCourse, () {
                notifyCourse = !notifyCourse;
                setState(() {});
              }),
              _itemSwitch("校車提醒", notifyBus, () {
                notifyBus = !notifyBus;
                setState(() {});
              }),
              Container(
                color: Colors.grey,
                height: 0.5,
              ),
              _titleItem("一般設定"),
              _itemSwitch("顯示大頭貼", displayIcon, () {
                displayIcon = !displayIcon;
                setState(() {});
              }),
              _itemSwitch("上課震動", vibrateCourse, () {
                vibrateCourse = !vibrateCourse;
                setState(() {});
              }),
              Container(
                color: Colors.grey,
                height: 0.5,
              ),
              _titleItem("其他資訊"),
              _item("回饋意見", "私訊給粉絲專頁", () {}),
              _item("Donate", "貢獻一點心力支持作者，\n可以提早使用未開放功能！", () {
                Utils.launchUrl("market://details?id=com.kuas.ap");
              }),
              _item("App版本", "v0.3.1", () {}),
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
              onChanged: null,
            ),
          ],
        ),
        onPressed: function,
      );

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
