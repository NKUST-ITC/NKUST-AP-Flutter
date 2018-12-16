import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/utils/global.dart';
import 'package:nkust_ap/widgets/flutter_calendar.dart';
import 'package:flutter/cupertino.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;
import 'package:nkust_ap/models/models.dart';
import 'package:nkust_ap/widgets/hint_content.dart';
import 'package:nkust_ap/widgets/progress_dialog.dart';

enum _State { loading, finish, error, empty }
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

class BusReservePageState extends State<BusReservePage> {
  double top = 0.0;

  _State state = _State.loading;
  BusData busData;
  List<Widget> busTimeWeights = [];

  Station selectStartStation = Station.janGong;
  DateTime dateTime = DateTime.now();

  AppLocalizations app;

  @override
  void initState() {
    super.initState();
    FA.setCurrentScreen("BusReservePage", "bus_reserve_page.dart");
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
      case _State.loading:
        return Container(
            child: CircularProgressIndicator(), alignment: Alignment.center);
      case _State.error:
      case _State.empty:
        return FlatButton(
          onPressed: _getBusTimeTables,
          child: HintContent(
            icon: Icons.assignment,
            content: state == _State.error ? app.clickToRetry : app.busEmpty,
          ),
        );
      default:
        return ListView(
          physics: const NeverScrollableScrollPhysics(),
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
                      start = app.fromJiangong;
                    else if (selectStartStation == Station.yanchao)
                      start = app.fromYanchao;
                    showDialog(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                              title: Text(
                                  "${busTime.getSpecialTrainTitle(app)}"
                                  "${busTime.specialTrain == "0" ? app.reserve : ""}",
                                  textAlign: TextAlign.center,
                                  style:
                                      TextStyle(color: Resource.Colors.blue)),
                              content: Text(
                                "${busTime.getSpecialTrainRemark()}${app.busReserveConfirmTitle}\n"
                                    "${busTime.time} $start",
                                textAlign: TextAlign.center,
                              ),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text(app.cancel),
                                  onPressed: () {
                                    Navigator.of(context, rootNavigator: true)
                                        .pop('dialog');
                                  },
                                ),
                                FlatButton(
                                  child: Text(app.reserve),
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
                    "${busTime.reserveCount} ${app.people}",
                    textAlign: TextAlign.center,
                    style: _textStyle(busTime),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    busTime.getSpecialTrainTitle(app),
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
                    busTime.getReserveState(app),
                    textAlign: TextAlign.center,
                    style: _textStyle(busTime),
                  ),
                )
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(color: Colors.grey, height: 0.0),
          )
        ],
      );

  @override
  Widget build(BuildContext context) {
    app = AppLocalizations.of(context);
    return Scaffold(
      body: OrientationBuilder(builder: (_, orientation) {
        return NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                leading: Container(),
                expandedHeight: orientation == Orientation.portrait
                    ? MediaQuery.of(context).size.height * 0.19
                    : MediaQuery.of(context).size.width * 0.19,
                floating: true,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  background: Column(
                    children: <Widget>[
                      Container(
                        color: Colors.transparent,
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Calendar(
                          isExpandable: false,
                          showTodayAction: false,
                          showCalendarPickerIcon: false,
                          showChevronsToChangeRange: false,
                          onDateSelected: (DateTime datetime) {
                            dateTime = datetime;
                            _getBusTimeTables();
                          },
                          dayChildAspectRatio:
                              orientation == Orientation.portrait ? 1.5 : 3,
                          weekdays: app.weekdays,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Divider(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: double.infinity),
                  child: CupertinoSegmentedControl(
                    groupValue: selectStartStation,
                    children: {
                      Station.janGong: Container(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(app.fromJiangong),
                      ),
                      Station.yanchao: Container(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(app.fromYanchao),
                      )
                    },
                    onValueChanged: (Station text) {
                      selectStartStation = text;
                      if (state == _State.finish)
                        _updateBusTimeTables();
                      else
                        setState(() {});
                    },
                  ),
                ),
              ),
              Expanded(
                child: _body(),
              ),
            ],
          ),
        );
      }),
    );
  }

  _getBusTimeTables() {
    Helper.cancelToken.cancel("");
    Helper.cancelToken = CancelToken();
    state = _State.loading;
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
            if (mounted) {
              setState(() {
                state = _State.error;
                Utils.showToast(app.busFailInfinity);
              });
            }
          }
          break;
        case DioErrorType.CANCEL:
          break;
        default:
          setState(() {
            state = _State.error;
            Utils.handleDioError(dioError, app);
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
      if (!response.data["success"]) {
        title = app.busReserveFailTitle;
        message = response.data["message"];
      } else {
        title = app.busReserveSuccess;
        message = "${app.busReserveDate}：${busTime.getDate()}\n"
            "${app.busReserveLocation}：${busTime.getStart(app)}${app.campus}\n"
            "${app.busReserveTime}：${busTime.time}";
        _getBusTimeTables();
      }
      Navigator.pop(context, 'dialog');
      Utils.showDefaultDialog(context, title, message, app.iKnow, () {});
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
              state = _State.error;
              Utils.showToast(app.busFailInfinity);
            });
          }
          break;
        case DioErrorType.CANCEL:
          break;
        default:
          Utils.handleDioError(dioError, app);
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
        state = _State.finish;
      else
        state = _State.empty;
      setState(() {});
    }
  }
}
