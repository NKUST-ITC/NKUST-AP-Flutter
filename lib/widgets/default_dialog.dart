import 'package:flutter/material.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;
import 'package:nkust_ap/utils/app_localizations.dart';

class DefaultDialog extends StatelessWidget {
  final String title;
  final String content;

  DefaultDialog(this.title, this.content);

  static showSample(BuildContext context) => showDialog(
        context: context,
        builder: (BuildContext context) =>
            DefaultDialog('預約成功', '預約日期：2017/09/05\n上車地點：燕巢校區\n預約班次：08:20'),
      );

  @override
  Widget build(BuildContext context) {
    var app = AppLocalizations.of(context);
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(16),
        ),
      ),
      title: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Resource.Colors.blue,
          fontWeight: FontWeight.bold,
          fontSize: 18.0,
        ),
      ),
      titlePadding: EdgeInsets.symmetric(vertical: 16.0),
      contentPadding: EdgeInsets.all(0.0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey, width: 0.5),
                bottom: BorderSide(color: Colors.grey, width: 0.5),
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 24.0),
            child: Text(
              content,
              style: TextStyle(color: Resource.Colors.grey, height: 1.3),
            ),
          ),
          Container(
            width: double.infinity,
            child: InkWell(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16.0),
                bottomRight: Radius.circular(16.0),
              ),
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  app.iKnow,
                  style: TextStyle(
                    color: Resource.Colors.grey,
                    fontSize: 18.0,
                  ),
                ),
              ),
              onTap: () {
                Navigator.of(context, rootNavigator: true).pop('dialog');
              },
            ),
          ),
        ],
      ),
    );
  }
}
