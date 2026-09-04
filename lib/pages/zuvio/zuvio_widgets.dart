import 'package:flutter/material.dart';
import 'package:nkust_ap/pages/zuvio/zuvio_models.dart';
import 'package:nkust_ap/utils/global.dart';

String zuvioFormatDate(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

String zuvioFormatDateTime(DateTime date) {
  return '${zuvioFormatDate(date)} ${date.hour.toString().padLeft(2, '0')}:'
      '${date.minute.toString().padLeft(2, '0')}';
}

extension ZuvioAnswerStatusUi on ZuvioAnswerStatus {
  String label(BuildContext context, {required bool attendance}) {
    switch (this) {
      case ZuvioAnswerStatus.onTime:
        return attendance
            ? context.t.zuvioAttendanceOnTime
            : context.t.zuvioStatusOnTime;
      case ZuvioAnswerStatus.late:
        return attendance
            ? context.t.zuvioAttendanceLate
            : context.t.zuvioStatusLate;
      case ZuvioAnswerStatus.missed:
        return attendance
            ? context.t.zuvioAttendanceAbsent
            : context.t.zuvioStatusMissed;
    }
  }

  Color color(BuildContext context) {
    switch (this) {
      case ZuvioAnswerStatus.onTime:
        return Colors.green;
      case ZuvioAnswerStatus.late:
        return Colors.orange;
      case ZuvioAnswerStatus.missed:
        return Theme.of(context).colorScheme.error;
    }
  }
}

class ZuvioStatusChip extends StatelessWidget {
  const ZuvioStatusChip({
    super.key,
    required this.status,
    this.attendance = false,
  });

  final ZuvioAnswerStatus status;
  final bool attendance;

  @override
  Widget build(BuildContext context) {
    final Color color = status.color(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.label(context, attendance: attendance),
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
