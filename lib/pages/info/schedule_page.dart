import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:ap_common/resources/ap_icon.dart';
import 'package:ap_common/resources/ap_theme.dart';
import 'package:ap_common/utils/ap_localizations.dart';
import 'package:ap_common/utils/ap_utils.dart';
import 'package:ap_common/views/pdf_view.dart';
import 'package:ap_common/widgets/hint_content.dart';
import 'package:ap_common/widgets/yes_no_dialog.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nkust_ap/models/schedule_data.dart';
import 'package:nkust_ap/res/assets.dart';
import 'package:nkust_ap/utils/global.dart';
import 'package:sprintf/sprintf.dart';

enum _State { loading, finish, error, empty, pdf }

class SchedulePage extends StatefulWidget {
  static const String routerName = "/info/schedule";

  @override
  SchedulePageState createState() => new SchedulePageState();
}

class SchedulePageState extends State<SchedulePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late ApLocalizations ap;

  List<ScheduleData> scheduleDataList = [];

  _State state = _State.loading;

  int page = 1;

  TextStyle get _textBlueStyle => TextStyle(
        color: ApTheme.of(context).blueText,
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
      );

  TextStyle get _textStyle => TextStyle(
        fontSize: 16.0,
      );
  PdfState pdfState = PdfState.loading;

  Uint8List? data;

  @override
  void initState() {
    FirebaseAnalyticsUtils.instance
        .setCurrentScreen("SchedulePage", "schedule_page.dart");
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
            child: CircularProgressIndicator(), alignment: Alignment.center);
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
          slivers: [
            for (var value in scheduleDataList) ..._scheduleItem(value),
          ],
        );
    }
  }

  _getSchedules() async {
    var data = '';
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      try {
        final RemoteConfig remoteConfig = RemoteConfig.instance;
        await remoteConfig.setConfigSettings(
          RemoteConfigSettings(
            fetchTimeout: Duration(seconds: 10),
            minimumFetchInterval: const Duration(hours: 1),
          ),
        );
        await remoteConfig.fetchAndActivate();
        final pdfUrl = remoteConfig.getString(Constants.SCHEDULE_PDF_URL);
        if (pdfUrl != null && pdfUrl.isNotEmpty) {
          downloadFdf(pdfUrl);
        } else
          data = remoteConfig.getString(Constants.SCHEDULE_DATA);
      } catch (exception) {}
    } else {
      downloadFdf(
          'https://raw.githubusercontent.com/NKUST-ITC/NKUST-AP-Flutter/039ac35f41173f6c2eacfd9cc73052a257e8d68a/cal108-2.pdf');
    }
    if (data == null || data.isEmpty) {
      data = await rootBundle.loadString(FileAssets.scheduleData);
    }
    var jsonArray = jsonDecode(data);
    scheduleDataList = ScheduleData.toList(jsonArray);
  }

  List<Widget> _scheduleItem(ScheduleData schedule) {
    List<Widget> events = [];
    for (var i in schedule.events) {
      events.add(
        Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(horizontal: 12.0),
          child: Text(
            i,
            style: _textStyle,
            textAlign: TextAlign.left,
          ),
        ),
      );
      events.add(Divider(
        color: ApTheme.of(context).grey,
      ));
    }
    return [
      SliverPersistentHeader(
        pinned: true,
        delegate: _SliverAppBarDelegate(
          minHeight: 0.0,
          maxHeight: 50.0,
          child: Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(horizontal: 12.0),
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
                FirebaseAnalyticsUtils.instance.logEvent('add_schedule_create');
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
                              fontSize: 16.0),
                          children: [
                            TextSpan(
                              text: sprintf(ap.addCalendarContent,
                                  [schedule.events[index]]),
                            ),
                          ]),
                    ),
                    leftActionText: ap.cancel,
                    rightActionText: ap.determine,
                    leftActionFunction: null,
                    rightActionFunction: () {
                      if (schedule.events != null || schedule.events.length > 0)
                        _addToCalendar(schedule.events[index]);
                      FirebaseAnalyticsUtils.instance
                          .logEvent('add_schedule_click');
                    },
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                decoration: BoxDecoration(
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
    String _time = msg.split(")")[0].substring(1);
    String _msg = msg.split(")")[1];
    String _startTime;
    String _endTime;
    if (_time.contains("~")) {
      _startTime = _time.split("~")[0].trim();
      _endTime = _time.split("~")[1].trim();
    } else {
      _startTime = _time;
      _endTime = _time;
    }
    DateTime now = DateTime.now();
    DateTime beginTime = DateTime(now.year, int.parse(_startTime.split("/")[0]),
        int.parse(_startTime.split("/")[1]), 0, 0, 0);
    DateTime endTime = DateTime(now.year, int.parse(_endTime.split("/")[0]),
        int.parse(_endTime.split("/")[1]), 23, 59, 59);
    final Event event = Event(
      title: _msg,
      description: '',
      location: '高雄科技大學',
      startDate: beginTime,
      endDate: endTime,
    );
    try {
      if (Platform.isIOS || Platform.isAndroid) {
        Add2Calendar.addEvent2Cal(event);
        if (Platform.isIOS) ApUtils.showToast(context, ap.addSuccess);
      } else
        ApUtils.showToast(context, ap.calendarAppNotFound);
    } catch (e) {
      ApUtils.showToast(context, ap.calendarAppNotFound);
      throw e;
    }
  }

  void downloadFdf(String url) async {
    try {
      var response = await Dio().get(
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
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
