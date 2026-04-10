import 'package:ap_common/ap_common.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/utils/date_utils.dart';

class CalendarTile extends StatelessWidget {
  final VoidCallback? onDateSelected;
  final DateTime? date;
  final String? dayOfWeek;
  final bool isDayOfWeek;
  final bool isSelected;
  final TextStyle? dayOfWeekStyles;
  final TextStyle? dateStyles;
  final Widget? child;

  const CalendarTile({
    this.onDateSelected,
    this.date,
    this.child,
    this.dateStyles,
    this.dayOfWeek,
    this.dayOfWeekStyles,
    this.isDayOfWeek = false,
    this.isSelected = false,
  });

  Widget renderDateOrDayOfWeek(BuildContext context) {
    if (isDayOfWeek) {
      return InkWell(
        child: Container(
          alignment: Alignment.center,
          child: Text(
            dayOfWeek!,
            style: dayOfWeekStyles,
          ),
        ),
      );
    } else {
      return InkWell(
        onTap: onDateSelected,
        child: Container(
          decoration: isSelected
              ? BoxDecoration(
                  shape: BoxShape.circle,
                  color: ApTheme.of(context).yellow,
                )
              : const BoxDecoration(),
          alignment: Alignment.center,
          child: Text(
            CalendarDateUtils.formatDay(date!),
            style: isSelected
                ? TextStyle(color: ApTheme.of(context).calendarTileSelect)
                : dateStyles,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (child != null) {
      return InkWell(
        onTap: onDateSelected,
        child: child,
      );
    }
    return DecoratedBox(
      decoration: const BoxDecoration(),
      child: renderDateOrDayOfWeek(context),
    );
  }
}
