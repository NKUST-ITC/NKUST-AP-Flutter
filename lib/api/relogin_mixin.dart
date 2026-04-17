import 'dart:async';

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
///
/// Single-flight relogin: when multiple concurrent calls all see a session
/// expired error, only the first call actually performs [relogin]. Others
/// wait on the same in-flight [Completer] and then retry their own action.
/// This avoids hammering the login endpoint (and its captcha) with N parallel
/// login attempts when any app-start burst of requests all expire together.
mixin ReloginMixin {
  /// Maximum number of re-login attempts per call. Override in each helper.
  int get maxRelogins;

  /// Marks that a login has just succeeded. Call this from the login method
  /// so [withAutoRelogin] can distinguish race conditions from real expiry.
  /// Also broadcasts on [onReloginSuccess] so UI consumers can refresh data
  /// that was lost to an earlier exhausted-retry failure.
  void markReloginSuccess() {
    _lastSuccessfulRelogin = DateTime.now();
    _emitReloginSuccess();
  }

  /// Resets the relogin timestamp (e.g. on logout).
  void resetReloginState() {
    _lastSuccessfulRelogin = null;
  }

  /// Broadcast stream that fires whenever a relogin (or top-level login that
  /// called [markReloginSuccess]) completes successfully.
  ///
  /// Useful for UI layers: if a request gave up after [maxRelogins] attempts
  /// but a *later* unrelated request then succeeds in reauthenticating, the
  /// giver-upper can listen to this stream and retry itself.
  Stream<void> get onReloginSuccess => _reloginSuccessController.stream;

  final StreamController<void> _reloginSuccessController =
      StreamController<void>.broadcast();

  void _emitReloginSuccess() {
    if (!_reloginSuccessController.isClosed) {
      _reloginSuccessController.add(null);
    }
  }

  /// Tracks when the last successful login/re-login completed.
  ///
  /// Used to distinguish server race conditions from real session expiry:
  /// if we authenticated very recently yet receive a "session expired"
  /// response, the server likely hasn't finished initialising the session
  /// (race condition, see #342) — retrying with a delay is enough.
  DateTime? _lastSuccessfulRelogin;

  /// Holds the in-flight relogin [Completer] while a relogin is running.
  /// Concurrent callers awaiting session recovery wait on this future
  /// instead of launching their own relogin (single-flight pattern).
  Completer<void>? _reloginInFlight;

  /// Executes [action] with automatic re-login on session expiry.
  ///
  /// When [isSessionExpired] returns true for a caught error:
  /// - If the last successful login was within [recentLoginWindow], assumes
  ///   a server race condition and retries with only a delay (no re-login).
  /// - Otherwise, performs a single-flight [relogin]: the first caller runs
  ///   it, concurrent callers await the same future, then all retry.
  ///
  /// After [maxRelogins] attempts, the original error is rethrown.
  ///
  /// The retry counter is **per-call** (local variable), not shared across
  /// operations, so one failing operation cannot block others.
  ///
  /// **Contract:** the [relogin] callback is responsible for calling
  /// [markReloginSuccess] on successful authentication. This ensures both
  /// the race-condition timestamp and the [onReloginSuccess] broadcast stay
  /// consistent whether the login was triggered by top-level `login()` or
  /// by this method.
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

        if (recentlyLoggedIn && attempts <= 1) {
          // First retry after a recent login — likely a server race
          // condition (#342), not real session expiry. Just delay and
          // retry the request without re-authenticating.
          await Future<void>.delayed(retryDelay);
          continue;
        }

        // Single-flight relogin: piggy-back on any in-progress relogin.
        final Completer<void>? inFlight = _reloginInFlight;
        if (inFlight != null) {
          try {
            await inFlight.future;
          } catch (_) {
            // The in-flight relogin failed; the caller that started it
            // will rethrow its own error. We retry the loop, which will
            // either succeed (session may have recovered by another
            // path) or hit the next retry slot.
          }
          await Future<void>.delayed(retryDelay);
          continue;
        }

        final Completer<void> completer = Completer<void>();
        _reloginInFlight = completer;
        try {
          await relogin();
          // The relogin callback is expected to call [markReloginSuccess]
          // itself (see contract above), so we don't duplicate state updates
          // or event emissions here.
          completer.complete();
        } catch (err, st) {
          completer.completeError(err, st);
          rethrow;
        } finally {
          _reloginInFlight = null;
        }
        await Future<void>.delayed(retryDelay);
      }
    }
  }
}

/// Exception thrown when WebAP `apQuery` detects a session-expired response
/// (login parser returns code 2).
class ApSessionExpiredException implements Exception {
  const ApSessionExpiredException();

  @override
  String toString() =>
      'ApSessionExpiredException: WebAP session expired (code 2)';
}

/// Exception thrown when the Bus system returns a "未登入" (not logged in)
/// response.
class BusSessionExpiredException implements Exception {
  final String message;
  const BusSessionExpiredException(this.message);

  @override
  String toString() => 'BusSessionExpiredException: $message';
}
