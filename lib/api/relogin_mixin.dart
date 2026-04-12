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

  /// Executes [action] with automatic re-login on session expiry.
  ///
  /// When [isSessionExpired] returns true for a caught error:
  /// 1. Calls [relogin] to re-authenticate
  /// 2. Waits [retryDelay] to avoid server race conditions (#342)
  /// 3. Retries [action]
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
  }) async {
    int attempts = 0;
    while (true) {
      try {
        return await action();
      } catch (e) {
        if (isSessionExpired(e) && attempts < maxRelogins) {
          attempts++;
          await relogin();
          // Delay to avoid server session race condition:
          // The server may not have fully initialized the session yet after
          // a successful login POST. (#342)
          await Future<void>.delayed(retryDelay);
          continue;
        }
        rethrow;
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
