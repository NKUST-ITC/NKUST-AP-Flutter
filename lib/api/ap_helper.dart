//dio
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/cupertino.dart';

//overwrite origin Cookie Manager.
import 'package:nkust_ap/api/private_cookie_manager.dart';

//parser
import 'package:nkust_ap/api/parser/ap_parser.dart';

//Config
import 'package:nkust_ap/config/constants.dart';

//Model
import 'package:ap_common/models/user_info.dart';
import 'package:ap_common/models/score_data.dart';
import 'package:ap_common/models/course_data.dart';
import 'package:nkust_ap/models/semester_data.dart';
import 'package:nkust_ap/models/midterm_alerts_data.dart';
import 'package:nkust_ap/models/reward_and_penalty_data.dart';
import 'package:nkust_ap/models/room_data.dart';

// callback
import 'package:ap_common/callback/general_callback.dart';

class WebApHelper {
  static Dio dio;
  static WebApHelper _instance;
  static CookieJar cookieJar;
  static String username;
  static String password;

  int reLoginReTryCounts = 3;
  int timeoutMs = 5000;
  bool isLogin;

  //LOGIN API
  static const USER_DATA_ERROR = 1401;

  static WebApHelper get instance {
    if (_instance == null) {
      _instance = WebApHelper();
      dio = Dio();
      cookieJar = CookieJar();
      dioInit();
    }
    return _instance;
  }

  void setProxy(String proxyIP) {
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (client) {
      client.findProxy = (uri) {
        return "PROXY " + proxyIP;
      };
    };
  }

  static dioInit() {
    // Use PrivateCookieManager to overwrite origin CookieManager, because
    // Cookie name of the NKUST ap system not follow the RFC6265. :(
    dio.interceptors.add(
      PrivateCookieManager(cookieJar),
    );
    dio.options.headers['user-agent'] =
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/84.0.4147.89 Safari/537.36';
    dio.options.headers['Connection'] = 'close';
    dio.options.connectTimeout = Constants.TIMEOUT_MS;
    dio.options.receiveTimeout = Constants.TIMEOUT_MS;
  }

  Future<int> apLogin({
    @required String username,
    @required String password,
    GeneralCallback<int> callback,
  }) async {
    //
    /*
    Retrun type Int
    0 : Login Success
    1 : Password error or not found user
    2 : Relogin
    3 : Not found login message
    */

    try {
      Response res = await dio.post(
        "https://webap.nkust.edu.tw/nkust/perchk.jsp",
        data: {"uid": username, "pwd": password},
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      WebApHelper.username = username;
      WebApHelper.password = password;
      switch (apLoginParser(res.data)) {
        case 0:
          callback.onSuccess(0);
          break;
        case 1:
          callback?.onError(
            GeneralResponse(
              statusCode: USER_DATA_ERROR,
              message: 'username or password error',
            ),
          );
          break;
      }
    } on DioError catch (e) {
      if (e.type == DioErrorType.RESPONSE && e.response.statusCode == 401) {
      } else
        callback?.onFailure(e);
    } catch (e) {
      callback?.onError(
        GeneralResponse.unknownError(),
      );
      throw e;
    }
    return null;
  }

  Future<Response> apQuery(
      String queryQid, Map<String, String> queryData) async {
    /*
    Retrun type Response <Dio>
    */
    String url =
        "https://webap.nkust.edu.tw/nkust/${queryQid.substring(0, 2)}_pro/${queryQid}.jsp";

    Response request = await dio.post(
      url,
      data: queryData,
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    return request;
  }

  Future<UserInfo> userInfoCrawler() async {
    /*
    Retrun type ResponseData
    errorCode:
    2000   succss.

    5000   NKUST server error.
    5002   Dio error, maybe NKUST server error.
    5040   Timeout.
    5400   Something error.

    */
    var query = await apQuery("ag003", null);

    return UserInfo.fromJson(
      apUserInfoParser(query.data),
    );
  }

  Future<SemesterData> semesters() async {
    /*
    Return type ResponseData
    errorCode:
    2000   succss.

    5000   NKUST server error.
    5002   Dio error, maybe NKUST server error.
    5040   Timeout.
    5400   Something error.

    */

    var query = await apQuery("ag304_01", null);

    return SemesterData.fromJson(
      semestersParser(query.data),
    );
  }

  Future<ScoreData> scores(String years, String semesterValue) async {
    /*
    Retrun type ResponseData
    errorCode:
    2000   succss.

    5000   NKUST server error.
    5002   Dio error, maybe NKUST server error.
    5040   Timeout.
    5400   Something error.

    */
    var query = await apQuery(
      "ag008",
      {"arg01": years, "arg02": semesterValue},
    );

    return ScoreData.fromJson(query.data);
  }

  Future<CourseData> coursetable(String years, String semesterValue) async {
    /*
    Retrun type ResponseData
    errorCode:
    2000   succss.

    5000   NKUST server error.
    5002   Dio error, maybe NKUST server error.
    5040   Timeout.
    5400   Something error.

    */
    var query = await apQuery(
      "ag222",
      {"arg01": years, "arg02": semesterValue},
    );

    return CourseData.fromJson(
      coursetableParser(query.data),
    );
  }

  Future<MidtermAlertsData> midtermAlerts(
      String years, String semesterValue) async {
    /*
    Retrun type ResponseData
    errorCode:
    2000   succss.

    5000   NKUST server error.
    5002   Dio error, maybe NKUST server error.
    5040   Timeout.
    5400   Something error.

    */

    var query = await apQuery(
      "ag009",
      {"arg01": years, "arg02": semesterValue},
    );

    return MidtermAlertsData.fromJson(
      midtermAlertsParser(query.data),
    );
  }

  Future<RewardAndPenaltyData> rewardAndPenalty(
      String years, String semesterValue) async {
    /*
    Retrun type ResponseData
    errorCode:
    2000   succss.

    5000   NKUST server error.
    5002   Dio error, maybe NKUST server error.
    5040   Timeout.
    5400   Something error.

    */
    var query = await apQuery(
      "ak010",
      {"arg01": years, "arg02": semesterValue},
    );

    return RewardAndPenaltyData.fromJson(
      rewardAndPenaltyParser(query.data),
    );
  }

  Future<RoomData> roomList(String cmpAreaId) async {
    /*
    Retrun type ResponseData
    errorCode:
    2000   succss.

    5000   NKUST server error.
    5002   Dio error, maybe NKUST server error.
    5040   Timeout.
    5400   Something error.

    cmpAreaId
    1=建工/2=燕巢/3=第一/4=楠梓/5=旗津
    */
    var query = await apQuery(
      "ag302_01",
      {"cmp_area_id": cmpAreaId},
    );

    return RoomData.fromJson(
      roomListParser(query.data),
    );
  }

  Future<CourseData> roomCourseTableQuery(
      String roomId, String years, String semesterValue) async {
    /*
    Retrun type ResponseData
    errorCode:
    2000   succss.

    5000   NKUST server error.
    5002   Dio error, maybe NKUST server error.
    5040   Timeout.
    5400   Something error.
    */
    var query = await apQuery(
      "ag302_02",
      {"room_id": roomId, "yms_yms": "${years}#${semesterValue}"},
    );

    return CourseData.fromJson(
      roomCourseTableQueryParser(query.data),
    );
  }
}
