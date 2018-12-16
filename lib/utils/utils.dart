import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nkust_ap/config/constants.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nkust_ap/utils/app_localizations.dart';
import 'package:share/share.dart';

class Utils {
  static void handleDioError(DioError dioError, AppLocalizations app) {
    switch (dioError.type) {
      case DioErrorType.DEFAULT:
        showToast(app.noInternet);
        break;
      case DioErrorType.CONNECT_TIMEOUT:
      case DioErrorType.RECEIVE_TIMEOUT:
        showToast(app.timeoutMessage);
        break;
      case DioErrorType.RESPONSE:
      case DioErrorType.CANCEL:
        break;
    }
  }

  static void showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.grey[300],
        textColor: Colors.black);
  }

  static void showDefaultDialog(BuildContext context, String title,
      String content, String actionText, Function function) {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Text(title,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Resource.Colors.blue)),
              content: Text(content,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Resource.Colors.grey)),
              actions: <Widget>[
                FlatButton(
                  child: Text(actionText,
                      style: TextStyle(color: Resource.Colors.blue)),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop('dialog');
                    function();
                  },
                )
              ],
            ));
  }

  static void showForceUpdateDialog(BuildContext context, String url) {
    var app = AppLocalizations.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
            title: Text(app.updateTitle,
                textAlign: TextAlign.center,
                style: TextStyle(color: Resource.Colors.blue)),
            content: Text(_getPlatformUpdateContent(app),
                textAlign: TextAlign.center,
                style: TextStyle(color: Resource.Colors.grey)),
            actions: <Widget>[
              FlatButton(
                child: Text(app.update,
                    style: TextStyle(color: Resource.Colors.blue)),
                onPressed: () {
                  launchUrl(url);
                },
              )
            ],
          ),
    );
  }

  static void showUpdateDialog(BuildContext context, String url) {
    var app = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
            title: Text(app.updateTitle,
                textAlign: TextAlign.center,
                style: TextStyle(color: Resource.Colors.blue)),
            content: Text(_getPlatformUpdateContent(app),
                textAlign: TextAlign.center,
                style: TextStyle(color: Resource.Colors.grey)),
            actions: <Widget>[
              FlatButton(
                child: Text(app.skip,
                    style: TextStyle(color: Resource.Colors.blue)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text(app.update,
                    style: TextStyle(color: Resource.Colors.blue)),
                onPressed: () {
                  launchUrl(url);
                },
              )
            ],
          ),
    );
  }

  static String _getPlatformUpdateContent(AppLocalizations app) {
    if (Platform.isAndroid)
      return app.updateAndroidContent;
    else if (Platform.isIOS)
      return app.updateIOSContent;
    else
      return app.updateContent;
  }

  static void showSnackBarBar(
    ScaffoldState scaffold,
    String contentText,
    String actionText,
    Color actionTextColor,
  ) {
    scaffold.showSnackBar(
      SnackBar(
        content: Text(contentText),
        duration: Duration(days: 1),
        action: SnackBarAction(
          label: actionText,
          onPressed: () {},
          textColor: actionTextColor,
        ),
      ),
    );
  }

  static Future<void> launchUrl(var url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  static callPhone(String url) async {
    url = url.replaceAll('#', ',');
    url = url.replaceAll('(', '');
    url = url.replaceAll(')', '');
    url = url.replaceAll('-', '');
    url = url.replaceAll(' ', '');
    url = "tel:$url";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  static void shareTo(String content) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    Share.share("$content\n\n"
        "Send from ${packageInfo.appName} ${Platform.operatingSystem}");
  }

  static void clearSetting() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool(Constants.PREF_AUTO_LOGIN, false);
  }
}
