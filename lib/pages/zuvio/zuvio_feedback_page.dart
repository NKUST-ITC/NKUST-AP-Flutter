import 'package:ap_common/ap_common.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/pages/zuvio/zuvio_models.dart';
import 'package:nkust_ap/pages/zuvio/zuvio_service.dart';
import 'package:nkust_ap/pages/zuvio/zuvio_widgets.dart';
import 'package:nkust_ap/utils/global.dart';

class ZuvioFeedbackPage extends StatefulWidget {
  static const String routerName = '/zuvio/feedback';

  const ZuvioFeedbackPage({super.key, required this.course});

  final ZuvioCourse course;

  @override
  ZuvioFeedbackPageState createState() => ZuvioFeedbackPageState();
}

class ZuvioFeedbackPageState extends State<ZuvioFeedbackPage> {
  final TextEditingController _input = TextEditingController();
  List<ZuvioFeedbackMessage>? _messages;
  bool _error = false;
  bool _sending = false;

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
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.t.zuvioFeedback)),
      body: Column(
        children: <Widget>[
          Expanded(child: _list()),
          const Divider(height: 1),
          _composer(),
        ],
      ),
    );
  }

  Widget _list() {
    if (_error) {
      return _hint(context.ap.somethingError);
    }
    if (_messages == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_messages!.isEmpty) {
      return _hint(context.t.zuvioFeedbackEmpty);
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(12),
        itemCount: _messages!.length,
        itemBuilder: (BuildContext context, int index) =>
            _bubble(_messages![index]),
      ),
    );
  }

  Widget _hint(String text) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: <Widget>[
        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
        HintContent(icon: ApIcon.assignment, content: text),
      ],
    );
  }

  Widget _bubble(ZuvioFeedbackMessage m) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color bg = m.isMine
        ? colorScheme.primaryContainer
        : colorScheme.surfaceContainerHighest;
    return Align(
      alignment: m.isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (!m.isMine && m.authorName != null)
              Text(
                m.authorName!,
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            Text(m.content),
            if (m.createdAt != null) ...<Widget>[
              const SizedBox(height: 2),
              Text(
                zuvioFormatDateTime(m.createdAt!),
                style: TextStyle(
                  fontSize: 10,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _composer() {
    return Padding(
      padding: EdgeInsets.only(
        left: 12,
        right: 8,
        top: 8,
        bottom: 8 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _input,
              minLines: 1,
              maxLines: 4,
              decoration: InputDecoration(
                isDense: true,
                hintText: context.t.zuvioFeedbackHint,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          IconButton(
            icon: _sending
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send_rounded),
            onPressed: _sending ? null : _send,
          ),
        ],
      ),
    );
  }

  Future<void> _load() async {
    setState(() {
      _error = false;
      _messages = null;
    });
    try {
      final List<ZuvioFeedbackMessage> data =
          await ZuvioService.instance.getFeedback(widget.course.courseId);
      if (!mounted) return;
      setState(() => _messages = data);
    } on ZuvioException {
      if (!mounted) return;
      setState(() => _error = true);
    }
  }

  Future<void> _send() async {
    final String text = _input.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);
    try {
      await ZuvioService.instance
          .sendFeedback(widget.course.courseId, text);
      if (!mounted) return;
      _input.clear();
      setState(() {
        _sending = false;
        _messages = <ZuvioFeedbackMessage>[
          ...?_messages,
          ZuvioFeedbackMessage(
            content: text,
            createdAt: DateTime.now(),
            isMine: true,
          ),
        ];
      });
    } on ZuvioException catch (e) {
      if (!mounted) return;
      setState(() => _sending = false);
      UiUtil.instance.showToast(context, e.message);
    }
  }
}
