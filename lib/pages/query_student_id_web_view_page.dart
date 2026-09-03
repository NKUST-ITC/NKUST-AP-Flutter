import 'dart:convert';

import 'package:ap_common/ap_common.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nkust_ap/l10n/nkust_localizations.dart';
import 'package:nkust_crawler/nkust_crawler.dart';
import 'package:sprintf/sprintf.dart';

/// Drives the student-id lookup on stdsys inside a WebView and pops a
/// [StudentIdQueryResult].
///
/// The page is fronted by Cloudflare Turnstile and the token is verified
/// server-side, so a plain HTTP POST always comes back with
/// 「機器人驗證失敗」 — the challenge has to run in a real browser engine.
/// Id and birthday are injected from the native form so the only thing left
/// for the user is the challenge itself, and the form is submitted as soon as
/// Turnstile hands out a token (which for a non-interactive challenge means no
/// user action at all).
class QueryStudentIdWebViewPage extends StatefulWidget {
  const QueryStudentIdWebViewPage({
    super.key,
    required this.rocId,
    required this.birthday,
  });

  static const String routerName = '/queryStudentId';

  static const String queryUrl =
      'https://stdsys.nkust.edu.tw/student/QueryStudentId';
  static const String resultPath = '/student/QueryStudentId/ShowResult';

  /// 身分證號, goes into the `IdNo` field.
  final String rocId;

  /// Goes into the `Birthday` field as ROC-calendar `YYYMMDD`.
  final DateTime birthday;

  @override
  State<QueryStudentIdWebViewPage> createState() =>
      _QueryStudentIdWebViewPageState();
}

class _QueryStudentIdWebViewPageState extends State<QueryStudentIdWebViewPage> {
  /// Turnstile serves a different (or no) challenge to non-browser user
  /// agents, so keep a plain desktop Chrome string here.
  static const String _userAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';

  bool _finished = false;
  bool _isLoading = true;
  bool _hintShown = false;

  String get _birthdayText => sprintf('%03i%02i%02i', <int>[
        widget.birthday.year - 1911,
        widget.birthday.month,
        widget.birthday.day,
      ]);

  @override
  Widget build(BuildContext context) {
    final NkustLocalizations app = context.t;

    return Scaffold(
      appBar: AppBar(
        title: Text(app.studentIdQueryVerify),
        bottom: _isLoading
            ? const PreferredSize(
                preferredSize: Size.fromHeight(4),
                child: LinearProgressIndicator(minHeight: 4),
              )
            : null,
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(
          url: WebUri(QueryStudentIdWebViewPage.queryUrl),
        ),
        initialSettings: InAppWebViewSettings(
          userAgent: _userAgent,
          // Every attempt needs a fresh antiforgery cookie / token pair, and a
          // cached page would replay a spent Turnstile token.
          clearCache: true,
          // Turnstile renders the challenge in an iframe, which on Android is
          // a third-party context — WebView blocks its cookies by default and
          // the challenge then never completes.
          // https://developers.cloudflare.com/turnstile/get-started/mobile-implementation/
          thirdPartyCookiesEnabled: true,
          // Deliberately left off: the challenge builds nested `about:blank` /
          // `about:srcdoc` iframes and loads challenges.cloudflare.com in a
          // subframe. Any navigation interception has to let those through, so
          // the safest thing on a page that never links outwards is to not
          // intercept at all.
          useShouldOverrideUrlLoading: false,
        ),
        onLoadStart: (_, __) {
          if (mounted) setState(() => _isLoading = true);
        },
        onLoadStop: (InAppWebViewController controller, WebUri? url) async {
          if (mounted) setState(() => _isLoading = false);
          if (url == null) return;

          if (url.path == QueryStudentIdWebViewPage.resultPath) {
            await _finish(controller);
            return;
          }

          if (url.path == WebUri(QueryStudentIdWebViewPage.queryUrl).path) {
            await _fillForm(controller);
            await _autoSubmitWhenChallenged(controller);
            if (!_hintShown && mounted) {
              _hintShown = true;
              UiUtil.instance.showToast(context, app.studentIdQueryVerifyHint);
            }
          }
        },
        onReceivedError: (_, __, WebResourceError error) {
          if (mounted) setState(() => _isLoading = false);
          debugPrint('QueryStudentId onReceivedError: ${error.description}');
        },
      ),
    );
  }

  Future<void> _fillForm(InAppWebViewController controller) async {
    await controller.evaluateJavascript(
      source: '''
(function () {
  var id = document.getElementById('IdNo');
  var birthday = document.getElementById('Birthday');
  if (!id || !birthday) return;
  id.value = ${jsonEncode(widget.rocId)};
  birthday.value = ${jsonEncode(_birthdayText)};
  id.dispatchEvent(new Event('input', { bubbles: true }));
  birthday.dispatchEvent(new Event('input', { bubbles: true }));
})();
''',
    );
  }

  /// Submits the form once Turnstile writes its token into the hidden
  /// `cf-turnstile-response` field. There is no callback to hook into — the
  /// widget is rendered implicitly from `.cf-turnstile`, without
  /// `data-callback` — so polling the field is the only handle we get.
  Future<void> _autoSubmitWhenChallenged(
    InAppWebViewController controller,
  ) async {
    await controller.evaluateJavascript(
      source: '''
(function () {
  if (window.__nkustAutoSubmit) return;
  window.__nkustAutoSubmit = true;
  var timer = setInterval(function () {
    var token = document.querySelector('[name="cf-turnstile-response"]');
    var form = document.getElementById('LoginForm');
    if (!form || !token || !token.value) return;
    clearInterval(timer);
    form.submit();
  }, 300);
})();
''',
    );
  }

  Future<void> _finish(InAppWebViewController controller) async {
    if (_finished) return;
    _finished = true;

    final Object? html = await controller.evaluateJavascript(
      source: 'document.documentElement.outerHTML',
    );
    final StudentIdQueryResult result =
        StdsysParser.instance.queryStudentIdResultParser(html as String?);

    if (!mounted) return;
    Navigator.pop(context, result);
  }
}
