class ZuvioCourse {
  const ZuvioCourse({
    required this.courseId,
    required this.name,
    required this.teacherName,
    required this.semester,
  });

  final String courseId;
  final String name;
  final String teacherName;
  final String semester;
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
}

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
    required this.date,
    required this.title,
    required this.content,
  });

  final String author;
  final DateTime date;
  final String title;
  final String content;
}

class ZuvioFeedbackMessage {
  const ZuvioFeedbackMessage({
    required this.content,
    required this.isMine,
    this.createdAt,
    this.authorName,
  });

  final String content;
  final DateTime? createdAt;
  final bool isMine;
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
