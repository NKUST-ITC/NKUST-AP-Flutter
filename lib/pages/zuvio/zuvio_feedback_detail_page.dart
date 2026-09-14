import 'package:ap_common/ap_common.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/pages/zuvio/ui/zuvio_ui.dart';
import 'package:nkust_ap/pages/zuvio/zuvio_models.dart';
import 'package:nkust_ap/pages/zuvio/zuvio_service.dart';
import 'package:nkust_ap/utils/global.dart';

class ZuvioFeedbackDetailPage extends StatefulWidget {
  static const String routerName = '/zuvio/feedback/detail';

  const ZuvioFeedbackDetailPage({super.key, required this.feedbackId});

  final String feedbackId;

  @override
  ZuvioFeedbackDetailPageState createState() =>
      ZuvioFeedbackDetailPageState();
}

class ZuvioFeedbackDetailPageState extends State<ZuvioFeedbackDetailPage> {
  ZViewState _state = ZViewState.loading;
  ZuvioFeedbackThread? _thread;

  @override
  void initState() {
    super.initState();
    AnalyticsUtil.instance.setCurrentScreen(
      'ZuvioFeedbackDetailPage',
      'zuvio_feedback_detail_page.dart',
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return ZScaffold(
      title: context.t.zuvioFeedback,
      body: ZStateView(
        state: _state,
        onRetry: _load,
        builder: (_) => _content(_thread!),
      ),
    );
  }

  Widget _content(ZuvioFeedbackThread t) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(ZGap.m, ZGap.l, ZGap.m, ZGap.xxl),
      children: <Widget>[
        _bubble(
          author: context.t.zuvioFeedbackMe,
          text: t.question,
          at: t.questionAt,
          mine: true,
        ),
        const SizedBox(height: ZGap.m),
        if (t.reply != null)
          _bubble(
            author: t.replyAuthor ?? '',
            text: t.reply!,
            at: t.replyAt,
            mine: false,
          )
        else
          Center(
            child: Padding(
              padding: const EdgeInsets.all(ZGap.l),
              child: Text(
                context.t.zuvioFeedbackNotReplied,
                style: context.zt.supporting,
              ),
            ),
          ),
      ],
    );
  }

  Widget _bubble({
    required String author,
    required String text,
    required DateTime? at,
    required bool mine,
  }) {
    final ZColors zc = context.zc;
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: ZGap.sm,
          vertical: ZGap.s,
        ),
        decoration: BoxDecoration(
          color: mine ? zc.accentSoft : zc.surfaceHi,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(mine ? 14 : 4),
            bottomRight: Radius.circular(mine ? 4 : 14),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (author.isNotEmpty)
              Text(
                author,
                style: context.zt.label.copyWith(fontWeight: FontWeight.w600),
              ),
            const SizedBox(height: 2),
            Text(text, style: context.zt.body),
            if (at != null) ...<Widget>[
              const SizedBox(height: ZGap.xs),
              Text(zuvioDateTime(at), style: context.zt.label),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _load() async {
    setState(() => _state = ZViewState.loading);
    try {
      final ZuvioFeedbackThread? t =
          await ZuvioService.instance.getFeedbackThread(widget.feedbackId);
      if (!mounted) return;
      setState(() {
        _thread = t;
        _state = t == null ? ZViewState.error : ZViewState.ready;
      });
    } on ZuvioException {
      if (!mounted) return;
      setState(() => _state = ZViewState.error);
    }
  }
}
