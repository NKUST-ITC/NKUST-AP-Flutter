import 'dart:convert';
import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Drawer(
      semanticLabel: "測試",
      child: Column(
        children: <Widget>[
          Container(
            decoration: new BoxDecoration(
              image: new DecorationImage(
                image: new AssetImage("assets/images/kuasap3.png"),
                fit: BoxFit.fill,
              ),
            ),
            width: double.infinity,
            child: Container(
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
          ),
          _item(Icons.class_, AppLocalizations.of(context).course,
              CoursePageRoute()),
          _item(Icons.assignment, AppLocalizations.of(context).score,
              ScorePageRoute()),
          _item(Icons.directions_bus, AppLocalizations.of(context).bus,
              BusPageRoute()),
          _item(Icons.info, AppLocalizations.of(context).schoolInfo,
              SchoolInfoPageRoute()),
          _item(Icons.face, AppLocalizations.of(context).about,
              AboutUsPageRoute()),
          _item(Icons.settings, AppLocalizations.of(context).settings,
              SettingPageRoute()),
        ],
      ),
    );
  }

  _item(IconData icon, String title, MaterialPageRoute route) => FlatButton(
      onPressed: () {
        Navigator.of(context).pop();
        Navigator.of(context).push(route);
      },
      child: Row(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(18.0),
            child: Icon(
              icon,
              size: 24.0,
              color: Resource.Colors.grey,
            ),
          ),
          SizedBox(width: 4.0),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(color: Resource.Colors.grey, fontSize: 16.0),
          )
        ],
      ));

  _getUserPicture() {
    Helper.instance.getUsersPicture().then((response) {
      if (response == null) {
        return;
      }
      pictureUrl = response.data;
      setState(() {});
    });
  }

  _getUserInfo() {
    Helper.instance.getUsersInfo().then((response) {
      if (response == null) {
        return;
      }
      JsonCodec jsonCodec = JsonCodec();
      var json = jsonCodec.decode(response.data);
      userInfo = UserInfo.fromJson(json);
      setState(() {});
    });
  }
  _getPreference() async {
    prefs = await SharedPreferences.getInstance();
    displayPicture = prefs.getBool(Constants.PREF_DISPLAY_PICTURE) ?? true;
    setState(() {});
  }

}
