import 'package:ap_common/ap_common.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/api/helper.dart';
import 'package:nkust_ap/config/constants.dart';
import 'package:nkust_ap/models/bus_violation_records_data.dart';
import 'package:nkust_ap/utils/app_localizations.dart';
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
  late AppLocalizations app;
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
    app = AppLocalizations.of(context);
    ap = ApLocalizations.of(context);
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
                                        color: ApTheme.of(context).greyText,
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
                            color:
                                (index != 0) ? ApTheme.of(context).grey : null,
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
                              color: ApTheme.of(context).yellow,
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
                                  ? ApTheme.of(context).yellow
                                  : ApTheme.of(context).red,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            color: (index != reservations.length - 1)
                                ? ApTheme.of(context).grey
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
                                        color: ApTheme.of(context).greyText,
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
    Helper.instance.getBusViolationRecords(
      callback: GeneralCallback<BusViolationRecordsData>(
        onSuccess: (BusViolationRecordsData data) {
          violationData = data;
          violationData!.reservations.sort(
            (Reservation a, Reservation b) => b.time.compareTo(a.time),
          );
          if (mounted) {
            setState(() {
              if (violationData == null ||
                  violationData!.reservations.isEmpty) {
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
        },
        onFailure: (DioException e) {
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
                      'getBusViolationRecords',
                      e.response!.statusCode!,
                      message: e.message ?? '',
                    );
                  }
                });
                if (e.response!.statusCode == 401 ||
                    e.response!.statusCode == 403) {
                  AnalyticsUtil.instance.setUserProperty(
                    Constants.canUseBus,
                    AnalyticsConstants.no,
                  );
                }
              case DioExceptionType.unknown:
                setState(() {
                  if (e.message?.contains('HttpException') ?? false) {
                    state = _State.custom;
                    customStateHint = app.busFailInfinity;
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
        onError: (GeneralResponse response) {
          setState(() {
            state = _State.custom;
            customStateHint = response.getGeneralMessage(context);
          });
        },
      ),
    );
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
        DateFormat('E h:mm a', ApLocalizations.of(context).dateTimeLocale);
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
                      color: ApTheme.of(context).greyText,
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
                color: ApTheme.of(context).greyText,
              ),
              const SizedBox(width: 2.0),
              Text(
                dateFormat
                    .format(reservation!.time.add(const Duration(hours: 8))),
                style: TextStyle(
                  color: ApTheme.of(context).greyText,
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
                    reservation!.isPayment
                        ? AppLocalizations.of(context).paid
                        : AppLocalizations.of(context).unpaid,
                    style: TextStyle(
                      color: reservation!.isPayment
                          ? ApTheme.of(context).green
                          : ApTheme.of(context).red,
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
        color: ApTheme.of(context).blueAccent,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 1.0,
        horizontal: 8.0,
      ),
      child: Text(
        station ?? AppLocalizations.of(context).unknown,
        overflow: TextOverflow.fade,
        style: TextStyle(
          fontSize: 12.0,
          color: ApTheme.of(context).courseText,
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
      color: ApTheme.of(context).blue,
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
                  strokeColor: ApTheme.of(context).blue,
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
