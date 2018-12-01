import 'package:flutter/material.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;

class ProgressDialog extends StatelessWidget {
  final String content;

  ProgressDialog(this.content);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircularProgressIndicator(
            value: null,
            valueColor: AlwaysStoppedAnimation<Color>(Resource.Colors.blue),
          ),
          Container(
            margin: const EdgeInsets.only(top: 25.0),
            child: Text(
              content,
              style: TextStyle(color: Resource.Colors.blue),
            ),
          ),
        ],
      ),
    );
  }
}
