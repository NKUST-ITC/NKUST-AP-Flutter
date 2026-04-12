import 'package:ap_common/ap_common.dart';
import 'package:nkust_ap/api/ap_status_code.dart';

/// Mixin for handling session-level re-login when a scraper session expires.
///
/// This is distinct from HTTP-level retry (handled by [RetryInterceptor] in
/// api_config.dart which retries on timeout/5xx errors). This mixin handles
/// the case where the HTTP request succeeds but the server response indicates
/// the session has expired (e.g., WebAP returns code 2, Bus returns "未登入").
///
/// Fixes #342: The previous implementation used a `static` counter
/// (`reLoginReTryCounts`) shared across ALL operations. When one operation
/// exhausted the retry limit, ALL subsequent operations would immediately fail.
/// This mixin uses **per-call** counting so operations are independent.
mixin ReloginMixin {
  /// Maximum number of re-login attempts per call. Override in each helper.
  int get maxRelogins;

  /// Marks that a login has just succeeded. Call this from the login method
  /// so [withAutoRelogin] can distinguish race conditions from real expiry.
  void markReloginSuccess() {
    _lastSuccessfulRelogin = DateTime.now();
  }

  /// Resets the relogin timestamp (e.g. on logout).
  void resetReloginState() {
    _lastSuccessfulRelogin = null;
  }

  /// Tracks when the last successful login/re-login completed.
  ///
  /// Used to distinguish server race conditions from real session expiry:
  /// if we authenticated very recently yet receive a "session expired"
  /// response, the server likely hasn't finished initialising the session
  /// (race condition, see #342) — retrying with a delay is enough.
  DateTime? _lastSuccessfulRelogin;

  /// Executes [action] with automatic re-login on session expiry.
  ///
  /// When [isSessionExpired] returns true for a caught error:
  /// - If the last successful login was within [recentLoginWindow], assumes
  ///   a server race condition and retries with only a delay (no re-login).
  /// - Otherwise, calls [relogin] to re-authenticate, then retries.
  ///
  /// After [maxRelogins] attempts, the original error is rethrown.
  ///
  /// The retry counter is **per-call** (local variable), not shared across
  /// operations, so one failing operation cannot block others.
  Future<T> withAutoRelogin<T>({
    required Future<T> Function() action,
    required Future<void> Function() relogin,
    required bool Function(Object error) isSessionExpired,
    Duration retryDelay = const Duration(milliseconds: 500),
    Duration recentLoginWindow = const Duration(seconds: 30),
  }) async {
    int attempts = 0;
    while (true) {
      try {
        return await action();
      } catch (e) {
        if (!isSessionExpired(e) || attempts >= maxRelogins) rethrow;
        attempts++;

        final bool recentlyLoggedIn = _lastSuccessfulRelogin != null &&
            DateTime.now().difference(_lastSuccessfulRelogin!) <
                recentLoginWindow;

        if (recentlyLoggedIn) {
          // Logged in recently — likely a server race condition (#342),
          // not real session expiry. Just delay and retry the request.
          await Future<void>.delayed(retryDelay);
        } else {
          // Session actually expired — re-authenticate first.
          await relogin();
          _lastSuccessfulRelogin = DateTime.now();
          await Future<void>.delayed(retryDelay);
        }
      }
    }
  }
}

/// Exception thrown when WebAP `apQuery` detects a session-expired response
/// (login parser returns code 2).
class ApSessionExpiredException implements Exception {
  const ApSessionExpiredException();

  @override
  String toString() => 'ApSessionExpiredException: WebAP session expired (code 2)';
}

/// Exception thrown when the Bus system returns a "未登入" (not logged in)
/// response.
class BusSessionExpiredException implements Exception {
  final String message;
  const BusSessionExpiredException(this.message);

  @override
  String toString() => 'BusSessionExpiredException: $message';
}
