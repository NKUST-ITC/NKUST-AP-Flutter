import 'package:ap_common/ap_common.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/api/exceptions/api_exception.dart';
import 'package:nkust_ap/api/exceptions/api_exception_l10n.dart';
import 'package:nkust_ap/models/models.dart';
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
  static const String routerName = '/bus/reservations';

  @override
  BusReservationsPageState createState() => BusReservationsPageState();
}

class BusReservationsPageState extends State<BusReservationsPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  _State state = _State.finish;
  String? customStateHint;

  BusReservationsData? busReservationsData;
  DateTime dateTime = DateTime.now();

  AppLocalizations? app;
  late ApLocalizations ap;

  bool isOffline = false;

  @override
  void initState() {
    AnalyticsUtil.instance
        .setCurrentScreen('BusReservationsPage', 'bus_reservations_page.dart');
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
    ap = context.ap;
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: isOffline
              ? Text(
                  app!.offlineBusReservations,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.outlineVariant),
                )
              : null,
        ),
        Expanded(
          child: _body(),
        ),
      ],
    );
  }

  String? get errorText {
    switch (state) {
      case _State.error:
        return ap.clickToRetry;
      case _State.empty:
        return app!.busReservationEmpty;
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
        return const Center(
          child: CircularProgressIndicator(),
        );
      case _State.error:
      case _State.empty:
      case _State.campusNotSupport:
      case _State.userNotSupport:
      case _State.custom:
        return InkWell(
          onTap: () {
            _getBusReservations();
            AnalyticsUtil.instance.logEvent('retry_click');
          },
          child: HintContent(
            icon: ApIcon.assignment,
            content: errorText!,
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
            AnalyticsUtil.instance.logEvent('refresh_swipe');
            return;
          },
          child: ListView.builder(
            itemCount: busReservationsData!.reservations.length,
            itemBuilder: (BuildContext context, int i) {
              return _busReservationWidget(
                busReservationsData!.reservations[i],
              );
            },
          ),
        );
    }
  }

  TextStyle _textStyle(BusReservation busReservation) => TextStyle(
        color: busReservation.getColorState(context),
        fontSize: 18.0,
        decorationColor: Theme.of(context).colorScheme.onSurfaceVariant,
      );

  Widget _busReservationWidget(BusReservation busReservation) => Column(
        children: <Widget>[
          Container(
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Icon(
                    ApIcon.directionsBus,
                    size: 20.0,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '${busReservation.getStart(app)}'
                    '→${busReservation.getEnd(app)}',
                    textAlign: TextAlign.center,
                    style: _textStyle(busReservation),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    busReservation.dateTime,
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
                          ? Theme.of(context).colorScheme.outlineVariant
                          : Theme.of(context).colorScheme.error,
                    ),
                    onPressed: isOffline
                        ? null
                        : () => _showCancelDialog(busReservation),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Divider(
              color: Theme.of(context).colorScheme.outlineVariant,
              indent: 4.0,
            ),
          ),
        ],
      );

  Future<void> _getBusReservations() async {
    if (PreferenceUtil.instance.getBool(Constants.prefIsOfflineLogin, false)) {
      busReservationsData = BusReservationsData.load(Helper.username);
      if (mounted) {
        setState(() {
          isOffline = true;
          if (busReservationsData == null) {
            state = _State.offlineEmpty;
          } else if (busReservationsData!.reservations.isNotEmpty) {
            state = _State.finish;
          } else {
            state = _State.empty;
          }
        });
      }
      return;
    }
    if (mounted) {
      setState(() {
        state = _State.loading;
      });
    }
    try {
      final BusReservationsData data =
          await Helper.instance.getBusReservations();
      busReservationsData = data;
      if (mounted) {
        setState(() {
          if (busReservationsData == null ||
              busReservationsData!.reservations.isEmpty) {
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
      busReservationsData?.save(Helper.username);
    } on ApException catch (e) {
      if (e is CancelledException) return;
      if (!mounted) return;
      if (e is AccountNotSupportedException) {
        setState(() => state = _State.userNotSupport);
        AnalyticsUtil.instance.setUserProperty(
          Constants.canUseBus,
          AnalyticsConstants.no,
        );
      } else if (e is CampusNotSupportedException) {
        setState(() => state = _State.campusNotSupport);
        AnalyticsUtil.instance.setUserProperty(
          Constants.canUseBus,
          AnalyticsConstants.no,
        );
      } else {
        setState(() {
          state = _State.custom;
          customStateHint = e.toLocalizedMessage(context);
        });
        if (e is ServerException && e.httpStatusCode != null) {
          AnalyticsUtil.instance.logApiEvent(
            'getBusReservations',
            e.httpStatusCode!,
            message: e.message,
          );
        }
      }
      _loadCache();
    }
  }

  void _showCancelDialog(BusReservation reservation) {
    showDialog(
      context: context,
      builder: (BuildContext context) => YesNoDialog(
        title: app!.busCancelReserve,
        contentWidget: Text(
          '${app!.busCancelReserveConfirmContent1}${reservation.getStart(app)}'
          '${app!.busCancelReserveConfirmContent2}${reservation.getEnd(app)}\n'
          '${reservation.getTime()}${app!.busCancelReserveConfirmContent3}',
          textAlign: TextAlign.center,
        ),
        leftActionText: ap.back,
        rightActionText: ap.determine,
        rightActionFunction: () {
          cancelBusReservation(reservation);
          AnalyticsUtil.instance.logEvent('cancel_bus_click');
        },
      ),
    );
    AnalyticsUtil.instance.logEvent('cancel_bus_create');
  }

  Future<void> cancelBusReservation(BusReservation busTime) async {
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
        cancelKey: busTime.cancelKey,
      );
      _getBusReservations();
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
        UiUtil.instance.showToast(context, e.toLocalizedMessage(context));
      }
    }
  }

  Future<void> _loadCache() async {
    busReservationsData = BusReservationsData.load(Helper.username);
    if (mounted) {
      setState(() {
        isOffline = true;
        if (busReservationsData == null) {
          state = _State.offlineEmpty;
        } else if (busReservationsData!.reservations.isNotEmpty) {
          state = _State.finish;
        } else {
          state = _State.empty;
        }
      });
    }
  }
}
