import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;
import 'package:url_launcher/url_launcher.dart';
import 'package:nkust_ap/utils/app_localizations.dart';

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
        bgcolor: "#434c61",
        textcolor: '#ffffff');
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
                  textAlign: TextAlign.left,
                  style: TextStyle(color: Resource.Colors.grey)),
              actions: <Widget>[
                FlatButton(
                  child: Text(actionText,
                      style: TextStyle(color: Resource.Colors.grey)),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop('dialog');
                    function();
                  },
                )
              ],
            ));
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
}
