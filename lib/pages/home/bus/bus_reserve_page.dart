import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/models/models.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;
import 'package:nkust_ap/utils/global.dart';
import 'package:nkust_ap/widgets/default_dialog.dart';
import 'package:nkust_ap/widgets/flutter_calendar.dart';
import 'package:nkust_ap/widgets/hint_content.dart';
import 'package:nkust_ap/widgets/progress_dialog.dart';
import 'package:nkust_ap/widgets/yes_no_dialog.dart';

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

class BusReservePageState extends State<BusReservePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  double top = 0.0;

  _State state = _State.loading;
  BusData busData;

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
          onPressed: () {
            _getBusTimeTables();
            FA.logAction('retry', 'click');
          },
          child: HintContent(
            icon: Icons.assignment,
            content: state == _State.error ? app.clickToRetry : app.busEmpty,
          ),
        );
      default:
        return RefreshIndicator(
          onRefresh: () {
            _getBusTimeTables();
            FA.logAction('refresh', 'swipe');
          },
          child: ListView(
            physics: const NeverScrollableScrollPhysics(),
            children: _renderBusTimeWidgets(),
          ),
        );
    }
  }

  _renderBusTimeWidgets() {
    List<Widget> list = [];
    if (busData != null) {
      for (var i in busData.timetable) {
        if (selectStartStation == Station.janGong && i.endStation == "燕巢")
          list.add(_busTimeWidget(i));
        else if (selectStartStation == Station.yanchao && i.endStation == "建工")
          list.add(_busTimeWidget(i));
      }
    }
    return list;
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
                      builder: (BuildContext context) => YesNoDialog(
                            title: '${busTime.getSpecialTrainTitle(app)}'
                                '${busTime.specialTrain == "0" ? app.reserve : ""}',
                            contentWidget: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                  style: TextStyle(
                                      color: Resource.Colors.grey,
                                      height: 1.3,
                                      fontSize: 16.0),
                                  children: [
                                    TextSpan(
                                      text: '${busTime.getTime()} $start\n',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text:
                                          '${busTime.getSpecialTrainRemark()}${app.busReserveConfirmTitle}\n',
                                      style: TextStyle(
                                          color: Resource.Colors.grey,
                                          height: 1.3,
                                          fontSize: 14.0),
                                    ),
                                    TextSpan(
                                        text: '預約截止時間：\n',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    TextSpan(
                                        text: '${busTime.endEnrollDateTime}'),
                                  ]),
                            ),
                            leftActionText: app.cancel,
                            rightActionText: app.reserve,
                            leftActionFunction: null,
                            rightActionFunction: () {
                              _bookingBus(busTime);
                            },
                          ),
                    );
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
                    busTime.getTime(),
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
                    ? MediaQuery.of(context).size.height * 0.20
                    : MediaQuery.of(context).size.width * 0.19,
                floating: true,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  background: Column(
                    children: <Widget>[
                      Container(
                        color: Colors.transparent,
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 0.0),
                        child: Calendar(
                          isExpandable: false,
                          showTodayAction: false,
                          showCalendarPickerIcon: true,
                          showChevronsToChangeRange: true,
                          onDateSelected: (DateTime datetime) {
                            dateTime = datetime;
                            _getBusTimeTables();
                            FA.logAction('date_select', 'click');
                          },
                          initialCalendarDateOverride: dateTime,
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
                    selectedColor: Resource.Colors.blue,
                    borderColor: Resource.Colors.blue,
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
                      if (mounted) {
                        setState(() {
                          selectStartStation = text;
                        });
                      }
                      FA.logAction('segment', 'click');
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
    if (mounted) {
      setState(() {
        state = _State.loading;
      });
    }
    Helper.instance.getBusTimeTables(dateTime).then((response) {
      busData = response;
      if (mounted) {
        setState(() {
          if (busData.timetable.length != 0)
            state = _State.finish;
          else
            state = _State.empty;
        });
      }
    }).catchError((e) {
      if (e is DioError) {
        DioError dioError = e;
        //if bus can't connection:
        // dioError.message = HttpException: Connection closed before full header was received
        switch (dioError.type) {
          case DioErrorType.RESPONSE:
            Utils.handleResponseError(context, 'getBusTimeTables', mounted, e);
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
            if (mounted) {
              setState(() {
                state = _State.error;
                Utils.handleDioError(dioError, app);
              });
            }
            break;
        }
      } else {
        throw (e);
      }
    });
  }

  _bookingBus(BusTime busTime) {
    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(app.reserving),
        barrierDismissible: true);
    Helper.instance.bookingBusReservation(busTime.busId).then((response) {
      //TODO to object
      String title = "";
      Widget messageWidget;
      if (!response.data["success"]) {
        title = app.busReserveFailTitle;
        messageWidget = Text(
          response.data["message"],
          style: TextStyle(
              color: Resource.Colors.grey, height: 1.3, fontSize: 16.0),
        );
        FA.logAction('book_bus', 'status',
            message: 'fail_${response.data["message"]}');
      } else {
        title = app.busReserveSuccess;
        messageWidget = RichText(
          textAlign: TextAlign.left,
          text: TextSpan(
              style: TextStyle(
                  color: Resource.Colors.grey, height: 1.3, fontSize: 16.0),
              children: [
                TextSpan(
                  text: '${app.busReserveDate}：',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: '${busTime.getDate()}\n',
                ),
                TextSpan(
                  text: '${app.busReserveLocation}：',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: '${busTime.getStart(app)}${app.campus}\n',
                ),
                TextSpan(
                  text: '${app.busReserveTime}：',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: '${busTime.getTime()}',
                ),
              ]),
        );
        _getBusTimeTables();
        FA.logAction('book_bus', 'status', message: 'success');
      }
      Navigator.pop(context, 'dialog');
      showDialog(
        context: context,
        builder: (BuildContext context) => DefaultDialog(
            title: title,
            contentWidget: messageWidget,
            actionText: app.iKnow,
            actionFunction: () =>
                Navigator.of(context, rootNavigator: true).pop('dialog')),
      );
      //Utils.showDefaultDialog(context, title, message, app.iKnow, () {});
    }).catchError((e) {
      Navigator.pop(context, 'dialog');
      if (e is DioError) {
        switch (e.type) {
          case DioErrorType.RESPONSE:
            Utils.handleResponseError(context, 'book_bus', mounted, e);
            break;
          case DioErrorType.DEFAULT:
            if (e.message.contains("HttpException")) {
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
            Utils.handleDioError(e, app);
            break;
        }
      } else {
        throw e;
      }
    });
  }
}
