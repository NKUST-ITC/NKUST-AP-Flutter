import 'dart:developer';

import 'package:ap_common/ap_common.dart';
import 'package:nkust_ap/l10n/nkust_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nkust_ap/api/leave_helper.dart';

/// Single stable Chrome UA used by the leave.nkust.edu.tw WebView login
/// flow. Previously came from [MobileNkustHelper.userAgentList]'s random
/// rotation — inlined here after the mobile.nkust.edu.tw scraper was
/// removed, since leave is the only remaining surface that still needs
/// a browser-shaped UA string.
const String _leaveLoginUserAgent =
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
    '(KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';

class LeaveNkustPage extends StatefulWidget {
  final String username;
  final String password;
  final bool clearCache;

  const LeaveNkustPage({
    super.key,
    required this.username,
    required this.password,
    this.clearCache = false,
  });

  @override
  LeaveNkustPageState createState() => LeaveNkustPageState();
}

class LeaveNkustPageState extends State<LeaveNkustPage> {
  late NkustLocalizations app;
  late InAppWebViewController webViewController;
  bool finish = false;

  @override
  Widget build(BuildContext context) {
    app = context.t;
    return Scaffold(
      appBar: AppBar(
        title: Text(app.loginAuth),
        actions: [
          TextButton(
            onPressed: () {
              DialogUtils.showDefault(
                context: context,
                title: app.loginAuth,
                content: app.mobileNkustLoginDescription,
              );
            },
            child: Text(app.clickShowDescription),
          ),
        ],
      ),
      floatingActionButton: kDebugMode
          ? FloatingActionButton(
              child: const Icon(Icons.done_outline),
              onPressed: () async {},
            )
          : null,
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(LeaveHelper.basePath)),
        initialSettings: InAppWebViewSettings(
          clearCache: widget.clearCache,
          userAgent: _leaveLoginUserAgent,
        ),
        onWebViewCreated: (controller) {
          webViewController = controller;
          UiUtil.instance.showToast(context, app.mobileNkustLoginHint);
        },
        onJsPrompt: (controller, jsPromptRequest) async => null,
        onPageCommitVisible: (controller, title) async {
          final uri = await controller.getUrl();
          debugPrint('onPageCommitVisible $title $uri');
        },
        onTitleChanged: (controller, title) async {
          final uri = await controller.getUrl();
          debugPrint('onTitleChanged $title $uri');
          if (uri.toString() == LeaveHelper.home) {
            _finishLogin();
          }
        },
        onLoadStop: (controller, title) async {
          final uri = await controller.getUrl();
          debugPrint('onLoadStop $title $uri');
          if (uri.toString() == LeaveHelper.basePath) {
            await webViewController.evaluateJavascript(
              source:
                  'document.getElementsByName("Login1\$UserName")[0].value = "${widget.username}";',
            );
            await webViewController.evaluateJavascript(
              source:
                  'document.getElementsByName("Login1\$Password")[0].value = "${widget.password}";',
            );
          }
        },
      ),
    );
  }

  Future<void> _finishLogin() async {
    if (finish) return;
    finish = true;
    final cookies = await CookieManager.instance().getCookies(
      url: WebUri(LeaveHelper.basePath),
    );
    for (final element in cookies) {
      LeaveHelper.instance.setCookie(
        LeaveHelper.basePath,
        cookieName: element.name,
        cookieValue: element.value.toString(),
        cookieDomain: element.domain ??
            (element.name == 'ASP.NET_SessionId'
                ? 'leave.nkust.edu.tw'
                : '.nkust.edu.tw'),
      );
      if (kDebugMode) {
        log(
          'Cookie: ${element.name}: ${element.value} ${element.domain} ${element.expiresDate}',
        );
      }
    }
    if (!mounted) return;
    Navigator.pop(context, true);
  }
}
