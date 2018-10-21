import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;
import 'package:url_launcher/url_launcher.dart';

class Utils {
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

  static launchUrl(var url) async {
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
