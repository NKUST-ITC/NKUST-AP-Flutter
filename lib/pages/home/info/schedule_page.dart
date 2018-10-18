import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;
import 'package:nkust_ap/api/helper.dart';
import 'package:nkust_ap/models/models.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

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
                    Icons.directions_bus,
                    size: 150.0,
                  ),
                  width: 200.0,
                ),
                Text(
                  state == ScheduleState.error
                      ? "發生錯誤，點擊重試"
                      : "Oops！本學期沒有任何成績資料哦～\n請選擇其他學期\uD83D\uDE0B",
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
    scheduleWeights.clear();
    state = ScheduleState.loading;
    setState(() {});

    /*final RemoteConfig remoteConfig = await RemoteConfig.instance;
    await remoteConfig.fetch(expiration: const Duration(seconds: 0));
    await remoteConfig.activateFetched();*/
    JsonCodec jsonCodec = JsonCodec();
    String json =
        "[{\"week\":\"預備週\",\"events\":[\"(9/4 ~ 9/5) 新生課程初選\",\"(9/7) 前一學期研究所畢業生離校手續截止日\"]},{\"week\":\"第一週\",\"events\":[\"(9/10) 第一學期註冊日、開始上課\",\"(9/10) 休退學,學雜費全額退費\",\"(9/10) 研究生申請學位考試\",\"(9/10 ~ 9/14) 學分數抵免/輔系、雙主修申請\",\"(9/11 ~ 10/19) 休退學,學雜費退還三分之二\",\"(9/18 ~ 9/21) 課程加退選\"]},{\"week\":\"第二週\",\"events\":[\"(9/18 ~ 9/21) 課程加退選\"]},{\"week\":\"第三週\",\"events\":[\"(9/24) 中秋節(放假一天)\",\"(9/25 ~ 10/5) 轉部申請\"]},{\"week\":\"第五週\",\"events\":[\"(10/10) 國慶日(放假一天)\"]},{\"week\":\"第六週\",\"events\":[\"(10/15 ~ 12/28) 申請課程停修\",\"(10/19) 申請休退學者,學雜費退還三分之二\",\"(10/22) 申請休退學者,學雜費退還三分之一\"]},{\"week\":\"第七週\",\"events\":[\"(10/22) 申請休退學者,學雜費退還三分之一\"]},{\"week\":\"第九週\",\"events\":[\"(11/5 ~ 11/9) 第一學期期中考試\"]},{\"week\":\"第十一週\",\"events\":[\"(11/19 ~ 11/30) 轉系申請\"]},{\"week\":\"第十二週\",\"events\":[\"(11/30) 申請休退學者,學雜費退還三分之一\"]},{\"week\":\"第十三週\",\"events\":[\"(12/8) 校慶日(放假一天)\"]},{\"week\":\"第十五週\",\"events\":[\"(12/22) 開國紀念日彈性放假補行上班上課\"]},{\"week\":\"第十七週\",\"events\":[\"(12/31) 開國紀念日彈性放假一天\",\"(12/31) 研究生申請學位考試截止日\",\"(1/1) 開國紀念日(放假一天)\",\"(1/2 ~ 1/25)第二學期課程初選\"]},{\"week\":\"第十八週\",\"events\":[\"(1/7 ~ 1/11) 第一學期期末考試\",\"(1/11) 本學期休退學申請截止日\",\"(1/7 ~ 1/20)教師學期成績登錄\"]}]";
    var jsonArray = jsonCodec.decode(json);
    scheduleList = ScheduleData.toList(jsonArray);
    for (var i in scheduleList) scheduleWeights.add(_scheduleItem(i));
    state = ScheduleState.finish;
    setState(() {});
  }
}
