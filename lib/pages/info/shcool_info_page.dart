import 'dart:developer';
import 'dart:io';

import 'package:ap_common/ap_common.dart';
import 'package:ap_common_firebase/ap_common_firebase.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/utils/global.dart';

class SchoolInfoPage extends StatefulWidget {
  static const String routerName = '/ShcoolInfo';

  @override
  SchoolInfoPageState createState() => SchoolInfoPageState();
}

class SchoolInfoPageState extends State<SchoolInfoPage>
    with SingleTickerProviderStateMixin {
  final List<PhoneModel> phoneModelList = <PhoneModel>[
    PhoneModel('校安中心\n分機號碼：建工1 楠梓2 第一3 燕巢4 旗津5', '0800-550995'),
    PhoneModel('建工校區', ''),
    PhoneModel('校安專線', '0916-507-506'),
    PhoneModel('事務組', '(07) 381-4526 #2650'),
    PhoneModel('營繕組', '(07) 381-4526 #2630'),
    PhoneModel('課外活動組', '(07) 381-4526 #2525'),
    PhoneModel('諮商輔導中心', '(07) 381-4526 #2541'),
    PhoneModel('圖書館', '(07) 381-4526 #3100'),
    PhoneModel('校外賃居服務中心', '(07) 381-4526 #3420'),
    PhoneModel('燕巢校區', ''),
    PhoneModel('校安專線', '0925-350-995'),
    PhoneModel('校外賃居服務中心', '(07) 381-4526 #8615'),
    PhoneModel('第一校區', ''),
    PhoneModel('生輔組', '(07)601-1000 #31212'),
    PhoneModel('總務處 總機', '(07)601-1000 #31316'),
    PhoneModel('總務處 場地租借', '(07)601-1000 #31312'),
    PhoneModel('總務處 高科大會館', '(07)601-1000 #31306'),
    PhoneModel('總務處 學雜費相關(原事務組)', '(07)601-1000 #31340'),
    PhoneModel('課外活動組', '(07)601-1000 #31211'),
    PhoneModel('諮輔組', '(07)601-1000 #31241'),
    PhoneModel('圖書館', '(07)6011000 #1599'),
    PhoneModel('生輔組', '(07)6011000 #31212'),
    PhoneModel('楠梓校區', ''),
    PhoneModel('總機', '07-3617141'),
    PhoneModel('課外活動組', '07-3617141 #22070'),
    PhoneModel('旗津校區', ''),
    PhoneModel('旗津校區', '07-8100888'),
    PhoneModel('學生事務處', '07-3617141 #2052'),
    PhoneModel('課外活動組', '07-8100888 #25065'),
    PhoneModel('生活輔導組', '07-3617141 #23967'),
  ];

  NotificationState notificationState = NotificationState.loading;

  List<Notifications> notificationList = <Notifications>[];

  int page = 1;

  PhoneState phoneState = PhoneState.finish;

  PdfState pdfState = PdfState.loading;

  late ApLocalizations ap;

  late TabController controller;

  int _currentIndex = 0;

  Uint8List? data;

  @override
  void initState() {
    AnalyticsUtil.instance
        .setCurrentScreen('SchoolInfoPage', 'school_info_page.dart');
    controller = TabController(length: 3, vsync: this);
    _getNotifications();
    _getSchedules();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ap = ApLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(ap.schoolInfo),
        backgroundColor: ApTheme.of(context).blue,
      ),
      body: TabBarView(
        controller: controller,
        physics: const NeverScrollableScrollPhysics(),
        children: <Widget>[
          NotificationListView(
            state: notificationState,
            notificationList: notificationList,
            onRefresh: () async {
              setState(() => notificationList.clear());
              _getNotifications();
            },
            onLoadingMore: () async {
              page++;
              setState(() => notificationState = NotificationState.loadingMore);
              _getNotifications();
            },
          ),
          PhoneListView(
            state: phoneState,
            phoneModelList: phoneModelList,
          ),
          PdfView(
            state: pdfState,
            data: data,
            onRefresh: () {
              setState(() => pdfState = PdfState.loading);
              _getSchedules();
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
            controller.animateTo(_currentIndex);
          });
        },
        fixedColor: ApTheme.of(context).yellow,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(ApIcon.fiberNew),
            label: ap.notifications,
          ),
          BottomNavigationBarItem(
            icon: Icon(ApIcon.phone),
            label: ap.phones,
          ),
          BottomNavigationBarItem(
            icon: Icon(ApIcon.dateRange),
            label: ap.events,
          ),
        ],
      ),
    );
  }

  void _getNotifications() {
    if (PreferenceUtil.instance.getBool(Constants.prefIsOfflineLogin, false)) {
      setState(() => notificationState = NotificationState.offline);
    } else {
      Helper.instance.getNotifications(
        page: page,
        callback: GeneralCallback<NotificationsData>(
          onSuccess: (NotificationsData data) {
            notificationList.addAll(data.data.notifications);
            if (mounted) {
              setState(() => notificationState = NotificationState.finish);
            }
          },
          onFailure: (DioException e) {
            if (e.i18nMessage != null) {
              UiUtil.instance.showToast(context, e.i18nMessage!);
            }
            if (mounted && notificationList.isEmpty) {
              setState(() => notificationState = NotificationState.error);
            }
          },
          onError: (GeneralResponse response) {
            UiUtil.instance.showToast(context, ap.somethingError);
            if (mounted && notificationList.isEmpty) {
              setState(() => notificationState = NotificationState.error);
            }
          },
        ),
      );
    }
  }

  Future<void> _getSchedules() async {
    String pdfUrl =
        'https://raw.githubusercontent.com/NKUST-ITC/NKUST-AP-Flutter/master/school_schedule.pdf';
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      try {
        final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
        await remoteConfig.setConfigSettings(
          RemoteConfigSettings(
            fetchTimeout: const Duration(seconds: 10),
            minimumFetchInterval: const Duration(hours: 1),
          ),
        );
        await remoteConfig.fetchAndActivate();
        pdfUrl = remoteConfig.getString(Constants.schedulePdfUrl);
        downloadFdf(pdfUrl);
      } catch (exception) {
        downloadFdf(pdfUrl);
      }
    } else {
      downloadFdf(pdfUrl);
    }
  }

  Future<void> downloadFdf(String url) async {
    try {
      log(url);
      final Response<Uint8List> response = await Dio().get<Uint8List>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      setState(() {
        pdfState = PdfState.finish;
        data = response.data;
      });
    } catch (e) {
      setState(() {
        pdfState = PdfState.error;
      });
      rethrow;
    }
  }
}
