class ZuvioCourse {
  const ZuvioCourse({
    required this.courseId,
    required this.name,
    required this.teacherName,
    required this.semester,
    this.pinned = false,
    this.unreadCount = 0,
  });

  final String courseId;
  final String name;
  final String teacherName;
  final String semester;
  final bool pinned;
  final int unreadCount;
}

enum ZuvioRollcallState {
  notOpen,
  open,
  answered,
  absent,
  leave,
}

class ZuvioRollcall {
  const ZuvioRollcall({
    required this.rollcallId,
    required this.state,
    this.answeredAt,
  });

  const ZuvioRollcall.notOpen()
      : rollcallId = '',
        state = ZuvioRollcallState.notOpen,
        answeredAt = null;

  final String rollcallId;
  final ZuvioRollcallState state;
  final DateTime? answeredAt;
}

enum ZuvioFeature {
  clickers,
  rollcall,
  history,
  feedback,
  bulletin,
}

class ZuvioLocation {
  const ZuvioLocation({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;
}

class ZuvioClickerQuestion {
  const ZuvioClickerQuestion({
    required this.id,
    required this.name,
    required this.isLive,
    required this.answered,
  });

  final String id;
  final String name;
  final bool isLive;
  final bool answered;
}

enum ZuvioAnswerStatus {
  onTime,
  late,
  missed,
  unknown,
}

class ZuvioHistoryFolder {
  const ZuvioHistoryFolder({required this.folderId, required this.title});

  final String folderId;
  final String title;
}

enum ZuvioQuestionResult { correct, wrong, unanswered, submitted }

enum ZuvioQuestionKind { single, multiple, essay }

class ZuvioQuestion {
  const ZuvioQuestion({
    required this.id,
    required this.type,
    required this.text,
    required this.result,
  });

  final String id;
  final String type;
  final String text;
  final ZuvioQuestionResult result;
}

class ZuvioQuestionOption {
  const ZuvioQuestionOption({
    required this.order,
    required this.text,
    required this.isCorrect,
    required this.isSelected,
  });

  final String order;
  final String text;
  final bool isCorrect;
  final bool isSelected;
}

class ZuvioQuestionDetail {
  const ZuvioQuestionDetail({
    required this.type,
    required this.kind,
    required this.text,
    required this.result,
    required this.options,
    this.essayAnswer,
  });

  final String type;
  final ZuvioQuestionKind kind;
  final String text;
  final ZuvioQuestionResult result;
  final List<ZuvioQuestionOption> options;
  final String? essayAnswer;
}

class ZuvioFeedbackThread {
  const ZuvioFeedbackThread({
    required this.question,
    this.questionAt,
    this.reply,
    this.replyAuthor,
    this.replyAt,
  });

  final String question;
  final DateTime? questionAt;
  final String? reply;
  final String? replyAuthor;
  final DateTime? replyAt;
}

class ZuvioAttendanceRecord {
  const ZuvioAttendanceRecord({
    required this.date,
    required this.status,
    this.checkedInAt,
  });

  final DateTime date;
  final ZuvioAnswerStatus status;
  final DateTime? checkedInAt;
}

class ZuvioAttachment {
  const ZuvioAttachment({required this.name, required this.url});

  final String name;
  final String url;
}

class ZuvioBulletin {
  const ZuvioBulletin({
    required this.id,
    required this.author,
    required this.date,
    required this.title,
    required this.content,
    this.attachments = const <ZuvioAttachment>[],
  });

  final String id;
  final String author;
  final DateTime date;
  final String title;
  final String content;
  final List<ZuvioAttachment> attachments;
}

class ZuvioFeedbackMessage {
  const ZuvioFeedbackMessage({
    required this.id,
    required this.content,
    required this.isMine,
    this.replied = false,
    this.createdAt,
    this.authorName,
  });

  final String id;
  final String content;
  final DateTime? createdAt;
  final bool isMine;
  final bool replied;
  final String? authorName;
}

enum ZuvioSticker {
  understand,
  interesting,
  tooFast,
  confused,
}

class ZuvioInfoRow {
  const ZuvioInfoRow({required this.label, required this.value});

  final String label;
  final String value;
}

class ZuvioInfoSection {
  const ZuvioInfoSection({required this.title, required this.rows});

  final String title;
  final List<ZuvioInfoRow> rows;
}
