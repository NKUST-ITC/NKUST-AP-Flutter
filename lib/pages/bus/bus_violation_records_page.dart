import 'package:ap_common/config/analytics_constants.dart';
import 'package:ap_common/resources/ap_icon.dart';
import 'package:ap_common/resources/ap_theme.dart';
import 'package:ap_common/utils/ap_localizations.dart';
import 'package:ap_common/widgets/hint_content.dart';
import 'package:ap_common_firebase/utils/firebase_analytics_utils.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/api/helper.dart';
import 'package:nkust_ap/config/constants.dart';
import 'package:nkust_ap/models/bus_violation_records_data.dart';
import 'package:nkust_ap/utils/app_localizations.dart';
import 'package:nkust_ap/widgets/share_data_widget.dart';
import 'package:intl/intl.dart';

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
  AppLocalizations app;
  ApLocalizations ap;

  _State state = _State.loading;

  String customStateHint = '';

  BusViolationRecordsData violationData;

  String get errorText {
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
        return Center(
          child: CircularProgressIndicator(),
        );
      case _State.error:
      case _State.empty:
      case _State.campusNotSupport:
      case _State.userNotSupport:
      case _State.custom:
        return FlatButton(
          onPressed: () {
            getBusViolationRecords();
            FirebaseAnalyticsUtils.instance.logAction('retry', 'click');
          },
          child: HintContent(
            icon: ApIcon.assignment,
            content: errorText,
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
        return null;
      },
      child: CustomScrollView(
        slivers: <Widget>[
          SliverPersistentHeader(
            delegate: MySliverAppBar(
              expandedHeight: 140,
              text: '\$${violationData?.notPaymentAmountend ?? 0}',
            ),
            pinned: false,
          ),
          SliverFixedExtentList(
            itemExtent: 100.0,
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                bool isLeft = (index % 2 != 0);
                final reservations = violationData.reservations;
                final isShowYear = (index == 0) ||
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
                            borderRadius: BorderRadius.all(
                              Radius.circular(40),
                            ),
                            border: Border.all(
                              width: 3,
                              color: ApTheme.of(context).yellow,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Text(
                            '${reservations[index].amountendText}',
                            style: TextStyle(
                              color: reservations[index].isPayment
                                  ? ApTheme.of(context).yellow
                                  : ApTheme.of(context).red,
                            ),
                          ),
                          constraints: BoxConstraints(
                            minWidth: 45.0,
                            minHeight: 45.0,
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
              childCount: violationData?.reservations?.length ?? 0,
            ),
          )
        ],
      ),
    );
  }

  Future<void> getBusViolationRecords() async {
    Helper.instance.getBusViolationRecords(
      callback: GeneralCallback(
        onSuccess: (BusViolationRecordsData data) {
          violationData = data;
          if (mounted) {
            setState(() {
              if (violationData == null ||
                  violationData.reservations.length == 0)
                state = _State.empty;
              else
                state = _State.finish;
              ShareDataWidget.of(context).data.hasBusViolationRecords =
                  (data?.hasBusViolationRecords ?? false);
            });
          }
          FirebaseAnalyticsUtils.instance.setUserProperty(
            Constants.CAN_USE_BUS,
            AnalyticsConstants.yes,
          );
          FirebaseAnalyticsUtils.instance.setUserProperty(
            Constants.HAS_BUS_VIOLATION,
            (data?.hasBusViolationRecords ?? false)
                ? AnalyticsConstants.yes
                : AnalyticsConstants.no,
          );
        },
        onFailure: (DioError e) {
          if (mounted)
            switch (e.type) {
              case DioErrorType.response:
                setState(() {
                  if (e.response.statusCode == 401)
                    state = _State.userNotSupport;
                  else if (e.response.statusCode == 403)
                    state = _State.campusNotSupport;
                  else {
                    state = _State.custom;
                    customStateHint = e.message;
                    FirebaseAnalyticsUtils.instance.logApiEvent(
                        'getBusViolationRecords', e.response.statusCode,
                        message: e.message);
                  }
                });
                if (e.response.statusCode == 401 ||
                    e.response.statusCode == 403)
                  FirebaseAnalyticsUtils.instance.setUserProperty(
                    Constants.CAN_USE_BUS,
                    AnalyticsConstants.no,
                  );
                break;
              case DioErrorType.other:
                setState(() {
                  if (e.message.contains("HttpException")) {
                    state = _State.custom;
                    customStateHint = app.busFailInfinity;
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
            customStateHint = response.getGeneralMessage(context);
          });
        },
      ),
    );
  }
}

class ReservationItem extends StatelessWidget {
  final Reservation reservation;
  final bool isLeft;

  const ReservationItem({
    Key key,
    this.reservation,
    this.isLeft,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat =
        DateFormat('E h:mm a', ApLocalizations.of(context).dateTimeLocale);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 2.0,
      ),
      alignment: isLeft ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (isLeft)
                startStation(
                  context,
                  reservation.startStationText(context),
                ),
              Tooltip(
                message: '${reservation.time.year}',
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: Text(
                    '${reservation.time.month}/${reservation.time.day}',
                    style: TextStyle(
                      fontSize: 24.0,
                      color: ApTheme.of(context).greyText,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                  ),
                ),
              ),
              if (!isLeft)
                startStation(
                  context,
                  reservation.startStationText(context),
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
              SizedBox(width: 2.0),
              Text(
                dateFormat.format(reservation.time.add(Duration(hours: 8))),
                style: TextStyle(
                  color: ApTheme.of(context).greyText,
                ),
              ),
            ],
          ),
          if (reservation.amountend != 0)
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: Text(
                    reservation.isPayment
                        ? AppLocalizations.of(context).paid
                        : AppLocalizations.of(context).unpaid,
                    style: TextStyle(
                      color: reservation.isPayment
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

  Widget startStation(BuildContext context, String station) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(12),
        ),
        color: ApTheme.of(context).blueAccent,
      ),
      padding: EdgeInsets.symmetric(
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
    @required this.expandedHeight,
    @required this.text,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: ApTheme.of(context).blue,
      child: Stack(
        fit: StackFit.expand,
        overflow: Overflow.visible,
        children: [
          Opacity(
            opacity: 1 - shrinkOffset / expandedHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                SizedBox(height: 32.0),
                Text(
                  text,
                  style: TextStyle(
                    color: Colors.grey[100],
                    fontSize: 56.0,
                  ),
                ),
                SizedBox(height: 32.0),
              ],
            ),
          ),
          Positioned(
            top: expandedHeight + 8.0 - shrinkOffset,
            left: MediaQuery.of(context).size.width / 2 - 10.0,
            child: Opacity(
              opacity: (1 - shrinkOffset / expandedHeight),
              child: CustomPaint(
                painter: TrianglePainter(
                  strokeColor: ApTheme.of(context).blue,
                  strokeWidth: 10,
                  paintingStyle: PaintingStyle.fill,
                ),
                child: Container(
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
    Paint paint = Paint()
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
