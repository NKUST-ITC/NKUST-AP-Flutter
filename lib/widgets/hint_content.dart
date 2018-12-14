import 'package:flutter/material.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;

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
          Container(
            padding: EdgeInsets.all(25.0),
            decoration: BoxDecoration(
                image: DecorationImage(
              image: AssetImage("assets/images/dash_line.png"),
            )),
            child: Icon(
              icon,
              size: 50.0,
              color: Resource.Colors.blue,
            ),
          ),
          SizedBox(height: 20.0),
          Text(
            content,
            textAlign: TextAlign.center,
            style: TextStyle(color: Resource.Colors.grey),
          )
        ],
      ),
    );
  }
}
