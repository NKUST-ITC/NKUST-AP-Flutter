import 'package:ap_common/ap_common.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/pages/zuvio/ui/zuvio_ui.dart';
import 'package:nkust_ap/pages/zuvio/zuvio_answer_history_page.dart';
import 'package:nkust_ap/pages/zuvio/zuvio_attendance_history_page.dart';
import 'package:nkust_ap/pages/zuvio/zuvio_bulletin_page.dart';
import 'package:nkust_ap/pages/zuvio/zuvio_clicker_page.dart';
import 'package:nkust_ap/pages/zuvio/zuvio_feedback_page.dart';
import 'package:nkust_ap/pages/zuvio/zuvio_models.dart';
import 'package:nkust_ap/pages/zuvio/zuvio_rollcall_page.dart';
import 'package:nkust_ap/pages/zuvio/zuvio_service.dart';
import 'package:nkust_ap/utils/global.dart';

class ZuvioCoursePage extends StatefulWidget {
  static const String routerName = '/zuvio/course';

  const ZuvioCoursePage({super.key, required this.course});

  final ZuvioCourse course;

  @override
  ZuvioCoursePageState createState() => ZuvioCoursePageState();
}

class ZuvioCoursePageState extends State<ZuvioCoursePage> {
  List<ZuvioInfoSection>? _info;

  @override
  void initState() {
    super.initState();
    AnalyticsUtil.instance.setCurrentScreen(
      'ZuvioCoursePage',
      'zuvio_course_page.dart',
    );
    _loadInfo();
  }

  @override
  Widget build(BuildContext context) {
    final ZuvioCourse course = widget.course;
    return ZScaffold(
      title: course.name,
      body: RefreshIndicator(
        onRefresh: _loadInfo,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(ZGap.m, ZGap.m, ZGap.m, ZGap.xxl),
          children: <Widget>[
            _summary(course),
            ..._stats(),
            const SizedBox(height: ZGap.xl),
            ZSectionHeader(context.t.zuvioFeatures),
            ZCard(
              padding: const EdgeInsets.symmetric(vertical: ZGap.xs),
              child: Column(children: _features(course)),
            ),
            ..._infoSections(),
          ],
        ),
      ),
    );
  }

  Widget _summary(ZuvioCourse course) {
    final ZColors zc = context.zc;
    return ZCard(
      child: Row(
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: zc.accentSoft,
              borderRadius: ZRadii.control,
            ),
            child: Icon(Icons.class_rounded, color: zc.onAccentSoft, size: 22),
          ),
          const SizedBox(width: ZGap.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  course.name,
                  style: context.zt.cardTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${course.teacherName} · ${course.semester}',
                  style: context.zt.supporting,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _stats() {
    final List<ZuvioInfoSection>? info = _info;
    if (info == null) return <Widget>[];

    String? find(String label, {bool last = false}) {
      String? value;
      for (final ZuvioInfoSection s in info) {
        for (final ZuvioInfoRow r in s.rows) {
          if (r.label == label) {
            value = r.value;
            if (!last) return value;
          }
        }
      }
      return value;
    }

    final List<(String, String)> stats = <(String, String)>[
      if (find('出席率') != null)
        (context.t.zuvioAttendanceRate, find('出席率')!),
      if (find('正確率排名') != null)
        (context.t.zuvioAccuracyRank, find('正確率排名')!),
      if (find('修課人數') != null)
        (context.t.zuvioEnrolled, find('修課人數')!),
    ];
    if (stats.isEmpty) return <Widget>[];

    return <Widget>[
      const SizedBox(height: ZGap.sm),
      Row(
        children: <Widget>[
          for (int i = 0; i < stats.length; i++) ...<Widget>[
            if (i != 0) const SizedBox(width: ZGap.s),
            Expanded(
              child: ZStatTile(value: stats[i].$2, label: stats[i].$1),
            ),
          ],
        ],
      ),
    ];
  }

  List<Widget> _features(ZuvioCourse course) {
    final List<(IconData, String, Widget)> items = <(IconData, String, Widget)>[
      (
        Icons.quiz_outlined,
        context.t.zuvioClickers,
        ZuvioClickerPage(course: course),
      ),
      (
        Icons.how_to_reg_outlined,
        context.t.zuvioRollcall,
        ZuvioRollcallPage(course: course),
      ),
      (
        Icons.event_available_outlined,
        context.t.zuvioAttendanceRecord,
        ZuvioAttendanceHistoryPage(course: course),
      ),
      (
        Icons.history_rounded,
        context.t.zuvioAnswerHistory,
        ZuvioAnswerHistoryPage(course: course),
      ),
      (
        Icons.forum_outlined,
        context.t.zuvioFeedback,
        ZuvioFeedbackPage(course: course),
      ),
      (
        Icons.campaign_outlined,
        context.t.zuvioBulletin,
        ZuvioBulletinPage(course: course),
      ),
    ];
    return <Widget>[
      for (int i = 0; i < items.length; i++) ...<Widget>[
        if (i != 0)
          Divider(
            height: 1,
            indent: ZGap.xxl + ZGap.s,
            color: context.zc.outline,
          ),
        ZListRow(
          icon: items[i].$1,
          title: items[i].$2,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(builder: (_) => items[i].$3),
          ),
        ),
      ],
    ];
  }

  List<Widget> _infoSections() {
    final List<ZuvioInfoSection>? info = _info;
    if (info == null) {
      return <Widget>[
        const SizedBox(height: ZGap.xl),
        const ZSkeleton(height: 96, radius: 16),
      ];
    }
    // Drop the basic course-info block (授課教師 / 助教 / 修課人數) — the
    // header and stat tiles already surface it.
    final Iterable<ZuvioInfoSection> sections = info.where(
      (ZuvioInfoSection s) => s.rows.every(
        (ZuvioInfoRow r) => r.label != '授課教師',
      ),
    );
    return <Widget>[
      for (final ZuvioInfoSection section in sections) ...<Widget>[
        const SizedBox(height: ZGap.xl),
        ZSectionHeader(section.title),
        ZCard(
          child: Column(
            children: <Widget>[
              for (int i = 0; i < section.rows.length; i++) ...<Widget>[
                if (i != 0) const SizedBox(height: ZGap.sm),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        section.rows[i].label,
                        style: context.zt.supporting,
                      ),
                    ),
                    const SizedBox(width: ZGap.sm),
                    Text(
                      section.rows[i].value,
                      style: context.zt.cardTitle,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    ];
  }

  Future<void> _loadInfo() async {
    try {
      final List<ZuvioInfoSection> data =
          await ZuvioService.instance.getCourseInfo(widget.course.courseId);
      if (!mounted) return;
      setState(() => _info = data);
    } on ZuvioException {
      if (!mounted) return;
      setState(() => _info = <ZuvioInfoSection>[]);
    }
  }
}
