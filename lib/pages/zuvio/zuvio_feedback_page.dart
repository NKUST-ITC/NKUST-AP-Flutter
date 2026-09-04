import 'package:ap_common/ap_common.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/pages/zuvio/ui/zuvio_ui.dart';
import 'package:nkust_ap/pages/zuvio/zuvio_feedback_detail_page.dart';
import 'package:nkust_ap/pages/zuvio/zuvio_models.dart';
import 'package:nkust_ap/pages/zuvio/zuvio_service.dart';
import 'package:nkust_ap/utils/global.dart';

class ZuvioFeedbackPage extends StatefulWidget {
  static const String routerName = '/zuvio/feedback';

  const ZuvioFeedbackPage({super.key, required this.course});

  final ZuvioCourse course;

  @override
  ZuvioFeedbackPageState createState() => ZuvioFeedbackPageState();
}

class ZuvioFeedbackPageState extends State<ZuvioFeedbackPage> {
  ZViewState _state = ZViewState.loading;
  List<ZuvioFeedbackMessage> _messages = <ZuvioFeedbackMessage>[];

  @override
  void initState() {
    super.initState();
    AnalyticsUtil.instance.setCurrentScreen(
      'ZuvioFeedbackPage',
      'zuvio_feedback_page.dart',
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return ZScaffold(
      title: context.t.zuvioFeedback,
      body: Column(
        children: <Widget>[
          Expanded(
            child: ZStateView(
              state: _state,
              onRetry: _load,
              emptyIcon: Icons.forum_outlined,
              emptyText: context.t.zuvioFeedbackEmpty,
              builder: (_) => RefreshIndicator(
                onRefresh: _load,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding:
                      const EdgeInsets.fromLTRB(ZGap.m, ZGap.m, ZGap.m, ZGap.m),
                  itemCount: _messages.length,
                  itemBuilder: (BuildContext context, int index) =>
                      _bubble(_messages[index]),
                ),
              ),
            ),
          ),
          _readOnlyNotice(),
        ],
      ),
    );
  }

  Widget _readOnlyNotice() {
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: ZGap.m,
          vertical: ZGap.sm,
        ),
        color: context.zc.surfaceHi,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.info_outline_rounded,
              size: 15,
              color: context.zc.textFaint,
            ),
            const SizedBox(width: ZGap.xs),
            Flexible(
              child: Text(
                context.t.zuvioWriteUnsupported,
                style: context.zt.label,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bubble(ZuvioFeedbackMessage m) {
    final ZColors zc = context.zc;
    final bool openable = m.isMine && m.id.isNotEmpty;
    return Align(
      alignment: m.isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onTap: openable
            ? () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        ZuvioFeedbackDetailPage(feedbackId: m.id),
                  ),
                )
            : null,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78,
          ),
          margin: const EdgeInsets.symmetric(vertical: ZGap.xs),
          padding: const EdgeInsets.symmetric(
            horizontal: ZGap.sm,
            vertical: ZGap.s,
          ),
          decoration: BoxDecoration(
            color: m.isMine ? zc.accentSoft : zc.surfaceHi,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(14),
              topRight: const Radius.circular(14),
              bottomLeft: Radius.circular(m.isMine ? 14 : 4),
              bottomRight: Radius.circular(m.isMine ? 4 : 14),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (!m.isMine && m.authorName != null)
                Text(m.authorName!, style: context.zt.label),
              Text(m.content, style: context.zt.body),
              const SizedBox(height: ZGap.xs),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (m.createdAt != null)
                    Text(
                      zuvioDateTime(m.createdAt!),
                      style: context.zt.label,
                    ),
                  if (m.isMine) ...<Widget>[
                    const SizedBox(width: ZGap.s),
                    Text(
                      m.replied
                          ? context.t.zuvioFeedbackReplied
                          : context.t.zuvioFeedbackNotReplied,
                      style: context.zt.label.copyWith(
                        color: m.replied ? zc.success : zc.textFaint,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _load() async {
    setState(() => _state = ZViewState.loading);
    try {
      final List<ZuvioFeedbackMessage> data =
          await ZuvioService.instance.getFeedback(widget.course.courseId);
      if (!mounted) return;
      setState(() {
        _messages = data;
        _state = data.isEmpty ? ZViewState.empty : ZViewState.ready;
      });
    } on ZuvioException {
      if (!mounted) return;
      setState(() => _state = ZViewState.error);
    }
  }
}
