import 'package:zuvio_crawler/src/models/models.dart';
import 'package:zuvio_crawler/src/parsers/bulletin_parser.dart';
import 'package:zuvio_crawler/src/parsers/clicker_parser.dart';
import 'package:zuvio_crawler/src/parsers/course_info_parser.dart';
import 'package:zuvio_crawler/src/parsers/course_parser.dart';
import 'package:zuvio_crawler/src/parsers/feedback_parser.dart';
import 'package:zuvio_crawler/src/parsers/history_parser.dart';
import 'package:zuvio_crawler/src/parsers/question_parser.dart';
import 'package:zuvio_crawler/src/parsers/rollcall_parser.dart';
import 'package:zuvio_crawler/src/zuvio_client.dart';

/// The single entry point the host app talks to. Wraps a [ZuvioClient]
/// and the stateless parsers.
class ZuvioHelper {
  ZuvioHelper({ZuvioClient? client}) : client = client ?? ZuvioClient();

  final ZuvioClient client;

  bool get isLogin => client.isLogin;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    await client.login(email: email, password: password);
  }

  Future<void> logout() => client.logout();

  Future<List<ZuvioCourse>> getCourses() async {
    final Map<String, dynamic> json =
        await client.getJson('course/listStudentFullCourses');
    return parseCourseList(json);
  }

  Future<ZuvioRollcall> getCurrentRollcall(String courseId) async {
    final String html = await client.getHtml(
      'student5/irs/rollcall/$courseId',
      headers: <String, String>{
        'Referer':
            '${ZuvioClient.baseUrl}student5/irs/clickers/$courseId',
      },
    );
    return parseRollcall(html);
  }

  /// Submits `app_v2/makeRollcall`. [latitude] / [longitude] are only
  /// needed for GPS rollcalls; a plain (non-GPS) rollcall accepts empty
  /// coordinates. The raw `msg` (e.g. `ROLLCALL IS NOT ONAIR`,
  /// `LOSE THE GPS LOCATION`) is surfaced untranslated so the host app
  /// can localize it.
  Future<ZuvioRollcallResult> makeRollcall({
    required String rollcallId,
    double? latitude,
    double? longitude,
  }) async {
    final Map<String, dynamic> json = await client.postJson(
      'app_v2/makeRollcall',
      <String, dynamic>{
        'rollcall_id': rollcallId,
        'device': 'WEB',
        'lat': latitude ?? '',
        'lng': longitude ?? '',
      },
    );
    return ZuvioRollcallResult.fromJson(json);
  }

  Future<ZuvioClickerQuestion?> getLiveClicker(String courseId) async {
    final String html =
        await client.getHtml('student5/irs/clickers/$courseId');
    return parseLiveClicker(html);
  }

  Future<List<ZuvioHistoryEntry>> getAnswerHistory(String courseId) async {
    final String html =
        await client.getHtml('student5/irs/history/$courseId/0');
    return parseAnswerFolders(html);
  }

  Future<List<ZuvioAttendanceRecord>> getAttendanceHistory(
    String courseId,
  ) async {
    final String html =
        await client.getHtml('student5/irs/history/$courseId/0');
    return parseAttendanceHistory(html);
  }

  Future<List<ZuvioBulletin>> getBulletins(String courseId) async {
    final String html =
        await client.getHtml('student5/irs/course/$courseId/0');
    return parseBulletins(html);
  }

  Future<ZuvioBulletin?> getBulletinDetail(String bulletinId) async {
    final String html =
        await client.getHtml('student5/irs/bulletin/$bulletinId');
    final ZuvioBulletin? b = parseBulletinDetail(html, id: bulletinId);
    if (b == null || b.attachments.isEmpty) return b;
    return ZuvioBulletin(
      id: b.id,
      author: b.author,
      title: b.title,
      content: b.content,
      date: b.date,
      attachments: b.attachments
          .map(
            (ZuvioAttachment a) => ZuvioAttachment(
              name: a.name,
              url: client.proxyDownloadUrl(a.url, a.name),
            ),
          )
          .toList(),
    );
  }

  Future<List<ZuvioQuestion>> getQuestions(
    String courseId,
    String folderId,
  ) async {
    final String html =
        await client.getHtml('student5/irs/questions/$courseId/$folderId');
    return parseQuestionList(html);
  }

  Future<ZuvioQuestionDetail?> getQuestionDetail(String questionId) async {
    final String html =
        await client.getHtml('student5/irs/question/$questionId');
    return parseQuestionDetail(html);
  }

  Future<ZuvioFeedbackThread?> getFeedbackThread(String feedbackId) async {
    final String html =
        await client.getHtml('student5/irs/feedback/$feedbackId');
    return parseFeedbackThread(html);
  }

  Future<ZuvioCourseInfo> getCourseInfo(String courseId) async {
    final String html =
        await client.getHtml('student5/irs/course/$courseId/1');
    return parseCourseInfo(html);
  }

  /// The 私訊老師 feed. [offset] pages older messages.
  Future<List<ZuvioFeedbackMessage>> getFeedback(
    String courseId, {
    int offset = 0,
  }) async {
    final Map<String, dynamic> json = await client.postJson(
      'app_v2/getFeedbackList',
      <String, dynamic>{
        'course_id': courseId,
        'offset': offset,
      },
    );
    return parseFeedbackList(json);
  }
}
