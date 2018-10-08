import 'package:flutter/material.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;
import 'package:nkust_ap/api/helper.dart';
import 'package:nkust_ap/models/models.dart';

class ScorePageRoute extends MaterialPageRoute {
  ScorePageRoute() : super(builder: (BuildContext context) => new ScorePage());

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return new FadeTransition(opacity: animation, child: new ScorePage());
  }
}

class ScorePage extends StatefulWidget {
  static const String routerName = "/score";

  @override
  ScorePageState createState() => new ScorePageState();
}

class ScorePageState extends State<ScorePage> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      // Appbar
        appBar: new AppBar(
          // Title
          title: new Text(Resource.Strings.score),
          backgroundColor: Resource.Colors.blue,
        ),
        body: Container());
  }
}
