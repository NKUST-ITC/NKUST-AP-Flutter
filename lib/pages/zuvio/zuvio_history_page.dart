import 'package:ap_common/ap_common.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/pages/zuvio/zuvio_models.dart';
import 'package:nkust_ap/pages/zuvio/zuvio_service.dart';
import 'package:nkust_ap/pages/zuvio/zuvio_widgets.dart';
import 'package:nkust_ap/utils/global.dart';

class ZuvioHistoryPage extends StatefulWidget {
  static const String routerName = '/zuvio/history';

  const ZuvioHistoryPage({super.key, required this.course});

  final ZuvioCourse course;

  @override
  ZuvioHistoryPageState createState() => ZuvioHistoryPageState();
}

class ZuvioHistoryPageState extends State<ZuvioHistoryPage> {
  @override
  void initState() {
    super.initState();
    AnalyticsUtil.instance.setCurrentScreen(
      'ZuvioHistoryPage',
      'zuvio_history_page.dart',
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.t.zuvioAnswerHistory),
          bottom: TabBar(
            tabs: <Widget>[
              Tab(text: context.t.zuvioHistoryAnswers),
              Tab(text: context.t.zuvioHistoryAttendance),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            _AnswerHistoryTab(courseId: widget.course.courseId),
            _AttendanceHistoryTab(courseId: widget.course.courseId),
          ],
        ),
      ),
    );
  }
}

class _AnswerHistoryTab extends StatefulWidget {
  const _AnswerHistoryTab({required this.courseId});

  final String courseId;

  @override
  State<_AnswerHistoryTab> createState() => _AnswerHistoryTabState();
}

class _AnswerHistoryTabState extends State<_AnswerHistoryTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<ZuvioHistoryEntry>? _entries;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_error) {
      return HintContent(
        icon: ApIcon.assignment,
        content: context.ap.somethingError,
      );
    }
    if (_entries == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_entries!.isEmpty) {
      return HintContent(
        icon: ApIcon.assignment,
        content: context.t.noData,
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _entries!.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (BuildContext context, int index) {
          final ZuvioHistoryEntry e = _entries![index];
          return ListTile(
            leading: const Icon(Icons.folder_outlined),
            title: Text(e.title),
          );
        },
      ),
    );
  }

  Future<void> _load() async {
    setState(() {
      _error = false;
      _entries = null;
    });
    try {
      final List<ZuvioHistoryEntry> data =
          await ZuvioService.instance.getAnswerHistory(widget.courseId);
      if (!mounted) return;
      setState(() => _entries = data);
    } on ZuvioException {
      if (!mounted) return;
      setState(() => _error = true);
    }
  }
}

class _AttendanceHistoryTab extends StatefulWidget {
  const _AttendanceHistoryTab({required this.courseId});

  final String courseId;

  @override
  State<_AttendanceHistoryTab> createState() => _AttendanceHistoryTabState();
}

class _AttendanceHistoryTabState extends State<_AttendanceHistoryTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<ZuvioAttendanceRecord>? _records;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_error) {
      return HintContent(
        icon: ApIcon.assignment,
        content: context.ap.somethingError,
      );
    }
    if (_records == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_records!.isEmpty) {
      return HintContent(
        icon: ApIcon.assignment,
        content: context.t.noData,
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _records!.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (BuildContext context, int index) {
          final ZuvioAttendanceRecord r = _records![index];
          return ListTile(
            leading: const Icon(Icons.how_to_reg_outlined),
            title: Text(zuvioFormatDate(r.date)),
            subtitle: r.checkedInAt == null
                ? null
                : Text(zuvioFormatDateTime(r.checkedInAt!)),
            trailing: ZuvioStatusChip(status: r.status, attendance: true),
          );
        },
      ),
    );
  }

  Future<void> _load() async {
    setState(() {
      _error = false;
      _records = null;
    });
    try {
      final List<ZuvioAttendanceRecord> data =
          await ZuvioService.instance.getAttendanceHistory(widget.courseId);
      if (!mounted) return;
      setState(() => _records = data);
    } on ZuvioException {
      if (!mounted) return;
      setState(() => _error = true);
    }
  }
}
