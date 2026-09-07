import 'dart:async';
import 'dart:io';

import 'package:ap_common/ap_common.dart';
import 'package:ap_common_firebase/ap_common_firebase.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nkust_ap/utils/academic_calendar.dart';
import 'package:nkust_ap/utils/global.dart';

enum _State { loading, finish, error, empty, pdf }

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

  List<AcademicCalendarEvent> events = <AcademicCalendarEvent>[];
  DateTime firstMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime lastMonth = DateTime(DateTime.now().year, DateTime.now().month);
  late DateTime focusedMonth = firstMonth;
  DateTime? selectedDay;

  AcademicCalendarEvent? nextExam;

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
        final List<AcademicCalendarEvent> dayEvents = selectedDay == null
            ? <AcademicCalendarEvent>[]
            : _eventsOn(selectedDay!);
        return Column(
          children: <Widget>[
            _viewSwitchBar(showingPdf: false),
            if (nextExam != null) _examBanner(nextExam!),
            _MonthGrid(
              focusedMonth: focusedMonth,
              selectedDay: selectedDay,
              firstMonth: firstMonth,
              lastMonth: lastMonth,
              hasEvents: _eventsOn,
              isExamWeek: _isExamWeek,
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

  /// Pinned above the grid so the answer is there without paging months.
  Widget _examBanner(AcademicCalendarEvent exam) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final DateTime today = DateTime.now();
    final bool started = exam.covers(today);
    final int days = exam.daysUntil(today);
    String fmt(DateTime d) => '${d.month}/${d.day}';
    return InkWell(
      onTap: () => setState(() {
        selectedDay = DateTime(
          exam.start.year,
          exam.start.month,
          exam.start.day,
        );
        focusedMonth =
            _clampMonth(DateTime(exam.start.year, exam.start.month));
      }),
      child: Container(
        margin: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 4.0),
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: examAccent.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 8.0,
              height: 8.0,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: examAccent,
              ),
            ),
            const SizedBox(width: 10.0),
            Text(
              exam.shortTitle,
              style: const TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
                color: examAccent,
              ),
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: Text(
                '${fmt(exam.start)} – ${fmt(exam.end)}',
                style: TextStyle(
                  fontSize: 13.0,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Text(
              started
                  ? context.t.scheduleExamToday
                  : context.t.scheduleExamCountdown(days: days),
              style: const TextStyle(
                fontSize: 13.0,
                fontWeight: FontWeight.bold,
                color: examAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isExamWeek(DateTime day) {
    for (final AcademicCalendarEvent event in events) {
      if (event.isMajorExam && event.covers(day)) return true;
    }
    return false;
  }

  void _goToToday() {
    final DateTime today = DateTime.now();
    setState(() {
      selectedDay = DateTime(today.year, today.month, today.day);
      focusedMonth = _clampMonth(DateTime(today.year, today.month));
    });
  }

  List<AcademicCalendarEvent> _eventsOn(DateTime day) {
    final DateTime target = DateTime(day.year, day.month, day.day);
    return <AcademicCalendarEvent>[
      for (final AcademicCalendarEvent event in events)
        if (!target.isBefore(event.start) && !target.isAfter(event.end)) event,
    ];
  }

  Future<void> _getSchedules() async {
    try {
      final List<AcademicCalendarEvent> parsed = await loadAcademicCalendar();
      if (!mounted) return;
      unawaited(_refreshSchedules());
      if (parsed.isEmpty) {
        setState(() => state = _State.empty);
        return;
      }
      setState(() {
        events = parsed;
        nextExam = nextMajorExam(parsed, DateTime.now());
        final DateTime firstStart = parsed.first.start;
        firstMonth = DateTime(firstStart.year, firstStart.month);
        DateTime maxEnd = parsed.first.end;
        for (final AcademicCalendarEvent event in parsed) {
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

  /// Picks up a calendar published since this build, without making the
  /// page wait on the network to draw the one it already has.
  Future<void> _refreshSchedules() async {
    final List<AcademicCalendarEvent>? fresh = await refreshAcademicCalendar();
    if (fresh == null || !mounted) return;
    setState(() {
      events = fresh;
      nextExam = nextMajorExam(fresh, DateTime.now());
      DateTime maxEnd = fresh.first.end;
      for (final AcademicCalendarEvent event in fresh) {
        if (event.end.isAfter(maxEnd)) maxEnd = event.end;
      }
      firstMonth = DateTime(fresh.first.start.year, fresh.first.start.month);
      lastMonth = DateTime(maxEnd.year, maxEnd.month);
      focusedMonth = _clampMonth(focusedMonth);
    });
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

  void _confirmAddToCalendar(AcademicCalendarEvent event) {
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

  void _addToCalendar(AcademicCalendarEvent event) {
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

Color _categoryColor(ColorScheme colorScheme, AcademicCategory category) {
  switch (category) {
    case AcademicCategory.holiday:
      return holidayAccent;
    case AcademicCategory.exam:
      return examAccent;
    case AcademicCategory.enrollment:
      return colorScheme.primary;
    case AcademicCategory.registrar:
      return const Color(0xFFEF6C00);
    case AcademicCategory.general:
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
    required this.isExamWeek,
    required this.onPage,
    required this.onSelect,
  });

  final DateTime focusedMonth;
  final DateTime? selectedDay;
  final DateTime firstMonth;
  final DateTime lastMonth;
  final List<AcademicCalendarEvent> Function(DateTime day) hasEvents;
  final bool Function(DateTime day) isExamWeek;
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
            isExamWeek: isExamWeek(day),
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
    required this.isExamWeek,
    required this.onSelect,
  });

  final DateTime day;
  final DateTime focusedMonth;
  final DateTime? selectedDay;
  final DateTime today;
  final List<AcademicCalendarEvent> events;
  final bool isExamWeek;
  final ValueChanged<DateTime> onSelect;

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool inMonth = day.month == focusedMonth.month;
    final bool isSelected = selectedDay != null && _sameDay(day, selectedDay!);
    final bool isToday = _sameDay(day, today);

    final List<AcademicCategory> dots = <AcademicCategory>[];
    bool isHoliday = false;
    for (final AcademicCalendarEvent event in events) {
      if (!dots.contains(event.category)) dots.add(event.category);
      if (event.category == AcademicCategory.holiday) isHoliday = true;
    }
    final bool isWeekend = day.weekday == DateTime.saturday ||
        day.weekday == DateTime.sunday;
    final bool isDayOff = isWeekend || isHoliday;

    Color numberColor = isDayOff ? holidayAccent : colorScheme.onSurface;
    if (!inMonth) {
      numberColor = numberColor.withValues(alpha: 0.4);
    } else if (isSelected) {
      numberColor = colorScheme.onPrimary;
    }

    // Red says "no class" the way a wall calendar does, so a declared
    // holiday gets more of it than a plain weekend. The exam band wins the
    // background where they overlap — it has to stay unbroken across the
    // week to read as one block — and the red day number carries the rest.
    Color? cellTint;
    if (inMonth) {
      if (isExamWeek) {
        cellTint = examAccent.withValues(alpha: 0.12);
      } else if (isHoliday) {
        cellTint = holidayAccent.withValues(alpha: 0.13);
      } else if (isWeekend) {
        cellTint = holidayAccent.withValues(alpha: 0.05);
      }
    }

    return InkWell(
      onTap: () => onSelect(DateTime(day.year, day.month, day.day)),
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        height: 46.0,
        // Adjacent cells share a tint, so a run of days reads as one band
        // across the row rather than as separate marks.
        color: cellTint,
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
                  for (final AcademicCategory category in dots.take(4))
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

  final AcademicCalendarEvent event;
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
