import 'package:ap_common/ap_common.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/pages/zuvio/zuvio_models.dart';
import 'package:nkust_ap/pages/zuvio/zuvio_service.dart';
import 'package:nkust_ap/utils/global.dart';

enum _State { loading, live, idle, error }

class ZuvioClickerPage extends StatefulWidget {
  static const String routerName = '/zuvio/clicker';

  const ZuvioClickerPage({super.key, required this.course});

  final ZuvioCourse course;

  @override
  ZuvioClickerPageState createState() => ZuvioClickerPageState();
}

class ZuvioClickerPageState extends State<ZuvioClickerPage> {
  _State _state = _State.loading;
  ZuvioClickerQuestion? _question;

  @override
  void initState() {
    super.initState();
    AnalyticsUtil.instance.setCurrentScreen(
      'ZuvioClickerPage',
      'zuvio_clicker_page.dart',
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.t.zuvioClickers)),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: <Widget>[
            const SizedBox(height: 24),
            _body(),
          ],
        ),
      ),
    );
  }

  Widget _body() {
    switch (_state) {
      case _State.loading:
        return const Center(child: CircularProgressIndicator());
      case _State.error:
        return HintContent(
          icon: ApIcon.assignment,
          content: context.ap.somethingError,
        );
      case _State.idle:
        return Column(
          children: <Widget>[
            Icon(
              Icons.pause_circle_outline_rounded,
              size: 88,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 24),
            Text(
              context.t.zuvioNoLiveClicker,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              context.t.zuvioNoLiveClickerHint,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        );
      case _State.live:
        final ZuvioClickerQuestion q = _question!;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const Icon(Icons.podcasts_rounded,
                        size: 18, color: Colors.redAccent),
                    const SizedBox(width: 6),
                    Text(
                      context.t.zuvioClickerLive,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(q.name, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 20),
                ApButton(
                  text: q.answered
                      ? context.t.zuvioClickerAnswered
                      : context.t.zuvioClickerAnswer,
                  onPressed: q.answered ? null : _answer,
                ),
              ],
            ),
          ),
        );
    }
  }

  Future<void> _load() async {
    setState(() => _state = _State.loading);
    try {
      final ZuvioClickerQuestion? q =
          await ZuvioService.instance.getLiveClicker(widget.course.courseId);
      if (!mounted) return;
      setState(() {
        _question = q;
        _state = q == null ? _State.idle : _State.live;
      });
    } on ZuvioException {
      if (!mounted) return;
      setState(() => _state = _State.error);
    }
  }

  void _answer() {
    AnalyticsUtil.instance.logEvent('zuvio_clicker_answer');
    UiUtil.instance.showToast(context, context.t.zuvioComingSoon);
  }
}
