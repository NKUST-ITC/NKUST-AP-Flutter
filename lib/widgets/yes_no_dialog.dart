import 'package:flutter/material.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;

class YesNoDialog extends StatelessWidget {
  final String title;
  final Widget contentWidget;
  final EdgeInsetsGeometry contentWidgetPadding;
  final String leftActionText;
  final String rightActionText;
  final Function leftActionFunction;
  final Function rightActionFunction;

  const YesNoDialog(
      {Key key,
      this.title,
      this.contentWidget,
      this.contentWidgetPadding,
      this.leftActionText,
      this.rightActionText,
      this.leftActionFunction,
      this.rightActionFunction})
      : super(key: key);

  static showSample(BuildContext context) => showDialog(
        context: context,
        builder: (BuildContext context) => YesNoDialog(
          title: '預約成功',
          contentWidget: Text(
            '預約日期：2017/09/05\n上車地點：燕巢校區\n預約班次：08:20',
            style: TextStyle(color: Resource.Colors.greyText, height: 1.3),
          ),
          leftActionText: '取消',
          rightActionText: '預約',
          leftActionFunction: null,
          rightActionFunction: null,
        ),
      );

  @override
  Widget build(BuildContext context) {
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
          color: Resource.Colors.blueText,
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
            padding: contentWidgetPadding ??
                EdgeInsets.symmetric(horizontal: 30.0, vertical: 24.0),
            child: contentWidget,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16.0),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: Colors.grey, width: 0.5),
                      ),
                    ),
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      leftActionText,
                      style: TextStyle(
                        color: Resource.Colors.greyText,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context, rootNavigator: true).pop('dialog');
                    if (leftActionFunction != null) leftActionFunction();
                  },
                ),
              ),
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(16.0),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      rightActionText,
                      style: TextStyle(
                        color: Resource.Colors.greyText,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context, rootNavigator: true).pop('dialog');
                    if (rightActionFunction != null) rightActionFunction();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
