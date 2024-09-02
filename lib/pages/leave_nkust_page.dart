import 'dart:developer';

import 'package:ap_common/resources/ap_theme.dart';
import 'package:ap_common/utils/ap_utils.dart';
import 'package:ap_common/utils/dialog_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nkust_ap/api/leave_helper.dart';
import 'package:nkust_ap/api/mobile_nkust_helper.dart';
import 'package:nkust_ap/models/mobile_cookies_data.dart';
import 'package:nkust_ap/utils/app_localizations.dart';

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
  _LeaveNkustPageState createState() => _LeaveNkustPageState();
}

class _LeaveNkustPageState extends State<LeaveNkustPage> {
  late AppLocalizations app;

  late InAppWebViewController webViewController;

  bool finish = false;

  @override
  Widget build(BuildContext context) {
    app = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(app.loginAuth),
        backgroundColor: ApTheme.of(context).blue,
        actions: <Widget>[
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
              onPressed: () async {
                // final html = await webViewController.getHtml();
                // debugPrint(html);
              },
            )
          : null,
      body: InAppWebView(
        initialUrlRequest: URLRequest(
          url: WebUri(LeaveHelper.basePath),
        ),
        initialSettings: InAppWebViewSettings(
          clearCache: widget.clearCache,
          userAgent: MobileNkustHelper.instance.userAgent,
        ),
        onWebViewCreated: (InAppWebViewController webViewController) {
          this.webViewController = webViewController;
          ApUtils.showToast(context, app.mobileNkustLoginHint);
        },
        onJsPrompt: (
          InAppWebViewController controller,
          JsPromptRequest jsPromptRequest,
        ) async {
          return;
        },
        onPageCommitVisible:
            (InAppWebViewController controller, Uri? title) async {
          final Uri? uri = await controller.getUrl();
          debugPrint('onPageCommitVisible $title $uri');
          // await webViewController.evaluateJavascript(
          //     source:
          //         r'$.getScript("https://cdnjs.cloudflare.com/ajax/libs/vConsole/3.4.0/vconsole.min.js", function() {var vConsole = new VConsole();});');
        },
        onTitleChanged:
            (InAppWebViewController controller, String? title) async {
          final Uri? uri = await controller.getUrl();
          debugPrint('onTitleChanged $title $uri');
          if (uri.toString() == LeaveHelper.home) {
            _finishLogin();
          }
        },
        onLoadStop: (InAppWebViewController controller, Uri? title) async {
          final Uri? uri = await controller.getUrl();
          debugPrint('onLoadStop $title $uri');
          if (uri.toString() == LeaveHelper.basePath) {
            await webViewController.evaluateJavascript(
              source: 'document.getElementsByName("Login1\$UserName")[0].value'
                  ' = "${widget.username}";',
            );
            await webViewController.evaluateJavascript(
              source: 'document.getElementsByName("Login1\$Password")[0].value'
                  ' = "${widget.password}";',
            );
          }
        },
      ),
    );
  }

  Future<void> _finishLogin() async {
    if (finish) {
      return;
    } else {
      finish = true;
    }
    final List<Cookie> cookies = await CookieManager.instance().getCookies(
      url: WebUri(LeaveHelper.basePath),
    );
    final MobileCookiesData data = MobileCookiesData(
      cookies: <MobileCookies>[],
    );
    for (final Cookie element in cookies) {
      data.cookies.add(
        MobileCookies(
          path: MobileNkustHelper.homeUrl,
          name: element.name,
          value: element.value.toString(),
          domain: element.domain ??
              (element.name == 'ASP.NET_SessionId'
                  ? 'leave.nkust.edu.tw'
                  : '.nkust.edu.tw'),
        ),
      );
      if (kDebugMode) {
        log(
          'Cookie: ${element.name}: '
          '${element.value} ${element.domain} ${element.expiresDate} \n',
        );
      }
    }
    LeaveHelper.instance.setCookieFromData(data);
    if (!mounted) return;
    Navigator.pop(context, true);
  }
}
