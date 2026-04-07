enum WebApSessionState {
  idle,
  authenticating,
  verifying,
  authenticated,
  expired,
  backoff,
  failed,
}

enum WebApServiceSessionState {
  cold,
  handshaking,
  ready,
  expired,
  failed,
}

enum WebApServiceType {
  leave,
  stdsys,
  mobile,
  oosaf,
}
