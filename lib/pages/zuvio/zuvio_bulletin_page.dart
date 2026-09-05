import 'package:ap_common/ap_common.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/pages/zuvio/ui/zuvio_ui.dart';
import 'package:nkust_ap/pages/zuvio/zuvio_bulletin_detail_page.dart';
import 'package:nkust_ap/pages/zuvio/zuvio_models.dart';
import 'package:nkust_ap/pages/zuvio/zuvio_service.dart';
import 'package:nkust_ap/utils/global.dart';

class ZuvioBulletinPage extends StatefulWidget {
  static const String routerName = '/zuvio/bulletin';

  const ZuvioBulletinPage({super.key, required this.course});

  final ZuvioCourse course;

  @override
  ZuvioBulletinPageState createState() => ZuvioBulletinPageState();
}

class ZuvioBulletinPageState extends State<ZuvioBulletinPage> {
  ZViewState _state = ZViewState.loading;
  List<ZuvioBulletin> _items = <ZuvioBulletin>[];

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
    return ZScaffold(
      title: context.t.zuvioBulletin,
      body: RefreshIndicator(
        onRefresh: _load,
        child: ZStateView(
          state: _state,
          onRetry: _load,
          emptyIcon: Icons.campaign_outlined,
          builder: (_) => ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding:
                const EdgeInsets.fromLTRB(ZGap.m, ZGap.m, ZGap.m, ZGap.xxl),
            itemCount: _items.length,
            separatorBuilder: (_, __) => const SizedBox(height: ZGap.s),
            itemBuilder: (BuildContext context, int index) {
              final ZuvioBulletin b = _items[index];
              return ZCard(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => ZuvioBulletinDetailPage(summary: b),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(b.title, style: context.zt.cardTitle),
                    const SizedBox(height: ZGap.xs),
                    Text(
                      '${b.author} · ${zuvioDate(b.date)}',
                      style: context.zt.label,
                    ),
                    const SizedBox(height: ZGap.s),
                    Text(
                      b.content,
                      style: context.zt.supporting,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _load() async {
    setState(() => _state = ZViewState.loading);
    try {
      final List<ZuvioBulletin> data =
          await ZuvioService.instance.getBulletins(widget.course.courseId);
      if (!mounted) return;
      setState(() {
        _items = data;
        _state = data.isEmpty ? ZViewState.empty : ZViewState.ready;
      });
    } on ZuvioException {
      if (!mounted) return;
      setState(() => _state = ZViewState.error);
    }
  }
}
