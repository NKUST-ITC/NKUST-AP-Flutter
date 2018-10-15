import 'package:flutter/material.dart';
import 'package:flutter_calendar/flutter_calendar.dart';
import 'package:flutter/cupertino.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;
import 'package:nkust_ap/api/helper.dart';
import 'package:nkust_ap/models/models.dart';
import 'package:nkust_ap/utils/utils.dart';

enum BusReserveState { loading, finish, error, empty }
enum Station { janGong, yanchao }

class BusReservePageRoute extends MaterialPageRoute {
  BusReservePageRoute()
      : super(builder: (BuildContext context) => new BusReservePage());

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return new FadeTransition(opacity: animation, child: new BusReservePage());
  }
}

class BusReservePage extends StatefulWidget {
  static const String routerName = "/bus/reserve";
  static const String title = "校車預約";

  @override
  BusReservePageState createState() => new BusReservePageState();
}

class BusReservePageState extends State<BusReservePage>
    with SingleTickerProviderStateMixin {
  BusReserveState state = BusReserveState.loading;
  BusData busData;
  List<Widget> busTimeWeights = [];

  Station selectStartStation = Station.janGong;
  DateTime dateTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _getBusTimeTables();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _textStyle(BusTime busTime) => new TextStyle(
      color: busTime.getColorState(),
      fontSize: 18.0,
      decorationColor: Colors.grey);

  Widget _body() {
    switch (state) {
      case BusReserveState.loading:
        return Container(
            child: CircularProgressIndicator(), alignment: Alignment.center);
      case BusReserveState.error:
      case BusReserveState.empty:
        return FlatButton(
            onPressed: _getBusTimeTables,
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
                    state == BusReserveState.error
                        ? "發生錯誤，點擊重試"
                        : "Oops！本日校車沒有上班喔～\n請選擇其他日期\uD83D\uDE0B",
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ));
      default:
        return ListView(
          children: busTimeWeights,
        );
    }
  }

  _busTimeWidget(BusTime busTime) => Column(
        children: <Widget>[
          FlatButton(
            padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            onPressed: busTime.hasReserve()
                ? () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                              title: Text(
                                  "${busTime.getSpecialTrainTitle()}"
                                  "${busTime.specialTrain == "0" ? "預約" : ""}",
                                  textAlign: TextAlign.center,
                                  style:
                                      TextStyle(color: Resource.Colors.blue)),
                              content: Text(
                                "${busTime.getSpecialTrainRemark()}確定要預定本次校車？",
                                textAlign: TextAlign.center,
                              ),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text("取消"),
                                  onPressed: () {
                                    Navigator.of(context, rootNavigator: true)
                                        .pop('dialog');
                                  },
                                ),
                                FlatButton(
                                  child: Text("預約"),
                                  onPressed: () {
                                    Navigator.of(context, rootNavigator: true)
                                        .pop('dialog');
                                    _bookingBus(busTime);
                                  },
                                )
                              ],
                            ));
                  }
                : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Icon(
                    Icons.directions_bus,
                    size: 20.0,
                    color: busTime.getColorState(),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    busTime.time,
                    textAlign: TextAlign.center,
                    style: _textStyle(busTime),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    "${busTime.reserveCount}人",
                    textAlign: TextAlign.center,
                    style: _textStyle(busTime),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    busTime.getSpecialTrainTitle(),
                    textAlign: TextAlign.center,
                    style: _textStyle(busTime),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Icon(
                    Icons.access_time,
                    size: 20.0,
                    color: busTime.getColorState(),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    busTime.getReserveState(),
                    textAlign: TextAlign.center,
                    style: _textStyle(busTime),
                  ),
                )
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Divider(
              color: Colors.grey,
              indent: 4.0,
            ),
          )
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: Axis.vertical,
      children: <Widget>[
        Expanded(
            flex: 3,
            child: Calendar(
              onDateSelected: (DateTime datetime) {
                dateTime = datetime;
                _getBusTimeTables();
              },
            )),
        Expanded(
            flex: 1,
            child: Container(
                padding: EdgeInsets.all(8.0),
                child: CupertinoSegmentedControl(
                  groupValue: selectStartStation,
                  children: {
                    Station.janGong: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 4.0, horizontal: 48.0),
                      child: Text("建工上車"),
                    ),
                    Station.yanchao: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 4.0, horizontal: 48.0),
                      child: Text("燕巢上車"),
                    )
                  },
                  onValueChanged: (Station text) {
                    selectStartStation = text;
                    _updateBusTimeTables();
                  },
                ))),
        Expanded(
          flex: 9,
          child: _body(),
        ),
      ],
    );
  }

  _getBusTimeTables() {
    state = BusReserveState.loading;
    setState(() {});
    Helper.instance.getBusTimeTables(dateTime).then((response) {
      if (response.data == null) {
        state = BusReserveState.error;
        setState(() {});
      } else {
        busData = BusData.fromJson(response.data);
        _updateBusTimeTables();
      }
    });
  }

  _bookingBus(BusTime busTime) {
    Helper.instance.bookingBusReservation(busTime.busId).then((response) {
      String title = "", message = "";
      print(response.data["success"].runtimeType);
      if (!response.data["success"]) {
        title = "錯誤";
        message = response.data["message"];
      } else {
        title = "預約成功";
        message = "預約日期：${busTime.getDate()}\n"
            "上車地點：${busTime.getStart()}上車\n"
            "預約班次：${busTime.time}";
        _getBusTimeTables();
      }
      Utils.showDefaultDialog(context, title, message, "我知道了", () {});
    });
  }

  _updateBusTimeTables() {
    busTimeWeights = [];
    if (busData != null) {
      for (var i in busData.timetable) {
        if (selectStartStation == Station.janGong && i.endStation == "燕巢")
          busTimeWeights.add(_busTimeWidget(i));
        else if (selectStartStation == Station.yanchao && i.endStation == "建工")
          busTimeWeights.add(_busTimeWidget(i));
      }
      if (busData.timetable.length != 0)
        state = BusReserveState.finish;
      else
        state = BusReserveState.empty;
      setState(() {});
    }
  }
}
