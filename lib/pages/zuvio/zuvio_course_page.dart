import 'package:ap_common/ap_common.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/pages/zuvio/zuvio_bulletin_page.dart';
import 'package:nkust_ap/pages/zuvio/zuvio_clicker_page.dart';
import 'package:nkust_ap/pages/zuvio/zuvio_course_info_page.dart';
import 'package:nkust_ap/pages/zuvio/zuvio_feedback_page.dart';
import 'package:nkust_ap/pages/zuvio/zuvio_history_page.dart';
import 'package:nkust_ap/pages/zuvio/zuvio_models.dart';
import 'package:nkust_ap/pages/zuvio/zuvio_rollcall_page.dart';
import 'package:nkust_ap/utils/global.dart';

class ZuvioCoursePage extends StatefulWidget {
  static const String routerName = '/zuvio/course';

  const ZuvioCoursePage({super.key, required this.course});

  final ZuvioCourse course;

  @override
  ZuvioCoursePageState createState() => ZuvioCoursePageState();
}

class ZuvioCoursePageState extends State<ZuvioCoursePage> {
  @override
  void initState() {
    super.initState();
    AnalyticsUtil.instance.setCurrentScreen(
      'ZuvioCoursePage',
      'zuvio_course_page.dart',
    );
  }

  @override
  Widget build(BuildContext context) {
    final ZuvioCourse course = widget.course;
    return Scaffold(
      appBar: AppBar(title: Text(course.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          _header(course),
          const SizedBox(height: 24),
          _featureTile(
            icon: Icons.quiz_outlined,
            title: context.t.zuvioClickers,
            page: ZuvioClickerPage(course: course),
          ),
          _featureTile(
            icon: Icons.how_to_reg_outlined,
            title: context.t.zuvioRollcall,
            subtitle: context.t.zuvioRollcallEntryHint,
            page: ZuvioRollcallPage(course: course),
          ),
          _featureTile(
            icon: Icons.history_rounded,
            title: context.t.zuvioAnswerHistory,
            page: ZuvioHistoryPage(course: course),
          ),
          _featureTile(
            icon: Icons.forum_outlined,
            title: context.t.zuvioFeedback,
            page: ZuvioFeedbackPage(course: course),
          ),
          _featureTile(
            icon: Icons.campaign_outlined,
            title: context.t.zuvioBulletin,
            page: ZuvioBulletinPage(course: course),
          ),
          _featureTile(
            icon: Icons.info_outline_rounded,
            title: context.t.zuvioCourseInfo,
            page: ZuvioCourseInfoPage(course: course),
          ),
        ],
      ),
    );
  }

  Widget _header(ZuvioCourse course) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            course.name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _infoRow(context.t.zuvioTeacher, course.teacherName),
          _infoRow(context.t.zuvioSemester, course.semester),
          _infoRow(context.t.zuvioCourseId, course.courseId),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _featureTile({
    required IconData icon,
    required String title,
    required Widget page,
    String? subtitle,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: subtitle == null ? null : Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute<void>(builder: (_) => page),
        ),
      ),
    );
  }
}
