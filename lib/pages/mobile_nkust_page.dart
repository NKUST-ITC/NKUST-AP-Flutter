import 'dart:developer';

import 'package:ap_common/ap_common.dart';
import 'package:nkust_ap/utils/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nkust_ap/api/mobile_nkust_helper.dart';
import 'package:nkust_ap/config/constants.dart';
import 'package:nkust_ap/models/mobile_cookies_data.dart';

class MobileNkustPage extends StatefulWidget {
  final String? username;
  final String? password;
  final bool clearCache;

  const MobileNkustPage({
    super.key,
    this.username,
    this.password,
    this.clearCache = false,
  });

  @override
  MobileNkustPageState createState() => MobileNkustPageState();
}

class MobileNkustPageState extends State<MobileNkustPage> {
  late AppLocalizations app;
  late InAppWebViewController webViewController;
  bool finish = false;

  @override
  Widget build(BuildContext context) {
    app = AppLocalizations.of(context);
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
        initialUrlRequest: URLRequest(url: WebUri(MobileNkustHelper.loginUrl)),
        initialSettings: InAppWebViewSettings(
          clearCache: widget.clearCache,
          userAgent: MobileNkustHelper.instance.userAgent,
        ),
        onWebViewCreated: (controller) {
          webViewController = controller;
          UiUtil.instance.showToast(context, app.mobileNkustLoginHint);
        },
        onJsPrompt: (controller, jsPromptRequest) async => null,
        onPageCommitVisible: (controller, title) async {
          final uri = await controller.getUrl();
          debugPrint('onPageCommitVisible $title $uri');
          if (uri.toString() == MobileNkustHelper.loginUrl) {
            await webViewController.evaluateJavascript(
              source:
                  'document.getElementsByName("Account")[0].value = "${widget.username}";',
            );
            await webViewController.evaluateJavascript(
              source:
                  'document.getElementsByName("Password")[0].value = "${widget.password}";',
            );
            await webViewController.evaluateJavascript(
              source:
                  'document.getElementsByName("RememberMe")[0].checked = true;',
            );
          }
        },
        onTitleChanged: (controller, title) async {
          final uri = await controller.getUrl();
          debugPrint('onTitleChanged $title $uri');
          if (uri.toString() == MobileNkustHelper.homeUrl) {
            _finishLogin();
          }
        },
        onLoadStop: (controller, title) async {
          final uri = await controller.getUrl();
          debugPrint('onLoadStop $title $uri');
        },
      ),
    );
  }

  Future<void> _finishLogin() async {
    if (finish) return;
    finish = true;
    final cookies = await CookieManager.instance().getCookies(
      url: WebUri(MobileNkustHelper.baseUrl),
    );
    final data = MobileCookiesData(cookies: []);
    for (final element in cookies) {
      data.cookies.add(
        MobileCookies(
          path: MobileNkustHelper.homeUrl,
          name: element.name,
          value: element.value.toString(),
          domain: element.domain ??
              (element.name == '.AspNetCore.Cookies'
                  ? 'mobile.nkust.edu.tw'
                  : '.nkust.edu.tw'),
        ),
      );
      if (kDebugMode) {
        log(
          'Cookie: ${element.name}: ${element.value} ${element.domain} ${element.expiresDate}',
        );
      }
    }
    MobileNkustHelper.instance.setCookieFromData(data);
    data.save();
    PreferenceUtil.instance.setInt(
      Constants.mobileCookiesLastTime,
      DateTime.now().microsecondsSinceEpoch,
    );
    if (!mounted) return;
    Navigator.pop(context, true);
  }
}
