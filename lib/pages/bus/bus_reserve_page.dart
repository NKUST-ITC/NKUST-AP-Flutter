import 'package:ap_common/ap_common.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/api/exceptions/api_exception.dart';
import 'package:nkust_ap/api/exceptions/api_exception_l10n.dart';
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
  static const String routerName = '/bus/reserve';

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
    AnalyticsUtil.instance
        .setCurrentScreen('BusReservePage', 'bus_reserve_page.dart');
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
    ap = context.ap;
    return Scaffold(
      body: OrientationBuilder(
        builder: (_, Orientation orientation) {
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                          ),
                          child: Calendar(
                            showTodayAction: false,
                            onDateSelected: (DateTime? datetime) {
                              if (datetime != null) {
                                dateTime = datetime;
                                _getBusTimeTables();
                                AnalyticsUtil.instance
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
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Divider(
                              color:
                                  Theme.of(context).colorScheme.outlineVariant),
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
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(minWidth: double.infinity),
                    child: CupertinoSegmentedControl<Station>(
                      selectedColor: Theme.of(context).colorScheme.primary,
                      borderColor: Theme.of(context).colorScheme.primary,
                      unselectedColor: Theme.of(context).colorScheme.surface,
                      groupValue: selectStartStation,
                      children: <Station, Widget>{
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
                      onValueChanged: (Station text) {
                        if (mounted) {
                          setState(() {
                            selectStartStation = text;
                          });
                        }
                        AnalyticsUtil.instance.logEvent('segment_click');
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

  TextStyle _textStyle(BusTime busTime) => TextStyle(
        color: busTime.getColorState(context),
        fontSize: 18.0,
        decorationColor: Theme.of(context).colorScheme.onSurfaceVariant,
      );

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
            AnalyticsUtil.instance.logEvent('refresh_swipe');
            return;
          },
          child: ListView(
            physics: const NeverScrollableScrollPhysics(),
            children: _renderBusTimeWidgets(),
          ),
        );
    }
  }

  List<Widget> _renderBusTimeWidgets() {
    final List<Widget> list = <Widget>[];
    if (busData != null) {
      for (final BusTime i in busData!.timetable) {
        if (selectStartStation == Station.janGong && i.startStation == '建工') {
          list.add(_busTimeWidget(i));
        } else if (selectStartStation == Station.yanchao &&
            i.startStation == '燕巢') {
          list.add(_busTimeWidget(i));
        } else if (selectStartStation == Station.first &&
            i.startStation == '第一') {
          list.add(_busTimeWidget(i));
        }
      }
    }
    return list;
  }

  Widget _busTimeWidget(BusTime busTime) => Column(
        children: <Widget>[
          InkWell(
            onTap: busTime.canReserve() && !busTime.isReserve
                ? () => _showBookingDialog(busTime)
                : (busTime.isReserve ? () => _showCancelDialog(busTime) : null),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
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
            child: Divider(
                color: Theme.of(context).colorScheme.outlineVariant,
                height: 0.0),
          ),
        ],
      );

  Future<void> _getBusTimeTables() async {
    if (PreferenceUtil.instance.getBool(Constants.prefIsOfflineLogin, false)) {
      setState(() {
        state = _State.offline;
      });
      return;
    }
    Helper.cancelToken!.cancel('');
    Helper.cancelToken = CancelToken();
    if (mounted) setState(() => state = _State.loading);
    try {
      final BusData data = await Helper.instance.getBusTimeTables(
        dateTime: dateTime,
      );
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
    } on ApException catch (e) {
      if (e is CancelledException) return;
      if (!mounted) return;
      if (e is ServerException) {
        switch (e.httpStatusCode) {
          case 401:
            setState(() => state = _State.userNotSupport);
            AnalyticsUtil.instance.setUserProperty(
              Constants.canUseBus,
              AnalyticsConstants.no,
            );
          case 403:
            setState(() {
              state = _State.custom;
              // Bus "cannot reserve" business rule keeps the raw server
              // message (e.g. reservation window closed); other 403s fall
              // back to the generic campus-unsupported hint.
              customStateHint = e.message.isNotEmpty
                  ? e.message
                  : e.toLocalizedMessage(context);
            });
          default:
            setState(() {
              state = _State.custom;
              customStateHint = e.toLocalizedMessage(context);
            });
            if (e.httpStatusCode != null) {
              AnalyticsUtil.instance.logApiEvent(
                'getBusTimeTables',
                e.httpStatusCode!,
                message: e.message,
              );
            }
        }
      } else {
        setState(() {
          state = _State.custom;
          customStateHint = e.toLocalizedMessage(context);
        });
      }
    }
  }

  void _showBookingDialog(BusTime busTime) {
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
      builder: (BuildContext context) => YesNoDialog(
        title: '${busTime.getSpecialTrainTitle(app)}'
            '${busTime.specialTrain == '0' ? app!.reserve : ''}',
        contentWidget: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              color: Theme.of(context).colorScheme.outlineVariant,
              height: 1.3,
              fontSize: 16.0,
            ),
            children: <TextSpan>[
              TextSpan(
                text: '${busTime.getTime()} $start\n',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: '${app!.destination}：${busTime.getEnd(app)}\n\n',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (busTime.description != null &&
                  busTime.description!.isNotEmpty)
                TextSpan(
                  text:
                      '${busTime.description!.replaceAll('<br />', '\n')}\n\n',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    height: 1.3,
                    fontSize: 14.0,
                  ),
                ),
              TextSpan(
                text: app!.busReserveConfirmTitle,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
            ],
          ),
        ),
        leftActionText: ap.cancel,
        rightActionText: app!.reserve,
        rightActionFunction: () {
          _bookingBus(busTime);
        },
      ),
    );
  }

  void _showCancelDialog(BusTime busTime) {
    showDialog(
      context: context,
      builder: (BuildContext context) => YesNoDialog(
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

  Future<void> _bookingBus(BusTime busTime) async {
    showDialog(
      context: context,
      builder: (BuildContext context) => PopScope(
        canPop: false,
        child: ProgressDialog(app!.reserving),
      ),
      barrierDismissible: false,
    );
    try {
      await Helper.instance.bookingBusReservation(
        busId: busTime.busId,
      );
      _getBusTimeTables();
      _refreshBusReservationsCache();
      AnalyticsUtil.instance.logEvent('book_bus_success');
      Navigator.of(context, rootNavigator: true).pop();
      showDialog(
        context: context,
        builder: (BuildContext context) => DefaultDialog(
          title: app!.busReserveSuccess,
          contentWidget: RichText(
            textAlign: TextAlign.left,
            text: TextSpan(
              style: TextStyle(
                color: Theme.of(context).colorScheme.outlineVariant,
                height: 1.3,
                fontSize: 16.0,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: '${app!.busReserveDate}：',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: '${busTime.getDate()}\n',
                ),
                TextSpan(
                  text: '${app!.busReserveLocation}：',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: '${busTime.getStart(app)}${app!.campus}\n',
                ),
                TextSpan(
                  text: '${app!.busReserveTime}：',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: busTime.getTime(),
                ),
              ],
            ),
          ),
          actionText: ap.iKnow,
          actionFunction: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
        ),
      );
    } on ApException catch (e) {
      if (e is CancelledException) return;
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        UiUtil.instance.showToast(context, e.toLocalizedMessage(context));
      }
    }
  }

  Future<void> cancelBusReservation(BusTime busTime) async {
    showDialog(
      context: context,
      builder: (BuildContext context) => PopScope(
        canPop: false,
        child: ProgressDialog(app!.canceling),
      ),
      barrierDismissible: false,
    );
    try {
      await Helper.instance.cancelBusReservation(
        cancelKey: busTime.cancelKey!,
      );
      _getBusTimeTables();
      _refreshBusReservationsCache();
      AnalyticsUtil.instance.logEvent('cancel_bus_success');
      Navigator.of(context, rootNavigator: true).pop();
      showDialog(
        context: context,
        builder: (BuildContext context) => DefaultDialog(
          title: app!.busCancelReserveSuccess,
          contentWidget: RichText(
            textAlign: TextAlign.left,
            text: TextSpan(
              style: TextStyle(
                color: Theme.of(context).colorScheme.outlineVariant,
                height: 1.3,
                fontSize: 16.0,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: '${app!.busReserveCancelDate}：',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: '${busTime.getDate()}\n',
                ),
                TextSpan(
                  text: '${app!.busReserveCancelLocation}：',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: '${busTime.getStart(app)}${app!.campus}\n',
                ),
                TextSpan(
                  text: '${app!.busReserveCancelTime}：',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: busTime.getTime(),
                ),
              ],
            ),
          ),
          actionText: ap.iKnow,
          actionFunction: () =>
              Navigator.of(context, rootNavigator: true).pop(),
        ),
      );
    } on ApException catch (e) {
      if (e is CancelledException) return;
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        UiUtil.instance.showToast(context, e.toLocalizedMessage(context));
      }
    }
  }

  Future<void> _refreshBusReservationsCache() async {
    try {
      final BusReservationsData data =
          await Helper.instance.getBusReservations();
      data.save(Helper.username);
    } catch (_) {}
  }

}
