/// Sealed class hierarchy for explicitly modeling scraper session states.
///
/// Replaces the scattered login state that was previously spread across:
/// - `Helper.username/password/expireTime` (static fields)
/// - `WebApHelper.isLogin` (bool)
/// - `BusHelper.isLogin` (bool)
/// - `LeaveHelper.isLogin` (bool?)
/// - `MobileNkustHelper.cookiesData` (cookie-based)
sealed class ScraperSessionState {
  const ScraperSessionState();
}

/// No active session. Initial state and state after logout.
class Unauthenticated extends ScraperSessionState {
  const Unauthenticated();
}

/// Successfully authenticated with a valid session.
class Authenticated extends ScraperSessionState {
  final String username;
  final DateTime expireTime;

  const Authenticated({
    required this.username,
    required this.expireTime,
  });

  /// Whether the session has expired (8-hour window from [expireTime]).
  bool get isExpired => DateTime.now().isAfter(
        expireTime.add(const Duration(hours: 8)),
      );
}

/// Authentication attempt failed.
class AuthenticationFailed extends ScraperSessionState {
  final int statusCode;
  final String message;

  const AuthenticationFailed({
    required this.statusCode,
    required this.message,
  });
}
