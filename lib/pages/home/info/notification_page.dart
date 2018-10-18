import 'package:flutter/material.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;
import 'package:nkust_ap/api/helper.dart';
import 'package:nkust_ap/models/models.dart';
import 'package:nkust_ap/utils/utils.dart';

enum NotificationState { loading, finish, error, empty }

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
  List<Widget> notificationWeights = [];

  List<NotificationModel> notificationList;

  NotificationState state = NotificationState.loading;

  int page = 1;

  @override
  void initState() {
    super.initState();
    _getNotifications();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _textGreyStyle() {
    return TextStyle(color: Resource.Colors.grey, fontSize: 14.0);
  }

  _textStyle() {
    return TextStyle(
        color: Colors.black, fontSize: 18.0, fontWeight: FontWeight.bold);
  }

  Widget _notificationItem(NotificationModel notification) {
    return FlatButton(
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _body();
  }

  Widget _body() {
    switch (state) {
      case NotificationState.loading:
        return Container(
            child: CircularProgressIndicator(), alignment: Alignment.center);
      case NotificationState.error:
      case NotificationState.empty:
        return FlatButton(
          onPressed: () {},
          child: Center(
            child: Flex(
              mainAxisAlignment: MainAxisAlignment.center,
              direction: Axis.vertical,
              children: <Widget>[
                SizedBox(
                  child: Icon(
                    Icons.directions_bus,
                    size: 150.0,
                  ),
                  width: 200.0,
                ),
                Text(
                  state == NotificationState.error
                      ? "發生錯誤，點擊重試"
                      : "Oops！本學期沒有任何成績資料哦～\n請選擇其他學期\uD83D\uDE0B",
                  textAlign: TextAlign.center,
                )
              ],
            ),
          ),
        );
      default:
        return ListView(
          children: notificationWeights,
        );
    }
  }

  _getNotifications() async {
    notificationWeights.clear();
    state = NotificationState.loading;
    setState(() {});
    Helper.instance.getNotifications(page).then((response) {
      var notificationData = NotificationData.fromJson(response.data);
      for (var notification in notificationData.notifications) {
        notificationWeights.add(_notificationItem(notification));
      }
      state = NotificationState.finish;
      setState(() {});
    });
  }
}
