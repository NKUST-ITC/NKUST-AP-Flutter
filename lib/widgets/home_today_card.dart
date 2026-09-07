import 'package:ap_common/ap_common.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/utils/academic_calendar.dart';

/// Home dashboard card combining today's classes with the academic-calendar
/// events for the current week.
///
/// Replaces ap_common's [TodayScheduleCard] so both live in one container:
/// the class list needs a login and a current semester, the calendar comes
/// from a bundled asset, and keeping them apart left the dashboard looking
/// like three unrelated blocks. Either half may be absent — with no classes
/// the card is just the calendar row, which is more useful than the "no
/// courses this semester" placeholder it replaces.
class HomeTodayCard extends StatelessWidget {
  const HomeTodayCard({
    super.key,
    required this.courseData,
    required this.weekEvents,
    required this.onCourseTap,
    required this.onCalendarTap,
  });

  final CourseData? courseData;
  final List<AcademicCalendarEvent> weekEvents;
  final VoidCallback onCourseTap;
  final VoidCallback onCalendarTap;

  static const int _maxCourseRows = 3;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final int todayWeekday = DateTime.now().weekday;
    final int tomorrowWeekday = todayWeekday == 7 ? 1 : todayWeekday + 1;

    List<_ClassSlot> slots = _slotsFor(todayWeekday);
    final bool isTomorrow = slots.isEmpty;
    if (isTomorrow) slots = _slotsFor(tomorrowWeekday);

    if (slots.isEmpty && weekEvents.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outlineVariant.withAlpha(77)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (slots.isNotEmpty) ...<Widget>[
              _classSection(context, colorScheme, slots, isTomorrow),
              if (weekEvents.isNotEmpty) ...<Widget>[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
              ],
            ],
            if (weekEvents.isNotEmpty) _calendarSection(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _classSection(
    BuildContext context,
    ColorScheme colorScheme,
    List<_ClassSlot> slots,
    bool isTomorrow,
  ) {
    final CoursePaletteTheme palette = CoursePaletteTheme.of(context);
    final int shown = slots.length.clamp(0, _maxCourseRows);
    return GestureDetector(
      onTap: onCourseTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.today_rounded, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                isTomorrow
                    ? context.ap.tomorrowScheduleTitle
                    : context.ap.todayScheduleTitle,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < shown; i++) ...<Widget>[
            _classRow(colorScheme, palette, slots[i]),
            if (i < shown - 1) const SizedBox(height: 8),
          ],
          if (slots.length > shown)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '+${slots.length - shown} ${context.ap.course}',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _classRow(
    ColorScheme colorScheme,
    CoursePaletteTheme palette,
    _ClassSlot slot,
  ) {
    final DateTime now = DateTime.now();
    final bool isPast = slot.endMinutes < now.hour * 60 + now.minute;
    return Row(
      children: <Widget>[
        SizedBox(
          width: 44,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                slot.startTime,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isPast
                      ? colorScheme.onSurfaceVariant
                      : colorScheme.onSurface,
                ),
              ),
              Text(
                slot.endTime,
                style: TextStyle(
                  fontSize: 10,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 3,
          height: 28,
          decoration: BoxDecoration(
            color: isPast
                ? colorScheme.outlineVariant
                : palette.colorAt(slot.colorIndex),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                slot.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isPast
                      ? colorScheme.onSurfaceVariant
                      : colorScheme.onSurface,
                ),
              ),
              if (slot.location.isNotEmpty)
                Text(
                  slot.location,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _calendarSection(ColorScheme colorScheme) {
    String fmt(DateTime d) => '${d.month}/${d.day}';
    return SizedBox(
      height: 32,
      child: Row(
        children: <Widget>[
          Icon(ApIcon.dateRange, size: 18, color: colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: weekEvents.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (BuildContext context, int index) {
                final AcademicCalendarEvent event = weekEvents[index];
                final String range = event.isRange
                    ? '${fmt(event.start)}–${fmt(event.end)}'
                    : fmt(event.start);
                return Center(
                  child: Material(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      onTap: onCalendarTap,
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              range,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              event.title,
                              style: TextStyle(
                                fontSize: 13,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Today's classes for [weekday], consecutive slots of the same course
  /// merged into one row.
  List<_ClassSlot> _slotsFor(int weekday) {
    final CourseData? data = courseData;
    if (data == null) return <_ClassSlot>[];

    final List<_ClassSlot> slots = <_ClassSlot>[];
    final Map<String, int> colorMap = <String, int>{};
    int colorIndex = 0;

    for (final Course course in data.courses) {
      colorMap.putIfAbsent(course.code, () => colorIndex++);
      for (final SectionTime time in course.times) {
        if (time.weekday != weekday) continue;
        if (time.index >= data.timeCodes.length) continue;
        final TimeCode code = data.timeCodes[time.index];
        slots.add(
          _ClassSlot(
            title: course.title,
            code: course.code,
            startTime: code.startTime,
            endTime: code.endTime,
            timeIndex: time.index,
            location: course.location?.toString() ?? '',
            endMinutes: _minutesOf(code.endTime),
            colorIndex: colorMap[course.code]!,
          ),
        );
      }
    }
    slots.sort(
      (_ClassSlot a, _ClassSlot b) => a.startTime.compareTo(b.startTime),
    );

    final List<_ClassSlot> merged = <_ClassSlot>[];
    for (final _ClassSlot slot in slots) {
      final bool continues = merged.isNotEmpty &&
          merged.last.code == slot.code &&
          slot.timeIndex == merged.last.timeIndex + 1;
      if (continues) {
        merged[merged.length - 1] = merged.last.extendedTo(slot);
      } else {
        merged.add(slot);
      }
    }
    return merged;
  }

  static int _minutesOf(String time) {
    final List<String> parts = time.contains(':')
        ? time.split(':')
        : <String>[time.substring(0, 2), time.substring(2)];
    return (int.tryParse(parts[0]) ?? 0) * 60 + (int.tryParse(parts[1]) ?? 0);
  }
}

class _ClassSlot {
  const _ClassSlot({
    required this.title,
    required this.code,
    required this.startTime,
    required this.endTime,
    required this.timeIndex,
    required this.location,
    required this.endMinutes,
    required this.colorIndex,
  });

  final String title;
  final String code;
  final String startTime;
  final String endTime;
  final int timeIndex;
  final String location;
  final int endMinutes;
  final int colorIndex;

  _ClassSlot extendedTo(_ClassSlot next) => _ClassSlot(
        title: title,
        code: code,
        startTime: startTime,
        endTime: next.endTime,
        timeIndex: next.timeIndex,
        location: location,
        endMinutes: next.endMinutes,
        colorIndex: colorIndex,
      );
}
