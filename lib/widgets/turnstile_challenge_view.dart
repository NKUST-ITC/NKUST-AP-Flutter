import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nkust_crawler/nkust_crawler.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

/// Inline Cloudflare Turnstile challenge, sized to the widget itself.
///
/// Turnstile only issues a token to a real browser engine, so the challenge
/// has to run in a WebView — but it belongs inside the form the user is
/// filling in, not behind a page transition. This loads the school's query
/// page, hides everything except the challenge, and reports the token up so
/// the surrounding native form can submit over HTTP.
class TurnstileChallengeView extends StatefulWidget {
  const TurnstileChallengeView({
    super.key,
    required this.onToken,
    this.onError,
    this.height = 84,
    this.useMinimalPage = true,
  });

  /// Called with a fresh token every time the challenge resolves, and with
  /// `null` when the previous token expired and the widget reset itself.
  final ValueChanged<String?> onToken;

  /// Cloudflare's own error code, for surfacing why the challenge failed.
  final ValueChanged<String>? onError;

  final double height;

  /// Hosts the challenge on a minimal page of our own instead of loading the
  /// school's 12KB query page (which drags in admin-lte, font-awesome and
  /// sweetalert2 just to draw one widget).
  ///
  /// A Turnstile sitekey is tied to an allowed-hostname list held in the
  /// school's Cloudflare dashboard, so the page still has to *look* like it
  /// came from `stdsys.nkust.edu.tw` — hence the `baseUrl`. If Cloudflare
  /// rejects the spoofed origin it answers with error 110200 (invalid
  /// domain); set this to false to go back to loading the real page.
  final bool useMinimalPage;

  @override
  State<TurnstileChallengeView> createState() => TurnstileChallengeViewState();
}

class TurnstileChallengeViewState extends State<TurnstileChallengeView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      // The user agent is deliberately left alone. Claiming desktop Chrome
      // from a mobile WebView leaves navigator and client hints inconsistent
      // with the actual engine, which Turnstile scores as a spoofed browser
      // and fails the challenge outright.
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..addJavaScriptChannel(
        'TurnstileToken',
        onMessageReceived: (JavaScriptMessage message) =>
            widget.onToken(message.message),
      )
      ..addJavaScriptChannel(
        'TurnstileExpired',
        onMessageReceived: (_) => widget.onToken(null),
      )
      ..addJavaScriptChannel(
        'TurnstileError',
        onMessageReceived: (JavaScriptMessage message) {
          debugPrint('[turnstile] error=${message.message}');
          widget.onError?.call(message.message);
        },
      )
      // Navigation is deliberately not intercepted. The challenge builds
      // nested `about:blank` / `about:srcdoc` iframes and loads
      // `challenges.cloudflare.com` in a subframe, all of which Cloudflare
      // requires be allowed.
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) => _renderChallenge(),
          onWebResourceError: (WebResourceError error) {
            debugPrint('[turnstile] resource error ${error.description}');
          },
        ),
      );
    reload();
  }

  /// Loads a clean copy of the page and re-arms the challenge. The caller
  /// owns clearing whatever token it still holds — notifying from here would
  /// mean calling back into the parent while it is still building.
  Future<void> reload() async {
    await _enableAndroidThirdPartyCookies();
    // A cached page would come back with a spent challenge.
    await _controller.clearCache();

    if (widget.useMinimalPage) {
      await _controller.loadHtmlString(
        _minimalPage,
        baseUrl: StudentIdQueryHelper.queryUrl,
      );
      return;
    }

    await _controller.loadRequest(Uri.parse(StudentIdQueryHelper.queryUrl));
  }

  /// Carries the same `.cf-turnstile` placeholder the school's page uses, so
  /// the injected render script works unchanged for either page source.
  static const String _minimalPage = '''
<!DOCTYPE html>
<html lang="zh-TW">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<script src="https://challenges.cloudflare.com/turnstile/v0/api.js" async defer></script>
<style>html,body{margin:0;padding:0;background:transparent}</style>
</head>
<body>
<div class="cf-turnstile" data-sitekey="${StudentIdQueryHelper.turnstileSiteKey}"></div>
</body>
</html>
''';

  /// Android WebView blocks third-party cookies by default for targetSdk 21+,
  /// and the Turnstile challenge runs inside an iframe — a third-party context
  /// whose cookies being dropped makes the challenge unsolvable.
  /// https://developers.cloudflare.com/turnstile/get-started/mobile-implementation/
  Future<void> _enableAndroidThirdPartyCookies() async {
    if (!Platform.isAndroid) return;
    final controller = _controller.platform;
    final cookieManager = WebViewCookieManager().platform;
    if (controller is AndroidWebViewController &&
        cookieManager is AndroidWebViewCookieManager) {
      await cookieManager.setAcceptThirdPartyCookies(controller, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: WebViewWidget(controller: _controller),
    );
  }

  /// Strips the page down to the challenge and renders it explicitly.
  ///
  /// The page ships `.cf-turnstile` without `data-callback`, so implicit
  /// rendering hands back nothing: the token could only be scraped by polling
  /// the hidden field, and a failure shows up as 「驗證失敗」 with the error
  /// code buried in a cross-origin iframe. Rendering it ourselves also gets
  /// the expiry callback, which matters for an inline widget that may sit
  /// idle past the token's 300 second lifetime.
  Future<void> _renderChallenge() async {
    await _controller.runJavaScript('''
(function () {
  if (window.__nkustChallenge) return;

  function report(code) {
    TurnstileError.postMessage(String(code));
  }

  function setup() {
    var placeholder = document.querySelector('.cf-turnstile');
    if (!placeholder) return true;
    if (!window.turnstile || !window.turnstile.render) return false;

    window.__nkustChallenge = true;

    // Everything but the challenge lives in the native form.
    var style = document.createElement('style');
    style.textContent =
      'body > * { display: none !important; }' +
      '#nkust-challenge { display: block !important; margin: 0; padding: 0; }' +
      'body { background: transparent !important; margin: 0; padding: 0; }';
    document.head.appendChild(style);

    var holder = document.createElement('div');
    holder.id = 'nkust-challenge';
    var sitekey = placeholder.getAttribute('data-sitekey');
    document.body.appendChild(holder);
    placeholder.remove();

    try {
      window.turnstile.render(holder, {
        sitekey: sitekey,
        callback: function (token) { TurnstileToken.postMessage(token); },
        'expired-callback': function () { TurnstileExpired.postMessage(''); },
        'error-callback': function (code) { report(code); return true; },
        'timeout-callback': function () { report('timeout'); }
      });
    } catch (error) {
      report(error && error.message ? error.message : error);
    }
    return true;
  }

  if (setup()) return;
  // api.js is loaded async/defer, so it may not be there yet.
  var tries = 0;
  var timer = setInterval(function () {
    if (setup() || ++tries > 40) clearInterval(timer);
  }, 250);
})();
''');
  }
}
