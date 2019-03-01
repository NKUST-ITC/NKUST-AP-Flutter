import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/models/models.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;
import 'package:nkust_ap/utils/global.dart';
import 'package:nkust_ap/widgets/hint_content.dart';

enum _State { loading, finish, loadingMore, error, empty }

class NotificationPageRoute extends MaterialPageRoute {
  NotificationPageRoute()
      : super(builder: (BuildContext context) => new NotificationPage());

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return new FadeTransition(
        opacity: animation, child: new NotificationPage());
  }
}

class NotificationPage extends StatefulWidget {
  static const String routerName = "/info/notification";

  @override
  NotificationPageState createState() => new NotificationPageState();
}

class NotificationPageState extends State<NotificationPage>
    with SingleTickerProviderStateMixin {
  ScrollController controller;
  List<NotificationModel> notificationList = [];
  int page = 1;

  _State state = _State.loading;

  AppLocalizations app;

  @override
  void initState() {
    super.initState();
    FA.setCurrentScreen("NotificationPage", "notification_page.dart");
    controller = new ScrollController()..addListener(_scrollListener);
    _getNotifications();
  }

  @override
  void dispose() {
    super.dispose();
    controller.removeListener(_scrollListener);
  }

  _textGreyStyle() {
    return TextStyle(color: Resource.Colors.grey, fontSize: 14.0);
  }

  _textStyle() {
    return TextStyle(
        color: Colors.black, fontSize: 18.0, fontWeight: FontWeight.bold);
  }

  Widget _notificationItem(NotificationModel notification) {
    return GestureDetector(
      onLongPress: () {
        Utils.shareTo("${notification.info.title}\n${notification.link}");
      },
      child: FlatButton(
          padding: EdgeInsets.all(0.0),
          onPressed: () {
            Utils.launchUrl(notification.link);
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.0),
            decoration: new BoxDecoration(
              border: new Border(
                top: BorderSide(color: Colors.grey, width: 0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  notification.info.title ?? "",
                  style: _textStyle(),
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 8.0),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        notification.info.department ?? "",
                        style: _textGreyStyle(),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        notification.info.date ?? "",
                        style: _textGreyStyle(),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                )
              ],
            ),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        //TODO 優化
        return FlatButton(
          onPressed: () {},
          child: HintContent(
            icon: Icons.assignment,
            content:
                state == _State.error ? app.clickToRetry : app.clickToRetry,
          ),
        );
      default:
        return RefreshIndicator(
          onRefresh: () {
            state = _State.loading;
            setState(() {});
            notificationList.clear();
            _getNotifications();
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
          _getNotifications();
        });
      }
    }
  }

  _getNotifications() async {
    Helper.instance.getNotifications(page).then((response) {
      var notificationData = response;
      for (var notification in notificationData.notifications) {
        notificationList.add(notification);
      }
      state = _State.finish;
      setState(() {});
    }).catchError((e) {
      if (e is DioError) {
        switch (e.type) {
          case DioErrorType.RESPONSE:
            Utils.handleResponseError(context, mounted, e);
            break;
          case DioErrorType.CANCEL:
            break;
          default:
            Utils.handleDioError(e, app);
            break;
        }
      } else {
        throw e;
      }
    });
  }
}
