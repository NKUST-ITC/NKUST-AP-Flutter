import 'package:nkust_ap/pages/zuvio/zuvio_models.dart';
import 'package:zuvio_crawler/zuvio_crawler.dart' as zc;

/// Data source for the Zuvio pages. Defaults to the real
/// [zc.ZuvioHelper]; swap [instance] for [ZuvioMockService] to work on
/// the UI offline.
abstract class ZuvioService {
  static ZuvioService instance = ZuvioCrawlerService();

  bool get isLogin;

  Future<void> login({required String email, required String password});

  Future<void> logout();

  Future<List<ZuvioCourse>> getCourses();

  Future<ZuvioRollcall> getCurrentRollcall(String courseId);

  Future<void> makeRollcall({
    required String rollcallId,
    required ZuvioLocation location,
  });

  Future<ZuvioClickerQuestion?> getLiveClicker(String courseId);

  Future<List<ZuvioHistoryEntry>> getAnswerHistory(String courseId);

  Future<List<ZuvioAttendanceRecord>> getAttendanceHistory(String courseId);

  Future<List<ZuvioBulletin>> getBulletins(String courseId);

  Future<List<ZuvioInfoSection>> getCourseInfo(String courseId);

  Future<List<ZuvioFeedbackMessage>> getFeedback(String courseId);

  Future<void> sendFeedback(String courseId, String text);
}

class ZuvioException implements Exception {
  const ZuvioException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ZuvioCrawlerService implements ZuvioService {
  final zc.ZuvioHelper _helper = zc.ZuvioHelper();

  @override
  bool get isLogin => _helper.isLogin;

  @override
  Future<void> login({
    required String email,
    required String password,
  }) {
    return _run(() => _helper.login(email: email, password: password));
  }

  @override
  Future<void> logout() async => _helper.logout();

  @override
  Future<List<ZuvioCourse>> getCourses() {
    return _run(() async {
      final List<zc.ZuvioCourse> courses = await _helper.getCourses();
      return courses
          .map(
            (zc.ZuvioCourse c) => ZuvioCourse(
              courseId: c.courseId,
              name: c.courseName,
              teacherName: c.teacherName,
              semester: c.semesterName,
            ),
          )
          .toList();
    });
  }

  @override
  Future<ZuvioRollcall> getCurrentRollcall(String courseId) {
    return _run(() async {
      final zc.ZuvioRollcall r = await _helper.getCurrentRollcall(courseId);
      return ZuvioRollcall(
        rollcallId: r.rollcallId,
        state: switch (r.state) {
          zc.ZuvioRollcallState.open => ZuvioRollcallState.open,
          zc.ZuvioRollcallState.answered => ZuvioRollcallState.answered,
          zc.ZuvioRollcallState.notOpen => ZuvioRollcallState.notOpen,
        },
      );
    });
  }

  @override
  Future<void> makeRollcall({
    required String rollcallId,
    required ZuvioLocation location,
  }) {
    return _run(() async {
      final zc.ZuvioRollcallResult result = await _helper.makeRollcall(
        rollcallId: rollcallId,
        latitude: location.latitude,
        longitude: location.longitude,
      );
      if (!result.success) {
        throw ZuvioException(result.message);
      }
    });
  }

  @override
  Future<ZuvioClickerQuestion?> getLiveClicker(String courseId) {
    return _run(() async {
      final zc.ZuvioClickerQuestion? q =
          await _helper.getLiveClicker(courseId);
      if (q == null) return null;
      return ZuvioClickerQuestion(
        id: q.id,
        name: q.name,
        isLive: q.isLive,
        answered: q.answered,
      );
    });
  }

  @override
  Future<List<ZuvioHistoryEntry>> getAnswerHistory(String courseId) {
    return _run(() async {
      final List<zc.ZuvioHistoryEntry> data =
          await _helper.getAnswerHistory(courseId);
      return data
          .map(
            (zc.ZuvioHistoryEntry e) => ZuvioHistoryEntry(
              title: e.title,
              folder: e.folder,
              status: _status(e.status),
              openAt: e.openAt,
              answeredAt: e.answeredAt,
            ),
          )
          .toList();
    });
  }

  @override
  Future<List<ZuvioAttendanceRecord>> getAttendanceHistory(String courseId) {
    return _run(() async {
      final List<zc.ZuvioAttendanceRecord> data =
          await _helper.getAttendanceHistory(courseId);
      return data
          .map(
            (zc.ZuvioAttendanceRecord r) => ZuvioAttendanceRecord(
              date: r.date,
              status: _status(r.status),
              checkedInAt: r.checkedInAt,
            ),
          )
          .toList();
    });
  }

  @override
  Future<List<ZuvioBulletin>> getBulletins(String courseId) {
    return _run(() async {
      final List<zc.ZuvioBulletin> data =
          await _helper.getBulletins(courseId);
      return data
          .map(
            (zc.ZuvioBulletin b) => ZuvioBulletin(
              author: b.author,
              date: b.date ?? DateTime.now(),
              title: b.title,
              content: b.content,
            ),
          )
          .toList();
    });
  }

  @override
  Future<List<ZuvioInfoSection>> getCourseInfo(String courseId) {
    return _run(() async {
      final zc.ZuvioCourseInfo info = await _helper.getCourseInfo(courseId);
      return info.sections
          .map(
            (zc.ZuvioInfoSection s) => ZuvioInfoSection(
              title: s.title,
              rows: s.rows
                  .map(
                    (zc.ZuvioInfoRow r) =>
                        ZuvioInfoRow(label: r.label, value: r.value),
                  )
                  .toList(),
            ),
          )
          .toList();
    });
  }

  @override
  Future<List<ZuvioFeedbackMessage>> getFeedback(String courseId) {
    return _run(() async {
      final List<zc.ZuvioFeedbackMessage> data =
          await _helper.getFeedback(courseId);
      return data
          .map(
            (zc.ZuvioFeedbackMessage m) => ZuvioFeedbackMessage(
              content: m.content,
              createdAt: m.createdAt,
              isMine: m.isMine,
              authorName: m.authorName,
            ),
          )
          .toList();
    });
  }

  @override
  Future<void> sendFeedback(String courseId, String text) {
    return Future<void>.error(const ZuvioException('尚未支援送出回饋'));
  }

  ZuvioAnswerStatus _status(zc.ZuvioAnswerStatus s) {
    return switch (s) {
      zc.ZuvioAnswerStatus.onTime => ZuvioAnswerStatus.onTime,
      zc.ZuvioAnswerStatus.late => ZuvioAnswerStatus.late,
      zc.ZuvioAnswerStatus.missed => ZuvioAnswerStatus.missed,
    };
  }

  Future<T> _run<T>(Future<T> Function() body) async {
    try {
      return await body();
    } on zc.ZuvioException catch (e) {
      throw ZuvioException(e.message);
    }
  }
}

class ZuvioMockService implements ZuvioService {
  bool _login = false;

  @override
  bool get isLogin => _login;

  @override
  Future<void> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (password.isEmpty) {
      throw const ZuvioException('帳號或密碼錯誤');
    }
    _login = true;
  }

  @override
  Future<void> logout() async {
    _login = false;
  }

  @override
  Future<List<ZuvioCourse>> getCourses() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return const <ZuvioCourse>[
      ZuvioCourse(
        courseId: '751763',
        name: '物件導向程式設計',
        teacherName: '王大瑾',
        semester: '113-2',
      ),
      ZuvioCourse(
        courseId: '1088648',
        name: '國際貿易實務',
        teacherName: '王馨葦',
        semester: '112-1',
      ),
    ];
  }

  @override
  Future<ZuvioRollcall> getCurrentRollcall(String courseId) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (courseId == '751763') {
      return const ZuvioRollcall(
        rollcallId: '9001',
        state: ZuvioRollcallState.open,
      );
    }
    return const ZuvioRollcall.notOpen();
  }

  @override
  Future<void> makeRollcall({
    required String rollcallId,
    required ZuvioLocation location,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
  }

  @override
  Future<ZuvioClickerQuestion?> getLiveClicker(String courseId) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (courseId == '751763') {
      return const ZuvioClickerQuestion(
        id: 'q1',
        name: '第 3 章 隨堂測驗：多型的定義為何？',
        isLive: true,
        answered: false,
      );
    }
    return null;
  }

  @override
  Future<List<ZuvioHistoryEntry>> getAnswerHistory(String courseId) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return const <ZuvioHistoryEntry>[
      ZuvioHistoryEntry(
        title: 'W7 繼承與多型',
        folder: 'W7',
        status: ZuvioAnswerStatus.onTime,
      ),
      ZuvioHistoryEntry(
        title: 'W6 封裝',
        folder: 'W6',
        status: ZuvioAnswerStatus.onTime,
      ),
    ];
  }

  @override
  Future<List<ZuvioAttendanceRecord>> getAttendanceHistory(
    String courseId,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final DateTime now = DateTime.now();
    return <ZuvioAttendanceRecord>[
      ZuvioAttendanceRecord(
        date: now.subtract(const Duration(days: 2)),
        status: ZuvioAnswerStatus.onTime,
        checkedInAt: now.subtract(const Duration(days: 2)),
      ),
      ZuvioAttendanceRecord(
        date: now.subtract(const Duration(days: 9)),
        status: ZuvioAnswerStatus.late,
      ),
      ZuvioAttendanceRecord(
        date: now.subtract(const Duration(days: 16)),
        status: ZuvioAnswerStatus.missed,
      ),
    ];
  }

  @override
  Future<List<ZuvioBulletin>> getBulletins(String courseId) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return <ZuvioBulletin>[
      ZuvioBulletin(
        author: '王大瑾',
        date: DateTime.now().subtract(const Duration(days: 1)),
        title: '期末成績公佈',
        content: '附上期末成績及最後總成績，如有問題請於 1/21 前 email 告知。',
      ),
    ];
  }

  @override
  Future<List<ZuvioInfoSection>> getCourseInfo(String courseId) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return const <ZuvioInfoSection>[
      ZuvioInfoSection(
        title: '課程資訊',
        rows: <ZuvioInfoRow>[
          ZuvioInfoRow(label: '授課教師', value: '王馨葦'),
          ZuvioInfoRow(label: '助教', value: '未設置'),
          ZuvioInfoRow(label: '修課人數', value: '64'),
        ],
      ),
      ZuvioInfoSection(
        title: '出席表現',
        rows: <ZuvioInfoRow>[
          ZuvioInfoRow(label: '準時', value: '9'),
          ZuvioInfoRow(label: '遲到', value: '1'),
          ZuvioInfoRow(label: '出席率', value: '100%'),
        ],
      ),
    ];
  }

  @override
  Future<List<ZuvioFeedbackMessage>> getFeedback(String courseId) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return <ZuvioFeedbackMessage>[
      ZuvioFeedbackMessage(
        content: '老師好，因專題發表今日無法參與課程',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        isMine: true,
      ),
    ];
  }

  @override
  Future<void> sendFeedback(String courseId, String text) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }
}
