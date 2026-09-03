import 'package:ap_common/ap_common.dart';
import 'package:nkust_ap/l10n/nkust_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nkust_crawler/nkust_crawler.dart';

class LeavePage extends StatefulWidget {
  static const String routerName = '/leave';
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
        return LeaveHelper.oosafLeaveCreateUrl;
      case 1:
        return LeaveHelper.oosafAbsenteeismUrl;
      case 2:
      default:
        return LeaveHelper.oosafLeaveUrl;
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
    _login = Future.microtask(() => login());
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ap = context.ap;
    return Scaffold(
      appBar: AppBar(title: Text(ap.leave)),
      body: FutureBuilder<bool>(
        future: _login,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(path)),
              initialSettings: InAppWebViewSettings(
                mediaPlaybackRequiresUserGesture: false,
                allowsInlineMediaPlayback: true,
              ),
              onWebViewCreated: (controller) => webViewController = controller,
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return InkWell(
              onTap: () => _login = Future.microtask(() => login()),
              child: HintContent(
                content: ap.clickToRetry,
                icon: ApIcon.error,
              ),
            );
          }
        },
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: onTabTapped,
        destinations: [
          NavigationDestination(icon: Icon(ApIcon.edit), label: ap.leaveApply),
          NavigationDestination(
            icon: Icon(ApIcon.assignment),
            label: ap.leaveRecords,
          ),
          NavigationDestination(
            icon: Icon(ApIcon.folder),
            label: context.t.leaveApplyRecord,
          ),
        ],
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() => _currentIndex = index);
    webViewController?.loadUrl(urlRequest: URLRequest(url: WebUri(path)));
  }

  Future<bool> login() async {
    try {
      await WebApHelper.instance.loginToOosaf();
      final cookies = await WebApHelper.instance.cookieJar.loadForRequest(
        WebUri(LeaveHelper.oosafBasePath),
      );
      for (final cookie in cookies) {
        cookieManager.setCookie(
          url: WebUri(LeaveHelper.oosafBasePath),
          name: cookie.name,
          value: cookie.value,
        );
      }
      return true;
    } catch (_) {
      return false;
    }
  }
}
