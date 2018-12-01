import 'package:async/async.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar/flutter_calendar.dart';
import 'package:flutter/cupertino.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;
import 'package:nkust_ap/api/helper.dart';
import 'package:nkust_ap/models/models.dart';
import 'package:nkust_ap/utils/utils.dart';
import 'package:nkust_ap/utils/app_localizations.dart';
import 'package:nkust_ap/widgets/progress_dialog.dart';

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

  AppLocalizations local;

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
                        ? local.clickToRetry
                        : local.busEmpty,
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
            onPressed: busTime.hasReserve() && busTime.isReserve == 0
                ? () {
                    String start = "";
                    if (selectStartStation == Station.janGong)
                      start = local.fromJiangong;
                    else if (selectStartStation == Station.yanchao)
                      start = local.fromYanchao;
                    showDialog(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                              title: Text(
                                  "${busTime.getSpecialTrainTitle(local)}"
                                  "${busTime.specialTrain == "0" ? local.reserve : ""}",
                                  textAlign: TextAlign.center,
                                  style:
                                      TextStyle(color: Resource.Colors.blue)),
                              content: Text(
                                "${busTime.getSpecialTrainRemark()}${local.busReserveConfirmTitle}\n"
                                    "${busTime.time} $start",
                                textAlign: TextAlign.center,
                              ),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text(local.cancel),
                                  onPressed: () {
                                    Navigator.of(context, rootNavigator: true)
                                        .pop('dialog');
                                  },
                                ),
                                FlatButton(
                                  child: Text(local.reserve),
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
                    "${busTime.reserveCount} ${local.people}",
                    textAlign: TextAlign.center,
                    style: _textStyle(busTime),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    busTime.getSpecialTrainTitle(local),
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
                    busTime.getReserveState(local),
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
    local = AppLocalizations.of(context);
    return Flex(
      direction: Axis.vertical,
      children: <Widget>[
        Calendar(
          isExpandable: false,
          onDateSelected: (DateTime datetime) {
            dateTime = datetime;
            _getBusTimeTables();
          },
        ),
        Container(
            margin: EdgeInsets.all(8.0),
            child: CupertinoSegmentedControl(
              groupValue: selectStartStation,
              children: {
                Station.janGong: Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 4.0, horizontal: 36.0),
                  child: Text(local.fromJiangong),
                ),
                Station.yanchao: Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 4.0, horizontal: 36.0),
                  child: Text(local.fromYanchao),
                )
              },
              onValueChanged: (Station text) {
                selectStartStation = text;
                if (state == BusReserveState.finish)
                  _updateBusTimeTables();
                else
                  setState(() {});
              },
            )),
        Expanded(
          flex: 9,
          child: _body(),
        ),
      ],
    );
  }

  _getBusTimeTables() {
    Helper.cancelToken.cancel("");
    Helper.cancelToken = CancelToken();
    state = BusReserveState.loading;
    setState(() {});
    Helper.instance.getBusTimeTables(dateTime).then((response) {
      busData = response;
      _updateBusTimeTables();
    }).catchError((e) {
      assert(e is DioError);
      DioError dioError = e as DioError;
      //if bus can't connection:
      // dioError.message = HttpException: Connection closed before full header was received
      switch (dioError.type) {
        case DioErrorType.RESPONSE:
          Utils.showToast(AppLocalizations.of(context).tokenExpiredContent);
          Navigator.popUntil(
              context, ModalRoute.withName(Navigator.defaultRouteName));
          break;
        case DioErrorType.DEFAULT:
          if (dioError.message.contains("HttpException")) {
            setState(() {
              state = BusReserveState.error;
              Utils.showToast(local.busFailInfinity);
            });
          }
          break;
        case DioErrorType.CANCEL:
          break;
        default:
          setState(() {
            state = BusReserveState.error;
            Utils.handleDioError(dioError, local);
          });
          break;
      }
    });
  }

  _bookingBus(BusTime busTime) {
    showDialog(
        context: context,
        builder: (BuildContext context) =>
            ProgressDialog(AppLocalizations.of(context).reserving),
        barrierDismissible: true);
    Helper.instance.bookingBusReservation(busTime.busId).then((response) {
      //TODO 優化成物件
      String title = "", message = "";
      print(response.data["success"].runtimeType);
      if (!response.data["success"]) {
        title = local.busReserveFailTitle;
        message = response.data["message"];
      } else {
        title = local.busReserveSuccess;
        message = "${local.busReserveDate}：${busTime.getDate()}\n"
            "${local.busReserveLocation}：${busTime.getStart(local)}${local.campus}\n"
            "${local.busReserveTime}：${busTime.time}";
        _getBusTimeTables();
      }
      Navigator.pop(context, 'dialog');
      Utils.showDefaultDialog(context, title, message, local.iKnow, () {});
    }).catchError((e) {
      Navigator.pop(context, 'dialog');
      assert(e is DioError);
      DioError dioError = e as DioError;
      switch (dioError.type) {
        case DioErrorType.RESPONSE:
          Utils.showToast(AppLocalizations.of(context).tokenExpiredContent);
          Navigator.popUntil(
              context, ModalRoute.withName(Navigator.defaultRouteName));
          break;
        case DioErrorType.DEFAULT:
          if (dioError.message.contains("HttpException")) {
            setState(() {
              state = BusReserveState.error;
              Utils.showToast(local.busFailInfinity);
            });
          }
          break;
        case DioErrorType.CANCEL:
          break;
        default:
          Utils.handleDioError(dioError, local);
          break;
      }
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
