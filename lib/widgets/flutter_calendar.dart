import 'dart:async';

import 'package:ap_common/resources/ap_icon.dart';
import 'package:ap_common/resources/ap_theme.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/utils/date_utils.dart';
import 'package:nkust_ap/widgets/calendar_tile.dart';
import 'package:tuple/tuple.dart';

typedef DayBuilder = Widget Function(BuildContext context, DateTime day);

class Calendar extends StatefulWidget {
  final ValueChanged<DateTime?>? onDateSelected;
  final ValueChanged<Tuple2<DateTime, DateTime>>? onSelectedRangeChange;
  final bool isExpandable;
  final DayBuilder? dayBuilder;
  final bool showChevronsToChangeRange;
  final bool showTodayAction;
  final bool showCalendarPickerIcon;
  final DateTime? initialCalendarDateOverride;
  final List<String> weekdays;
  final double dayChildAspectRatio;

  const Calendar({
    this.onDateSelected,
    this.onSelectedRangeChange,
    this.isExpandable = false,
    this.dayBuilder,
    this.showTodayAction = true,
    this.showChevronsToChangeRange = true,
    this.showCalendarPickerIcon = true,
    this.initialCalendarDateOverride,
    this.dayChildAspectRatio = 1.5,
    this.weekdays = CalendarDateUtils.weekdays,
  });

  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  late List<DateTime> selectedMonthsDays;
  late Iterable<DateTime> selectedWeeksDays;
  DateTime? _selectedDate = DateTime.now();
  String? currentMonth;
  bool isExpanded = false;
  late String displayMonth;

  DateTime? get selectedDate => _selectedDate;

  @override
  void initState() {
    super.initState();
    if (widget.initialCalendarDateOverride != null) {
      _selectedDate = widget.initialCalendarDateOverride;
    }
    selectedMonthsDays = CalendarDateUtils.daysInMonth(_selectedDate!);
    final DateTime firstDayOfCurrentWeek =
        CalendarDateUtils.firstDayOfWeek(_selectedDate!);
    final DateTime lastDayOfCurrentWeek =
        CalendarDateUtils.lastDayOfWeek(_selectedDate!);
    selectedWeeksDays = CalendarDateUtils.daysInRange(
      firstDayOfCurrentWeek,
      lastDayOfCurrentWeek,
    ).toList().sublist(0, 7);
    displayMonth = CalendarDateUtils.formatMonth(_selectedDate!);
  }

  Widget get nameAndIconRow {
    Widget leftInnerIcon;
    Widget rightInnerIcon;
    Widget leftOuterIcon;
    Widget rightOuterIcon;

    if (widget.showCalendarPickerIcon) {
      rightInnerIcon = IconButton(
        onPressed: () => selectDateFromPicker(),
        icon: Icon(
          ApIcon.calendarToday,
          color: ApTheme.of(context).grey,
        ),
      );
    } else {
      rightInnerIcon = Container();
    }

    if (widget.showChevronsToChangeRange) {
      leftOuterIcon = IconButton(
        onPressed: isExpanded ? previousMonth : previousWeek,
        icon: Icon(
          ApIcon.chevronLeft,
          color: ApTheme.of(context).grey,
        ),
      );
      rightOuterIcon = IconButton(
        onPressed: isExpanded ? nextMonth : nextWeek,
        icon: Icon(
          ApIcon.chevronRight,
          color: ApTheme.of(context).grey,
        ),
      );
    } else {
      leftOuterIcon = Container();
      rightOuterIcon = Container();
    }

    if (widget.showTodayAction) {
      leftInnerIcon = InkWell(
        onTap: resetToToday,
        child: const Text('Today'),
      );
    } else {
      leftInnerIcon = Container();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        leftOuterIcon,
        leftInnerIcon,
        Text(
          displayMonth,
          style: TextStyle(fontSize: 20.0, color: ApTheme.of(context).grey),
        ),
        rightInnerIcon,
        rightOuterIcon,
      ],
    );
  }

  Widget get calendarGridView {
    return GestureDetector(
      onHorizontalDragStart: (DragStartDetails gestureDetails) =>
          beginSwipe(gestureDetails),
      onHorizontalDragUpdate: (DragUpdateDetails gestureDetails) =>
          getDirection(gestureDetails),
      onHorizontalDragEnd: (DragEndDetails gestureDetails) =>
          endSwipe(gestureDetails),
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 7,
        childAspectRatio: widget.dayChildAspectRatio,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        children: calendarBuilder(),
      ),
    );
  }

  List<Widget> calendarBuilder() {
    final List<Widget> dayWidgets = <Widget>[];
    final List<DateTime> calendarDays =
        isExpanded ? selectedMonthsDays : selectedWeeksDays as List<DateTime>;

    for (final String day in widget.weekdays) {
      dayWidgets.add(
        CalendarTile(
          isDayOfWeek: true,
          dayOfWeek: day,
        ),
      );
    }

    bool monthStarted = false;
    bool monthEnded = false;

    for (final DateTime day in calendarDays) {
      if (monthStarted && day.day == 01) {
        monthEnded = true;
      }

      if (CalendarDateUtils.isFirstDayOfMonth(day)) {
        monthStarted = true;
      }

      if (widget.dayBuilder != null) {
        dayWidgets.add(
          CalendarTile(
            date: day,
            onDateSelected: () => handleSelectedDateAndUserCallback(day),
            child: widget.dayBuilder!(context, day),
          ),
        );
      } else {
        dayWidgets.add(
          CalendarTile(
            onDateSelected: () => handleSelectedDateAndUserCallback(day),
            date: day,
            dateStyles: configureDateStyle(
              monthStarted: monthStarted,
              monthEnded: monthEnded,
            ),
            isSelected: CalendarDateUtils.isSameDay(selectedDate!, day),
          ),
        );
      }
    }
    return dayWidgets;
  }

  TextStyle configureDateStyle({
    required bool monthStarted,
    required bool monthEnded,
  }) {
    TextStyle dateStyles;
    if (isExpanded) {
      dateStyles = monthStarted && !monthEnded
          ? const TextStyle(color: Colors.black)
          : const TextStyle(color: Colors.black38);
    } else {
      dateStyles = TextStyle(color: ApTheme.of(context).grey);
    }
    return dateStyles;
  }

  Widget get expansionButtonRow {
    if (widget.isExpandable) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(CalendarDateUtils.fullDayFormat(selectedDate!)),
          IconButton(
            iconSize: 20.0,
            padding: EdgeInsets.zero,
            onPressed: toggleExpanded,
            icon: isExpanded
                ? Icon(ApIcon.arrowDropUp)
                : Icon(ApIcon.arrowDropDown),
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        nameAndIconRow,
        ExpansionCrossFade(
          collapsed: calendarGridView,
          expanded: calendarGridView,
          isExpanded: isExpanded,
        ),
        expansionButtonRow
      ],
    );
  }

  void resetToToday() {
    _selectedDate = DateTime.now();
    final DateTime firstDayOfCurrentWeek =
        CalendarDateUtils.firstDayOfWeek(_selectedDate!);
    final DateTime lastDayOfCurrentWeek =
        CalendarDateUtils.lastDayOfWeek(_selectedDate!);

    setState(() {
      selectedWeeksDays = CalendarDateUtils.daysInRange(
        firstDayOfCurrentWeek,
        lastDayOfCurrentWeek,
      ).toList();
      displayMonth = CalendarDateUtils.formatMonth(_selectedDate!);
    });

    _launchDateSelectionCallback(_selectedDate);
  }

  void nextMonth() {
    setState(() {
      _selectedDate = CalendarDateUtils.nextMonth(_selectedDate!);
      final DateTime firstDateOfNewMonth =
          CalendarDateUtils.firstDayOfMonth(_selectedDate!);
      final DateTime lastDateOfNewMonth =
          CalendarDateUtils.lastDayOfMonth(_selectedDate!);
      updateSelectedRange(firstDateOfNewMonth, lastDateOfNewMonth);
      selectedMonthsDays = CalendarDateUtils.daysInMonth(_selectedDate!);
      displayMonth = CalendarDateUtils.formatMonth(_selectedDate!);
    });
  }

  void previousMonth() {
    setState(() {
      _selectedDate = CalendarDateUtils.previousMonth(_selectedDate!);
      final DateTime firstDateOfNewMonth =
          CalendarDateUtils.firstDayOfMonth(_selectedDate!);
      final DateTime lastDateOfNewMonth =
          CalendarDateUtils.lastDayOfMonth(_selectedDate!);
      updateSelectedRange(firstDateOfNewMonth, lastDateOfNewMonth);
      selectedMonthsDays = CalendarDateUtils.daysInMonth(_selectedDate!);
      displayMonth = CalendarDateUtils.formatMonth(_selectedDate!);
    });
  }

  void nextWeek() {
    setState(() {
      _selectedDate = CalendarDateUtils.nextWeek(_selectedDate!);
      final DateTime firstDayOfCurrentWeek =
          CalendarDateUtils.firstDayOfWeek(_selectedDate!);
      final DateTime lastDayOfCurrentWeek =
          CalendarDateUtils.lastDayOfWeek(_selectedDate!);
      updateSelectedRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek);
      selectedWeeksDays = CalendarDateUtils.daysInRange(
        firstDayOfCurrentWeek,
        lastDayOfCurrentWeek,
      ).toList().sublist(0, 7);
      displayMonth = CalendarDateUtils.formatMonth(_selectedDate!);
    });
    _launchDateSelectionCallback(_selectedDate);
  }

  void previousWeek() {
    setState(() {
      _selectedDate = CalendarDateUtils.previousWeek(_selectedDate!);
      final DateTime firstDayOfCurrentWeek =
          CalendarDateUtils.firstDayOfWeek(_selectedDate!);
      final DateTime lastDayOfCurrentWeek =
          CalendarDateUtils.lastDayOfWeek(_selectedDate!);
      updateSelectedRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek);
      selectedWeeksDays = CalendarDateUtils.daysInRange(
        firstDayOfCurrentWeek,
        lastDayOfCurrentWeek,
      ).toList().sublist(0, 7);
      displayMonth = CalendarDateUtils.formatMonth(_selectedDate!);
    });
    _launchDateSelectionCallback(_selectedDate);
  }

  void updateSelectedRange(DateTime start, DateTime end) {
    final Tuple2<DateTime, DateTime> selectedRange =
        Tuple2<DateTime, DateTime>(start, end);
    if (widget.onSelectedRangeChange != null) {
      widget.onSelectedRangeChange!.call(selectedRange);
    }
  }

  Future<void> selectDateFromPicker() async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1960),
      lastDate: DateTime(2050),
    );

    if (selected != null) {
      final DateTime firstDayOfCurrentWeek =
          CalendarDateUtils.firstDayOfWeek(selected);
      final DateTime lastDayOfCurrentWeek =
          CalendarDateUtils.lastDayOfWeek(selected);

      setState(() {
        _selectedDate = selected;
        selectedWeeksDays = CalendarDateUtils.daysInRange(
          firstDayOfCurrentWeek,
          lastDayOfCurrentWeek,
        ).toList();
        selectedMonthsDays = CalendarDateUtils.daysInMonth(selected);
        displayMonth = CalendarDateUtils.formatMonth(selected);
      });
      // updating selected date range based on selected week
      updateSelectedRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek);
      _launchDateSelectionCallback(selected);
    }
  }

  late double gestureStart;
  String gestureDirection = 'rightToLeft';

  void beginSwipe(DragStartDetails gestureDetails) {
    gestureStart = gestureDetails.globalPosition.dx;
  }

  void getDirection(DragUpdateDetails gestureDetails) {
    if (gestureDetails.globalPosition.dx < gestureStart) {
      gestureDirection = 'rightToLeft';
    } else {
      gestureDirection = 'leftToRight';
    }
  }

  void endSwipe(DragEndDetails gestureDetails) {
    if (gestureDirection == 'rightToLeft') {
      if (isExpanded) {
        nextMonth();
      } else {
        nextWeek();
      }
    } else {
      if (isExpanded) {
        previousMonth();
      } else {
        previousWeek();
      }
    }
  }

  void toggleExpanded() {
    if (widget.isExpandable) {
      setState(() => isExpanded = !isExpanded);
    }
  }

  void handleSelectedDateAndUserCallback(DateTime day) {
    final DateTime firstDayOfCurrentWeek =
        CalendarDateUtils.firstDayOfWeek(day);
    final DateTime lastDayOfCurrentWeek = CalendarDateUtils.lastDayOfWeek(day);
    setState(() {
      _selectedDate = day;
      selectedWeeksDays = CalendarDateUtils.daysInRange(
        firstDayOfCurrentWeek,
        lastDayOfCurrentWeek,
      ).toList();
      selectedMonthsDays = CalendarDateUtils.daysInMonth(day);
    });
    _launchDateSelectionCallback(day);
  }

  void _launchDateSelectionCallback(DateTime? day) {
    if (widget.onDateSelected != null) {
      widget.onDateSelected!.call(day);
    }
  }
}

class ExpansionCrossFade extends StatelessWidget {
  final Widget? collapsed;
  final Widget? expanded;
  final bool? isExpanded;

  const ExpansionCrossFade({this.collapsed, this.expanded, this.isExpanded});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: AnimatedCrossFade(
        firstChild: collapsed!,
        secondChild: expanded!,
        firstCurve: const Interval(0.0, 1.0, curve: Curves.fastOutSlowIn),
        secondCurve: const Interval(0.0, 1.0, curve: Curves.fastOutSlowIn),
        sizeCurve: Curves.decelerate,
        crossFadeState:
            isExpanded! ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        duration: const Duration(milliseconds: 300),
      ),
    );
  }
}
