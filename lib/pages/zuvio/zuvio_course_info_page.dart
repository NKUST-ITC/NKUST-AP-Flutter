import 'package:ap_common/ap_common.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/pages/zuvio/zuvio_models.dart';
import 'package:nkust_ap/pages/zuvio/zuvio_service.dart';
import 'package:nkust_ap/utils/global.dart';

class ZuvioCourseInfoPage extends StatefulWidget {
  static const String routerName = '/zuvio/courseInfo';

  const ZuvioCourseInfoPage({super.key, required this.course});

  final ZuvioCourse course;

  @override
  ZuvioCourseInfoPageState createState() => ZuvioCourseInfoPageState();
}

class ZuvioCourseInfoPageState extends State<ZuvioCourseInfoPage> {
  List<ZuvioInfoSection>? _sections;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    AnalyticsUtil.instance.setCurrentScreen(
      'ZuvioCourseInfoPage',
      'zuvio_course_info_page.dart',
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.t.zuvioCourseInfo)),
      body: RefreshIndicator(onRefresh: _load, child: _body()),
    );
  }

  Widget _body() {
    if (_error) {
      return _hint(context.ap.somethingError);
    }
    if (_sections == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_sections!.isEmpty) {
      return _hint(context.t.noData);
    }
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        for (final ZuvioInfoSection section in _sections!) _card(section),
      ],
    );
  }

  Widget _card(ZuvioInfoSection section) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            section.title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          for (final ZuvioInfoRow row in section.rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      row.label,
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    row.value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _hint(String text) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: <Widget>[
        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
        HintContent(icon: ApIcon.info, content: text),
      ],
    );
  }

  Future<void> _load() async {
    setState(() {
      _error = false;
      _sections = null;
    });
    try {
      final List<ZuvioInfoSection> data =
          await ZuvioService.instance.getCourseInfo(widget.course.courseId);
      if (!mounted) return;
      setState(() => _sections = data);
    } on ZuvioException {
      if (!mounted) return;
      setState(() => _error = true);
    }
  }
}
