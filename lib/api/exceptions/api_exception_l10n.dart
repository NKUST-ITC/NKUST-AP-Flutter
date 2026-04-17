import 'package:ap_common/ap_common.dart';
import 'package:flutter/widgets.dart';
import 'package:nkust_ap/api/exceptions/api_exception.dart';
import 'package:nkust_ap/l10n/l10n.dart';

/// Maps a typed [ApException] to the best-fit user-facing message, pulling
/// from both the shared [ApLocalizations] (ap_common) and the project's own
/// [AppLocalizations] so project-specific strings such as
/// `loginFailedFiveTimes` can be reached.
extension ApExceptionL10n on ApException {
  String toLocalizedMessage(BuildContext context) {
    final ApLocalizations ap = ApLocalizations.of(context);
    final AppLocalizations app = AppLocalizations.of(context);
    final ApException self = this;
    switch (self) {
      case AuthException():
        switch (self.reason) {
          case AuthFailureReason.invalidCredentials:
            return ap.loginFail;
          case AuthFailureReason.tooManyAttempts:
            return app.loginFailedFiveTimes;
          case AuthFailureReason.wrongCampus:
            return ap.campusNotSupport;
          case AuthFailureReason.unknown:
            return ap.somethingError;
        }
      case NetworkException():
        return ap.noInternet;
      case CaptchaException():
        return ap.captchaError;
      case ServerException():
        if (self.httpStatusCode == 503) return ap.schoolServerError;
        if (self.httpStatusCode == 500) return ap.apiServerError;
        return ap.schoolServerError;
      case CancelledException():
        return ap.loginFail;
    }
  }
}
