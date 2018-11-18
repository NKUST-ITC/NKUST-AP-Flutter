import 'package:flutter/material.dart';

class HintContent extends StatelessWidget {
  final IconData icon;
  final String content;

  HintContent({this.icon, this.content});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Flex(
        mainAxisAlignment: MainAxisAlignment.center,
        direction: Axis.vertical,
        children: <Widget>[
          SizedBox(
            child: Icon(
              icon,
              size: 150.0,
            ),
            width: 200.0,
          ),
          Text(
            content,
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}
