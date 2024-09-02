import 'dart:io' as io;

import 'package:ap_common/resources/ap_icon.dart';
import 'package:ap_common/resources/ap_theme.dart';
import 'package:ap_common/utils/ap_localizations.dart';
import 'package:ap_common/widgets/hint_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nkust_ap/api/ap_helper.dart';
import 'package:nkust_ap/utils/app_localizations.dart';

class LeavePage extends StatefulWidget {
  static const String routerName = '/leave';

  // final List<Widget> _children = <Widget>[
  //   LeaveApplyPage(),
  //   LeaveRecordPage(),
  // ];
  final int initIndex;

  const LeavePage({this.initIndex = 0});

  @override
  LeavePageState createState() => LeavePageState();
}

class LeavePageState extends State<LeavePage>
    with SingleTickerProviderStateMixin {
  late ApLocalizations ap;

  late TabController controller;

  int _currentIndex = 0;

  InAppWebViewController? webViewController;

  CookieManager cookieManager = CookieManager.instance();

  Future<bool>? _login;

  String get path {
    switch (_currentIndex) {
      case 0:
        return 'https://mobile.nkust.edu.tw/Student/Leave/Create';
      case 1:
        return 'https://mobile.nkust.edu.tw/Student/Absenteeism';
      case 2:
      default:
        return 'https://mobile.nkust.edu.tw/Student/Leave';
    }
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initIndex;
    controller = TabController(
      length: 3,
      initialIndex: widget.initIndex,
      vsync: this,
    );
    _login = Future<bool>.microtask(() => login());
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ap = ApLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(ap.leave),
        backgroundColor: ApTheme.of(context).blue,
      ),
      body: FutureBuilder<bool>(
        future: _login,
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri(path),
              ),
              initialSettings: InAppWebViewSettings(
                useShouldOverrideUrlLoading: true,
                mediaPlaybackRequiresUserGesture: false,
                allowsInlineMediaPlayback: true,
              ),
              onWebViewCreated: (InAppWebViewController controller) {
                webViewController = controller;
              },
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return InkWell(
              onTap: () {
                _login = Future<bool>.microtask(() => login());
              },
              child: HintContent(
                content: ApLocalizations.of(context).clickToRetry,
                icon: ApIcon.error,
              ),
            );
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: onTabTapped,
        fixedColor: ApTheme.of(context).yellow,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(ApIcon.edit),
            label: ap.leaveApply,
          ),
          BottomNavigationBarItem(
            icon: Icon(ApIcon.assignment),
            label: ap.leaveRecords,
          ),
          BottomNavigationBarItem(
            icon: Icon(ApIcon.folder),
            label: AppLocalizations.of(context).leaveApplyRecord,
          ),
        ],
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      // controller.animateTo(_currentIndex);
    });
    webViewController?.loadUrl(
      urlRequest: URLRequest(
        url: WebUri(path),
      ),
    );
  }

  Future<bool> login() async {
    try {
      await WebApHelper.instance.loginToMobile();
      final List<io.Cookie> cookies =
          await WebApHelper.instance.cookieJar.loadForRequest(
        WebUri('https://mobile.nkust.edu.tw'),
      );
      for (final io.Cookie cookie in cookies) {
        cookieManager.setCookie(
          url: WebUri('https://mobile.nkust.edu.tw'),
          name: cookie.name,
          value: cookie.value,
        );
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}
