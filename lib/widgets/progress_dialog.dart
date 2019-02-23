import 'package:flutter/material.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;

class ProgressDialog extends StatelessWidget {
  final String content;

  ProgressDialog(this.content);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(16),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 8.0),
          CircularProgressIndicator(
            value: null,
            valueColor: AlwaysStoppedAnimation<Color>(Resource.Colors.blue),
          ),
          SizedBox(height: 28.0),
          Container(
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
