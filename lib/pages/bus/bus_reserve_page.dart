import 'package:ap_common/ap_common.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/models/booking_bus_data.dart';
import 'package:nkust_ap/models/cancel_bus_data.dart';
import 'package:nkust_ap/models/error_response.dart';
import 'package:nkust_ap/models/models.dart';
import 'package:nkust_ap/utils/global.dart';
import 'package:nkust_ap/widgets/flutter_calendar.dart';

enum _State { loading, finish, error, empty, campusNotSupport, userNotSupport, offline, custom }

enum Station { janGong, yanchao, first }

class BusReservePage extends StatefulWidget {
  static const String routerName = '/bus/reserve';

  @override
  BusReservePageState createState() => BusReservePageState();
}

class BusReservePageState extends State<BusReservePage> with AutomaticKeepAliveClientMixin {
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
    AnalyticsUtil.instance.setCurrentScreen(
      'BusReservePage',
      'bus_reserve_page.dart',
    );
    _getBusTimeTables();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    app = AppLocalizations.of(context);
    ap = ApLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: OrientationBuilder(
        builder: (_, orientation) {
          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  leading: Container(),
                  expandedHeight: orientation == Orientation.portrait
                      ? MediaQuery.of(context).size.height * 0.20
                      : MediaQuery.of(context).size.width * 0.19,
                  floating: true,
                  backgroundColor: Colors.transparent,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Column(
                      children: [
                        Container(
                          color: Colors.transparent,
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Calendar(
                            showTodayAction: false,
                            onDateSelected: (datetime) {
                              if (datetime != null) {
                                dateTime = datetime;
                                _getBusTimeTables();
                                AnalyticsUtil.instance.logEvent(
                                  'date_picker_click',
                                );
                              }
                            },
                            initialCalendarDateOverride: dateTime,
                            dayChildAspectRatio: orientation == Orientation.portrait ? 1.5 : 3,
                            weekdays: ap.weekdays,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Divider(color: colorScheme.outlineVariant),
                        ),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: double.infinity),
                    child: CupertinoSegmentedControl<Station>(
                      selectedColor: colorScheme.primary,
                      borderColor: colorScheme.primary,
                      unselectedColor: colorScheme.surface,
                      groupValue: selectStartStation,
                      children: {
                        Station.janGong: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(app!.fromJiangong),
                        ),
                        Station.yanchao: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(app!.fromYanchao),
                        ),
                        Station.first: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(app!.fromFirst),
                        ),
                      },
                      onValueChanged: (text) {
                        if (mounted) setState(() => selectStartStation = text);
                        AnalyticsUtil.instance.logEvent('segment_click');
                      },
                    ),
                  ),
                ),
                Expanded(child: _body()),
              ],
            ),
          );
        },
      ),
    );
  }

  TextStyle _textStyle(BusTime busTime) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextStyle(
      color: busTime.getColorState(context),
      fontSize: 18.0,
      decorationColor: colorScheme.onSurfaceVariant,
    );
  }

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
          alignment: Alignment.center,
          child: const CircularProgressIndicator(),
        );
      case _State.error:
      case _State.empty:
      case _State.campusNotSupport:
      case _State.userNotSupport:
      case _State.custom:
        return InkWell(
          onTap: () {
            _getBusTimeTables();
            AnalyticsUtil.instance.logEvent('retry_click');
          },
          child: HintContent(icon: ApIcon.assignment, content: errorText!),
        );
      case _State.offline:
        return HintContent(icon: ApIcon.offlineBolt, content: ap.offlineMode);
      default:
        return RefreshIndicator(
          onRefresh: () async {
            await _getBusTimeTables();
            AnalyticsUtil.instance.logEvent('refresh_swipe');
          },
          child: ListView(
            physics: const NeverScrollableScrollPhysics(),
            children: _renderBusTimeWidgets(),
          ),
        );
    }
  }

  List<Widget> _renderBusTimeWidgets() {
    final list = <Widget>[];
    if (busData != null) {
      for (final i in busData!.timetable) {
        if (selectStartStation == Station.janGong && i.startStation == '建工') {
          list.add(_busTimeWidget(i));
        } else if (selectStartStation == Station.yanchao && i.startStation == '燕巢') {
          list.add(_busTimeWidget(i));
        } else if (selectStartStation == Station.first && i.startStation == '第一') {
          list.add(_busTimeWidget(i));
        }
      }
    }
    return list;
  }

  Widget _busTimeWidget(BusTime busTime) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        InkWell(
          onTap: busTime.canReserve() && !busTime.isReserve
              ? () => _showBookingDialog(busTime)
              : (busTime.isReserve ? () => _showCancelDialog(busTime) : null),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
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
                    '${busTime.reserveCount} ${ap.people}',
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
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Divider(color: colorScheme.outlineVariant, height: 0.0),
        ),
      ],
    );
  }

  Future<void> _getBusTimeTables() async {
    if (PreferenceUtil.instance.getBool(Constants.prefIsOfflineLogin, false)) {
      setState(() => state = _State.offline);
      return;
    }
    Helper.cancelToken!.cancel('');
    Helper.cancelToken = CancelToken();
    if (mounted) setState(() => state = _State.loading);
    Helper.instance.getBusTimeTables(
      dateTime: dateTime,
      callback: GeneralCallback<BusData>(
        onSuccess: (data) {
          busData = data;
          if (mounted) {
            setState(() {
              if (busData == null || busData!.timetable.isEmpty) {
                state = _State.empty;
              } else {
                state = _State.finish;
              }
            });
          }
          AnalyticsUtil.instance.setUserProperty(
            Constants.canUseBus,
            AnalyticsConstants.yes,
          );
        },
        onFailure: (e) {
          if (mounted) {
            switch (e.type) {
              case DioExceptionType.badResponse:
                setState(() {
                  if (e.response!.statusCode == 401) {
                    state = _State.userNotSupport;
                  } else if (e.response!.statusCode == 403) {
                    state = _State.campusNotSupport;
                  } else {
                    state = _State.custom;
                    customStateHint = e.message;
                    AnalyticsUtil.instance.logApiEvent(
                      'getBusTimeTables',
                      e.response!.statusCode!,
                      message: e.message ?? '',
                    );
                  }
                });
                if (e.response!.statusCode == 401 || e.response!.statusCode == 403) {
                  AnalyticsUtil.instance.setUserProperty(
                    Constants.canUseBus,
                    AnalyticsConstants.no,
                  );
                }
              case DioExceptionType.unknown:
                setState(() {
                  if (e.message?.contains('HttpException') ?? false) {
                    state = _State.custom;
                    customStateHint = app!.busFailInfinity;
                  } else {
                    state = _State.error;
                  }
                });
              case DioExceptionType.cancel:
                break;
              default:
                setState(() {
                  state = _State.custom;
                  customStateHint = e.i18nMessage;
                });
            }
          }
        },
        onError: (response) {
          setState(() {
            state = _State.custom;
            customStateHint = response.statusCode == 403 ? response.message : response.getGeneralMessage(context);
          });
        },
      ),
    );
  }

  void _showBookingDialog(BusTime busTime) {
    final colorScheme = Theme.of(context).colorScheme;
    String start = '';
    if (selectStartStation == Station.janGong) {
      start = app!.fromJiangong;
    } else if (selectStartStation == Station.yanchao) {
      start = app!.fromYanchao;
    } else if (selectStartStation == Station.first) {
      start = app!.fromFirst;
    }
    showDialog(
      context: context,
      builder: (_) => YesNoDialog(
        title: '${busTime.getSpecialTrainTitle(app)}'
            '${busTime.specialTrain == '0' ? app!.reserve : ''}',
        contentWidget: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              height: 1.3,
              fontSize: 16.0,
            ),
            children: [
              TextSpan(
                text: '${busTime.getTime()} $start\n',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: '${app!.destination}：${busTime.getEnd(app)}\n\n',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (busTime.description != null && busTime.description!.isNotEmpty)
                TextSpan(
                  text: '${busTime.description!.replaceAll('<br />', '\n')}\n\n',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.3,
                    fontSize: 14.0,
                  ),
                ),
              TextSpan(
                text: app!.busReserveConfirmTitle,
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        leftActionText: ap.cancel,
        rightActionText: app!.reserve,
        rightActionFunction: () => _bookingBus(busTime),
      ),
    );
  }

  void _showCancelDialog(BusTime busTime) {
    showDialog(
      context: context,
      builder: (_) => YesNoDialog(
        title: app!.busCancelReserve,
        contentWidget: Text(
          '${app!.busCancelReserveConfirmContent1}${busTime.getStart(app)}'
          '${app!.busCancelReserveConfirmContent2}${busTime.getEnd(app)}\n'
          '${busTime.getTime()}${app!.busCancelReserveConfirmContent3}',
          textAlign: TextAlign.center,
        ),
        leftActionText: ap.back,
        rightActionText: ap.determine,
        rightActionFunction: () {
          cancelBusReservation(busTime);
          AnalyticsUtil.instance.logEvent('cancel_bus_click');
        },
      ),
    );
    AnalyticsUtil.instance.logEvent('cancel_bus_create');
  }

  void _bookingBus(BusTime busTime) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (_) => PopScope(
        canPop: false,
        child: ProgressDialog(app!.reserving),
      ),
      barrierDismissible: false,
    );
    Helper.instance.bookingBusReservation(
      busId: busTime.busId,
      callback: GeneralCallback<BookingBusData>(
        onSuccess: (data) {
          _getBusTimeTables();
          AnalyticsUtil.instance.logEvent('book_bus_success');
          Navigator.of(context, rootNavigator: true).pop();
          showDialog(
            context: context,
            builder: (_) => DefaultDialog(
              title: app!.busReserveSuccess,
              contentWidget: RichText(
                textAlign: TextAlign.left,
                text: TextSpan(
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.3,
                    fontSize: 16.0,
                  ),
                  children: [
                    TextSpan(
                      text: '${app!.busReserveDate}：',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: '${busTime.getDate()}\n'),
                    TextSpan(
                      text: '${app!.busReserveLocation}：',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: '${busTime.getStart(app)}${app!.campus}\n'),
                    TextSpan(
                      text: '${app!.busReserveTime}：',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: busTime.getTime()),
                  ],
                ),
              ),
              actionText: ap.iKnow,
              actionFunction: () => Navigator.of(context, rootNavigator: true).pop(),
            ),
          );
        },
        onFailure: (e) => handleDioError(context, e, app!.busReserveFailTitle, 'book_bus'),
        onError: (response) => handleGeneralError(context, response, app!.busReserveFailTitle),
      ),
    );
  }

  void cancelBusReservation(BusTime busTime) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (_) => PopScope(
        canPop: false,
        child: ProgressDialog(app!.canceling),
      ),
      barrierDismissible: false,
    );
    Helper.instance.cancelBusReservation(
      cancelKey: busTime.cancelKey!,
      callback: GeneralCallback<CancelBusData>(
        onSuccess: (data) {
          _getBusTimeTables();
          AnalyticsUtil.instance.logEvent('cancel_bus_success');
          Navigator.of(context, rootNavigator: true).pop();
          showDialog(
            context: context,
            builder: (_) => DefaultDialog(
              title: app!.busCancelReserveSuccess,
              contentWidget: RichText(
                textAlign: TextAlign.left,
                text: TextSpan(
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.3,
                    fontSize: 16.0,
                  ),
                  children: [
                    TextSpan(
                      text: '${app!.busReserveCancelDate}：',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: '${busTime.getDate()}\n'),
                    TextSpan(
                      text: '${app!.busReserveCancelLocation}：',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: '${busTime.getStart(app)}${app!.campus}\n'),
                    TextSpan(
                      text: '${app!.busReserveCancelTime}：',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: busTime.getTime()),
                  ],
                ),
              ),
              actionText: ap.iKnow,
              actionFunction: () => Navigator.of(context, rootNavigator: true).pop(),
            ),
          );
        },
        onFailure: (e) => handleDioError(context, e, app!.busCancelReserveFail, 'cancel_bus'),
        onError: (response) => handleGeneralError(context, response, app!.busCancelReserveFail),
      ),
    );
  }

  static void handleGeneralError(
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

  static void handleDioError(
    BuildContext context,
    DioException e,
    String title,
    String tag,
  ) {
    Navigator.of(context, rootNavigator: true).pop();
    String? message;
    switch (e.type) {
      case DioExceptionType.badResponse:
        final errorResponse = ErrorResponse.fromJson(e.response!.data as Map<String, dynamic>);
        message = errorResponse.description;
        AnalyticsUtil.instance.logEvent(
          tag,
          parameters: {'message': errorResponse.description},
        );
      case DioExceptionType.unknown:
        if (e.message?.contains('HttpException') ?? false) {
          message = AppLocalizations.of(context).busFailInfinity;
        } else {
          message = ApLocalizations.of(context).somethingError;
        }
      case DioExceptionType.cancel:
        break;
      default:
        message = e.i18nMessage;
    }
    if (message != null) {
      DialogUtils.showDefault(context: context, title: title, content: message);
    }
  }
}
