import 'dart:convert';
import 'dart:io';

import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/models/schedule_data.dart';
import 'package:nkust_ap/res/app_icon.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;
import 'package:nkust_ap/utils/cache_utils.dart';
import 'package:nkust_ap/utils/global.dart';
import 'package:nkust_ap/widgets/hint_content.dart';
import 'package:nkust_ap/widgets/yes_no_dialog.dart';
import 'package:sprintf/sprintf.dart';

enum _State { loading, finish, error, empty }

class SchedulePage extends StatefulWidget {
  static const String routerName = "/info/schedule";

  @override
  SchedulePageState createState() => new SchedulePageState();
}

class SchedulePageState extends State<SchedulePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  AppLocalizations app;

  List<ScheduleData> scheduleDataList = [];

  _State state = _State.loading;

  int page = 1;

  TextStyle get _textBlueStyle => TextStyle(
        color: Resource.Colors.blueText,
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
      );

  TextStyle get _textStyle => TextStyle(
        fontSize: 16.0,
      );

  @override
  void initState() {
    FA.setCurrentScreen("SchedulePage", "schedule_page.dart");
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
    app = AppLocalizations.of(context);
    return _body();
  }

  Widget _body() {
    switch (state) {
      case _State.loading:
        return Container(
            child: CircularProgressIndicator(), alignment: Alignment.center);
      case _State.error:
      case _State.empty:
        return FlatButton(
          onPressed: _getSchedules,
          child: HintContent(
            icon: AppIcon.assignment,
            content: state == _State.error ? app.clickToRetry : app.busEmpty,
          ),
        );
      default:
        return CustomScrollView(
          slivers: [
            for (var value in scheduleDataList) ..._scheduleItem(value),
          ],
        );
    }
  }

  _getSchedules() async {
    scheduleDataList = await CacheUtils.loadScheduleDataList();
    setState(() {
      if (scheduleDataList == null) {
        scheduleDataList = [];
        state = _State.loading;
      } else
        state = _State.finish;
    });
    final RemoteConfig remoteConfig = await RemoteConfig.instance;
    try {
      await remoteConfig.fetch(expiration: const Duration(days: 7));
      await remoteConfig.activateFetched();
    } on FetchThrottledException catch (exception) {
      setState(() {
        state = _State.error;
      });
      return;
    } catch (exception) {
      setState(() {
        state = _State.error;
      });
      throw exception;
    }
    var data = remoteConfig.getString(Constants.SCHEDULE_DATA);
    if (data == null || data.isEmpty) {
      setState(() {
        state = _State.error;
      });
    } else {
      var jsonArray = jsonDecode(data);
      scheduleDataList = ScheduleData.toList(jsonArray);
      if (mounted) {
        setState(() {
          if (scheduleDataList.length == 0)
            state = _State.empty;
          else
            state = _State.finish;
        });
      }
      CacheUtils.saveScheduleDataList(scheduleDataList);
    }
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
        color: Resource.Colors.grey,
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
              schedule.week ?? "",
              style: _textBlueStyle,
              textAlign: TextAlign.left,
            ),
          ),
        ),
      ),
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            return FlatButton(
              padding: EdgeInsets.all(0.0),
              onPressed: () {
                FA.logAction('add_schedule', 'create');
                showDialog(
                  context: context,
                  builder: (BuildContext context) => YesNoDialog(
                    title: app.events,
                    contentWidget: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                          style: TextStyle(
                              color: Resource.Colors.grey,
                              height: 1.3,
                              fontSize: 16.0),
                          children: [
                            TextSpan(
                              text: sprintf(app.addCalendarContent,
                                  [schedule.events[index]]),
                            ),
                          ]),
                    ),
                    leftActionText: app.cancel,
                    rightActionText: app.determine,
                    leftActionFunction: null,
                    rightActionFunction: () {
                      _addToCalendar(schedule.events[index]);
                      FA.logAction('add_schedule', 'click');
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
        if (Platform.isIOS) Utils.showToast(context, app.addSuccess);
      } else
        Utils.showToast(context, app.calendarAppNotFound);
    } catch (e) {
      Utils.showToast(context, app.calendarAppNotFound);
      throw e;
    }
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    @required this.minHeight,
    @required this.maxHeight,
    @required this.child,
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
