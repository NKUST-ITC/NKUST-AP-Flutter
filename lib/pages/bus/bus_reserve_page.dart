import 'package:ap_common/callback/general_callback.dart';
import 'package:ap_common/config/analytics_constants.dart';
import 'package:ap_common/resources/ap_icon.dart';
import 'package:ap_common/resources/ap_theme.dart';
import 'package:ap_common/utils/ap_localizations.dart';
import 'package:ap_common/utils/ap_utils.dart';
import 'package:ap_common/utils/dialog_utils.dart';
import 'package:ap_common/utils/preferences.dart';
import 'package:ap_common/widgets/default_dialog.dart';
import 'package:ap_common/widgets/hint_content.dart';
import 'package:ap_common/widgets/progress_dialog.dart';
import 'package:ap_common/widgets/yes_no_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/models/booking_bus_data.dart';
import 'package:nkust_ap/models/cancel_bus_data.dart';
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
  offline,
  custom
}

enum Station { janGong, yanchao, first }

class BusReservePage extends StatefulWidget {
  static const String routerName = "/bus/reserve";

  @override
  BusReservePageState createState() => BusReservePageState();
}

class BusReservePageState extends State<BusReservePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  AppLocalizations? app;
  late ApLocalizations ap;

  _State state = _State.finish;

  String? customStateHint = '';

  Station selectStartStation = Station.janGong;
  DateTime dateTime = DateTime.now();

  BusData? busData;

  double top = 0.0;

  @override
  void initState() {
    FirebaseAnalyticsUtils.instance
        .setCurrentScreen("BusReservePage", "bus_reserve_page.dart");
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
                            onDateSelected: (DateTime? datetime) {
                              if (datetime != null) {
                                dateTime = datetime;
                                _getBusTimeTables();
                                FirebaseAnalyticsUtils.instance
                                    .logEvent('date_picker_click');
                              }
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
                      unselectedColor:
                          ApTheme.of(context).segmentControlUnSelect,
                      groupValue: selectStartStation,
                      children: {
                        Station.janGong: Container(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(app!.fromJiangong),
                        ),
                        Station.yanchao: Container(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(app!.fromYanchao),
                        ),
                        Station.first: Container(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(app!.fromFirst),
                        ),
                      },
                      onValueChanged: (Station text) {
                        if (mounted) {
                          setState(() {
                            selectStartStation = text;
                          });
                        }
                        FirebaseAnalyticsUtils.instance
                            .logEvent('segment_click');
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

  String? get errorText {
    switch (state) {
      case _State.error:
        return ap.clickToRetry;
      case _State.empty:
        return app!.busEmpty;
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
        return Container(
            child: CircularProgressIndicator(), alignment: Alignment.center);
      case _State.error:
      case _State.empty:
      case _State.campusNotSupport:
      case _State.userNotSupport:
      case _State.custom:
        return InkWell(
          onTap: () {
            _getBusTimeTables();
            FirebaseAnalyticsUtils.instance.logEvent('retry_click');
          },
          child: HintContent(
            icon: ApIcon.assignment,
            content: errorText!,
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
            FirebaseAnalyticsUtils.instance.logEvent('refresh_swipe');
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
      for (var i in busData!.timetable) {
        if (selectStartStation == Station.janGong && i.startStation == "建工")
          list.add(_busTimeWidget(i));
        else if (selectStartStation == Station.yanchao &&
            i.startStation == "燕巢")
          list.add(_busTimeWidget(i));
        else if (selectStartStation == Station.first && i.startStation == "第一")
          list.add(_busTimeWidget(i));
      }
    }
    return list;
  }

  _busTimeWidget(BusTime busTime) => Column(
        children: <Widget>[
          InkWell(
            onTap: busTime.canReserve() && !busTime.isReserve
                ? () {
                    String start = "";
                    if (selectStartStation == Station.janGong)
                      start = app!.fromJiangong;
                    else if (selectStartStation == Station.yanchao)
                      start = app!.fromYanchao;
                    else if (selectStartStation == Station.first)
                      start = app!.fromFirst;
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => YesNoDialog(
                        title: '${busTime.getSpecialTrainTitle(app)}'
                            '${busTime.specialTrain == "0" ? app!.reserve : ""}',
                        contentWidget: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(
                              color: ApTheme.of(context).grey,
                              height: 1.3,
                              fontSize: 16.0,
                            ),
                            children: [
                              TextSpan(
                                text: '${busTime.getTime()} $start\n',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text:
                                    '${app!.destination}：${busTime.getEnd(app)}\n\n',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (busTime.description != null &&
                                  busTime.description!.isNotEmpty)
                                TextSpan(
                                  text:
                                      '${busTime.description!.replaceAll('<br />', '\n')}\n\n',
                                  style: TextStyle(
                                    color: ApTheme.of(context).grey,
                                    height: 1.3,
                                    fontSize: 14.0,
                                  ),
                                ),
                              TextSpan(
                                text: '${app!.busReserveConfirmTitle}',
                                style: TextStyle(
                                  color: ApTheme.of(context).grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        leftActionText: ap.cancel,
                        rightActionText: app!.reserve,
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
                            title: app!.busCancelReserve,
                            contentWidget: Text(
                              "${app!.busCancelReserveConfirmContent1}${busTime.getStart(app)}"
                              "${app!.busCancelReserveConfirmContent2}${busTime.getEnd(app)}\n"
                              "${busTime.getTime()}${app!.busCancelReserveConfirmContent3}",
                              textAlign: TextAlign.center,
                            ),
                            leftActionText: ap.back,
                            rightActionText: ap.determine,
                            rightActionFunction: () {
                              cancelBusReservation(busTime);
                              FirebaseAnalyticsUtils.instance
                                  .logEvent('cancel_bus_click');
                            },
                          ),
                        );
                        FirebaseAnalyticsUtils.instance
                            .logEvent('cancel_bus_create');
                      }
                    : null,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
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
    Helper.cancelToken!.cancel("");
    Helper.cancelToken = CancelToken();
    if (mounted) setState(() => state = _State.loading);
    Helper.instance.getBusTimeTables(
      dateTime: dateTime,
      callback: GeneralCallback(
        onSuccess: (BusData data) {
          busData = data;
          if (mounted)
            setState(() {
              if (busData == null || busData!.timetable.length == 0)
                state = _State.empty;
              else
                state = _State.finish;
            });
          FirebaseAnalyticsUtils.instance.setUserProperty(
            Constants.CAN_USE_BUS,
            AnalyticsConstants.yes,
          );
        },
        onFailure: (DioError e) {
          if (mounted)
            switch (e.type) {
              case DioErrorType.response:
                setState(() {
                  if (e.response!.statusCode == 401)
                    state = _State.userNotSupport;
                  else if (e.response!.statusCode == 403)
                    state = _State.campusNotSupport;
                  else {
                    state = _State.custom;
                    customStateHint = e.message;
                    FirebaseAnalyticsUtils.instance.logApiEvent(
                        'getBusTimeTables', e.response!.statusCode!,
                        message: e.message);
                  }
                });
                if (e.response!.statusCode == 401 ||
                    e.response!.statusCode == 403)
                  FirebaseAnalyticsUtils.instance.setUserProperty(
                    Constants.CAN_USE_BUS,
                    AnalyticsConstants.no,
                  );
                break;
              case DioErrorType.other:
                setState(() {
                  if (e.message.contains("HttpException")) {
                    state = _State.custom;
                    customStateHint = app!.busFailInfinity;
                  } else
                    state = _State.error;
                });
                break;
              case DioErrorType.cancel:
                break;
              default:
                setState(() {
                  state = _State.custom;
                  customStateHint = e.i18nMessage;
                });
                break;
            }
        },
        onError: (GeneralResponse response) {
          setState(() {
            state = _State.custom;
            if (response.statusCode == 403) {
              customStateHint = response.message;
            } else {
              customStateHint = response.getGeneralMessage(context);
            }
          });
        },
      ),
    );
  }

  _bookingBus(BusTime busTime) {
    showDialog(
      context: context,
      builder: (BuildContext context) => WillPopScope(
          child: ProgressDialog(app!.reserving),
          onWillPop: () async {
            return false;
          }),
      barrierDismissible: false,
    );
    Helper.instance.bookingBusReservation(
      busId: busTime.busId,
      callback: GeneralCallback(
        onSuccess: (BookingBusData data) {
          _getBusTimeTables();
          FirebaseAnalyticsUtils.instance.logEvent('book_bus_success');
          Navigator.of(context, rootNavigator: true).pop();
          showDialog(
            context: context,
            builder: (BuildContext context) => DefaultDialog(
              title: app!.busReserveSuccess,
              contentWidget: RichText(
                textAlign: TextAlign.left,
                text: TextSpan(
                    style: TextStyle(
                        color: ApTheme.of(context).grey,
                        height: 1.3,
                        fontSize: 16.0),
                    children: [
                      TextSpan(
                        text: '${app!.busReserveDate}：',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: '${busTime.getDate()}\n',
                      ),
                      TextSpan(
                        text: '${app!.busReserveLocation}：',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: '${busTime.getStart(app)}${app!.campus}\n',
                      ),
                      TextSpan(
                        text: '${app!.busReserveTime}：',
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
        },
        onFailure: (DioError e) =>
            handleDioError(context, e, app!.busReserveFailTitle, 'book_bus'),
        onError: (GeneralResponse response) =>
            handleGeneralError(context, response, app!.busReserveFailTitle),
      ),
    );
  }

  cancelBusReservation(BusTime busTime) {
    showDialog(
      context: context,
      builder: (BuildContext context) => WillPopScope(
        child: ProgressDialog(app!.canceling),
        onWillPop: () async {
          return false;
        },
      ),
      barrierDismissible: false,
    );
    Helper.instance.cancelBusReservation(
      cancelKey: busTime.cancelKey,
      callback: GeneralCallback(
        onSuccess: (CancelBusData data) {
          _getBusTimeTables();
          FirebaseAnalyticsUtils.instance.logEvent('cancel_bus_success');
          Navigator.of(context, rootNavigator: true).pop();
          showDialog(
            context: context,
            builder: (BuildContext context) => DefaultDialog(
              title: app!.busCancelReserveSuccess,
              contentWidget: RichText(
                textAlign: TextAlign.left,
                text: TextSpan(
                    style: TextStyle(
                        color: ApTheme.of(context).grey,
                        height: 1.3,
                        fontSize: 16.0),
                    children: [
                      TextSpan(
                        text: '${app!.busReserveCancelDate}：',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: '${busTime.getDate()}\n',
                      ),
                      TextSpan(
                        text: '${app!.busReserveCancelLocation}：',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: '${busTime.getStart(app)}${app!.campus}\n',
                      ),
                      TextSpan(
                        text: '${app!.busReserveCancelTime}：',
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
        onFailure: (DioError e) =>
            handleDioError(context, e, app!.busCancelReserveFail, 'cancel_bus'),
        onError: (GeneralResponse response) =>
            handleGeneralError(context, response, app!.busCancelReserveFail),
      ),
    );
  }

  static handleGeneralError(
    BuildContext context,
    GeneralResponse response,
    String title,
  ) {
    Navigator.of(context, rootNavigator: true).pop();
    DialogUtils.showDefault(
      context: context,
      title: title,
      content: response.getGeneralMessage(context),
    );
  }

  static handleDioError(
    BuildContext context,
    DioError e,
    String title,
    String tag,
  ) {
    Navigator.of(context, rootNavigator: true).pop();
    String? message;
    switch (e.type) {
      case DioErrorType.response:
        final errorResponse = ErrorResponse.fromJson(e.response!.data);
        message = errorResponse.description;
        FirebaseAnalyticsUtils.instance.logEvent(
          tag,
          parameters: {
            'message': errorResponse.description,
          },
        );
        break;
      case DioErrorType.other:
        if (e.message.contains("HttpException"))
          message = AppLocalizations.of(context).busFailInfinity;
        else
          message = ApLocalizations.of(context).somethingError;
        break;
      case DioErrorType.cancel:
        break;
      default:
        message = e.i18nMessage;
        break;
    }
    if (message != null)
      DialogUtils.showDefault(
        context: context,
        title: title,
        content: message,
      );
  }
}
