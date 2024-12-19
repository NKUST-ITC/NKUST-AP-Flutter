import 'dart:convert';
import 'dart:io';

import 'package:ap_common/ap_common.dart';
import 'package:ap_common_firebase/ap_common_firebase.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nkust_ap/models/schedule_data.dart';
import 'package:nkust_ap/res/assets.dart';
import 'package:nkust_ap/utils/global.dart';
import 'package:sprintf/sprintf.dart';

enum _State { loading, finish, error, empty, pdf }

class SchedulePage extends StatefulWidget {
  static const String routerName = '/info/schedule';

  @override
  SchedulePageState createState() => SchedulePageState();
}

class SchedulePageState extends State<SchedulePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late ApLocalizations ap;

  List<ScheduleData> scheduleDataList = <ScheduleData>[];

  _State state = _State.loading;

  int page = 1;

  TextStyle get _textBlueStyle => TextStyle(
        color: ApTheme.of(context).blueText,
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
      );

  TextStyle get _textStyle => const TextStyle(
        fontSize: 16.0,
      );
  PdfState pdfState = PdfState.loading;

  Uint8List? data;

  @override
  void initState() {
    AnalyticsUtil.instance
        .setCurrentScreen('SchedulePage', 'schedule_page.dart');
    _getSchedules();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    ap = ApLocalizations.of(context);
    return _body();
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
        return InkWell(
          onTap: _getSchedules,
          child: HintContent(
            icon: ApIcon.assignment,
            content: state == _State.error
                ? ap.clickToRetry
                : AppLocalizations.of(context).busEmpty,
          ),
        );
      case _State.pdf:
        return PdfView(
          state: pdfState,
          data: data,
          onRefresh: _getSchedules,
        );
      case _State.finish:
      default:
        return CustomScrollView(
          slivers: <Widget>[
            for (final ScheduleData value in scheduleDataList)
              ..._scheduleItem(value),
          ],
        );
    }
  }

  Future<void> _getSchedules() async {
    String data = '';
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(hours: 1),
        ),
      );
      await remoteConfig.fetchAndActivate();
      final String pdfUrl = remoteConfig.getString(Constants.schedulePdfUrl);
      if (pdfUrl.isNotEmpty) {
        downloadFdf(pdfUrl);
      } else {
        data = remoteConfig.getString(Constants.scheduleData);
      }
    } else {
      downloadFdf(
        'https://raw.githubusercontent.com/NKUST-ITC/NKUST-AP-Flutter/039ac35f41173f6c2eacfd9cc73052a257e8d68a/cal108-2.pdf',
      );
    }
    if (data.isEmpty) {
      data = await rootBundle.loadString(FileAssets.scheduleData);
    }
    final dynamic jsonArray = jsonDecode(data);
    scheduleDataList = ScheduleData.toList(
      jsonArray as List<Map<String, dynamic>>,
    );
  }

  List<Widget> _scheduleItem(ScheduleData schedule) {
    final List<Widget> events = <Widget>[];
    for (final String i in schedule.events) {
      events.add(
        Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Text(
            i,
            style: _textStyle,
            textAlign: TextAlign.left,
          ),
        ),
      );
      events.add(
        Divider(
          color: ApTheme.of(context).grey,
        ),
      );
    }
    return <Widget>[
      SliverPersistentHeader(
        pinned: true,
        delegate: _SliverAppBarDelegate(
          minHeight: 0.0,
          maxHeight: 50.0,
          child: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              schedule.week,
              style: _textBlueStyle,
              textAlign: TextAlign.left,
            ),
          ),
        ),
      ),
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            return InkWell(
              onTap: () {
                AnalyticsUtil.instance.logEvent('add_schedule_create');
                showDialog(
                  context: context,
                  builder: (BuildContext context) => YesNoDialog(
                    title: ap.events,
                    contentWidget: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          color: ApTheme.of(context).grey,
                          height: 1.3,
                          fontSize: 16.0,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: sprintf(
                              ap.addCalendarContent,
                              <dynamic>[schedule.events[index]],
                            ),
                          ),
                        ],
                      ),
                    ),
                    leftActionText: ap.cancel,
                    rightActionText: ap.determine,
                    rightActionFunction: () {
                      if (schedule.events.isNotEmpty) {
                        _addToCalendar(schedule.events[index]);
                      }
                      AnalyticsUtil.instance.logEvent('add_schedule_click');
                    },
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 16.0,
                ),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey, width: 0.5),
                  ),
                ),
                alignment: Alignment.centerLeft,
                child: Text(
                  schedule.events[index],
                  style: _textStyle,
                  textAlign: TextAlign.left,
                ),
              ),
            );
          },
          childCount: schedule.events.length,
        ),
      ),
    ];
  }

  void _addToCalendar(String msg) {
    final String timeText = msg.split(')')[0].substring(1);
    final String message = msg.split(')')[1];
    String startTimeText;
    String endTimeText;
    if (timeText.contains('~')) {
      startTimeText = timeText.split('~')[0].trim();
      endTimeText = timeText.split('~')[1].trim();
    } else {
      startTimeText = timeText;
      endTimeText = timeText;
    }
    final DateTime now = DateTime.now();
    final DateTime beginTime = DateTime(
      now.year,
      int.parse(startTimeText.split('/')[0]),
      int.parse(startTimeText.split('/')[1]),
    );
    final DateTime endTime = DateTime(
      now.year,
      int.parse(endTimeText.split('/')[0]),
      int.parse(endTimeText.split('/')[1]),
      23,
      59,
      59,
    );
    try {
      if (ApPlatformCalendarUtil.isSupported) {
        PlatformCalendarUtil.instance.addToApp(
          title: message,
          location: '高雄科技大學',
          startDate: beginTime,
          endDate: endTime,
        );
        if (Platform.isIOS) UiUtil.instance.showToast(context, ap.addSuccess);
      } else {
        UiUtil.instance.showToast(context, ap.calendarAppNotFound);
      }
    } catch (e) {
      UiUtil.instance.showToast(context, ap.calendarAppNotFound);
      rethrow;
    }
  }

  Future<void> downloadFdf(String url) async {
    try {
      final Response<Uint8List> response = await Dio().get<Uint8List>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      setState(() {
        state = _State.pdf;
        pdfState = PdfState.finish;
        data = response.data;
      });
    } catch (e) {
      setState(() {
        pdfState = PdfState.error;
        state = _State.finish;
      });
    }
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
