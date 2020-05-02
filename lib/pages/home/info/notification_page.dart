import 'package:ap_common/resources/ap_icon.dart';
import 'package:ap_common/resources/ap_theme.dart';
import 'package:ap_common/utils/preferences.dart';
import 'package:ap_common/widgets/hint_content.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/models/models.dart';
import 'package:nkust_ap/utils/global.dart';

enum _State { loading, finish, loadingMore, error, empty, offline }

class NotificationPage extends StatefulWidget {
  static const String routerName = "/info/notification";

  @override
  NotificationPageState createState() => NotificationPageState();
}

class NotificationPageState extends State<NotificationPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  _State state = _State.loading;

  AppLocalizations app;

  ScrollController controller;
  List<Notifications> notificationList = [];

  int page = 1;

  TextStyle get _textStyle => TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
      );

  TextStyle get _textGreyStyle => TextStyle(
        color: ApTheme.of(context).grey,
        fontSize: 14.0,
      );

  @override
  void initState() {
    FA.setCurrentScreen("NotificationPage", "notification_page.dart");
    controller = ScrollController()..addListener(_scrollListener);
    _getNotifications();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    controller.removeListener(_scrollListener);
  }

  Widget _notificationItem(Notifications notification) {
    return GestureDetector(
      onLongPress: () {
        Utils.shareTo("${notification.info.title}\n${notification.link}");
        FA.logAction('share', 'long_click',
            message: '${notification.info.title}');
      },
      child: FlatButton(
        padding: EdgeInsets.all(0.0),
        onPressed: () {
          Utils.launchUrl(notification.link);
          FA.logAction('notification_link"', 'click',
              message: '${notification.info.title}');
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.grey, width: 0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                notification.info.title ?? '',
                style: _textStyle,
                textAlign: TextAlign.left,
              ),
              SizedBox(height: 8.0),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      notification.info.department ?? '',
                      style: _textGreyStyle,
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      notification.info.date ?? '',
                      style: _textGreyStyle,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    app = AppLocalizations.of(context);
    return _body();
  }

  Widget _body() {
    switch (state) {
      case _State.loading:
        return Container(
            child: CircularProgressIndicator(), alignment: Alignment.center);
      case _State.error:
      case _State.empty:
        //TODO improve
        return FlatButton(
          onPressed: () {
            _getNotifications();
            FA.logAction('rerty', 'click');
          },
          child: HintContent(
            icon: ApIcon.assignment,
            content:
                state == _State.error ? app.clickToRetry : app.clickToRetry,
          ),
        );
      case _State.offline:
        return HintContent(
          icon: ApIcon.offlineBolt,
          content: app.offlineMode,
        );
      default:
        return RefreshIndicator(
          onRefresh: () async {
            setState(() {
              state = _State.loading;
            });
            notificationList.clear();
            await _getNotifications();
            FA.logAction('refresh', 'swipe');
            return null;
          },
          child: ListView.builder(
            controller: controller,
            itemBuilder: (context, index) {
              return _notificationItem(notificationList[index]);
            },
            itemCount: notificationList.length,
          ),
        );
    }
  }

  void _scrollListener() {
    if (controller.position.extentAfter < 500) {
      if (state == _State.finish) {
        setState(() {
          page++;
          state = _State.loadingMore;
        });
        _getNotifications();
      }
    }
  }

  _getNotifications() async {
    if (Preferences.getBool(Constants.PREF_IS_OFFLINE_LOGIN, false)) {
      setState(() {
        state = _State.offline;
      });
      return;
    }
    Helper.instance.getNotifications(page).then((response) {
      for (var notification in response.data.notifications) {
        notificationList.add(notification);
      }
      if (mounted) {
        setState(() {
          state = _State.finish;
        });
      }
    }).catchError((e) {
      if (e is DioError) {
        switch (e.type) {
          case DioErrorType.RESPONSE:
            Utils.handleResponseError(context, 'getNotifications', mounted, e);
            break;
          case DioErrorType.CANCEL:
            break;
          default:
            Utils.handleDioError(context, e);
            break;
        }
      } else {
        throw e;
      }
    });
  }
}
