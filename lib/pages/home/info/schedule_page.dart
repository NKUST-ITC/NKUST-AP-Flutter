import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;
import 'package:nkust_ap/api/helper.dart';
import 'package:nkust_ap/models/models.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:nkust_ap/config/constants.dart';
import 'package:nkust_ap/utils/app_localizations.dart';

enum ScheduleState { loading, finish, error, empty }

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

  ScheduleState state = ScheduleState.loading;

  int page = 1;

  @override
  void initState() {
    super.initState();
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
    return _body();
  }

  Widget _body() {
    switch (state) {
      case ScheduleState.loading:
        return Container(
            child: CircularProgressIndicator(), alignment: Alignment.center);
      case ScheduleState.error:
      case ScheduleState.empty:
        return FlatButton(
          onPressed: () {},
          child: Center(
            child: Flex(
              mainAxisAlignment: MainAxisAlignment.center,
              direction: Axis.vertical,
              children: <Widget>[
                SizedBox(
                  child: Icon(
                    Icons.info,
                    size: 150.0,
                  ),
                  width: 200.0,
                ),
                Text(
                  state == ScheduleState.error
                      ? AppLocalizations.of(context).clickToRetry
                      : "Oops！本學期沒有任何行事曆資料哦～\n請點選重試\uD83D\uDE0B",
                  textAlign: TextAlign.center,
                )
              ],
            ),
          ),
        );
      default:
        return ListView(
          children: scheduleWeights,
        );
    }
  }

  _getSchedules() async {
    state = ScheduleState.loading;
    setState(() {});
    final RemoteConfig remoteConfig = await RemoteConfig.instance;
    JsonCodec jsonCodec = JsonCodec();
    var data = remoteConfig.getString(Constants.SCHEDULE_DATA);
    if (data == null)
      state = ScheduleState.error;
    else {
      var jsonArray = jsonCodec.decode(data);
      scheduleList = ScheduleData.toList(jsonArray);
      scheduleWeights.clear();
      for (var i in scheduleList) scheduleWeights.add(_scheduleItem(i));
      if (scheduleList.length == 0)
        state = ScheduleState.empty;
      else
        state = ScheduleState.finish;
    }
    setState(() {});
  }
}
