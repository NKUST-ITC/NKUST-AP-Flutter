import 'package:dio/dio.dart';
import 'package:nkust_ap/api/ap_status_code.dart';

/// Root of the typed exception hierarchy for crawler / login flows.
///
/// All helpers that can fail should throw a subtype of [ApException] so UI
/// layers can handle each failure mode with an appropriate message and
/// recovery action, instead of relying on brittle status-code mapping or
/// generic [Exception] instances.
sealed class ApException implements Exception {
  const ApException({
    required this.statusCode,
    this.message = '',
    this.cause,
    this.causeStackTrace,
  });

  /// App-internal status code (see [ApStatusCode]).
  final int statusCode;

  /// Human-readable diagnostic message (English, not user-facing —
  /// use the `toLocalizedMessage` extension for UI text).
  final String message;

  /// Underlying error that triggered this exception, if any.
  final Object? cause;
  final StackTrace? causeStackTrace;

  /// Concrete type name used by [toString]; override in each subtype so
  /// `runtimeType` is avoided (minified builds rename it).
  String get typeName;

  @override
  String toString() {
    final String base = '$typeName($statusCode)';
    if (message.isEmpty) return base;
    return '$base: $message';
  }
}

/// Why an authentication attempt failed.
enum AuthFailureReason {
  /// Wrong username or password, or account does not exist.
  invalidCredentials,

  /// Account has been locked after too many failed attempts.
  tooManyAttempts,

  /// Selected campus does not match the account (e.g. Bus 400 response).
  wrongCampus,

  /// Generic auth failure with no more specific reason known.
  unknown,
}

/// Authentication failed (wrong credentials, locked account, etc.).
///
/// Distinct from [NetworkException] and [ServerException]: the request
/// reached the server, parsed normally, and the server rejected the
/// credentials.
final class AuthException extends ApException {
  AuthException(
    this.reason, {
    int? statusCode,
    super.message = 'authentication failed',
    super.cause,
    super.causeStackTrace,
  }) : super(statusCode: statusCode ?? _defaultCodeFor(reason));

  final AuthFailureReason reason;

  @override
  String get typeName => 'AuthException';

  static int _defaultCodeFor(AuthFailureReason reason) {
    switch (reason) {
      case AuthFailureReason.invalidCredentials:
        return ApStatusCode.userDataError;
      case AuthFailureReason.tooManyAttempts:
        return ApStatusCode.passwordFiveTimesError;
      case AuthFailureReason.wrongCampus:
      case AuthFailureReason.unknown:
        return ApStatusCode.unknownError;
    }
  }
}

/// Transport-level failure: DNS, timeout, connection reset, SSL, etc.
/// The request could not be completed; no server response was received or
/// the response was malformed at the transport layer.
final class NetworkException extends ApException {
  const NetworkException({
    this.dioType,
    super.message = 'network error',
    super.cause,
    super.causeStackTrace,
  }) : super(statusCode: ApStatusCode.networkConnectFail);

  factory NetworkException.from(DioException e) => NetworkException(
        dioType: e.type,
        message: e.message ?? 'network error',
        cause: e,
        causeStackTrace: e.stackTrace,
      );

  final DioExceptionType? dioType;

  /// Whether [e] represents a transport-layer failure (no usable response
  /// was received), as opposed to an HTTP-level error the server
  /// actually produced. Callers short-circuit with [NetworkException.from]
  /// on `true` instead of interpreting the failure as e.g. a captcha retry.
  static bool isTransport(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.connectionError:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return true;
      case DioExceptionType.badResponse:
      case DioExceptionType.cancel:
        return false;
    }
  }

  @override
  String get typeName => 'NetworkException';
}

/// CAPTCHA could not be solved after the allowed attempts.
/// Typically bubbles up from OCR segmentation errors or repeated rejection
/// by the server.
final class CaptchaException extends ApException {
  const CaptchaException({
    this.attempts = 1,
    super.message = 'captcha solving failed',
    super.cause,
    super.causeStackTrace,
  }) : super(statusCode: ApStatusCode.unknownError);

  /// Number of captcha attempts that were exhausted.
  final int attempts;

  @override
  String get typeName => 'CaptchaException';
}

/// Server returned an error response (500 / 503 / malformed HTML).
/// Distinct from [NetworkException]: the round-trip succeeded but the
/// server could not produce a usable response.
final class ServerException extends ApException {
  ServerException({
    int? statusCode,
    this.httpStatusCode,
    super.message = 'server error',
    super.cause,
    super.causeStackTrace,
  }) : super(statusCode: statusCode ?? ApStatusCode.schoolServerError);

  /// Raw HTTP status if known (may differ from [statusCode] which is the
  /// app-internal [ApStatusCode] mapping).
  final int? httpStatusCode;

  @override
  String get typeName => 'ServerException';
}

/// The user cancelled the flow (e.g. closed the WebView login page, or
/// dismissed a confirmation dialog).
final class CancelledException extends ApException {
  const CancelledException({
    super.message = 'cancelled',
  }) : super(statusCode: ApStatusCode.cancel);

  @override
  String get typeName => 'CancelledException';
}

/// Server indicated the current session has expired and a re-login is
/// required (e.g. WebAP login parser returns code 2, Bus system returns
/// "未登入"). Usually caught and handled by [ReloginMixin.withAutoRelogin];
/// only escapes to the UI when all relogin attempts have been exhausted.
final class ApSessionExpiredException extends ApException {
  const ApSessionExpiredException()
      : super(
          statusCode: ApStatusCode.apiExpire,
          message: 'WebAP session expired (code 2)',
        );

  @override
  String get typeName => 'ApSessionExpiredException';
}

/// Bus-system variant of [ApSessionExpiredException]. Kept distinct so
/// [BusHelper] can match only its own session errors without accidentally
/// reacting to WebAP's.
final class BusSessionExpiredException extends ApException {
  const BusSessionExpiredException(String message)
      : super(statusCode: ApStatusCode.apiExpire, message: message);

  @override
  String get typeName => 'BusSessionExpiredException';
}

/// Feature not usable on the current platform/campus configuration
/// (e.g. bus system on web, or a sub-system the user's campus doesn't
/// have access to).
final class PlatformUnsupportedException extends ApException {
  const PlatformUnsupportedException({
    super.message = 'feature not supported on this platform',
  }) : super(statusCode: ApStatusCode.unknownError);

  @override
  String get typeName => 'PlatformUnsupportedException';
}

/// Translates the transport / HTTP failure captured by Dio into the
/// appropriate [ApException] subtype so callers can use a single
/// `on ApException catch` clause instead of handling DioException
/// separately in every UI page.
extension DioExceptionToApException on DioException {
  ApException toApException() {
    if (type == DioExceptionType.cancel) {
      return const CancelledException(message: 'request cancelled');
    }
    if (NetworkException.isTransport(this)) {
      return NetworkException.from(this);
    }
    // DioExceptionType.badResponse — server responded with a non-2xx.
    return ServerException(
      httpStatusCode: response?.statusCode,
      message: message ?? 'server error',
      cause: this,
      causeStackTrace: stackTrace,
    );
  }
}
