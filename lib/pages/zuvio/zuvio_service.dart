import 'dart:typed_data';

import 'package:ap_common/ap_common.dart';
import 'package:ap_common_firebase/ap_common_firebase.dart';
import 'package:nkust_ap/pages/zuvio/zuvio_models.dart';
import 'package:zuvio_crawler/zuvio_crawler.dart' as zc;

/// UI-facing wrapper over the live [zc.ZuvioHelper] scraper. Every call
/// here performs a real request against `irs.zuvio.com.tw`.
abstract class ZuvioService {
  static ZuvioService instance = ZuvioCrawlerService();

  bool get isLogin;

  Future<void> login({required String email, required String password});

  Future<void> logout();

  Future<List<ZuvioCourse>> getCourses();

  Future<ZuvioRollcall> getCurrentRollcall(String courseId);

  Future<void> makeRollcall({
    required String rollcallId,
    double? latitude,
    double? longitude,
  });

  Future<ZuvioClickerQuestion?> getLiveClicker(String courseId);

  Future<List<ZuvioHistoryFolder>> getAnswerFolders(String courseId);

  Future<List<ZuvioQuestion>> getQuestions(String courseId, String folderId);

  Future<ZuvioQuestionDetail?> getQuestionDetail(String questionId);

  Future<List<ZuvioAttendanceRecord>> getAttendanceHistory(String courseId);

  Future<List<ZuvioBulletin>> getBulletins(String courseId);

  Future<ZuvioBulletin?> getBulletinDetail(String bulletinId);

  /// Downloads [attachment] through the authenticated session and
  /// returns its bytes. Do not pass [ZuvioAttachment.url] itself to an
  /// external browser/share sheet — it carries the session token in its
  /// query string.
  Future<Uint8List> downloadAttachment(ZuvioAttachment attachment);

  Future<List<ZuvioInfoSection>> getCourseInfo(String courseId);

  Future<List<ZuvioFeedbackMessage>> getFeedback(String courseId);

  Future<void> sendFeedback(String courseId, String text);

  Future<ZuvioFeedbackThread?> getFeedbackThread(String feedbackId);
}

/// [code] is a stable machine token the UI can translate; [message] is a
/// human-readable fallback (already localized, or the raw upstream text
/// when there is no code).
class ZuvioException implements Exception {
  const ZuvioException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => message;
}

/// Machine tokens for [ZuvioException.code].
abstract final class ZuvioErrorCode {
  static const String auth = 'auth';
  static const String sessionExpired = 'session_expired';
  static const String network = 'network';
  static const String unexpected = 'unexpected';
  static const String rollcallNotOnair = 'rollcall_not_onair';
  static const String rollcallNeedLocation = 'rollcall_need_location';
  static const String rollcallAnswered = 'rollcall_answered';
  static const String rollcallExpired = 'rollcall_expired';
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
  Future<void> logout() => _helper.logout();

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
              pinned: c.pinned,
              unreadCount: c.unreadCount,
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
    double? latitude,
    double? longitude,
  }) {
    return _run(() async {
      final zc.ZuvioRollcallResult result = await _helper.makeRollcall(
        rollcallId: rollcallId,
        latitude: latitude,
        longitude: longitude,
      );
      if (!result.success) {
        throw ZuvioException(
          result.message,
          code: _rollcallCode(result.message),
        );
      }
    });
  }

  String? _rollcallCode(String raw) {
    return switch (raw.trim().toUpperCase()) {
      'ROLLCALL IS NOT ONAIR' => ZuvioErrorCode.rollcallNotOnair,
      'LOSE THE GPS LOCATION' => ZuvioErrorCode.rollcallNeedLocation,
      'ROLLCALL IS ANSWERED' => ZuvioErrorCode.rollcallAnswered,
      'ROLLCALL IS EXPIRED' => ZuvioErrorCode.rollcallExpired,
      _ => null,
    };
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
  Future<List<ZuvioHistoryFolder>> getAnswerFolders(String courseId) {
    return _run(() async {
      final List<zc.ZuvioHistoryEntry> data =
          await _helper.getAnswerHistory(courseId);
      return data
          .map(
            (zc.ZuvioHistoryEntry e) =>
                ZuvioHistoryFolder(folderId: e.folderId, title: e.title),
          )
          .toList();
    });
  }

  @override
  Future<List<ZuvioQuestion>> getQuestions(
    String courseId,
    String folderId,
  ) {
    return _run(() async {
      final List<zc.ZuvioQuestion> data =
          await _helper.getQuestions(courseId, folderId);
      return data.map(_question).toList();
    });
  }

  @override
  Future<ZuvioQuestionDetail?> getQuestionDetail(String questionId) {
    return _run(() async {
      final zc.ZuvioQuestionDetail? d =
          await _helper.getQuestionDetail(questionId);
      if (d == null) return null;
      return ZuvioQuestionDetail(
        type: d.type,
        kind: switch (d.kind) {
          zc.ZuvioQuestionKind.single => ZuvioQuestionKind.single,
          zc.ZuvioQuestionKind.multiple => ZuvioQuestionKind.multiple,
          zc.ZuvioQuestionKind.essay => ZuvioQuestionKind.essay,
        },
        text: d.text,
        result: _qResult(d.result),
        essayAnswer: d.essayAnswer,
        options: d.options
            .map(
              (zc.ZuvioQuestionOption o) => ZuvioQuestionOption(
                order: o.order,
                text: o.text,
                isCorrect: o.isCorrect,
                isSelected: o.isSelected,
              ),
            )
            .toList(),
      );
    });
  }

  ZuvioQuestion _question(zc.ZuvioQuestion q) {
    return ZuvioQuestion(
      id: q.id,
      type: q.type,
      text: q.text,
      result: _qResult(q.result),
    );
  }

  ZuvioQuestionResult _qResult(zc.ZuvioQuestionResult r) {
    return switch (r) {
      zc.ZuvioQuestionResult.correct => ZuvioQuestionResult.correct,
      zc.ZuvioQuestionResult.wrong => ZuvioQuestionResult.wrong,
      zc.ZuvioQuestionResult.unanswered => ZuvioQuestionResult.unanswered,
      zc.ZuvioQuestionResult.submitted => ZuvioQuestionResult.submitted,
    };
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
      return data.map(_bulletin).toList();
    });
  }

  @override
  Future<ZuvioBulletin?> getBulletinDetail(String bulletinId) {
    return _run(() async {
      final zc.ZuvioBulletin? b =
          await _helper.getBulletinDetail(bulletinId);
      return b == null ? null : _bulletin(b);
    });
  }

  @override
  Future<Uint8List> downloadAttachment(ZuvioAttachment attachment) {
    return _run(() async {
      final List<int> bytes =
          await _helper.downloadAttachment(attachment.url);
      return Uint8List.fromList(bytes);
    });
  }

  ZuvioBulletin _bulletin(zc.ZuvioBulletin b) {
    return ZuvioBulletin(
      id: b.id,
      author: b.author,
      date: b.date ?? DateTime.now(),
      title: b.title,
      content: b.content,
      attachments: b.attachments
          .map(
            (zc.ZuvioAttachment a) =>
                ZuvioAttachment(name: a.name, url: a.url),
          )
          .toList(),
    );
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
              id: m.id,
              content: m.content,
              createdAt: m.createdAt,
              isMine: m.isMine,
              replied: m.replied,
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

  @override
  Future<ZuvioFeedbackThread?> getFeedbackThread(String feedbackId) {
    return _run(() async {
      final zc.ZuvioFeedbackThread? t =
          await _helper.getFeedbackThread(feedbackId);
      if (t == null) return null;
      return ZuvioFeedbackThread(
        question: t.question,
        questionAt: t.questionAt,
        reply: t.reply,
        replyAuthor: t.replyAuthor,
        replyAt: t.replyAt,
      );
    });
  }

  ZuvioAnswerStatus _status(zc.ZuvioAnswerStatus s) {
    return switch (s) {
      zc.ZuvioAnswerStatus.onTime => ZuvioAnswerStatus.onTime,
      zc.ZuvioAnswerStatus.late => ZuvioAnswerStatus.late,
      zc.ZuvioAnswerStatus.missed => ZuvioAnswerStatus.missed,
      zc.ZuvioAnswerStatus.unknown => ZuvioAnswerStatus.unknown,
    };
  }

  Future<T> _run<T>(Future<T> Function() body) async {
    try {
      return await body();
    } on ZuvioException {
      // Already an app-level failure raised inside [body]; pass through.
      rethrow;
    } on zc.ZuvioAuthException catch (e) {
      throw ZuvioException(e.message, code: ZuvioErrorCode.auth);
    } on zc.ZuvioSessionExpiredException catch (e) {
      throw ZuvioException(e.message, code: ZuvioErrorCode.sessionExpired);
    } on zc.ZuvioNetworkException catch (e) {
      throw ZuvioException(e.message, code: ZuvioErrorCode.network);
    } on zc.ZuvioException catch (e, s) {
      // Unexpected: parse failure or a shape Zuvio changed under us.
      _report(e, s, 'zuvio scrape failed');
      throw ZuvioException(e.message, code: ZuvioErrorCode.unexpected);
    } catch (e, s) {
      _report(e, s, 'zuvio unexpected error');
      throw ZuvioException(e.toString(), code: ZuvioErrorCode.unexpected);
    }
  }

  void _report(Object error, StackTrace stack, String reason) {
    if (!FirebaseCrashlyticsUtils.isSupported) return;
    CrashlyticsUtil.instance.recordError(error, stack, reason: reason);
  }
}
