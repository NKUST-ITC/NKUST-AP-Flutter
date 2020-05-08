import 'package:ap_common/callback/general_callback.dart';
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
import 'package:flutter/material.dart';
import 'package:nkust_ap/models/models.dart';
import 'package:nkust_ap/utils/cache_utils.dart';
import 'package:nkust_ap/utils/global.dart';

enum _State {
  loading,
  finish,
  error,
  empty,
  campusNotSupport,
  userNotSupport,
  offlineEmpty,
  custom
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
  String customStateHint;

  BusReservationsData busReservationsData;
  DateTime dateTime = DateTime.now();

  AppLocalizations app;
  ApLocalizations ap;

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
    ap = ApLocalizations.of(context);
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
        return ap.clickToRetry;
      case _State.empty:
        return app.busReservationEmpty;
      case _State.campusNotSupport:
        return ap.campusNotSupport;
      case _State.userNotSupport:
        return ap.userNotSupport;
      case _State.custom:
        return customStateHint;
      default:
        return ap.somethingError;
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
            icon: ApIcon.assignment,
            content: errorText,
          ),
        );
      case _State.offlineEmpty:
        return HintContent(
          icon: ApIcon.assignment,
          content: ap.noOfflineData,
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
                    ApIcon.directionsBus,
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
                      ApIcon.cancel,
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
                                leftActionText: ap.back,
                                rightActionText: ap.determine,
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
    Helper.instance.getBusReservations(
      callback: GeneralCallback(
        onSuccess: (BusReservationsData data) {
          busReservationsData = data;
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
        },
        onFailure: (DioError e) {
          if (mounted)
            switch (e.type) {
              case DioErrorType.RESPONSE:
                setState(() {
                  if (e.response.statusCode == 401)
                    state = _State.userNotSupport;
                  else if (e.response.statusCode == 403)
                    state = _State.campusNotSupport;
                  else {
                    state = _State.error;
                    Utils.handleResponseError(
                        context, 'getBusReservations', mounted, e);
                  }
                });
                break;
              case DioErrorType.DEFAULT:
                setState(() {
                  if (e.message.contains("HttpException")) {
                    state = _State.custom;
                    customStateHint = app.busFailInfinity;
                  } else
                    state = _State.error;
                });
                break;
              case DioErrorType.CANCEL:
                break;
              default:
                setState(() {
                  state = _State.custom;
                  customStateHint = ApLocalizations.dioError(context, e);
                });
                break;
            }
          _loadCache();
        },
        onError: (GeneralResponse response) {
          setState(() {
            state = _State.custom;
            customStateHint = response.getGeneralMessage(context);
          });
          _loadCache();
        },
      ),
    );
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
    Helper.instance.cancelBusReservation(
      cancelKey: busTime.cancelKey,
      callback: GeneralCallback(
        onSuccess: (data) {
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
              actionText: ap.iKnow,
              actionFunction: () =>
                  Navigator.of(context, rootNavigator: true).pop(),
            ),
          );
        },
        onFailure: (DioError e) => BusReservePageState.handleDioError(
            context, e, app.busCancelReserveFail, 'cancel_bus'),
        onError: (GeneralResponse response) =>
            BusReservePageState.handleGeneralError(
                context, response, app.busCancelReserveFail),
      ),
    );
  }

  _loadCache() async {
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
  }
}
