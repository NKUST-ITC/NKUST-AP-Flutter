import 'package:ap_common/ap_common.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/pages/zuvio/ui/zuvio_ui.dart';
import 'package:nkust_ap/pages/zuvio/zuvio_models.dart';
import 'package:nkust_ap/pages/zuvio/zuvio_question_detail_page.dart';
import 'package:nkust_ap/pages/zuvio/zuvio_service.dart';
import 'package:nkust_ap/utils/global.dart';

(String, ZStatusTone) zuvioQuestionResultChip(
  BuildContext context,
  ZuvioQuestionResult result,
) {
  return switch (result) {
    ZuvioQuestionResult.correct => (
        context.t.zuvioQuestionCorrect,
        ZStatusTone.success
      ),
    ZuvioQuestionResult.wrong => (
        context.t.zuvioQuestionWrong,
        ZStatusTone.danger
      ),
    ZuvioQuestionResult.submitted => (
        context.t.zuvioQuestionSubmitted,
        ZStatusTone.accent
      ),
    ZuvioQuestionResult.unanswered => (
        context.t.zuvioQuestionUnanswered,
        ZStatusTone.neutral
      ),
  };
}

class ZuvioQuestionListPage extends StatefulWidget {
  static const String routerName = '/zuvio/questions';

  const ZuvioQuestionListPage({
    super.key,
    required this.course,
    required this.folder,
  });

  final ZuvioCourse course;
  final ZuvioHistoryFolder folder;

  @override
  ZuvioQuestionListPageState createState() => ZuvioQuestionListPageState();
}

class ZuvioQuestionListPageState extends State<ZuvioQuestionListPage> {
  ZViewState _state = ZViewState.loading;
  List<ZuvioQuestion> _questions = <ZuvioQuestion>[];

  @override
  void initState() {
    super.initState();
    AnalyticsUtil.instance.setCurrentScreen(
      'ZuvioQuestionListPage',
      'zuvio_question_list_page.dart',
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return ZScaffold(
      title: widget.folder.title,
      body: RefreshIndicator(
        onRefresh: _load,
        child: ZStateView(
          state: _state,
          onRetry: _load,
          emptyIcon: Icons.help_outline_rounded,
          emptyText: context.t.zuvioNoQuestions,
          builder: (_) => ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding:
                const EdgeInsets.fromLTRB(ZGap.m, ZGap.m, ZGap.m, ZGap.xxl),
            itemCount: _questions.length,
            separatorBuilder: (_, __) => const SizedBox(height: ZGap.s),
            itemBuilder: (BuildContext context, int index) {
              final ZuvioQuestion q = _questions[index];
              final (String label, ZStatusTone tone) =
                  zuvioQuestionResultChip(context, q.result);
              return ZCard(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        ZuvioQuestionDetailPage(questionId: q.id),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(q.type, style: context.zt.label),
                        ),
                        ZStatusChip(label: label, tone: tone),
                      ],
                    ),
                    const SizedBox(height: ZGap.s),
                    Text(
                      q.text,
                      style: context.zt.body,
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
      final List<ZuvioQuestion> data = await ZuvioService.instance
          .getQuestions(widget.course.courseId, widget.folder.folderId);
      if (!mounted) return;
      setState(() {
        _questions = data;
        _state = data.isEmpty ? ZViewState.empty : ZViewState.ready;
      });
    } on ZuvioException {
      if (!mounted) return;
      setState(() => _state = ZViewState.error);
    }
  }
}
