import 'package:ap_common/ap_common.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/pages/zuvio/zuvio_course_page.dart';
import 'package:nkust_ap/pages/zuvio/zuvio_models.dart';
import 'package:nkust_ap/pages/zuvio/zuvio_service.dart';
import 'package:nkust_ap/utils/global.dart';

enum _State { loading, finish, empty, error }

class ZuvioCourseListPage extends StatefulWidget {
  static const String routerName = '/zuvio/courses';

  const ZuvioCourseListPage({super.key});

  @override
  ZuvioCourseListPageState createState() => ZuvioCourseListPageState();
}

class ZuvioCourseListPageState extends State<ZuvioCourseListPage> {
  _State _state = _State.loading;
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
    return Scaffold(
      appBar: AppBar(title: Text(context.t.zuvioCourseList)),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _body(),
      ),
    );
  }

  Widget _body() {
    switch (_state) {
      case _State.loading:
        return const Center(child: CircularProgressIndicator());
      case _State.empty:
        return _hint(context.t.zuvioNoCourses);
      case _State.error:
        return _hint(context.ap.somethingError);
      case _State.finish:
        return _groupedList();
    }
  }

  Widget _groupedList() {
    final List<String> order = <String>[];
    final Map<String, List<ZuvioCourse>> grouped =
        <String, List<ZuvioCourse>>{};
    for (final ZuvioCourse course in _courses) {
      final String key = course.semester;
      grouped.putIfAbsent(key, () {
        order.add(key);
        return <ZuvioCourse>[];
      }).add(course);
    }

    final List<Widget> children = <Widget>[];
    for (final String semester in order) {
      children.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text(
            _semesterLabel(semester),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      );
      for (final ZuvioCourse course in grouped[semester]!) {
        children.add(
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: ListTile(
              leading: const Icon(Icons.class_outlined),
              title: Text(course.name),
              subtitle: Text(course.teacherName),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => ZuvioCoursePage(course: course),
                ),
              ),
            ),
          ),
        );
      }
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 16),
      children: children,
    );
  }

  String _semesterLabel(String code) {
    final List<String> parts = code.split(RegExp('[-_]'));
    if (parts.length == 2 && int.tryParse(parts[0]) != null) {
      return context.t.zuvioSemesterFormat(year: parts[0], term: parts[1]);
    }
    return code;
  }

  Widget _hint(String text) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: <Widget>[
        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
        HintContent(icon: ApIcon.classIcon, content: text),
      ],
    );
  }

  Future<void> _load() async {
    setState(() => _state = _State.loading);
    try {
      final List<ZuvioCourse> courses =
          await ZuvioService.instance.getCourses();
      if (!mounted) return;
      setState(() {
        _courses = courses;
        _state = courses.isEmpty ? _State.empty : _State.finish;
      });
    } on ZuvioException {
      if (!mounted) return;
      setState(() => _state = _State.error);
    }
  }
}
