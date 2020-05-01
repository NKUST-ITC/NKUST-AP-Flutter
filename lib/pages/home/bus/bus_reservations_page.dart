import 'package:ap_common/resources/ap_theme.dart';
import 'package:ap_common/widgets/default_dialog.dart';
import 'package:ap_common/widgets/hint_content.dart';
import 'package:ap_common/widgets/progress_dialog.dart';
import 'package:ap_common/widgets/yes_no_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/models/error_response.dart';
import 'package:nkust_ap/models/models.dart';
import 'package:nkust_ap/res/app_icon.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;
import 'package:nkust_ap/utils/cache_utils.dart';
import 'package:nkust_ap/utils/global.dart';
import 'package:nkust_ap/utils/preferences.dart';

enum _State {
  loading,
  finish,
  error,
  empty,
  campusNotSupport,
  userNotSupport,
  offlineEmpty,
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

  _State state = _State.finish;
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
                  style: TextStyle(color: ApTheme.of(context).grey),
                )
              : null,
        ),
        Expanded(
          child: _body(),
        ),
      ],
    );
  }

  String get errorText {
    switch (state) {
      case _State.error:
        return app.clickToRetry;
      case _State.empty:
        return app.busReservationEmpty;
      case _State.campusNotSupport:
        return app.campusNotSupport;
      case _State.userNotSupport:
        return app.userNotSupport;
      default:
        return '';
    }
  }

  Widget _body() {
    switch (state) {
      case _State.loading:
        return Center(
          child: CircularProgressIndicator(),
        );
      case _State.error:
      case _State.empty:
      case _State.campusNotSupport:
      case _State.userNotSupport:
        return FlatButton(
          onPressed: () {
            _getBusReservations();
            FA.logAction('retry', 'click');
          },
          child: HintContent(
            icon: AppIcon.assignment,
            content: errorText,
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
      color: busReservation.getColorState(context),
      fontSize: 18.0,
      decorationColor: ApTheme.of(context).greyText);

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
                    color: ApTheme.of(context).blueAccent,
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
                  child: IconButton(
                    icon: Icon(
                      AppIcon.cancel,
                      size: 20.0,
                      color: isOffline
                          ? ApTheme.of(context).grey
                          : ApTheme.of(context).red,
                    ),
                    onPressed: isOffline
                        ? null
                        : () {
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
                                rightActionText: app.determine,
                                rightActionFunction: () {
                                  cancelBusReservation(busReservation);
                                  FA.logAction('cancel_bus', 'click');
                                },
                              ),
                            );
                            FA.logAction('cancel_bus', 'create');
                          },
                  ),
                )
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Divider(
              color: ApTheme.of(context).grey,
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
          if (busReservationsData == null ||
              busReservationsData.reservations.length == 0)
            state = _State.empty;
          else
            state = _State.finish;
        });
      }
      CacheUtils.saveBusReservationsData(busReservationsData);
    }).catchError((e) async {
      if (e is DioError) {
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
                  context, 'getBusReservations', mounted, e);
            }
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

  cancelBusReservation(BusReservation busTime) {
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
      _getBusReservations();
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
                    color: ApTheme.of(context).grey,
                    height: 1.3,
                    fontSize: 16.0),
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
          actionText: app.iKnow,
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
                      color: ApTheme.of(context).grey,
                      height: 1.3,
                      fontSize: 16.0),
                ),
                actionText: app.iKnow,
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
