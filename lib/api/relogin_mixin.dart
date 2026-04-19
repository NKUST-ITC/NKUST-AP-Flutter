import 'dart:async';
import 'dart:developer';

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
  /// How many initial session-expired errors should skip relogin when a
  /// successful login happened within [recentLoginWindow]. webap
  /// occasionally returns code 2 on the first query after a fresh
  /// session, and a short backoff is enough to recover without burning
  /// a captcha. Kept intentionally small (2) — observations show that
  /// if the first 1–2 retries don't recover the session, waiting
  /// longer doesn't help and only the real relogin path does. This
  /// budget is tracked SEPARATELY from [maxRelogins] so race-retry
  /// never starves the relogin path.
  static const int _raceConditionAttemptLimit = 2;

  Future<T> withAutoRelogin<T>({
    required Future<T> Function() action,
    required Future<void> Function() relogin,
    required bool Function(Object error) isSessionExpired,
    Duration retryDelay = const Duration(milliseconds: 500),
    Duration recentLoginWindow = const Duration(seconds: 30),
  }) async {
    int raceAttempts = 0;
    int reloginAttempts = 0;
    while (true) {
      try {
        return await action();
      } catch (e) {
        if (!isSessionExpired(e)) rethrow;

        final bool recentlyLoggedIn = _lastSuccessfulRelogin != null &&
            DateTime.now().difference(_lastSuccessfulRelogin!) <
                recentLoginWindow;
        log('[withAutoRelogin] race=$raceAttempts/$_raceConditionAttemptLimit '
            'relogin=$reloginAttempts/$maxRelogins '
            'recentlyLoggedIn=$recentlyLoggedIn '
            'trigger=${e.runtimeType}');

        if (recentlyLoggedIn &&
            raceAttempts < _raceConditionAttemptLimit) {
          // Short-circuit for the small server-side session-propagation
          // race (#342). Delay with exponential backoff (500ms → 1000ms)
          // and retry the same request without re-authenticating.
          raceAttempts++;
          final Duration delay = retryDelay * raceAttempts;
          log('[withAutoRelogin] → race-retry $raceAttempts/$_raceConditionAttemptLimit delay=${delay.inMilliseconds}ms');
          await Future<void>.delayed(delay);
          continue;
        }

        // Race budget exhausted (or we never qualified) — the session is
        // genuinely gone and only a real relogin will recover it.
        if (reloginAttempts >= maxRelogins) rethrow;
        reloginAttempts++;

        // Single-flight relogin: piggy-back on any in-progress relogin.
        // If it fails (e.g. wrong password), propagate the same failure to
        // all waiters instead of letting each one run its own retry budget
        // and trigger redundant captcha attempts.
        final Completer<void>? inFlight = _reloginInFlight;
        if (inFlight != null) {
          log('[withAutoRelogin] → await in-flight relogin');
          await inFlight.future;
          await Future<void>.delayed(retryDelay);
          continue;
        }

        log('[withAutoRelogin] → relogin $reloginAttempts/$maxRelogins');
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

// ApSessionExpiredException is part of the ApException hierarchy in
// lib/api/exceptions/api_exception.dart so UI layers that catch
// `on ApException catch` automatically cover the session-expired case
// when relogin retries are exhausted.
