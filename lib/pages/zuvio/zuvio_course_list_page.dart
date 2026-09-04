import 'package:ap_common/ap_common.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/pages/zuvio/ui/zuvio_ui.dart';
import 'package:nkust_ap/pages/zuvio/zuvio_course_page.dart';
import 'package:nkust_ap/pages/zuvio/zuvio_models.dart';
import 'package:nkust_ap/pages/zuvio/zuvio_service.dart';
import 'package:nkust_ap/utils/global.dart';

class ZuvioCourseListPage extends StatefulWidget {
  static const String routerName = '/zuvio/courses';

  const ZuvioCourseListPage({super.key});

  @override
  ZuvioCourseListPageState createState() => ZuvioCourseListPageState();
}

class ZuvioCourseListPageState extends State<ZuvioCourseListPage> {
  ZViewState _state = ZViewState.loading;
  List<ZuvioCourse> _courses = <ZuvioCourse>[];

  @override
  void initState() {
    super.initState();
    AnalyticsUtil.instance.setCurrentScreen(
      'ZuvioCourseListPage',
      'zuvio_course_list_page.dart',
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return ZScaffold(
      title: context.t.zuvioCourseList,
      actions: <Widget>[
        IconButton(
          tooltip: context.t.zuvioLogout,
          icon: const Icon(Icons.logout_rounded),
          onPressed: _logout,
        ),
      ],
      body: RefreshIndicator(
        onRefresh: _load,
        child: ZStateView(
          state: _state,
          onRetry: _load,
          emptyIcon: Icons.school_outlined,
          emptyText: context.t.zuvioNoCourses,
          loading: _loadingList(),
          builder: (_) => _list(),
        ),
      ),
    );
  }

  Widget _loadingList() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(ZGap.m, ZGap.m, ZGap.m, ZGap.m),
      children: <Widget>[
        for (int i = 0; i < 5; i++)
          const Padding(
            padding: EdgeInsets.only(bottom: ZGap.sm),
            child: ZSkeleton(height: 64, radius: 16),
          ),
      ],
    );
  }

  Widget _list() {
    final List<String> order = <String>[];
    final Map<String, List<ZuvioCourse>> grouped =
        <String, List<ZuvioCourse>>{};
    for (final ZuvioCourse c in _courses) {
      grouped.putIfAbsent(c.semester, () {
        order.add(c.semester);
        return <ZuvioCourse>[];
      }).add(c);
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(ZGap.m, ZGap.s, ZGap.m, ZGap.xxl),
      children: <Widget>[
        for (final String semester in order) ...<Widget>[
          const SizedBox(height: ZGap.m),
          ZSectionHeader(_semesterLabel(semester)),
          ZCard(
            padding: const EdgeInsets.symmetric(vertical: ZGap.xs),
            child: Column(
              children: <Widget>[
                for (int i = 0; i < grouped[semester]!.length; i++) ...<Widget>[
                  if (i != 0)
                    Divider(
                      height: 1,
                      indent: ZGap.xxl + ZGap.s,
                      color: context.zc.outline,
                    ),
                  _row(grouped[semester]![i]),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _row(ZuvioCourse course) {
    return ZListRow(
      icon: Icons.class_outlined,
      title: course.name,
      subtitle: course.teacherName,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => ZuvioCoursePage(course: course),
        ),
      ),
    );
  }

  String _semesterLabel(String code) {
    final List<String> parts = code.split(RegExp('[-_]'));
    if (parts.length == 2 && int.tryParse(parts[0]) != null) {
      return context.t.zuvioSemesterFormat(year: parts[0], term: parts[1]);
    }
    return code;
  }

  Future<void> _logout() async {
    final bool confirmed = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: Text(context.t.zuvioLogout),
            content: Text(context.t.zuvioLogoutConfirm),
            actions: <Widget>[
              TextButton(
                onPressed: () =>
                    Navigator.of(context, rootNavigator: true).pop(false),
                child: Text(context.ap.cancel),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.of(context, rootNavigator: true).pop(true),
                child: Text(context.t.zuvioLogout),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed || !mounted) return;
    await ZuvioService.instance.logout();
    await PreferenceUtil.instance
        .setBool(Constants.prefZuvioSignedOut, true);
    AnalyticsUtil.instance.logEvent('zuvio_logout');
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _load() async {
    setState(() => _state = ZViewState.loading);
    try {
      final List<ZuvioCourse> courses =
          await ZuvioService.instance.getCourses();
      if (!mounted) return;
      setState(() {
        _courses = courses;
        _state =
            courses.isEmpty ? ZViewState.empty : ZViewState.ready;
      });
    } on ZuvioException {
      if (!mounted) return;
      setState(() => _state = ZViewState.error);
    }
  }
}
