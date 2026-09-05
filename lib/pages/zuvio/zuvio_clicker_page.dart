import 'dart:async';

import 'package:ap_common/ap_common.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/pages/zuvio/ui/zuvio_ui.dart';
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
  static const Duration _pollInterval = Duration(seconds: 15);

  _State _state = _State.loading;
  ZuvioClickerQuestion? _question;
  Timer? _poll;

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
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ZScaffold(
      title: context.t.zuvioClickers,
      body: RefreshIndicator(
        onRefresh: () => _load(),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    ZGap.m,
                    ZGap.xl,
                    ZGap.m,
                    ZGap.xl,
                  ),
                  child: _state == _State.live
                      ? _body()
                      : Center(child: _body()),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _body() {
    final ZColors zc = context.zc;
    switch (_state) {
      case _State.loading:
        return const CircularProgressIndicator(strokeWidth: 2.5);
      case _State.error:
        return _hint(Icons.error_outline_rounded, context.ap.somethingError);
      case _State.idle:
        return _hint(
          Icons.pause_circle_outline_rounded,
          context.t.zuvioNoLiveClicker,
          detail: context.t.zuvioNoLiveClickerHint,
        );
      case _State.live:
        final ZuvioClickerQuestion q = _question!;
        return ZCard(
          padding: const EdgeInsets.all(ZGap.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: zc.danger,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: ZGap.s),
                  Text(
                    context.t.zuvioClickerLive,
                    style: context.zt.label.copyWith(
                      color: zc.danger,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: ZGap.sm),
              Text(q.name, style: context.zt.body),
              const SizedBox(height: ZGap.l),
              ZButton(
                label: q.answered
                    ? context.t.zuvioClickerAnswered
                    : context.t.zuvioClickerAnswer,
              ),
              if (!q.answered) ...<Widget>[
                const SizedBox(height: ZGap.s),
                Text(
                  context.t.zuvioWriteUnsupported,
                  textAlign: TextAlign.center,
                  style: context.zt.label,
                ),
              ],
            ],
          ),
        );
    }
  }

  Widget _hint(IconData icon, String text, {String? detail}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 44, color: context.zc.textFaint),
        const SizedBox(height: ZGap.m),
        Text(text, style: context.zt.cardTitle),
        if (detail != null) ...<Widget>[
          const SizedBox(height: ZGap.xs),
          Text(
            detail,
            textAlign: TextAlign.center,
            style: context.zt.supporting,
          ),
        ],
      ],
    );
  }

  /// [silent] is the background poll while idle: no spinner, and a
  /// transient failure keeps the "no live question" view.
  Future<void> _load({bool silent = false}) async {
    _poll?.cancel();
    if (!silent) setState(() => _state = _State.loading);
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
      if (!silent) setState(() => _state = _State.error);
    }
    if (mounted && _state == _State.idle) {
      _poll = Timer(_pollInterval, () => _load(silent: true));
    }
  }
}
