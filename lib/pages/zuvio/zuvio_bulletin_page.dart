import 'package:ap_common/ap_common.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/pages/zuvio/zuvio_models.dart';
import 'package:nkust_ap/pages/zuvio/zuvio_service.dart';
import 'package:nkust_ap/pages/zuvio/zuvio_widgets.dart';
import 'package:nkust_ap/utils/global.dart';

class ZuvioBulletinPage extends StatefulWidget {
  static const String routerName = '/zuvio/bulletin';

  const ZuvioBulletinPage({super.key, required this.course});

  final ZuvioCourse course;

  @override
  ZuvioBulletinPageState createState() => ZuvioBulletinPageState();
}

class ZuvioBulletinPageState extends State<ZuvioBulletinPage> {
  List<ZuvioBulletin>? _items;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    AnalyticsUtil.instance.setCurrentScreen(
      'ZuvioBulletinPage',
      'zuvio_bulletin_page.dart',
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.t.zuvioBulletin)),
      body: RefreshIndicator(onRefresh: _load, child: _body()),
    );
  }

  Widget _body() {
    if (_error) {
      return _hint(context.ap.somethingError);
    }
    if (_items == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_items!.isEmpty) {
      return _hint(context.t.noData);
    }
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      itemCount: _items!.length,
      itemBuilder: (BuildContext context, int index) {
        final ZuvioBulletin b = _items![index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  b.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${b.author} · ${zuvioFormatDate(b.date)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                Text(b.content, style: const TextStyle(height: 1.5)),
              ],
            ),
          ),
        );
      },
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
      _items = null;
    });
    try {
      final List<ZuvioBulletin> data =
          await ZuvioService.instance.getBulletins(widget.course.courseId);
      if (!mounted) return;
      setState(() => _items = data);
    } on ZuvioException {
      if (!mounted) return;
      setState(() => _error = true);
    }
  }
}
