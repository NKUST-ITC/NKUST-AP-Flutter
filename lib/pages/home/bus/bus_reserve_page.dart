import 'package:ap_common/resources/ap_icon.dart';
import 'package:ap_common/resources/ap_theme.dart';
import 'package:ap_common/utils/ap_localizations.dart';
import 'package:ap_common/utils/ap_utils.dart';
import 'package:ap_common/utils/preferences.dart';
import 'package:ap_common/widgets/default_dialog.dart';
import 'package:ap_common/widgets/hint_content.dart';
import 'package:ap_common/widgets/progress_dialog.dart';
import 'package:ap_common/widgets/yes_no_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/models/error_response.dart';
import 'package:nkust_ap/models/models.dart';
import 'package:nkust_ap/utils/global.dart';
import 'package:nkust_ap/widgets/flutter_calendar.dart';

enum _State {
  loading,
  finish,
  error,
  empty,
  campusNotSupport,
  userNotSupport,
  offline
}
enum Station { janGong, yanchao }

class BusReservePage extends StatefulWidget {
  static const String routerName = "/bus/reserve";

  @override
  BusReservePageState createState() => BusReservePageState();
}

class BusReservePageState extends State<BusReservePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  AppLocalizations app;
  ApLocalizations ap;

  _State state = _State.finish;

  Station selectStartStation = Station.janGong;
  DateTime dateTime = DateTime.now();

  BusData busData;

  double top = 0.0;

  @override
  void initState() {
    FA.setCurrentScreen("BusReservePage", "bus_reserve_page.dart");
    _getBusTimeTables();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    app = AppLocalizations.of(context);
    ap = ApLocalizations.of(context);
    return Scaffold(
      body: OrientationBuilder(
        builder: (_, orientation) {
          return NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
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
                            weekdays: ap.weekdays,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Divider(color: ApTheme.of(context).grey),
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
                      selectedColor: ApTheme.of(context).blueAccent,
                      borderColor: ApTheme.of(context).blueAccent,
                      unselectedColor: ApTheme.of(context).segmentControlUnSelect,
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
        },
      ),
    );
  }

  _textStyle(BusTime busTime) => TextStyle(
      color: busTime.getColorState(context),
      fontSize: 18.0,
      decorationColor: ApTheme.of(context).greyText);

  String get errorText {
    switch (state) {
      case _State.error:
        return ap.clickToRetry;
      case _State.empty:
        return app.busEmpty;
      case _State.campusNotSupport:
        return ap.campusNotSupport;
      case _State.userNotSupport:
        return ap.userNotSupport;
      default:
        return '';
    }
  }

  Widget _body() {
    switch (state) {
      case _State.loading:
        return Container(
            child: CircularProgressIndicator(), alignment: Alignment.center);
      case _State.error:
      case _State.empty:
      case _State.campusNotSupport:
      case _State.userNotSupport:
        return FlatButton(
          onPressed: () {
            _getBusTimeTables();
            FA.logAction('retry', 'click');
          },
          child: HintContent(
            icon: ApIcon.assignment,
            content: errorText,
          ),
        );
      case _State.offline:
        return HintContent(
          icon: ApIcon.offlineBolt,
          content: ap.offlineMode,
        );
      default:
        return RefreshIndicator(
          onRefresh: () async {
            await _getBusTimeTables();
            FA.logAction('refresh', 'swipe');
            return null;
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
        if (selectStartStation == Station.janGong && i.startStation == "建工")
          list.add(_busTimeWidget(i));
        else if (selectStartStation == Station.yanchao &&
            i.startStation == "燕巢") list.add(_busTimeWidget(i));
      }
    }
    return list;
  }

  _busTimeWidget(BusTime busTime) => Column(
        children: <Widget>[
          FlatButton(
            padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            onPressed: busTime.canReserve() && !busTime.isReserve
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
                                color: ApTheme.of(context).grey,
                                height: 1.3,
                                fontSize: 16.0),
                            children: [
                              TextSpan(
                                text: '${busTime.getTime()} $start\n',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text:
                                    '${busTime.description}${app.busReserveConfirmTitle}\n',
                                style: TextStyle(
                                    color: ApTheme.of(context).grey,
                                    height: 1.3,
                                    fontSize: 14.0),
                              ),
                              TextSpan(
                                  text: '${app.reserveDeadline}：\n',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(
                                  text: '${busTime.getEndEnrollDateTime()}'),
                            ],
                          ),
                        ),
                        leftActionText: ap.cancel,
                        rightActionText: app.reserve,
                        leftActionFunction: null,
                        rightActionFunction: () {
                          _bookingBus(busTime);
                        },
                      ),
                    );
                  }
                : busTime.isReserve
                    ? () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) => YesNoDialog(
                            title: app.busCancelReserve,
                            contentWidget: Text(
                              "${app.busCancelReserveConfirmContent1}${busTime.getStart(app)}"
                              "${app.busCancelReserveConfirmContent2}${busTime.getEnd(app)}\n"
                              "${busTime.getTime()}${app.busCancelReserveConfirmContent3}",
                              textAlign: TextAlign.center,
                            ),
                            leftActionText: ap.back,
                            rightActionText: ap.determine,
                            rightActionFunction: () {
                              cancelBusReservation(busTime);
                              FA.logAction('cancel_bus', 'click');
                            },
                          ),
                        );
                        FA.logAction('cancel_bus', 'create');
                      }
                    : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Icon(
                    ApIcon.directionsBus,
                    size: 20.0,
                    color: busTime.getColorState(context),
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
                    "${busTime.reserveCount} ${ap.people}",
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
                    ApIcon.accessTime,
                    size: 20.0,
                    color: busTime.getColorState(context),
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
            child: Divider(color: ApTheme.of(context).grey, height: 0.0),
          )
        ],
      );

  _getBusTimeTables() async {
    if (Preferences.getBool(Constants.PREF_IS_OFFLINE_LOGIN, false)) {
      setState(() {
        state = _State.offline;
      });
      return;
    }
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
          if (busData == null || busData.timetable.length == 0)
            state = _State.empty;
          else
            state = _State.finish;
        });
      }
    }).catchError((e) {
      if (e is DioError) {
        //if bus can't connection:
        // dioError.message = HttpException: Connection closed before full header was received
        switch (e.type) {
          case DioErrorType.RESPONSE:
            if (e.response.statusCode == 401) {
              setState(() {
                state = _State.userNotSupport;
              });
            } else if (e.response.statusCode == 403) {
              setState(() {
                state = _State.campusNotSupport;
              });
            } else {
              setState(() {
                state = _State.error;
              });
              Utils.handleResponseError(
                  context, 'getBusTimeTables', mounted, e);
            }
            break;
          case DioErrorType.DEFAULT:
            if (e.message.contains("HttpException")) {
              if (mounted) {
                setState(() {
                  state = _State.error;
                  ApUtils.showToast(context, app.busFailInfinity);
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
                Utils.handleDioError(context, e);
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
      builder: (BuildContext context) => WillPopScope(
          child: ProgressDialog(app.reserving),
          onWillPop: () async {
            return false;
          }),
      barrierDismissible: false,
    );
    Helper.instance.bookingBusReservation(busTime.busId).then((response) {
      _getBusTimeTables();
      FA.logAction('book_bus', 'status', message: 'success');
      Navigator.of(context, rootNavigator: true).pop();
      showDialog(
        context: context,
        builder: (BuildContext context) => DefaultDialog(
          title: app.busReserveSuccess,
          contentWidget: RichText(
            textAlign: TextAlign.left,
            text: TextSpan(
                style: TextStyle(
                    color: ApTheme.of(context).grey, height: 1.3, fontSize: 16.0),
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
          ),
          actionText: ap.iKnow,
          actionFunction: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
        ),
      );
    }).catchError((e) {
      Navigator.of(context, rootNavigator: true).pop();
      if (e is DioError) {
        switch (e.type) {
          case DioErrorType.RESPONSE:
            ErrorResponse errorResponse =
                ErrorResponse.fromJson(e.response.data);
            showDialog(
              context: context,
              builder: (BuildContext context) => DefaultDialog(
                title: app.busReserveFailTitle,
                contentWidget: Text(
                  errorResponse.description,
                  style: TextStyle(
                      color: ApTheme.of(context).grey, height: 1.3, fontSize: 16.0),
                ),
                actionText: ap.iKnow,
                actionFunction: () {
                  Navigator.of(context, rootNavigator: true).pop('dialog');
                },
              ),
            );
            FA.logAction('book_bus', 'status',
                message: 'fail_${errorResponse.description}');
            break;
          case DioErrorType.DEFAULT:
            if (e.message.contains("HttpException")) {
              if (mounted) {
                setState(() {
                  state = _State.error;
                  ApUtils.showToast(context, app.busFailInfinity);
                });
              }
            }
            break;
          case DioErrorType.CANCEL:
            break;
          default:
            Utils.handleDioError(context, e);
            break;
        }
      } else {
        throw e;
      }
    });
  }

  cancelBusReservation(BusTime busTime) {
    showDialog(
      context: context,
      builder: (BuildContext context) => WillPopScope(
        child: ProgressDialog(app.canceling),
        onWillPop: () async {
          return false;
        },
      ),
      barrierDismissible: false,
    );
    Helper.instance.cancelBusReservation(busTime.cancelKey).then((response) {
      _getBusTimeTables();
      FA.logAction('cancel_bus', 'status', message: 'success');
      Navigator.of(context, rootNavigator: true).pop();
      showDialog(
        context: context,
        builder: (BuildContext context) => DefaultDialog(
          title: app.busCancelReserveSuccess,
          contentWidget: RichText(
            textAlign: TextAlign.left,
            text: TextSpan(
                style: TextStyle(
                    color: ApTheme.of(context).grey, height: 1.3, fontSize: 16.0),
                children: [
                  TextSpan(
                    text: '${app.busReserveCancelDate}：',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: '${busTime.getDate()}\n',
                  ),
                  TextSpan(
                    text: '${app.busReserveCancelLocation}：',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: '${busTime.getStart(app)}${app.campus}\n',
                  ),
                  TextSpan(
                    text: '${app.busReserveCancelTime}：',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: '${busTime.getTime()}',
                  ),
                ]),
          ),
          actionText: ap.iKnow,
          actionFunction: () =>
              Navigator.of(context, rootNavigator: true).pop(),
        ),
      );
    }).catchError((e) {
      Navigator.of(context, rootNavigator: false).pop();
      if (e is DioError) {
        switch (e.type) {
          case DioErrorType.RESPONSE:
            ErrorResponse errorResponse =
                ErrorResponse.fromJson(e.response.data);
            showDialog(
              context: context,
              builder: (BuildContext context) => DefaultDialog(
                title: app.busReserveFailTitle,
                contentWidget: Text(
                  errorResponse.description,
                  style: TextStyle(
                      color: ApTheme.of(context).grey, height: 1.3, fontSize: 16.0),
                ),
                actionText: ap.iKnow,
                actionFunction: () {
                  Navigator.of(context, rootNavigator: true).pop('dialog');
                },
              ),
            );
            FA.logAction('book_bus', 'status',
                message: 'fail_${errorResponse.description}');
            break;
          case DioErrorType.DEFAULT:
            if (e.message.contains("HttpException")) {
              setState(() {
                state = _State.error;
              });
              ApUtils.showToast(context, app.busFailInfinity);
            }
            break;
          case DioErrorType.CANCEL:
            break;
          default:
            Utils.handleDioError(context, e);
            break;
        }
      } else {
        throw e;
      }
    });
  }
}
