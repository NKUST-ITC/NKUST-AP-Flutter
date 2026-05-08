import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:ap_common_core/ap_common_core.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:nkust_crawler/src/helpers/ap_helper.dart';
import 'package:nkust_crawler/src/capabilities/course_provider.dart';
import 'package:nkust_crawler/src/capabilities/score_provider.dart';
import 'package:nkust_crawler/src/capabilities/semester_provider.dart';
import 'package:nkust_crawler/src/capabilities/user_info_provider.dart';
import 'package:nkust_crawler/src/facade/helper.dart';
import 'package:nkust_crawler/src/parsers/stdsys_parser.dart';
import 'package:nkust_crawler/src/models/room_data.dart';
import 'package:nkust_crawler/src/abstractions/pdf_text_extractor.dart';

enum EnrollmentLetterLang {
  chinese,
  english;

  String get _path => switch (this) {
        EnrollmentLetterLang.chinese => 'ChinesePDF',
        EnrollmentLetterLang.english => 'EnglishPDF',
      };
}

class StdsysHelper
    implements CourseProvider, ScoreProvider, UserInfoProvider, SemesterProvider {
  /// The [WebApHelper] instance this helper depends on for Dio and cookie
  /// management.
  final WebApHelper _webApHelper;

  StdsysHelper(this._webApHelper);

  static StdsysHelper? _instance;
  // ignore: prefer_constructors_over_static_methods
  static StdsysHelper get instance {
    return _instance ??= StdsysHelper(WebApHelper.instance);
  }

  Dio get dio => _webApHelper.dio;
  CookieJar get cookieJar => _webApHelper.cookieJar;

  /// Decoder for transcript PDFs returned by stdsys. Wired at bootstrap;
  /// score lookup throws if it isn't.
  PdfTextExtractor? pdfTextExtractor;

  Future<Response<Uint8List>> getEnrollmentLetter([
    EnrollmentLetterLang lang = EnrollmentLetterLang.chinese,
  ]) async {
    await _webApHelper.loginToStdsys();

    final List<Cookie> cookies = await cookieJar
        .loadForRequest(Uri.parse('https://stdsys.nkust.edu.tw'));
    final String cookieHeader = cookies
        .map((Cookie cookie) => '${cookie.name}=${cookie.value}')
        .join('; ');

    final Response<Uint8List> response = await dio.get<Uint8List>(
      'https://stdsys.nkust.edu.tw/student/Doc/Status/${lang._path}',
      options: Options(
        responseType: ResponseType.bytes,
        headers: <String, dynamic>{
          'Referer': 'https://stdsys.nkust.edu.tw/student/Doc/Status',
          'Cookie': cookieHeader,
        },
      ),
    );
    return response;
  }

  Future<RoomData> roomList(
    String campusId,
    String? schoolYear,
    String? semester,
  ) async {
    await _webApHelper.loginToStdsys();

    final List<Cookie> cookies = await cookieJar
        .loadForRequest(Uri.parse('https://stdsys.nkust.edu.tw'));
    final String cookieHeader = cookies
        .map((Cookie cookie) => '${cookie.name}=${cookie.value}')
        .join('; ');

    final Response<String> response = await dio.get<String>(
      'https://stdsys.nkust.edu.tw/student/TimeTable/RoomTimeTable/GetRoomList/',
      queryParameters: <String, dynamic>{
        'fgShowAll': 'False',
        'fgEnable': 'True',
        'fgShowCode': 'False',
        'fgFilterByRole': 'True',
        'fgSchoolAllQuery': 'False',
        'sort': '',
        'group': '',
        'filter': "Value~eq~'1'",
        'schoolYear': schoolYear,
        'semester': semester,
        'campusId': campusId,
      },
      options: Options(
        responseType: ResponseType.plain,
        headers: <String, dynamic>{
          'Referer':
              'https://stdsys.nkust.edu.tw/student/TimeTable/RoomTimeTable',
          'Cookie': cookieHeader,
        },
      ),
    );

    return RoomData.fromJson(
      StdsysParser.instance.roomListParser(response.data),
    );
  }

  Future<CourseData> roomCourseTableQuery(
    String? roomId,
    String? years,
    String? semesterValue,
  ) async {
    await _webApHelper.loginToStdsys();

    final List<Cookie> cookies = await cookieJar
        .loadForRequest(Uri.parse('https://stdsys.nkust.edu.tw'));
    final String cookieHeader = cookies
        .map((Cookie cookie) => '${cookie.name}=${cookie.value}')
        .join('; ');

    final Response<String> response = await dio.get<String>(
      'https://stdsys.nkust.edu.tw/student/TimeTable/RoomTimeTable/GetScheduleByRoom',
      queryParameters: <String, dynamic>{
        'id': '$years;$semesterValue;$roomId',
      },
      options: Options(
        responseType: ResponseType.plain,
        headers: <String, dynamic>{
          'Referer':
              'https://stdsys.nkust.edu.tw/student/TimeTable/RoomTimeTable',
          'Cookie': cookieHeader,
        },
      ),
    );

    return CourseData.fromJson(
      StdsysParser.instance.roomCourseTableQueryParser(response.data),
    );
  }

  Future<CourseData> getCourseTable({
    String? year,
    String? semester,
  }) async {
    await _webApHelper.loginToStdsys();

    // 先 GET 表單頁，讓 server 種下 .AspNetCore.Antiforgery.* 與 XSRF-TOKEN
    // cookie，後續 POST 才有 antiforgery token 可帶。
    await dio.get<String>(
      'https://stdsys.nkust.edu.tw/student/Course/StudentCourseList',
      options: Options(responseType: ResponseType.plain),
    );

    final List<Cookie> cookies = await cookieJar
        .loadForRequest(Uri.parse('https://stdsys.nkust.edu.tw'));
    final String cookieHeader = cookies
        .map((Cookie cookie) => '${cookie.name}=${cookie.value}')
        .join('; ');
    final String? xsrfToken = cookies
        .where((Cookie cookie) => cookie.name == 'XSRF-TOKEN')
        .map((Cookie cookie) => cookie.value)
        .firstOrNull;

    // schoolYearSms 格式：學年-學期，例如 "114-2"
    final String schoolYearSms = '$year-$semester';

    try {
      final Response<String> response = await dio.post<String>(
        'https://stdsys.nkust.edu.tw/student/Course/StudentCourseList/Query',
        data: 'schoolYearSms=$schoolYearSms',
        options: Options(
          responseType: ResponseType.plain,
          contentType: 'application/x-www-form-urlencoded',
          headers: <String, dynamic>{
            'Accept': '*/*',
            'Origin': 'https://stdsys.nkust.edu.tw',
            'Referer':
                'https://stdsys.nkust.edu.tw/student/Course/StudentCourseList',
            'X-Requested-With': 'XMLHttpRequest',
            if (xsrfToken != null) 'X-XSRF-TOKEN': xsrfToken,
            'Cookie': cookieHeader,
          },
        ),
      );

      return CourseData.fromJson(
        StdsysParser.instance.studentCourseTableParser(response.data),
      );
    } on DioException catch (e) {
      // 當傳入無課程的學期時，會回傳 500
      if (e.response?.statusCode == 500) {
        return CourseData.empty();
      }
      rethrow;
    }
  }

  Future<UserInfo> getUserInfo() async {
    await _webApHelper.loginToStdsys();

    final List<Cookie> cookies = await cookieJar
        .loadForRequest(Uri.parse('https://stdsys.nkust.edu.tw'));
    final String cookieHeader = cookies
        .map((Cookie cookie) => '${cookie.name}=${cookie.value}')
        .join('; ');

    final Response<String> response = await dio.get<String>(
      'https://stdsys.nkust.edu.tw/Student/Register/StudentDataQuery',
      options: Options(
        responseType: ResponseType.plain,
        contentType: 'application/x-www-form-urlencoded',
        headers: <String, dynamic>{
          'Referer': 'https://stdsys.nkust.edu.tw/student',
          'Cookie': cookieHeader,
        },
      ),
    );

    final UserInfo data = StdsysParser.userInfoParser(response.data);
    return data;
  }

  @override
  Future<Uint8List?> getUserPicture(String? pictureUrl) async {
    if (pictureUrl == null) return null;
    dio.options.headers['Accept'] =
        'image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8';
    final Response<Uint8List> response = await dio.get<Uint8List>(
      pictureUrl,
      options: Options(
        responseType: ResponseType.bytes,
      ),
    );
    return response.data;
  }

  Future<SemesterData?> getSemesters() async {
    await _webApHelper.loginToStdsys();

    // Same antiforgery dance as getCourseTable: GET a stdsys page first
    // so the server seeds .AspNetCore.Antiforgery.* / XSRF-TOKEN cookies,
    // then echo the XSRF-TOKEN back as both the X-XSRF-TOKEN header and
    // X-Requested-With: XMLHttpRequest. Without this the WebCode/*
    // endpoints respond 400 Bad Request with an empty body.
    await dio.get<String>(
      'https://stdsys.nkust.edu.tw/student/Course/StudentCourseList',
      options: Options(responseType: ResponseType.plain),
    );

    final List<Cookie> cookies = await cookieJar
        .loadForRequest(Uri.parse('https://stdsys.nkust.edu.tw'));
    final String cookieHeader = cookies
        .map((Cookie cookie) => '${cookie.name}=${cookie.value}')
        .join('; ');
    final String? xsrfToken = cookies
        .where((Cookie cookie) => cookie.name == 'XSRF-TOKEN')
        .map((Cookie cookie) => cookie.value)
        .firstOrNull;

    final Response<String> response = await dio.post<String>(
      'https://stdsys.nkust.edu.tw/student/WebCode/GetSchoolYearSmsCodes',
      queryParameters: <String, dynamic>{
        'stdId': Helper.username,
      },
      options: Options(
        responseType: ResponseType.plain,
        headers: <String, dynamic>{
          'Accept': '*/*',
          'Origin': 'https://stdsys.nkust.edu.tw',
          'Referer':
              'https://stdsys.nkust.edu.tw/student/Course/StudentCourseList',
          'X-Requested-With': 'XMLHttpRequest',
          if (xsrfToken != null) 'X-XSRF-TOKEN': xsrfToken,
          'Cookie': cookieHeader,
        },
      ),
    );

    final Map<String, dynamic> json =
        StdsysParser.instance.semesterParser(response.data);
    return SemesterData.fromJson(json);
  }

  Future<Response<Uint8List>> getSingleTranscript(
      String? year, String? semester,
      [bool showRank = true]) async {
    await _webApHelper.loginToStdsys();

    final List<Cookie> cookies = await cookieJar
        .loadForRequest(Uri.parse('https://stdsys.nkust.edu.tw'));
    final String cookieHeader = cookies
        .map((Cookie cookie) => '${cookie.name}=${cookie.value}')
        .join('; ');

    final Response<Uint8List> response = await dio.get<Uint8List>(
      'https://stdsys.nkust.edu.tw/student/Score/SingleSemesterTranscript/PrintTranscript?YM=$year$semester&ShowRank=$showRank',
      options: Options(
        responseType: ResponseType.bytes,
        headers: <String, dynamic>{
          'Cookie': cookieHeader,
        },
      ),
    );
    return response;
  }

  Future<Response<Uint8List>> getHistoryTranscript(
      String? year, String? semester,
      [bool showRank = true]) async {
    await _webApHelper.loginToStdsys();

    final List<Cookie> cookies = await cookieJar
        .loadForRequest(Uri.parse('https://stdsys.nkust.edu.tw'));
    final String cookieHeader = cookies
        .map((Cookie cookie) => '${cookie.name}=${cookie.value}')
        .join('; ');

    final Response<Uint8List> response = await dio.get<Uint8List>(
      'https://stdsys.nkust.edu.tw/student/Score/HistoryTranscript/PrintTranscript?YM=$year$semester&ShowRank=$showRank',
      options: Options(
        responseType: ResponseType.bytes,
        headers: <String, dynamic>{
          'Cookie': cookieHeader,
        },
      ),
    );
    return response;
  }

  String parsePdfText(Response<Uint8List> rawpdf) {
    final extractor = pdfTextExtractor;
    if (extractor == null) {
      throw StateError(
        'StdsysHelper.pdfTextExtractor is not configured. '
        'Wire a PdfTextExtractor implementation at app bootstrap.',
      );
    }
    return extractor.extract(rawpdf.data!);
  }

  Future<ScoreData> getScoresByYearSemester(
    String? year,
    String? semester,
  ) async {
    final Response<Uint8List> rawpdf =
        await getSingleTranscript(year, semester);

    try {
      final String parsed = parsePdfText(rawpdf);
      return ScoreData.fromJson(
        StdsysParser.instance.scoresParser(parsed),
      );
    } catch (e) {
      return ScoreData.empty();
    }
  }

  @override
  Future<ScoreData?> getScores({
    required String year,
    required String semester,
  }) =>
      getScoresByYearSemester(year, semester);
}
