import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:ap_common/ap_common.dart';
import 'package:ap_common_firebase/ap_common_firebase.dart';
import 'package:ap_common_plugin/ap_common_plugin.dart';
import 'package:flutter/cupertino.dart';
import 'package:nkust_ap/api/ap_helper.dart';
import 'package:nkust_ap/api/ap_status_code.dart';
import 'package:nkust_ap/api/bus_helper.dart';
import 'package:nkust_ap/api/leave_helper.dart';
import 'package:nkust_ap/api/mobile_nkust_helper.dart';
import 'package:nkust_ap/api/nkust_helper.dart';
import 'package:nkust_ap/api/stdsys_helper.dart';
import 'package:nkust_ap/models/booking_bus_data.dart';
import 'package:nkust_ap/models/bus_violation_records_data.dart';
import 'package:nkust_ap/models/cancel_bus_data.dart';
import 'package:nkust_ap/models/crawler_selector.dart';
import 'package:nkust_ap/models/leave_data.dart';
import 'package:nkust_ap/models/leave_submit_data.dart';
import 'package:nkust_ap/models/leave_submit_info_data.dart';
import 'package:nkust_ap/models/library_info_data.dart';
import 'package:nkust_ap/models/login_response.dart';
import 'package:nkust_ap/models/midterm_alerts_data.dart';
import 'package:nkust_ap/models/models.dart';
import 'package:nkust_ap/models/reward_and_penalty_data.dart';
import 'package:nkust_ap/models/room_data.dart';
import 'package:nkust_ap/models/server_info_data.dart';
import 'package:nkust_ap/utils/global.dart';

class Helper {
  static const String host = 'nkust.taki.dog';

  static const String version = 'v3';

  //LOGIN API
  static const int userDataError = 1401;

  static const String webap = 'webap';
  static const String inkust = 'inkust';
  static const String mobile = 'mobile';
  static const String stdsys = 'stdsys';
  static const String remoteConfig = 'config';

  static Helper? _instance;

  late Dio dio;

  late BaseOptions options;

  JsonCodec? jsonCodec;

  static CancelToken? cancelToken;

  static String? username;
  static String? password;

  static DateTime? expireTime;

  /// From sqflite plugin setting
  static bool isSupportCacheData = false;

  static CrawlerSelector? selector;

  int reLoginCount = 0;

  bool get canReLogin => reLoginCount == 0;

  bool isExpire() {
    if (expireTime == null) {
      return false;
    } else {
      return DateTime.now().isAfter(expireTime!.add(const Duration(hours: 8)));
    }
  }

  //ignore: prefer_constructors_over_static_methods
  static Helper get instance {
    return _instance ??= Helper();
  }

  Helper() {
    final String apiHost =
        PreferenceUtil.instance.getString(Constants.apiHost, host);
    dio = Dio(
      BaseOptions(
        baseUrl: 'https://$apiHost/$version',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
    cancelToken = CancelToken();
  }

  static void resetInstance() {
    _instance = Helper();
    cancelToken = CancelToken();
  }

  Future<LoginResponse?> login({
    required String username,
    required String password,
    bool clearCache = false,
  }) async {
    Helper.username = username.toUpperCase();
    Helper.password = password;
    LoginResponse? loginResponse;
    switch (selector?.login) {
      case mobile:
      case webap:
      default:
        if (selector != null && (selector!.login == mobile)) {
          loginResponse = await WebApHelper.instance.login(
            username: username.toUpperCase(),
            password: password,
          );
          await WebApHelper.instance.loginVms();
        } else {
          loginResponse = await WebApHelper.instance.login(
            username: username.toUpperCase(),
            password: password,
          );
        }
    }
    if (loginResponse != null) {
      expireTime = loginResponse.expireTime;
    }
    return loginResponse;
  }

  Future<LoginResponse> adminLogin(String username, String password) async {
    try {
      final Response<Map<String, dynamic>> response =
          await dio.post<Map<String, dynamic>>(
        '/oauth/admin/token',
        data: <String, String>{
          'username': username,
          'password': password,
        },
      );
      final LoginResponse loginResponse =
          LoginResponse.fromJson(response.data!);
      options.headers = _createBearerTokenAuth(loginResponse.token);
      expireTime = loginResponse.expireTime;
      Helper.username = username;
      Helper.password = password;
      return loginResponse;
    } catch (dioError) {
      rethrow;
    }
  }

  Future<Response<dynamic>> deleteToken() async {
    try {
      final Response<dynamic> response = await dio.delete(
        '/oauth/token',
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response<dynamic>> deleteAllToken() async {
    try {
      final Response<dynamic> response = await dio.delete(
        '/oauth/token/all',
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<ServerInfoData> getServerInfoData() async {
    try {
      final Response<Map<String, dynamic>> response =
          await dio.get<Map<String, dynamic>>('​/server​/info');
      return ServerInfoData.fromJson(response.data!);
    } on DioException {
      rethrow;
    }
  }

  Future<List<Announcement>> getAllAnnouncements({
    String? locale,
  }) async {
    final Response<Map<String, dynamic>> response =
        await dio.get<Map<String, dynamic>>(
      '/news/announcements/all',
      queryParameters: <String, String>{
        'lang': locale ?? '',
      },
    );
    AnnouncementData data = AnnouncementData(
      data: <Announcement>[],
    );
    if (response.statusCode != 204) {
      data = AnnouncementData.fromJson(response.data!);
      data.data.sort((Announcement a, Announcement b) {
        return b.weight.compareTo(a.weight);
      });
    }
    return data.data;
  }

  Future<Response<dynamic>> addAnnouncement(Announcement announcements) async {
    try {
      final Response<dynamic> response = await dio.post(
        '/news/announcements/add',
        data: announcements.toUpdateJson(),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response<dynamic>> updateAnnouncement(
    Announcement announcements,
  ) async {
    try {
      final Response<dynamic> response = await dio.put(
        '/news/announcements/update/${announcements.id}',
        data: announcements.toUpdateJson(),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<Response<dynamic>> deleteAnnouncement(
    Announcement announcements,
  ) async {
    try {
      final Response<dynamic> response = await dio.delete(
        '/news/announcements/remove/${announcements.id}',
        data: announcements.toUpdateJson(),
      );
      return response;
    } on DioException {
      rethrow;
    }
  }

  Future<UserInfo> getUsersInfo() async {
    UserInfo data;
    switch (selector?.userInfo) {
      case mobile:
        data = await MobileNkustHelper.instance.getUserInfo();
      case webap:
        data = await WebApHelper.instance.userInfoCrawler();
      case stdsys:
      default:
        data = await StdsysHelper.instance.getUserInfo();
    }
    reLoginCount = 0;
    if (data.id.isEmpty) {
      data = data.copyWith(
        id: username!,
      );
    }
    return data;
  }

  Future<Uint8List?> getUserPicture(String pictureUrl) async {
    switch (selector?.userInfo) {
      case mobile:
        return MobileNkustHelper.instance.getUserPicture();
      case webap:
        return WebApHelper.instance.getUserPicture(pictureUrl);
      case stdsys:
      default:
        return StdsysHelper.instance.getUserPicture(pictureUrl);
    }
  }

  Future<SemesterData> getSemester() async {
    SemesterData? data;
    switch (selector?.semester) {
      case remoteConfig:
        data = SemesterData.load();
        await Future<void>.delayed(const Duration(milliseconds: 100));
      case inkust:
        //TODO
        break;
      case mobile:
        //TODO
        break;
      case webap:
      default:
        data = await WebApHelper.instance.semesters();
    }
    reLoginCount = 0;
    if (data == null) {
      throw GeneralResponse.unknownError();
    }
    return data;
  }

  Future<ScoreData?> getScores({
    required Semester semester,
  }) async {
    ScoreData? data;
    switch (selector?.score) {
      case mobile:
        data = await MobileNkustHelper.instance.getScores(
          year: semester.year,
          semester: semester.value,
        );
      case inkust:
        //TODO
        break;
      case webap:
      default:
        data = await WebApHelper.instance.scores(
          semester.year,
          semester.value,
        );
    }
    if (data != null && data.scores.isEmpty) data = null;
    return data;
  }

  Future<CourseData> getCourseTables({
    required Semester semester,
    Semester? semesterDefault,
  }) async {
    CourseData data;
    switch (selector?.course) {
      case mobile:
        final bool isDefault = semesterDefault!.code == semester.code;
        data = await MobileNkustHelper.instance.getCourseTable(
          year: isDefault ? null : semester.year,
          semester: isDefault ? null : semester.value,
        );
      case webap:
        data = await WebApHelper.instance.getCourseTable(
          year: semester.year,
          semester: semester.value,
        );
      case stdsys:
      default:
        data = await StdsysHelper.instance.getCourseTable(
          year: semester.year,
          semester: semester.value,
        );
    }
    if (data.courses.isNotEmpty) {
      reLoginCount = 0;
    }
    return data;
  }

  Future<RewardAndPenaltyData> getRewardAndPenalty({
    required Semester semester,
  }) async {
    final RewardAndPenaltyData data =
        await WebApHelper.instance.rewardAndPenalty(
      semester.year,
      semester.value,
    );
    reLoginCount = 0;
    return data;
  }

  Future<MidtermAlertsData> getMidtermAlerts({
    required Semester semester,
  }) async {
    return await WebApHelper.instance.midtermAlerts(
      semester.year,
      semester.value,
    );
  }

  //1=建工/2=燕巢/3=第一/4=楠梓/5=旗津/6=東方
  Future<RoomData> getRoomList({
    required Semester semester,
    required int campusCode,
  }) async {
    final RoomData data = await StdsysHelper.instance
        .roomList('$campusCode', semester.year, semester.value);
    reLoginCount = 0;
    return data;
  }

  Future<CourseData> getRoomCourseTables({
    required String? roomId,
    required Semester semester,
  }) async {
    final CourseData data = await StdsysHelper.instance.roomCourseTableQuery(
      roomId,
      semester.year,
      semester.value,
    );
    reLoginCount = 0;
    return data;
  }

  Future<BusData> getBusTimeTables({
    required DateTime dateTime,
  }) async {
    if (!MobileNkustHelper.isSupport) {
      throw GeneralResponse.platformNotSupport();
    }
    final BusData data = await MobileNkustHelper.instance.busTimeTableQuery(
      fromDateTime: dateTime,
    );
    reLoginCount = 0;
    if (data.canReserve) {
      return data;
    } else {
      throw GeneralResponse(
        statusCode: 403,
        message: data.description!,
      );
    }
  }

  Future<BusReservationsData> getBusReservations() async {
    if (!MobileNkustHelper.isSupport) {
      throw GeneralResponse.platformNotSupport();
    }
    final BusReservationsData data =
        await MobileNkustHelper.instance.busUserRecord();
    reLoginCount = 0;
    return data;
  }

  Future<BookingBusData> bookingBusReservation({
    required String busId,
  }) async {
    if (!MobileNkustHelper.isSupport) {
      throw GeneralResponse.platformNotSupport();
    }
    final BookingBusData data =
        await MobileNkustHelper.instance.busBook(busId: busId);
    reLoginCount = 0;
    return data;
  }

  Future<CancelBusData> cancelBusReservation({
    required String cancelKey,
  }) async {
    if (!MobileNkustHelper.isSupport) {
      throw GeneralResponse.platformNotSupport();
    }
    final CancelBusData data =
        await MobileNkustHelper.instance.busUnBook(busId: cancelKey);
    reLoginCount = 0;
    return data;
  }

  Future<BusViolationRecordsData> getBusViolationRecords() async {
    if (!MobileNkustHelper.isSupport) {
      throw GeneralResponse.platformNotSupport();
    }
    final BusViolationRecordsData data =
        await MobileNkustHelper.instance.busViolationRecords();
    reLoginCount = 0;
    return data;
  }

  Future<NotificationsData> getNotifications({
    required int page,
  }) async {
    return await NKUSTHelper.instance.getNotifications(page);
  }

  Future<LeaveData> getLeaves({
    required Semester semester,
  }) async {
    return await LeaveHelper.instance
        .getLeaves(year: semester.year, semester: semester.value);
  }

  Future<LeaveSubmitInfoData> getLeavesSubmitInfo() async {
    return await LeaveHelper.instance.getLeavesSubmitInfo();
  }

  Future<Response<dynamic>?> sendLeavesSubmit({
    required LeaveSubmitData data,
    required XFile? image,
  }) async {
    return await LeaveHelper.instance.leavesSubmit(data, proofImage: image);
  }

  Future<LibraryInfo?> getLibraryInfo() async {
    try {
      final Response<Map<String, dynamic>> response =
          await dio.get<Map<String, dynamic>>(
        '/leaves/submit/info',
        cancelToken: cancelToken,
      );
      if (response.statusCode == 204) {
        return null;
      } else {
        return LibraryInfoData.fromJson(response.data!).data;
      }
    } on DioException {
      rethrow;
    }
  }

  // v3 api Authorization
  Map<String, dynamic> _createBearerTokenAuth(String? token) {
    return <String, String>{
      'Authorization': 'Bearer $token',
    };
  }

  static void clearSetting() {
    expireTime = null;
    username = null;
    password = null;
    ApCommonPlugin.clearCourseWidget();
    ApCommonPlugin.clearUserInfoWidget();
    WebApHelper.instance.logout();
    WebApHelper.instance.dioInit();
    WebApHelper.instance.isLogin = false;
    BusHelper.instance.isLogin = false;
    MobileNkustHelper.instance.cookiesData?.clear();
  }
}

extension NewsExtension on Announcement {
  Map<String, dynamic> toUpdateJson() => <String, dynamic>{
        'title': title,
        'weight': weight,
        'imgUrl': imgUrl,
        'url': url,
        'description': description,
        'expireTime': expireTime,
      };
}

extension DioErrorExtension on DioException {
  bool get hasResponse => type == DioExceptionType.badResponse;

  bool get isExpire => response!.statusCode == ApStatusCode.apiExpire;

  bool get isServerError =>
      response!.statusCode == ApStatusCode.schoolServerError ||
      response!.statusCode == ApStatusCode.apiServerError;

  GeneralResponse get serverErrorResponse {
    switch (response!.statusCode) {
      case ApStatusCode.apiServerError:
        return GeneralResponse(
          statusCode: ApStatusCode.apiServerError,
          message: 'api server error',
        );
      case ApStatusCode.schoolServerError:
      default:
        return GeneralResponse(
          statusCode: ApStatusCode.schoolServerError,
          message: 'shool server error',
        );
    }
  }
}

extension GeneralResponseExtension on GeneralResponse {
  String getGeneralMessage(
    BuildContext context,
  ) {
    String message = '';
    switch (statusCode) {
      case ApStatusCode.schoolServerError:
        message = ap.schoolServerError;
      case ApStatusCode.apiServerError:
        message = ap.schoolServerError;
      case ApStatusCode.apiExpire:
        message = ap.tokenExpiredContent;
      case GeneralResponse.platformNotSupportCode:
        message = ap.platformError;
      default:
        message = ap.unknownError;
    }
    AnalyticsUtil.instance.logApiEvent(
      'GeneralResponse',
      statusCode,
      message: message,
    );
    return message;
  }
}

extension SemesterExtension on Semester {
  String get cacheSaveTag => '${Helper.username}_$code';
}
