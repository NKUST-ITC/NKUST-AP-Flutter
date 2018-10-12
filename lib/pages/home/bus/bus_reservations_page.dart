import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_calendar/flutter_calendar.dart';
import 'package:flutter/cupertino.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;
import 'package:nkust_ap/api/helper.dart';
import 'package:nkust_ap/models/models.dart';
import 'package:nkust_ap/utils/utils.dart';

enum BusReservationsState { loading, finish, error, empty }

class BusReservationsPageRoute extends MaterialPageRoute {
  BusReservationsPageRoute()
      : super(builder: (BuildContext context) => new BusReservationsPage());

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return new FadeTransition(
        opacity: animation, child: new BusReservationsPage());
  }
}

class BusReservationsPage extends StatefulWidget {
  static const String routerName = "/bus/reservations";
  static const String title = "校車記錄";

  @override
  BusReservationsPageState createState() => new BusReservationsPageState();
}

class BusReservationsPageState extends State<BusReservationsPage>
    with SingleTickerProviderStateMixin {
  BusReservationsState state = BusReservationsState.loading;
  BusReservationsData busReservationsData;
  List<Widget> busReservationWeights = [];
  DateTime dateTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _getBusReservations();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _body();
  }

  Widget _body() {
    switch (state) {
      case BusReservationsState.loading:
        return Container(
            child: CircularProgressIndicator(), alignment: Alignment.center);
      case BusReservationsState.error:
      case BusReservationsState.empty:
        return FlatButton(
            onPressed: _getBusReservations,
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
                    state == BusReservationsState.error
                        ? "發生錯誤，點擊重試"
                        : "Oops！您還沒有預約任何校車喔～\n多多搭乘大眾運輸，節能減碳救地球\uD83D\uDE0B",
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ));
      default:
        return ListView(
          children: busReservationWeights,
        );
    }
  }

  _textStyle(BusReservation busReservation) => new TextStyle(
      color: busReservation.getColorState(),
      fontSize: 18.0,
      decorationColor: Colors.grey);

  _busReservationWidget(BusReservation busReservation) => Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Icon(
                    Icons.directions_bus,
                    size: 20.0,
                    color: Resource.Colors.blue,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    "${busReservation.getStart()}→${busReservation.end}",
                    textAlign: TextAlign.center,
                    style: _textStyle(busReservation),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    busReservation.time,
                    textAlign: TextAlign.center,
                    style: _textStyle(busReservation),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: busReservation.canCancel()
                      ? IconButton(
                          icon: Icon(
                            Icons.cancel,
                            size: 20.0,
                            color: Resource.Colors.red,
                          ),
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                      title: Text("取消預約",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Resource.Colors.blue)),
                                      content: Text(
                                        "要取消從${busReservation.getStart()}"
                                            "到${busReservation.end}\n"
                                            "${busReservation.getTime()} 的校車嗎？",
                                        textAlign: TextAlign.center,
                                      ),
                                      actions: <Widget>[
                                        FlatButton(
                                          child: Text("返回"),
                                          onPressed: () {
                                            Navigator.of(context,
                                                    rootNavigator: true)
                                                .pop('dialog');
                                          },
                                        ),
                                        FlatButton(
                                          child: Text("取消預定校車"),
                                          onPressed: () {
                                            Navigator.of(context,
                                                    rootNavigator: true)
                                                .pop('dialog');
                                            _cancelBusReservation(
                                                busReservation);
                                          },
                                        )
                                      ],
                                    ));
                          },
                        )
                      : Container(),
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

  _getBusReservations() {
    state = BusReservationsState.loading;
    setState(() {});
    Helper.instance.getBusReservations().then((response) {
      if (response.data == null) {
        state = BusReservationsState.error;
        setState(() {});
      } else {
        busReservationsData = BusReservationsData.fromJson(response.data);
        for (var i in busReservationsData.reservations) {
          busReservationWeights.add(_busReservationWidget(i));
        }
        if (busReservationsData.reservations.length != 0)
          state = BusReservationsState.finish;
        else
          state = BusReservationsState.empty;
        setState(() {});
      }
    });
  }

  _cancelBusReservation(BusReservation busReservation) {
    Helper.instance
        .cancelBusReservation(busReservation.cancelKey)
        .then((response) {
      String title = "", message = "";
      print(response.data["success"].runtimeType);
      if (!response.data["success"]) {
        title = "錯誤";
        message = response.data["message"];
      } else {
        title = "取消成功";
        message = "取消日期：${busReservation.getDate()}\n"
            "上車地點：${busReservation.getStart()}上車\n"
            "取消班次：${busReservation.getTime()}";
      }
      Utils.showDefaultDialog(context, title, message, "我知道了", () {});
    });
  }
}
