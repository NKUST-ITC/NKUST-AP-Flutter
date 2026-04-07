/// Represents the lifecycle of the shared WebAP crawler session.
///
/// Transitions:
///   idle → loggingIn          (ensureAuthenticated() kicks off a login)
///   loggingIn → verifying     (perchk.jsp returned code 0)
///   verifying → authenticated (post-login probe confirmed session is ready)
///   verifying → idle          (probe failed all retries → outer login loop retries)
///   authenticated → expired   (apQuery received code 2 mid-flight)
///   expired → loggingIn       (ensureAuthenticated() starts a new login)
///   any → idle                (logout() / clearSetting())
enum WebApSessionState {
  idle,
  loggingIn,
  verifying,
  authenticated,
  expired,
}
