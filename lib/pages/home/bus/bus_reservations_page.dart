import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/models/models.dart';
import 'package:nkust_ap/res/app_icon.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;
import 'package:nkust_ap/utils/cache_utils.dart';
import 'package:nkust_ap/utils/global.dart';
import 'package:nkust_ap/utils/preferences.dart';
import 'package:nkust_ap/widgets/default_dialog.dart';
import 'package:nkust_ap/widgets/hint_content.dart';
import 'package:nkust_ap/widgets/progress_dialog.dart';
import 'package:nkust_ap/widgets/yes_no_dialog.dart';

enum _State { loading, finish, error, empty, offlineEmpty }

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
  DateTime dateTime = DateTime.now();

  AppLocalizations app;

  bool isOffline = false;

  @override
  void initState() {
    FA.setCurrentScreen("BusReservationsPage", "bus_reservations_page.dart");
    _getBusReservations();
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
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: isOffline
              ? Text(
                  app.offlineBusReservations,
                  style: TextStyle(color: Resource.Colors.grey),
                )
              : null,
        ),
        Expanded(
          child: _body(),
        ),
      ],
    );
  }

  Widget _body() {
    switch (state) {
      case _State.loading:
        return Container(
            child: CircularProgressIndicator(), alignment: Alignment.center);
      case _State.error:
      case _State.empty:
        return FlatButton(
          onPressed: () {
            _getBusReservations();
            FA.logAction('retry', 'click');
          },
          child: HintContent(
            icon: AppIcon.assignment,
            content: state == _State.error
                ? app.clickToRetry
                : app.busReservationEmpty,
          ),
        );
      case _State.offlineEmpty:
        return HintContent(
          icon: AppIcon.assignment,
          content: app.noOfflineData,
        );
      default:
        return RefreshIndicator(
          onRefresh: () async {
            _getBusReservations();
            FA.logAction('refresh', 'swipe');
            return null;
          },
          child: ListView.builder(
              itemCount: busReservationsData.reservations.length,
              itemBuilder: (context, i) {
                return _busReservationWidget(
                    busReservationsData.reservations[i]);
              }),
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
                    AppIcon.directionsBus,
                    size: 20.0,
                    color: Resource.Colors.blueAccent,
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
                            AppIcon.cancel,
                            size: 20.0,
                            color: isOffline
                                ? Resource.Colors.grey
                                : Resource.Colors.red,
                          ),
                          onPressed: isOffline
                              ? null
                              : () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        YesNoDialog(
                                      title: app.busCancelReserve,
                                      contentWidget: Text(
                                        "${app.busCancelReserveConfirmContent1}${busReservation.getStart(app)}"
                                        "${app.busCancelReserveConfirmContent2}${busReservation.getEnd(app)}\n"
                                        "${busReservation.getTime()}${app.busCancelReserveConfirmContent3}",
                                        textAlign: TextAlign.center,
                                      ),
                                      leftActionText: app.back,
                                      rightActionText: app.determine,
                                      rightActionFunction: () {
                                        _cancelBusReservation(busReservation);
                                        FA.logAction('cancel_bus', 'click');
                                      },
                                    ),
                                  );
                                  FA.logAction('cancel_bus', 'create');
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

  _getBusReservations() async {
    if (Preferences.getBool(Constants.PREF_IS_OFFLINE_LOGIN, false)) {
      busReservationsData = await CacheUtils.loadBusReservationsData();
      if (mounted) {
        setState(() {
          isOffline = true;
          if (busReservationsData == null)
            state = _State.offlineEmpty;
          else if (busReservationsData.reservations.length != 0)
            state = _State.finish;
          else
            state = _State.empty;
        });
      }
      return;
    }
    if (mounted) {
      setState(() {
        state = _State.loading;
      });
    }
    Helper.instance.getBusReservations().then((response) {
      busReservationsData = response;
      if (mounted) {
        setState(() {
          if (busReservationsData.reservations.length != 0)
            state = _State.finish;
          else
            state = _State.empty;
        });
      }
      CacheUtils.saveBusReservationsData(busReservationsData);
    }).catchError((e) async {
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
                Utils.showToast(context, app.busFailInfinity);
              });
            }
            break;
          case DioErrorType.CANCEL:
            break;
          default:
            setState(() {
              state = _State.error;
              Utils.handleDioError(context, e);
            });
            break;
        }
        busReservationsData = await CacheUtils.loadBusReservationsData();
        if (mounted) {
          setState(() {
            isOffline = true;
            if (busReservationsData == null)
              state = _State.offlineEmpty;
            else if (busReservationsData.reservations.length != 0)
              state = _State.finish;
            else
              state = _State.empty;
          });
        }
      } else {
        throw e;
      }
    });
  }

  _cancelBusReservation(BusReservation busReservation) {
    showDialog(
        context: context,
        builder: (BuildContext context) => WillPopScope(
            child: ProgressDialog(app.canceling),
            onWillPop: () async {
              return false;
            }),
        barrierDismissible: false);
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
        FA.logAction('cancel_bus', 'status',
            message: 'fail_${response.data["message"]}');
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
        FA.logAction('cancel_bus', 'status', message: 'success');
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
    }).catchError((e) {
      Navigator.pop(context, 'dialog');
      if (e is DioError) {
        switch (e.type) {
          case DioErrorType.RESPONSE:
            Utils.handleResponseError(context, 'cancel_bus', mounted, e);
            break;
          case DioErrorType.DEFAULT:
            if (e.message.contains("HttpException")) {
              setState(() {
                state = _State.error;
              });
              Utils.showToast(context, app.busFailInfinity);
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
