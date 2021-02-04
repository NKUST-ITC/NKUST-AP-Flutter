import 'package:ap_common/resources/ap_theme.dart';
import 'package:ap_common/utils/ap_utils.dart';
import 'package:ap_common/utils/dialog_utils.dart';
import 'package:ap_common/utils/preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nkust_ap/api/mobile_nkust_helper.dart';
import 'package:nkust_ap/config/constants.dart';
import 'package:nkust_ap/models/mobile_cookies_data.dart';
import 'package:nkust_ap/utils/app_localizations.dart';

class MobileNkustPage extends StatefulWidget {
  final String username;
  final String password;
  final bool clearCache;

  const MobileNkustPage({
    Key key,
    this.username,
    this.password,
    this.clearCache = false,
  }) : super(key: key);

  @override
  _MobileNkustPageState createState() => _MobileNkustPageState();
}

class _MobileNkustPageState extends State<MobileNkustPage> {
  AppLocalizations app;

  InAppWebViewController webViewController;

  @override
  Widget build(BuildContext context) {
    app = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(app.loginAuth),
        backgroundColor: ApTheme.of(context).blue,
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
              child: Icon(Icons.done_outline),
              onPressed: () async {
                // final html = await webViewController.getHtml();
                // debugPrint(html);
                MobileNkustHelper.instance.getScores();
              },
            )
          : null,
      body: InAppWebView(
        initialUrl: MobileNkustHelper.LOGIN,
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            clearCache: widget.clearCache,
          ),
        ),
        onWebViewCreated: (InAppWebViewController webViewController) {
          this.webViewController = webViewController;
          ApUtils.showToast(context, app.mobileNkustLoginHint);
        },
        onJsPrompt: (controller, JsPromptRequest jsPromptRequest) {
          print(jsPromptRequest.defaultValue);
          return;
        },
        onPageCommitVisible: (controller, title) async {
          final path = await controller.getUrl();
          debugPrint('onPageCommitVisible $title $path');
        },
        onTitleChanged: (controller, title) async {
          final path = await controller.getUrl();
          debugPrint('onTitleChanged $title $path');
        },
        onLoadStop: (controller, title) async {
          debugPrint('onLoadStop $title');
          final path = await controller.getUrl();
          if (path == MobileNkustHelper.LOGIN) {
            await webViewController.evaluateJavascript(
                source:
                    'document.getElementsByName("Account")[0].value = "${widget.username}";');
            await webViewController.evaluateJavascript(
                source:
                    'document.getElementsByName("Password")[0].value = "${widget.password}";');
            await webViewController.evaluateJavascript(
                source:
                    'document.getElementsByName("RememberMe")[0].checked = true;');
          } else if (path == MobileNkustHelper.HOME) {
            final cookies = await CookieManager.instance()
                .getCookies(url: MobileNkustHelper.BASE_URL);
            final data = MobileCookiesData(cookies: []);
            cookies.forEach(
              (element) {
                data.cookies.add(
                  MobileCookies(
                    path: path,
                    name: element.name,
                    value: element.value,
                    domain: element.domain ??
                        (element.name == '.AspNetCore.Cookies'
                            ? 'mobile.nkust.edu.tw'
                            : '.nkust.edu.tw'),
                  ),
                );
                if (kDebugMode)
                  print(
                      "Cookie: ${element.name}: ${element.value} ${element.domain} ${element.expiresDate} \n");
              },
            );
            MobileNkustHelper.instance.setCookieFromData(data);
            data.save();
            Preferences.setInt(
              Constants.SEMESTER_DATA,
              DateTime.now().microsecondsSinceEpoch,
            );
            Navigator.pop(context, true);
          }
        },
      ),
    );
  }
}
