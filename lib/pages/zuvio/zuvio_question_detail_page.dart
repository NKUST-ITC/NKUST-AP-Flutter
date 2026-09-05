import 'package:ap_common/ap_common.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/pages/zuvio/ui/zuvio_ui.dart';
import 'package:nkust_ap/pages/zuvio/zuvio_models.dart';
import 'package:nkust_ap/pages/zuvio/zuvio_question_list_page.dart';
import 'package:nkust_ap/pages/zuvio/zuvio_service.dart';
import 'package:nkust_ap/utils/global.dart';

class ZuvioQuestionDetailPage extends StatefulWidget {
  static const String routerName = '/zuvio/question';

  const ZuvioQuestionDetailPage({super.key, required this.questionId});

  final String questionId;

  @override
  ZuvioQuestionDetailPageState createState() =>
      ZuvioQuestionDetailPageState();
}

class ZuvioQuestionDetailPageState extends State<ZuvioQuestionDetailPage> {
  ZViewState _state = ZViewState.loading;
  ZuvioQuestionDetail? _detail;

  @override
  void initState() {
    super.initState();
    AnalyticsUtil.instance.setCurrentScreen(
      'ZuvioQuestionDetailPage',
      'zuvio_question_detail_page.dart',
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return ZScaffold(
      title: context.t.zuvioAnswerHistory,
      body: ZStateView(
        state: _state,
        onRetry: _load,
        builder: (_) => _content(_detail!),
      ),
    );
  }

  Widget _content(ZuvioQuestionDetail d) {
    final (String label, ZStatusTone tone) =
        zuvioQuestionResultChip(context, d.result);
    return ListView(
      padding: const EdgeInsets.fromLTRB(ZGap.m, ZGap.l, ZGap.m, ZGap.xxl),
      children: <Widget>[
        Row(
          children: <Widget>[
            if (d.type.isNotEmpty)
              ZStatusChip(label: d.type, tone: ZStatusTone.accent),
            const Spacer(),
            if (d.kind != ZuvioQuestionKind.essay)
              ZStatusChip(label: label, tone: tone),
          ],
        ),
        const SizedBox(height: ZGap.m),
        SelectableText(d.text, style: context.zt.body.copyWith(fontSize: 16)),
        const SizedBox(height: ZGap.xl),
        if (d.kind == ZuvioQuestionKind.essay)
          _essay(d)
        else
          ..._options(d),
      ],
    );
  }

  Widget _essay(ZuvioQuestionDetail d) {
    final String? answer = d.essayAnswer;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ZSectionHeader(context.t.zuvioYourAnswer),
        ZCard(
          emphasised: true,
          child: (answer == null || answer.isEmpty)
              ? Text(
                  context.t.zuvioQuestionUnanswered,
                  style: context.zt.supporting,
                )
              : SelectableText(
                  answer,
                  style: context.zt.body.copyWith(height: 1.6),
                ),
        ),
      ],
    );
  }

  List<Widget> _options(ZuvioQuestionDetail d) {
    final ZColors zc = context.zc;
    return <Widget>[
      for (final ZuvioQuestionOption o in d.options)
        Padding(
          padding: const EdgeInsets.only(bottom: ZGap.s),
          child: Container(
            padding: const EdgeInsets.all(ZGap.sm),
            decoration: BoxDecoration(
              color: o.isCorrect
                  ? zc.success.withValues(alpha: 0.1)
                  : (o.isSelected
                      ? zc.danger.withValues(alpha: 0.08)
                      : zc.surface),
              borderRadius: ZRadii.control,
              border: o.isSelected
                  ? Border.all(
                      color: o.isCorrect ? zc.success : zc.danger,
                      width: 1.2,
                    )
                  : null,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (o.order.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: ZGap.s),
                    child: Text(o.order, style: context.zt.cardTitle),
                  ),
                Expanded(child: Text(o.text, style: context.zt.body)),
                if (o.isCorrect) ...<Widget>[
                  const SizedBox(width: ZGap.s),
                  Icon(
                    Icons.check_circle_rounded,
                    size: 18,
                    color: zc.success,
                  ),
                ] else if (o.isSelected) ...<Widget>[
                  const SizedBox(width: ZGap.s),
                  Icon(
                    Icons.cancel_rounded,
                    size: 18,
                    color: zc.danger,
                  ),
                ],
              ],
            ),
          ),
        ),
    ];
  }

  Future<void> _load() async {
    setState(() => _state = ZViewState.loading);
    try {
      final ZuvioQuestionDetail? d =
          await ZuvioService.instance.getQuestionDetail(widget.questionId);
      if (!mounted) return;
      setState(() {
        _detail = d;
        _state = d == null ? ZViewState.error : ZViewState.ready;
      });
    } on ZuvioException {
      if (!mounted) return;
      setState(() => _state = ZViewState.error);
    }
  }
}
