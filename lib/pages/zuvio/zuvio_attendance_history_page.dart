import 'package:ap_common/ap_common.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/pages/zuvio/ui/zuvio_ui.dart';
import 'package:nkust_ap/pages/zuvio/zuvio_models.dart';
import 'package:nkust_ap/pages/zuvio/zuvio_service.dart';
import 'package:nkust_ap/utils/global.dart';

class ZuvioAttendanceHistoryPage extends StatefulWidget {
  static const String routerName = '/zuvio/attendance';

  const ZuvioAttendanceHistoryPage({super.key, required this.course});

  final ZuvioCourse course;

  @override
  ZuvioAttendanceHistoryPageState createState() =>
      ZuvioAttendanceHistoryPageState();
}

class ZuvioAttendanceHistoryPageState
    extends State<ZuvioAttendanceHistoryPage> {
  ZViewState _state = ZViewState.loading;
  List<ZuvioAttendanceRecord> _records = <ZuvioAttendanceRecord>[];

  @override
  void initState() {
    super.initState();
    AnalyticsUtil.instance.setCurrentScreen(
      'ZuvioAttendanceHistoryPage',
      'zuvio_attendance_history_page.dart',
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return ZScaffold(
      title: context.t.zuvioAttendanceRecord,
      body: RefreshIndicator(
        onRefresh: _load,
        child: ZStateView(
          state: _state,
          onRetry: _load,
          emptyIcon: Icons.event_available_outlined,
          builder: (_) => ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding:
                const EdgeInsets.fromLTRB(ZGap.m, ZGap.m, ZGap.m, ZGap.xxl),
            itemCount: _records.length,
            separatorBuilder: (_, __) => const SizedBox(height: ZGap.s),
            itemBuilder: (BuildContext context, int index) =>
                _card(_records[index]),
          ),
        ),
      ),
    );
  }

  Widget _card(ZuvioAttendanceRecord r) {
    final (String label, IconData icon, Color color) = switch (r.status) {
      ZuvioAnswerStatus.onTime => (
          context.t.zuvioAttendanceOnTime,
          Icons.check_rounded,
          context.zc.success,
        ),
      ZuvioAnswerStatus.late => (
          context.t.zuvioAttendanceLate,
          Icons.schedule_rounded,
          context.zc.warning,
        ),
      ZuvioAnswerStatus.missed => (
          context.t.zuvioAttendanceAbsent,
          Icons.close_rounded,
          context.zc.danger,
        ),
      ZuvioAnswerStatus.unknown => (
          context.t.zuvioAttendanceUnknown,
          Icons.help_outline_rounded,
          context.zc.textSecondary,
        ),
    };
    return ZCard(
      padding: const EdgeInsets.symmetric(
        horizontal: ZGap.m,
        vertical: ZGap.sm,
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: ZGap.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(zuvioDate(r.date), style: context.zt.cardTitle),
                const SizedBox(height: 2),
                Text(
                  r.checkedInAt == null
                      ? label
                      : '$label · ${zuvioTime(r.checkedInAt!)}',
                  style: context.zt.supporting.copyWith(color: color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _load() async {
    setState(() => _state = ZViewState.loading);
    try {
      final List<ZuvioAttendanceRecord> data = await ZuvioService.instance
          .getAttendanceHistory(widget.course.courseId);
      if (!mounted) return;
      setState(() {
        _records = data;
        _state = data.isEmpty ? ZViewState.empty : ZViewState.ready;
      });
    } on ZuvioException {
      if (!mounted) return;
      setState(() => _state = ZViewState.error);
    }
  }
}
