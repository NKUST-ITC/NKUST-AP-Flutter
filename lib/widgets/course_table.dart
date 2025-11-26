import 'package:ap_common/ap_common.dart';
import 'package:flutter/material.dart';

class CourseTableWidget extends StatefulWidget {
  final CourseData courseData;
  final VoidCallback? onRefresh;
  final Widget? header;

  const CourseTableWidget({
    super.key,
    required this.courseData,
    this.onRefresh,
    this.header,
  });

  @override
  State<CourseTableWidget> createState() => _CourseTableWidgetState();
}

class _CourseTableWidgetState extends State<CourseTableWidget> {
  static const List<String> _weekdays = <String>[
    '一',
    '二',
    '三',
    '四',
    '五',
    '六',
    '日',
  ];

  static const List<Color> _courseColors = <Color>[
    Color(0xFF5C6BC0), // Indigo
    Color(0xFF26A69A), // Teal
    Color(0xFFEF5350), // Red
    Color(0xFFAB47BC), // Purple
    Color(0xFF42A5F5), // Blue
    Color(0xFFFF7043), // Deep Orange
    Color(0xFF66BB6A), // Green
    Color(0xFFFFCA28), // Amber
    Color(0xFF8D6E63), // Brown
    Color(0xFF78909C), // Blue Grey
    Color(0xFFEC407A), // Pink
    Color(0xFF7E57C2), // Deep Purple
  ];

  final Map<String, Color> _courseColorMap = <String, Color>{};
  int _colorIndex = 0;

  Color _getCourseColor(String courseCode) {
    if (!_courseColorMap.containsKey(courseCode)) {
      _courseColorMap[courseCode] = _courseColors[_colorIndex % _courseColors.length];
      _colorIndex++;
    }
    return _courseColorMap[courseCode]!;
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool hasHoliday = widget.courseData.hasHoliday;
    final int weekdayCount = hasHoliday ? 7 : 5;
    final List<TimeCode> timeCodes = widget.courseData.timeCodes;

    return Column(
      children: <Widget>[
        if (widget.header != null) widget.header!,
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              widget.onRefresh?.call();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: <Widget>[
                  _buildWeekdayHeader(colorScheme, weekdayCount),
                  _buildCourseGrid(colorScheme, weekdayCount, timeCodes),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeekdayHeader(ColorScheme colorScheme, int weekdayCount) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withAlpha(77),
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withAlpha(128),
          ),
        ),
      ),
      child: Row(
        children: <Widget>[
          _buildTimeSlotHeader(colorScheme),
          for (int i = 0; i < weekdayCount; i++)
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  _weekdays[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTimeSlotHeader(ColorScheme colorScheme) {
    return Container(
      width: 48,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        '節',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildCourseGrid(
    ColorScheme colorScheme,
    int weekdayCount,
    List<TimeCode> timeCodes,
  ) {
    final int minIndex = widget.courseData.minTimeCodeIndex;
    final int maxIndex = widget.courseData.maxTimeCodeIndex;

    return Column(
      children: <Widget>[
        for (int timeIndex = minIndex; timeIndex <= maxIndex; timeIndex++)
          _buildTimeRow(
            colorScheme,
            weekdayCount,
            timeCodes,
            timeIndex,
            timeIndex == maxIndex,
          ),
      ],
    );
  }

  Widget _buildTimeRow(
    ColorScheme colorScheme,
    int weekdayCount,
    List<TimeCode> timeCodes,
    int timeIndex,
    bool isLast,
  ) {
    final TimeCode? timeCode =
        timeIndex < timeCodes.length ? timeCodes[timeIndex] : null;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: isLast
              ? BorderSide.none
              : BorderSide(
                  color: colorScheme.outlineVariant.withAlpha(77),
                  width: 0.5,
                ),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildTimeSlot(colorScheme, timeCode, timeIndex),
            for (int weekday = 1; weekday <= weekdayCount; weekday++)
              Expanded(
                child: _buildCourseCell(
                  colorScheme,
                  weekday,
                  timeIndex,
                  weekday < weekdayCount,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlot(
    ColorScheme colorScheme,
    TimeCode? timeCode,
    int timeIndex,
  ) {
    return Container(
      width: 48,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha(77),
        border: Border(
          right: BorderSide(
            color: colorScheme.outlineVariant.withAlpha(128),
          ),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            timeCode?.title ?? '${timeIndex + 1}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          if (timeCode != null) ...<Widget>[
            const SizedBox(height: 2),
            Text(
              timeCode.startTime,
              style: TextStyle(
                fontSize: 9,
                color: colorScheme.onSurfaceVariant.withAlpha(179),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCourseCell(
    ColorScheme colorScheme,
    int weekday,
    int timeIndex,
    bool showBorder,
  ) {
    final Course? course = _getCourseAt(weekday, timeIndex);

    return Container(
      constraints: const BoxConstraints(minHeight: 60),
      decoration: BoxDecoration(
        border: showBorder
            ? Border(
                right: BorderSide(
                  color: colorScheme.outlineVariant.withAlpha(51),
                  width: 0.5,
                ),
              )
            : null,
      ),
      child: course != null
          ? _buildCourseCard(colorScheme, course)
          : const SizedBox.shrink(),
    );
  }

  Course? _getCourseAt(int weekday, int timeIndex) {
    for (final Course course in widget.courseData.courses) {
      for (final SectionTime time in course.times) {
        if (time.weekday == weekday && time.index == timeIndex) {
          return course;
        }
      }
    }
    return null;
  }

  Widget _buildCourseCard(ColorScheme colorScheme, Course course) {
    final Color courseColor = _getCourseColor(course.code);

    return GestureDetector(
      onTap: () => _showCourseDetail(course, courseColor),
      child: Container(
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        decoration: BoxDecoration(
          color: courseColor.withAlpha(230),
          borderRadius: BorderRadius.circular(8),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: courseColor.withAlpha(77),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              course.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                height: 1.2,
              ),
            ),
            if (course.location != null) ...<Widget>[
              const SizedBox(height: 2),
              Text(
                course.location.toString(),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.white.withAlpha(217),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showCourseDetail(Course course, Color courseColor) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: courseColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          course.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(51),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          course.required ?? '',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    course.code,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withAlpha(204),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: <Widget>[
                  _buildDetailRow(
                    Icons.person_outline_rounded,
                    '授課教師',
                    course.getInstructors(),
                    colorScheme,
                  ),
                  _buildDetailRow(
                    Icons.location_on_outlined,
                    '上課地點',
                    course.location?.toString() ?? '-',
                    colorScheme,
                  ),
                  _buildDetailRow(
                    Icons.school_outlined,
                    '學分數',
                    '${course.units ?? "-"} 學分',
                    colorScheme,
                  ),
                  _buildDetailRow(
                    Icons.schedule_outlined,
                    '上課時間',
                    _formatCourseTimes(course),
                    colorScheme,
                  ),
                  if (course.className != null)
                    _buildDetailRow(
                      Icons.class_outlined,
                      '班級',
                      course.className!,
                      colorScheme,
                    ),
                ],
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    backgroundColor: courseColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('關閉'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withAlpha(128),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 18,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatCourseTimes(Course course) {
    final Map<int, List<int>> weekdayTimes = <int, List<int>>{};

    for (final SectionTime time in course.times) {
      weekdayTimes.putIfAbsent(time.weekday, () => <int>[]);
      weekdayTimes[time.weekday]!.add(time.index);
    }

    final List<String> result = <String>[];
    weekdayTimes.forEach((int weekday, List<int> times) {
      times.sort();
      final String dayName = '週${_weekdays[weekday - 1]}';
      final String timeStr = times.map((int i) => '第${i + 1}節').join('、');
      result.add('$dayName $timeStr');
    });

    return result.join('\n');
  }
}

class CourseListWidget extends StatelessWidget {
  final CourseData courseData;

  const CourseListWidget({
    super.key,
    required this.courseData,
  });

  static const List<Color> _courseColors = <Color>[
    Color(0xFF5C6BC0),
    Color(0xFF26A69A),
    Color(0xFFEF5350),
    Color(0xFFAB47BC),
    Color(0xFF42A5F5),
    Color(0xFFFF7043),
    Color(0xFF66BB6A),
    Color(0xFFFFCA28),
    Color(0xFF8D6E63),
    Color(0xFF78909C),
  ];

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: courseData.courses.length,
      itemBuilder: (BuildContext context, int index) {
        final Course course = courseData.courses[index];
        final Color courseColor = _courseColors[index % _courseColors.length];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outlineVariant.withAlpha(77),
            ),
          ),
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 4,
                    height: 60,
                    decoration: BoxDecoration(
                      color: courseColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          course.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${course.getInstructors()} · ${course.location ?? "-"}',
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: courseColor.withAlpha(26),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${course.units ?? "-"} 學分',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: courseColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

