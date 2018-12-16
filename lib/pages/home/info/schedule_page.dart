import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;
import 'package:nkust_ap/models/models.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:nkust_ap/utils/global.dart';
import 'package:nkust_ap/widgets/hint_content.dart';

enum _State { loading, finish, error, empty }

class SchedulePageRoute extends MaterialPageRoute {
  SchedulePageRoute()
      : super(builder: (BuildContext context) => new SchedulePage());

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return new FadeTransition(opacity: animation, child: new SchedulePage());
  }
}

class SchedulePage extends StatefulWidget {
  static const String routerName = "/info/schedule";

  @override
  SchedulePageState createState() => new SchedulePageState();
}

class SchedulePageState extends State<SchedulePage>
    with SingleTickerProviderStateMixin {
  List<Widget> scheduleWeights = [];

  List<ScheduleData> scheduleList = [];

  _State state = _State.loading;

  int page = 1;

  AppLocalizations app;

  @override
  void initState() {
    super.initState();
    FA.setCurrentScreen("SchedulePage", "schedule_page.dart");
    _getSchedules();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _textBlueStyle() {
    return TextStyle(
        color: Resource.Colors.blue,
        fontSize: 18.0,
        fontWeight: FontWeight.bold);
  }

  _textStyle() {
    return TextStyle(color: Colors.black, fontSize: 16.0);
  }

  Widget _scheduleItem(ScheduleData schedule) {
    List<Widget> items = [];
    for (var i in schedule.events) {
      items.add(Text(
        i,
        style: _textStyle(),
        textAlign: TextAlign.left,
      ));
      items.add(SizedBox(height: 2.0));
    }
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.0),
      decoration: new BoxDecoration(
        border: new Border(
          top: BorderSide(color: Colors.grey, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            schedule.week ?? "",
            style: _textBlueStyle(),
            textAlign: TextAlign.left,
          ),
          SizedBox(height: 8.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items,
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    app = AppLocalizations.of(context);
    return _body();
  }

  Widget _body() {
    switch (state) {
      case _State.loading:
        return Container(
            child: CircularProgressIndicator(), alignment: Alignment.center);
      case _State.error:
      case _State.empty:
        return FlatButton(
          onPressed: _getSchedules,
          child: HintContent(
            icon: Icons.assignment,
            content: state == _State.error ? app.clickToRetry : app.busEmpty,
          ),
        );
      default:
        return ListView(
          children: scheduleWeights,
        );
    }
  }

  _getSchedules() async {
    state = _State.loading;
    setState(() {});
    final RemoteConfig remoteConfig = await RemoteConfig.instance;
    await remoteConfig.fetch(expiration: const Duration(hours: 5));
    await remoteConfig.activateFetched();
    JsonCodec jsonCodec = JsonCodec();
    var data = remoteConfig.getString(Constants.SCHEDULE_DATA);
    if (data.isEmpty)
      state = _State.error;
    else {
      print(data);
      var jsonArray = jsonCodec.decode(data);
      scheduleList = ScheduleData.toList(jsonArray);
      scheduleWeights.clear();
      for (var i in scheduleList) scheduleWeights.add(_scheduleItem(i));
      if (scheduleList.length == 0)
        state = _State.empty;
      else
        state = _State.finish;
    }
    setState(() {});
  }
}
