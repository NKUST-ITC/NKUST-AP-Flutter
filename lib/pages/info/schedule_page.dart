import 'dart:convert';
import 'dart:io';

import 'package:ap_common/ap_common.dart';
import 'package:ap_common_firebase/ap_common_firebase.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nkust_ap/res/assets.dart';
import 'package:nkust_ap/utils/global.dart';

enum _State { loading, finish, error, empty, pdf }

enum _Category { holiday, exam, enrollment, registrar, general }

const List<String> _weekdayLabels = <String>[
  '日',
  '一',
  '二',
  '三',
  '四',
  '五',
  '六',
];

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  static const String routerName = '/info/schedule';

  @override
  SchedulePageState createState() => SchedulePageState();
}

class SchedulePageState extends State<SchedulePage>
    with AutomaticKeepAliveClientMixin {
  static const String _fallbackPdfUrl =
      'https://raw.githubusercontent.com/NKUST-ITC/NKUST-AP-Flutter/master/'
      'school_schedule.pdf';

  @override
  bool get wantKeepAlive => true;

  late ApLocalizations ap;

  List<_CalendarEvent> events = <_CalendarEvent>[];
  DateTime firstMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime lastMonth = DateTime(DateTime.now().year, DateTime.now().month);
  late DateTime focusedMonth = firstMonth;
  DateTime? selectedDay;

  _State state = _State.loading;

  PdfState pdfState = PdfState.loading;

  Uint8List? pdfData;

  @override
  void initState() {
    AnalyticsUtil.instance
        .setCurrentScreen('SchedulePage', 'schedule_page.dart');
    _getSchedules();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    ap = context.ap;
    return _body();
  }

  Widget _body() {
    switch (state) {
      case _State.loading:
        return const Center(child: CircularProgressIndicator());
      case _State.error:
      case _State.empty:
        return InkWell(
          onTap: () {
            setState(() => state = _State.loading);
            _getSchedules();
          },
          child: HintContent(
            icon: ApIcon.assignment,
            content:
                state == _State.error ? ap.clickToRetry : context.t.busEmpty,
          ),
        );
      case _State.pdf:
        return Column(
          children: <Widget>[
            _viewSwitchBar(showingPdf: true),
            Expanded(
              child: PdfView(
                state: pdfState,
                data: pdfData,
                onRefresh: _downloadPdf,
              ),
            ),
          ],
        );
      case _State.finish:
        final List<_CalendarEvent> dayEvents =
            selectedDay == null ? <_CalendarEvent>[] : _eventsOn(selectedDay!);
        return Column(
          children: <Widget>[
            _viewSwitchBar(showingPdf: false),
            _MonthGrid(
              focusedMonth: focusedMonth,
              selectedDay: selectedDay,
              firstMonth: firstMonth,
              lastMonth: lastMonth,
              hasEvents: _eventsOn,
              onPage: (int delta) => setState(() {
                focusedMonth =
                    DateTime(focusedMonth.year, focusedMonth.month + delta);
              }),
              onSelect: (DateTime day) => setState(() => selectedDay = day),
            ),
            const Divider(height: 1.0),
            // Only the selected day's events scroll; the grid stays put.
            Expanded(
              child: dayEvents.isEmpty
                  ? Center(
                      child: Text(
                        context.t.scheduleNoEvents,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: dayEvents.length,
                      itemBuilder: (BuildContext context, int index) =>
                          _EventTile(
                        event: dayEvents[index],
                        onTap: () => _confirmAddToCalendar(dayEvents[index]),
                      ),
                    ),
            ),
          ],
        );
    }
  }

  Widget _viewSwitchBar({required bool showingPdf}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        if (!showingPdf)
          TextButton.icon(
            onPressed: _goToToday,
            icon: const Icon(Icons.today_rounded, size: 18.0),
            label: Text(context.t.scheduleToday),
          )
        else
          const SizedBox.shrink(),
        TextButton.icon(
          onPressed: () {
            if (showingPdf) {
              setState(() => state = _State.finish);
            } else {
              setState(() => state = _State.pdf);
              if (pdfData == null) _downloadPdf();
            }
          },
          icon: Icon(
            showingPdf ? ApIcon.dateRange : ApIcon.assignment,
            size: 18.0,
          ),
          label: Text(
            showingPdf ? context.t.scheduleViewList : context.t.scheduleViewPdf,
          ),
        ),
      ],
    );
  }

  void _goToToday() {
    final DateTime today = DateTime.now();
    setState(() {
      selectedDay = DateTime(today.year, today.month, today.day);
      focusedMonth = _clampMonth(DateTime(today.year, today.month));
    });
  }

  List<_CalendarEvent> _eventsOn(DateTime day) {
    final DateTime target = DateTime(day.year, day.month, day.day);
    return <_CalendarEvent>[
      for (final _CalendarEvent event in events)
        if (!target.isBefore(event.start) && !target.isAfter(event.end)) event,
    ];
  }

  Future<void> _getSchedules() async {
    try {
      final String raw =
          await rootBundle.loadString(FileAssets.scheduleData);
      final List<dynamic> jsonArray = jsonDecode(raw) as List<dynamic>;
      final List<_CalendarEvent> parsed = <_CalendarEvent>[
        for (final dynamic item in jsonArray)
          if (item is Map<String, dynamic> && item['start'] is String)
            _CalendarEvent.fromJson(item),
      ]..sort(
          (_CalendarEvent a, _CalendarEvent b) => a.start.compareTo(b.start),
        );
      if (!mounted) return;
      if (parsed.isEmpty) {
        setState(() => state = _State.empty);
        return;
      }
      setState(() {
        events = parsed;
        final DateTime firstStart = parsed.first.start;
        firstMonth = DateTime(firstStart.year, firstStart.month);
        DateTime maxEnd = parsed.first.end;
        for (final _CalendarEvent event in parsed) {
          if (event.end.isAfter(maxEnd)) maxEnd = event.end;
        }
        lastMonth = DateTime(maxEnd.year, maxEnd.month);
        final DateTime today = DateTime.now();
        selectedDay = _eventsOn(today).isNotEmpty
            ? DateTime(today.year, today.month, today.day)
            : parsed.first.start;
        focusedMonth =
            _clampMonth(DateTime(selectedDay!.year, selectedDay!.month));
        state = _State.finish;
      });
    } catch (_) {
      if (mounted) setState(() => state = _State.error);
    }
  }

  DateTime _clampMonth(DateTime month) {
    if (month.isBefore(firstMonth)) return firstMonth;
    if (month.isAfter(lastMonth)) return lastMonth;
    return month;
  }

  Future<void> _downloadPdf() async {
    setState(() => pdfState = PdfState.loading);
    String url = _fallbackPdfUrl;
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      try {
        final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
        await remoteConfig.fetchAndActivate();
        final String remote =
            remoteConfig.getString(Constants.schedulePdfUrl);
        if (remote.isNotEmpty) url = remote;
      } catch (_) {}
    }
    try {
      final Response<Uint8List> response = await Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 20),
        ),
      ).get<Uint8List>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      if (!mounted) return;
      setState(() {
        pdfState = PdfState.finish;
        pdfData = response.data;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => pdfState = PdfState.error);
    }
  }

  void _confirmAddToCalendar(_CalendarEvent event) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    AnalyticsUtil.instance.logEvent('add_schedule_create');
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => YesNoDialog(
        title: ap.events,
        contentWidget: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              height: 1.3,
              fontSize: 16.0,
            ),
            children: <TextSpan>[
              TextSpan(text: ap.addCalendarContent(arg1: event.title)),
            ],
          ),
        ),
        leftActionText: ap.cancel,
        rightActionText: ap.determine,
        rightActionFunction: () {
          _addToCalendar(event);
          AnalyticsUtil.instance.logEvent('add_schedule_click');
        },
      ),
    );
  }

  void _addToCalendar(_CalendarEvent event) {
    try {
      if (ApPlatformCalendarUtil.isSupported) {
        PlatformCalendarUtil.instance.addToApp(
          title: event.title,
          location: '高雄科技大學',
          startDate: event.start,
          endDate: DateTime(
            event.end.year,
            event.end.month,
            event.end.day,
            23,
            59,
            59,
          ),
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
}

class _CalendarEvent {
  const _CalendarEvent({
    required this.start,
    required this.end,
    required this.title,
    required this.category,
  });

  factory _CalendarEvent.fromJson(Map<String, dynamic> json) {
    final DateTime start = DateTime.parse(json['start'] as String);
    final String rawEnd = json['end'] as String? ?? json['start'] as String;
    final String title = (json['title'] as String? ?? '').trim();
    return _CalendarEvent(
      start: start,
      end: DateTime.parse(rawEnd),
      title: title,
      category: _categorize(title),
    );
  }

  final DateTime start;
  final DateTime end;
  final String title;
  final _Category category;

  bool get isRange => end.isAfter(start);

  static _Category _categorize(String title) {
    if (title.contains('放假') ||
        title.contains('補假') ||
        title.contains('寒假') ||
        title.contains('暑假')) {
      return _Category.holiday;
    }
    if (title.contains('考試') || title.contains('競賽')) {
      return _Category.exam;
    }
    if (title.contains('選課')) {
      return _Category.enrollment;
    }
    if (title.contains('休退學') ||
        title.contains('抵免') ||
        title.contains('畢業') ||
        title.contains('離校') ||
        title.contains('轉系') ||
        title.contains('學位') ||
        title.contains('成績')) {
      return _Category.registrar;
    }
    return _Category.general;
  }
}

Color _categoryColor(ColorScheme colorScheme, _Category category) {
  switch (category) {
    case _Category.holiday:
      return const Color(0xFF2E7D32);
    case _Category.exam:
      return const Color(0xFFC62828);
    case _Category.enrollment:
      return colorScheme.primary;
    case _Category.registrar:
      return const Color(0xFFEF6C00);
    case _Category.general:
      return colorScheme.outline;
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.focusedMonth,
    required this.selectedDay,
    required this.firstMonth,
    required this.lastMonth,
    required this.hasEvents,
    required this.onPage,
    required this.onSelect,
  });

  final DateTime focusedMonth;
  final DateTime? selectedDay;
  final DateTime firstMonth;
  final DateTime lastMonth;
  final List<_CalendarEvent> Function(DateTime day) hasEvents;
  final ValueChanged<int> onPage;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final DateTime firstOfMonth =
        DateTime(focusedMonth.year, focusedMonth.month);
    final int leadingBlanks = firstOfMonth.weekday % 7;
    final DateTime gridStart =
        firstOfMonth.subtract(Duration(days: leadingBlanks));
    // Draw only the weeks this month actually spans (4-6) so the event
    // list below gets the rows we would otherwise waste on blanks.
    final int daysInMonth =
        DateTime(focusedMonth.year, focusedMonth.month + 1, 0).day;
    final int weekCount = ((leadingBlanks + daysInMonth) / 7).ceil();
    final bool canPrev = focusedMonth.isAfter(firstMonth);
    final bool canNext = focusedMonth.isBefore(lastMonth);
    final DateTime today = DateTime.now();

    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 4.0, 12.0, 12.0),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                onPressed: canPrev ? () => onPage(-1) : null,
                icon: Icon(ApIcon.chevronLeft),
              ),
              Text(
                '${focusedMonth.year} 年 ${focusedMonth.month} 月',
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: canNext ? () => onPage(1) : null,
                icon: Icon(ApIcon.chevronRight),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              for (final String label in _weekdayLabels)
                Expanded(
                  child: Center(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 12.0,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4.0),
          for (int week = 0; week < weekCount; week++)
            _weekRow(week, gridStart, today),
        ],
      ),
    );
  }

  Widget _weekRow(int week, DateTime gridStart, DateTime today) {
    final List<Widget> cells = <Widget>[];
    for (int weekday = 0; weekday < 7; weekday++) {
      final DateTime day = gridStart.add(Duration(days: week * 7 + weekday));
      cells.add(
        Expanded(
          child: _DayCell(
            day: day,
            focusedMonth: focusedMonth,
            selectedDay: selectedDay,
            today: today,
            events: hasEvents(day),
            onSelect: onSelect,
          ),
        ),
      );
    }
    return Row(children: cells);
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.focusedMonth,
    required this.selectedDay,
    required this.today,
    required this.events,
    required this.onSelect,
  });

  final DateTime day;
  final DateTime focusedMonth;
  final DateTime? selectedDay;
  final DateTime today;
  final List<_CalendarEvent> events;
  final ValueChanged<DateTime> onSelect;

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool inMonth = day.month == focusedMonth.month;
    final bool isSelected = selectedDay != null && _sameDay(day, selectedDay!);
    final bool isToday = _sameDay(day, today);

    final List<_Category> dots = <_Category>[];
    for (final _CalendarEvent event in events) {
      if (!dots.contains(event.category)) dots.add(event.category);
    }

    Color numberColor = colorScheme.onSurface;
    if (!inMonth) {
      numberColor = colorScheme.onSurfaceVariant.withValues(alpha: 0.4);
    } else if (isSelected) {
      numberColor = colorScheme.onPrimary;
    }

    return InkWell(
      onTap: () => onSelect(DateTime(day.year, day.month, day.day)),
      borderRadius: BorderRadius.circular(8.0),
      child: SizedBox(
        height: 46.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 28.0,
              height: 28.0,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? colorScheme.primary : null,
                border: isToday && !isSelected
                    ? Border.all(color: colorScheme.primary)
                    : null,
              ),
              child: Text(
                '${day.day}',
                style: TextStyle(fontSize: 13.0, color: numberColor),
              ),
            ),
            const SizedBox(height: 2.0),
            SizedBox(
              height: 6.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  for (final _Category category in dots.take(4))
                    Container(
                      width: 5.0,
                      height: 5.0,
                      margin: const EdgeInsets.symmetric(horizontal: 1.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _categoryColor(colorScheme, category),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({required this.event, required this.onTap});

  final _CalendarEvent event;
  final VoidCallback onTap;

  String _range() {
    String fmt(DateTime d) => '${d.month}/${d.day}';
    return event.isRange ? '${fmt(event.start)} ~ ${fmt(event.end)}'
        : fmt(event.start);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color accent = _categoryColor(colorScheme, event.category);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: colorScheme.outlineVariant, width: 0.5),
          ),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                width: 4.0,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
              const SizedBox(width: 14.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      _range(),
                      style: TextStyle(
                        fontSize: 12.0,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      event.title,
                      style: TextStyle(
                        fontSize: 15.0,
                        height: 1.35,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
