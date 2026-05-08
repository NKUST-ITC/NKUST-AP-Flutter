import 'package:ap_common/ap_common.dart';
import 'package:flutter/material.dart';
import 'package:nkust_crawler/nkust_crawler.dart';
import 'package:nkust_ap/api/exceptions/api_exception_l10n.dart';
import 'package:nkust_ap/config/constants.dart';
import 'package:nkust_ap/extensions/bus_violation_records_data_ui_extension.dart';
import 'package:nkust_ap/l10n/nkust_localizations.dart';
import 'package:nkust_ap/widgets/share_data_widget.dart';

enum _State {
  loading,
  finish,
  error,
  empty,
  campusNotSupport,
  userNotSupport,
  custom
}

class BusViolationRecordsPage extends StatefulWidget {
  @override
  _BusViolationRecordsPageState createState() =>
      _BusViolationRecordsPageState();
}

class _BusViolationRecordsPageState extends State<BusViolationRecordsPage> {
  late NkustLocalizations app;
  late ApLocalizations ap;

  _State state = _State.loading;

  String? customStateHint = '';

  BusViolationRecordsData? violationData;

  String? get errorText {
    switch (state) {
      case _State.error:
        return ap.clickToRetry;
      case _State.empty:
        return app.busViolationRecordEmpty;
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

  @override
  void initState() {
    getBusViolationRecords();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    app = context.t;
    ap = context.ap;
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
            getBusViolationRecords();
            AnalyticsUtil.instance.logEvent('retry_click');
          },
          child: HintContent(
            icon: ApIcon.assignment,
            content: errorText!,
          ),
        );
      default:
        return _body();
    }
  }

  Widget _body() {
    return RefreshIndicator(
      onRefresh: () async {
        await getBusViolationRecords();
        return;
      },
      child: CustomScrollView(
        slivers: <Widget>[
          SliverPersistentHeader(
            delegate: MySliverAppBar(
              expandedHeight: 140,
              text: '\$${violationData?.notPaymentAmountend ?? 0}',
            ),
          ),
          SliverFixedExtentList(
            itemExtent: 100.0,
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                final bool isLeft = index % 2 != 0;
                final List<Reservation> reservations =
                    violationData!.reservations;
                final bool isShowYear = (index == 0) ||
                    (index == reservations.length - 1) ||
                    (reservations[index].time.year !=
                        reservations[index + 1].time.year) ||
                    (reservations[index].time.year !=
                        reservations[index - 1].time.year);
                return Row(
                  children: <Widget>[
                    Expanded(
                      child: isLeft
                          ? ReservationItem(
                              reservation: reservations[index],
                              isLeft: true,
                            )
                          : Center(
                              child: isShowYear
                                  ? Text(
                                      '${reservations[index].time.year}',
                                      style: TextStyle(
                                        fontSize: 28.0,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                    )
                                  : null,
                            ),
                    ),
                    Column(
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            color: (index != 0)
                                ? Theme.of(context).colorScheme.outlineVariant
                                : null,
                            width: 1.0,
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(40),
                            ),
                            border: Border.all(
                              width: 3,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 45.0,
                            minHeight: 45.0,
                          ),
                          child: Text(
                            reservations[index].amountendText,
                            style: TextStyle(
                              color: reservations[index].isPayment
                                  ? Theme.of(context).colorScheme.secondary
                                  : Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            color: (index != reservations.length - 1)
                                ? Theme.of(context).colorScheme.outlineVariant
                                : null,
                            width: 1.0,
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: !isLeft
                          ? ReservationItem(
                              reservation: reservations[index],
                              isLeft: false,
                            )
                          : Center(
                              child: isShowYear
                                  ? Text(
                                      '${reservations[index].time.year}',
                                      style: TextStyle(
                                        fontSize: 28.0,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                    )
                                  : null,
                            ),
                    ),
                  ],
                );
              },
              childCount: violationData?.reservations.length ?? 0,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> getBusViolationRecords() async {
    try {
      final BusViolationRecordsData data =
          await Helper.instance.getBusViolationRecords();
      violationData = data;
      violationData!.reservations.sort(
        (Reservation a, Reservation b) => b.time.compareTo(a.time),
      );
      if (mounted) {
        setState(() {
          if (violationData == null || violationData!.reservations.isEmpty) {
            state = _State.empty;
          } else {
            state = _State.finish;
          }
          ShareDataWidget.of(context)!.data.hasBusViolationRecords =
              data.hasBusViolationRecords;
        });
      }
      AnalyticsUtil.instance.setUserProperty(
        Constants.canUseBus,
        AnalyticsConstants.yes,
      );
      AnalyticsUtil.instance.setUserProperty(
        Constants.hasBusViolation,
        (data.hasBusViolationRecords)
            ? AnalyticsConstants.yes
            : AnalyticsConstants.no,
      );
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
            'getBusViolationRecords',
            e.httpStatusCode!,
            message: e.message,
          );
        }
      }
    }
  }
}

class ReservationItem extends StatelessWidget {
  final Reservation? reservation;
  final bool? isLeft;

  const ReservationItem({
    super.key,
    this.reservation,
    this.isLeft,
  });

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat =
        DateFormat('E h:mm a', context.ap.dateTimeLocale);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 2.0,
      ),
      alignment: isLeft! ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (isLeft!)
                startStation(
                  context,
                  reservation!.startStationText(context),
                ),
              Tooltip(
                message: '${reservation!.time.year}',
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: Text(
                    '${reservation!.time.month}/${reservation!.time.day}',
                    style: TextStyle(
                      fontSize: 24.0,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                  ),
                ),
              ),
              if (!isLeft!)
                startStation(
                  context,
                  reservation!.startStationText(context),
                ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                ApIcon.accessTime,
                size: 12.0,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 2.0),
              Text(
                dateFormat
                    .format(reservation!.time.add(const Duration(hours: 8))),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          if (reservation!.amountend != 0)
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: Text(
                    reservation!.isPayment ? context.t.paid : context.t.unpaid,
                    style: TextStyle(
                      color: reservation!.isPayment
                          ? Theme.of(context).colorScheme.tertiary
                          : Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget startStation(BuildContext context, String? station) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(12),
        ),
        color: Theme.of(context).colorScheme.primary,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 1.0,
        horizontal: 8.0,
      ),
      child: Text(
        station ?? context.t.unknown,
        overflow: TextOverflow.fade,
        style: TextStyle(
          fontSize: 12.0,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    );
  }
}

class MySliverAppBar extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  final String text;

  MySliverAppBar({
    required this.expandedHeight,
    required this.text,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.primary,
      child: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: <Widget>[
          Opacity(
            opacity: 1 - shrinkOffset / expandedHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                const SizedBox(height: 32.0),
                Text(
                  text,
                  style: TextStyle(
                    color: Colors.grey[100],
                    fontSize: 56.0,
                  ),
                ),
                const SizedBox(height: 32.0),
              ],
            ),
          ),
          Positioned(
            top: expandedHeight + 8.0 - shrinkOffset,
            left: MediaQuery.of(context).size.width / 2 - 10.0,
            child: Opacity(
              opacity: 1 - shrinkOffset / expandedHeight,
              child: CustomPaint(
                painter: TrianglePainter(
                  strokeColor: Theme.of(context).colorScheme.primary,
                  strokeWidth: 10,
                  paintingStyle: PaintingStyle.fill,
                ),
                child: const SizedBox(
                  height: 18,
                  width: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => kToolbarHeight;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}

class TrianglePainter extends CustomPainter {
  final Color strokeColor;
  final PaintingStyle paintingStyle;
  final double strokeWidth;

  TrianglePainter({
    this.strokeColor = Colors.black,
    this.strokeWidth = 3,
    this.paintingStyle = PaintingStyle.stroke,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = strokeColor
      ..strokeWidth = strokeWidth
      ..style = paintingStyle;

    canvas.drawPath(getTrianglePath(size.width, size.height), paint);
  }

  Path getTrianglePath(double x, double y) {
    return Path()
      ..moveTo(0, -y * 0.5)
      ..lineTo(x / 2, 0)
      ..lineTo(x, -y * 0.5)
      ..lineTo(0, -y * 0.5);
  }

  @override
  bool shouldRepaint(TrianglePainter oldDelegate) {
    return oldDelegate.strokeColor != strokeColor ||
        oldDelegate.paintingStyle != paintingStyle ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
