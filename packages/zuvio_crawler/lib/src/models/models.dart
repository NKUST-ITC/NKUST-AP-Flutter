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
    required this.title,
    required this.folder,
    required this.status,
    this.openAt,
    this.answeredAt,
  });

  final String title;
  final String folder;
  final ZuvioAnswerStatus status;
  final DateTime? openAt;
  final DateTime? answeredAt;
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

class ZuvioBulletin {
  const ZuvioBulletin({
    required this.author,
    required this.title,
    required this.content,
    this.date,
  });

  final String author;
  final String title;
  final String content;
  final DateTime? date;
}

class ZuvioFeedbackMessage {
  const ZuvioFeedbackMessage({
    required this.content,
    required this.isMine,
    this.authorName,
    this.createdAt,
  });

  /// Items from `app_v2/getFeedbackList` in the 私訊老師 feed are all the
  /// current student's own messages.
  factory ZuvioFeedbackMessage.fromJson(Map<String, dynamic> json) {
    return ZuvioFeedbackMessage(
      content: '${json['content'] ?? ''}',
      isMine: true,
      createdAt: DateTime.tryParse(
        '${json['created_at']}'.replaceFirst(' ', 'T'),
      ),
    );
  }

  final String content;
  final bool isMine;
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
