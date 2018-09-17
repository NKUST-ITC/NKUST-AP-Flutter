import 'package:flutter/material.dart';
import 'package:nkust_ap/res/resource.dart';

class ScorePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: new FlatButton(
            onPressed: null, child: new Text(Strings.score)));
  }
}
