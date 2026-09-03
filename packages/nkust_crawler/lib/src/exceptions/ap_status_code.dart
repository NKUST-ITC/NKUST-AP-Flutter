class ApStatusCode {
  //After re-login fail.
  static const int networkConnectFail = 5000;

  //LOGIN API
  static const int cancel = 100;
  static const int userDataError = 1401;
  static const int unknownError = 1402;
  static const int passwordFiveTimesError = 1405;

  /// Session expired — used by [ApSessionExpiredException]. Matches
  /// HTTP 401 numerically for backwards compatibility with earlier
  /// status-code dumps, but is conceptually independent of any
  /// HTTP-layer meaning now that the app is crawler-only.
  static const int sessionExpired = 401;
  static const int schoolServerError = 503;
}
