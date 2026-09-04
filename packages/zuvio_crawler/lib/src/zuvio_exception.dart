class ZuvioException implements Exception {
  const ZuvioException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => 'ZuvioException: $message';
}

class ZuvioAuthException extends ZuvioException {
  const ZuvioAuthException(super.message, {super.cause});
}

class ZuvioSessionExpiredException extends ZuvioException {
  const ZuvioSessionExpiredException([
    super.message = 'zuvio session expired',
  ]);
}

class ZuvioNetworkException extends ZuvioException {
  const ZuvioNetworkException(super.message, {super.cause});
}
