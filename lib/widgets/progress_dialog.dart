import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProgressDialog extends StatelessWidget {
  final String content;

  ProgressDialog(this.content);

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
        content: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        CircularProgressIndicator(
          value: null,
        ),
        Container(
          margin: const EdgeInsets.only(top: 25.0),
          child: Text(
            content,
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ],
    ));
  }
}
