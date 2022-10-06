class ApStatusCode {
  //After re-login fail.
  static const int networkConnectFail = 5000;

  //LOGIN API
  static const int cancel = 100;
  static const int userDataError = 1401;
  static const int unknownError = 1402;

  //Common
  static const int apiExpire = 401;
  static const int apiServerError = 500;
  static const int schoolServerError = 503;
}
