import 'package:ap_common/ap_common.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/pages/zuvio/ui/zuvio_ui.dart';
import 'package:nkust_ap/pages/zuvio/zuvio_models.dart';
import 'package:nkust_ap/pages/zuvio/zuvio_question_list_page.dart';
import 'package:nkust_ap/pages/zuvio/zuvio_service.dart';
import 'package:nkust_ap/utils/global.dart';

class ZuvioAnswerHistoryPage extends StatefulWidget {
  static const String routerName = '/zuvio/answerHistory';

  const ZuvioAnswerHistoryPage({super.key, required this.course});

  final ZuvioCourse course;

  @override
  ZuvioAnswerHistoryPageState createState() => ZuvioAnswerHistoryPageState();
}

class ZuvioAnswerHistoryPageState extends State<ZuvioAnswerHistoryPage> {
  ZViewState _state = ZViewState.loading;
  List<ZuvioHistoryFolder> _folders = <ZuvioHistoryFolder>[];

  @override
  void initState() {
    super.initState();
    AnalyticsUtil.instance.setCurrentScreen(
      'ZuvioAnswerHistoryPage',
      'zuvio_answer_history_page.dart',
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return ZScaffold(
      title: context.t.zuvioAnswerHistory,
      body: RefreshIndicator(
        onRefresh: _load,
        child: ZStateView(
          state: _state,
          onRetry: _load,
          emptyIcon: Icons.folder_open_outlined,
          builder: (_) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding:
                const EdgeInsets.fromLTRB(ZGap.m, ZGap.m, ZGap.m, ZGap.xxl),
            children: <Widget>[
              ZCard(
                padding: const EdgeInsets.symmetric(vertical: ZGap.xs),
                child: Column(
                  children: <Widget>[
                    for (int i = 0; i < _folders.length; i++) ...<Widget>[
                      if (i != 0)
                        Divider(
                          height: 1,
                          indent: ZGap.xxl + ZGap.s,
                          color: context.zc.outline,
                        ),
                      ZListRow(
                        icon: Icons.folder_outlined,
                        title: _folders[i].title,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => ZuvioQuestionListPage(
                              course: widget.course,
                              folder: _folders[i],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
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
      final List<ZuvioHistoryFolder> data =
          await ZuvioService.instance.getAnswerFolders(widget.course.courseId);
      if (!mounted) return;
      setState(() {
        _folders = data;
        _state = data.isEmpty ? ZViewState.empty : ZViewState.ready;
      });
    } on ZuvioException {
      if (!mounted) return;
      setState(() => _state = ZViewState.error);
    }
  }
}
