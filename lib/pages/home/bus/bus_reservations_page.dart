import 'dart:convert';
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

  @override
  BusReservationsPageState createState() => new BusReservationsPageState();
}

class BusReservationsPageState extends State<BusReservationsPage>
    with SingleTickerProviderStateMixin {
  BusReservationsState state = BusReservationsState.loading;
  BusReservationsData busReservationsData;
  List<Widget> busReservationWeights = [];
  DateTime dateTime = DateTime.now();

  AppLocalizations local;

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
    local = AppLocalizations.of(context);
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
                        ? local.clickToRetry
                        : local.busReservationEmpty,
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
                    "${busReservation.getStart(local)}→${busReservation.getEnd(local)}",
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
                                      title: Text(local.busCancelReserve,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Resource.Colors.blue)),
                                      content: Text(
                                        "${local.busCancelReserveConfirmContent1}${busReservation.getStart(local)}"
                                            "${local.busCancelReserveConfirmContent2}${busReservation.getEnd(local)}\n"
                                            "${busReservation.getTime()}${local.busCancelReserveConfirmContent3}",
                                        textAlign: TextAlign.center,
                                      ),
                                      actions: <Widget>[
                                        FlatButton(
                                          child: Text(local.back),
                                          onPressed: () {
                                            Navigator.of(context,
                                                    rootNavigator: true)
                                                .pop('dialog');
                                          },
                                        ),
                                        FlatButton(
                                          child: Text(local.busCancelReserve),
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
    busReservationWeights.clear();
    state = BusReservationsState.loading;
    setState(() {});
    Helper.instance.getBusReservations().then((response) {
      busReservationsData = response;
      for (var i in busReservationsData.reservations) {
        busReservationWeights.add(_busReservationWidget(i));
      }
      if (busReservationsData.reservations.length != 0)
        state = BusReservationsState.finish;
      else
        state = BusReservationsState.empty;
      setState(() {});
    }).catchError((e) {
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
              state = BusReservationsState.error;
              Utils.showToast(local.busFailInfinity);
            });
          }
          break;
        case DioErrorType.CANCEL:
          break;
        default:
          setState(() {
            state = BusReservationsState.error;
            Utils.handleDioError(dioError, local);
          });
          break;
      }
    });
  }

  _cancelBusReservation(BusReservation busReservation) {
    showDialog(
        context: context,
        builder: (BuildContext context) =>
            ProgressDialog(AppLocalizations.of(context).canceling),
        barrierDismissible: true);
    Helper.instance
        .cancelBusReservation(busReservation.cancelKey)
        .then((response) {
      String title = "", message = "";
      if (!response.data["success"]) {
        title = local.busCancelReserveFail;
        message = response.data["message"];
      } else {
        title = local.busCancelReserveSuccess;
        message = "${local.busReserveCancelDate}：${busReservation.getDate()}\n"
            "${local.busReserveCancelLocation}：${busReservation.getStart(local)}${local.campus}\n"
            "${local.busReserveCancelTime}：${busReservation.getTime()}";
        _getBusReservations();
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
              state = BusReservationsState.error;
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
}
