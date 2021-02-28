import 'package:ap_common/resources/ap_icon.dart';
import 'package:ap_common/resources/ap_theme.dart';
import 'package:ap_common/utils/ap_localizations.dart';
import 'package:ap_common/utils/preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nkust_ap/api/helper.dart';
import 'package:nkust_ap/api/mobile_nkust_helper.dart';
import 'package:nkust_ap/config/constants.dart';
import 'package:nkust_ap/models/mobile_cookies_data.dart';
import 'package:nkust_ap/pages/leave/leave_apply_page.dart';
import 'package:nkust_ap/pages/leave/leave_record_page.dart';

class LeavePage extends StatefulWidget {
  static const String routerName = "/leave";
  final List<Widget> _children = [
    LeaveApplyPage(),
    LeaveRecordPage(),
  ];
  final int initIndex;

  LeavePage({this.initIndex = 0});

  @override
  LeavePageState createState() => LeavePageState();
}

class LeavePageState extends State<LeavePage>
    with SingleTickerProviderStateMixin {
  ApLocalizations ap;

  TabController controller;

  int _currentIndex = 0;

  InAppWebViewController webViewController;

  Future<bool> _init;

  String get path {
    switch (_currentIndex) {
      case 0:
        return 'https://mobile.nkust.edu.tw/Student/Leave/Create';
      case 1:
      default:
        return 'https://mobile.nkust.edu.tw/Student/Absenteeism';
    }
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initIndex;
    controller =
        TabController(length: 2, initialIndex: widget.initIndex, vsync: this);
    _init = Future.microtask(() => _loadData());
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
        future: _init,
        builder: (context, snapshot) {
          return InAppWebView(
            initialUrl: path,
            initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(),
            ),
            onWebViewCreated: (InAppWebViewController webViewController) {
              this.webViewController = webViewController;
            },
            onPageCommitVisible: (controller, title) async {
              final path = await controller.getUrl();
              debugPrint('onPageCommitVisible $title $path');
              if (path.contains(MobileNkustHelper.LOGIN)) {
                await webViewController.evaluateJavascript(
                    source:
                        'document.getElementsByName("Account")[0].value = "${Helper.username}";');
                await webViewController.evaluateJavascript(
                    source:
                        'document.getElementsByName("Password")[0].value = "${Helper.password}";');
                await webViewController.evaluateJavascript(
                    source:
                        'document.getElementsByName("RememberMe")[0].checked = true;');
              } else {
                _finishLogin();
              }
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: onTabTapped,
        fixedColor: ApTheme.of(context).yellow,
        items: [
          BottomNavigationBarItem(
            icon: Icon(ApIcon.edit),
            label: ap.leaveApply,
          ),
          BottomNavigationBarItem(
            icon: Icon(ApIcon.assignment),
            label: ap.leaveRecords,
          ),
        ],
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      controller.animateTo(_currentIndex);
      webViewController.loadUrl(url: path);
    });
  }

  Future<bool> _loadData() async {
    final cookieManager = CookieManager.instance();
    final cookiesData = MobileNkustHelper.instance.cookiesData;
    if (cookiesData != null) {
      for (var i = 0; i < cookiesData.cookies.length; i++) {
        final element = cookiesData.cookies[i];
        await cookieManager.setCookie(
          url: MobileNkustHelper.BASE_URL,
          name: element.name,
          value: element.value,
        );
      }
    }
    return true;
  }

  Future<void> _finishLogin() async {
    final cookies = await CookieManager.instance()
        .getCookies(url: MobileNkustHelper.BASE_URL);
    final data = MobileCookiesData(cookies: []);
    cookies.forEach(
      (element) {
        data.cookies.add(
          MobileCookies(
            path: MobileNkustHelper.HOME,
            name: element.name,
            value: element.value,
            domain: element.domain ??
                (element.name == '.AspNetCore.Cookies'
                    ? 'mobile.nkust.edu.tw'
                    : '.nkust.edu.tw'),
          ),
        );
      },
    );
    MobileNkustHelper.instance.setCookieFromData(data);
    data.save();
    Preferences.setInt(
      Constants.MOBILE_COOKIES_LAST_TIME,
      DateTime.now().microsecondsSinceEpoch,
    );
    Navigator.pop(context, true);
  }
}
