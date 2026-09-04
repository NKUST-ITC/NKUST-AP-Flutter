/// Auth material scraped from any logged-in Zuvio HTML page. The
/// `app_v2/*` JSON endpoints take [userId] + [accessToken] as parameters
/// rather than relying on the `PHPSESSID` cookie alone.
class ZuvioSession {
  const ZuvioSession({required this.userId, required this.accessToken});

  final String userId;
  final String accessToken;
}

class ZuvioCourse {
  const ZuvioCourse({
    required this.courseId,
    required this.courseName,
    required this.teacherName,
    required this.semesterName,
    this.pinned = false,
    this.unreadCount = 0,
  });

  factory ZuvioCourse.fromJson(Map<String, dynamic> json) {
    return ZuvioCourse(
      courseId: '${json['course_id']}',
      courseName: '${json['course_name']}',
      teacherName: '${json['teacher_name']}',
      semesterName: '${json['semester_name']}',
      pinned: json['pinned'] == true,
      unreadCount: int.tryParse('${json['course_unread_num']}') ?? 0,
    );
  }

  final String courseId;
  final String courseName;
  final String teacherName;
  final String semesterName;
  final bool pinned;
  final int unreadCount;
}

enum ZuvioRollcallState { notOpen, open, answered }

class ZuvioRollcall {
  const ZuvioRollcall({required this.rollcallId, required this.state});

  const ZuvioRollcall.notOpen()
      : rollcallId = '',
        state = ZuvioRollcallState.notOpen;

  final String rollcallId;
  final ZuvioRollcallState state;
}

/// Outcome of `app_v2/makeRollcall`.
class ZuvioRollcallResult {
  const ZuvioRollcallResult({required this.success, required this.message});

  factory ZuvioRollcallResult.fromJson(Map<String, dynamic> json) {
    return ZuvioRollcallResult(
      success: json['status'] == true,
      message: '${json['msg'] ?? ''}',
    );
  }

  final bool success;
  final String message;
}

enum ZuvioAnswerStatus { onTime, late, missed }

class ZuvioHistoryEntry {
  const ZuvioHistoryEntry({
    required this.folderId,
    required this.title,
    this.answeredCount,
  });

  final String folderId;
  final String title;

  /// From `app_v2/getFolderAnsweredAmount`; null until loaded.
  final String? answeredCount;
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
    required this.title,
    required this.content,
    this.date,
    this.attachments = const <ZuvioAttachment>[],
  });

  final String id;
  final String author;
  final String title;
  final String content;
  final DateTime? date;
  final List<ZuvioAttachment> attachments;
}

class ZuvioFeedbackMessage {
  const ZuvioFeedbackMessage({
    required this.id,
    required this.content,
    required this.isMine,
    this.replied = false,
    this.authorName,
    this.createdAt,
  });

  /// Items from `app_v2/getFeedbackList` in the 私訊老師 feed are all the
  /// current student's own messages; `reply_id` is set once the teacher
  /// has replied.
  factory ZuvioFeedbackMessage.fromJson(Map<String, dynamic> json) {
    return ZuvioFeedbackMessage(
      id: '${json['id'] ?? ''}',
      content: '${json['content'] ?? ''}',
      isMine: true,
      replied: json['reply_id'] != null &&
          '${json['reply_id']}'.isNotEmpty &&
          '${json['reply_id']}' != 'null',
      createdAt: DateTime.tryParse(
        '${json['created_at']}'.replaceFirst(' ', 'T'),
      ),
    );
  }

  final String id;
  final String content;
  final bool isMine;
  final bool replied;
  final String? authorName;
  final DateTime? createdAt;
}

class ZuvioInfoSection {
  const ZuvioInfoSection({required this.title, required this.rows});

  final String title;
  final List<ZuvioInfoRow> rows;
}

class ZuvioInfoRow {
  const ZuvioInfoRow({required this.label, required this.value});

  final String label;
  final String value;
}

class ZuvioCourseInfo {
  const ZuvioCourseInfo({required this.sections});

  final List<ZuvioInfoSection> sections;
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

class ZuvioClickerQuestion {
  const ZuvioClickerQuestion({
    required this.id,
    required this.name,
    required this.isLive,
    this.answered = false,
  });

  final String id;
  final String name;
  final bool isLive;
  final bool answered;
}
