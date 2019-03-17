import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/models/models.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;
import 'package:nkust_ap/utils/global.dart';
import 'package:nkust_ap/widgets/default_dialog.dart';
import 'package:nkust_ap/widgets/hint_content.dart';
import 'package:nkust_ap/widgets/progress_dialog.dart';
import 'package:nkust_ap/widgets/yes_no_dialog.dart';

enum _State { loading, finish, error, empty }

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

  @override
  BusReservationsPageState createState() => new BusReservationsPageState();
}

class BusReservationsPageState extends State<BusReservationsPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  _State state = _State.loading;
  BusReservationsData busReservationsData;
  List<Widget> busReservationWeights = [];
  DateTime dateTime = DateTime.now();

  AppLocalizations app;

  @override
  void initState() {
    super.initState();
    FA.setCurrentScreen("BusReservationsPage", "bus_reservations_page.dart");
    _getBusReservations();
  }

  @override
  void dispose() {
    super.dispose();
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
          onPressed: _getBusReservations,
          child: HintContent(
            icon: Icons.assignment,
            content: state == _State.error
                ? app.clickToRetry
                : app.busReservationEmpty,
          ),
        );
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
                    "${busReservation.getStart(app)}→${busReservation.getEnd(app)}",
                    textAlign: TextAlign.center,
                    style: _textStyle(busReservation),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    busReservation.getDateTimeStr(),
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
                              builder: (BuildContext context) => YesNoDialog(
                                    title: app.busCancelReserve,
                                    contentWidget: Text(
                                      "${app.busCancelReserveConfirmContent1}${busReservation.getStart(app)}"
                                          "${app.busCancelReserveConfirmContent2}${busReservation.getEnd(app)}\n"
                                          "${busReservation.getTime()}${app.busCancelReserveConfirmContent3}",
                                      textAlign: TextAlign.center,
                                    ),
                                    leftActionText: app.back,
                                    rightActionText: app.busCancelReserve,
                                    rightActionFunction: () {
                                      _cancelBusReservation(busReservation);
                                    },
                                  ),
                            );
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
    busReservationWeights.clear();
    if (mounted) {
      setState(() {
        state = _State.loading;
      });
    }
    Helper.instance.getBusReservations().then((response) {
      busReservationsData = response;
      for (var i in busReservationsData.reservations) {
        busReservationWeights.add(_busReservationWidget(i));
      }
      if (mounted) {
        setState(() {
          if (busReservationsData.reservations.length != 0)
            state = _State.finish;
          else
            state = _State.empty;
        });
      }
    }).catchError((e) {
      if (e is DioError) {
        switch (e.type) {
          case DioErrorType.RESPONSE:
            Utils.handleResponseError(
                context, 'getBusReservations', mounted, e);
            break;
          case DioErrorType.DEFAULT:
            if (e.message.contains("HttpException")) {
              setState(() {
                state = _State.error;
                Utils.showToast(app.busFailInfinity);
              });
            }
            break;
          case DioErrorType.CANCEL:
            break;
          default:
            setState(() {
              state = _State.error;
              Utils.handleDioError(e, app);
            });
            break;
        }
      } else {
        throw e;
      }
    });
  }

  _cancelBusReservation(BusReservation busReservation) {
    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(app.canceling),
        barrierDismissible: true);
    Helper.instance
        .cancelBusReservation(busReservation.cancelKey)
        .then((response) {
      String title = "", message = "";
      Widget messageWidget;
      if (!response.data["success"]) {
        title = app.busCancelReserveFail;
        messageWidget = Text(
          response.data["message"],
          style: TextStyle(
              color: Resource.Colors.grey, height: 1.3, fontSize: 16.0),
        );
      } else {
        title = app.busCancelReserveSuccess;
        messageWidget = RichText(
          textAlign: TextAlign.left,
          text: TextSpan(
              style: TextStyle(
                  color: Resource.Colors.grey, height: 1.3, fontSize: 16.0),
              children: [
                TextSpan(
                  text: '${app.busReserveCancelDate}：',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: '${busReservation.getDate()}\n',
                ),
                TextSpan(
                  text: '${app.busReserveCancelLocation}：',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: '${busReservation.getStart(app)}${app.campus}\n',
                ),
                TextSpan(
                  text: '${app.busReserveCancelTime}：',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: '${busReservation.getTime()}',
                ),
              ]),
        );
        _getBusReservations();
      }
      Navigator.pop(context, 'dialog');
      showDialog(
        context: context,
        builder: (BuildContext context) => DefaultDialog(
              title: title,
              contentWidget: messageWidget,
              actionText: app.iKnow,
            ),
      );
      //Utils.showDefaultDialog(context, title, message, app.iKnow, () {});
    }).catchError((e) {
      Navigator.pop(context, 'dialog');
      if (e is DioError) {
        switch (e.type) {
          case DioErrorType.RESPONSE:
            Utils.handleResponseError(
                context, 'getBusReservations', mounted, e);
            break;
          case DioErrorType.DEFAULT:
            if (e.message.contains("HttpException")) {
              setState(() {
                state = _State.error;
                Utils.showToast(app.busFailInfinity);
              });
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
