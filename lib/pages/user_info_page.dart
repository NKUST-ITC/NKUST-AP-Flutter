import 'package:ap_common/models/user_info.dart';
import 'package:ap_common/scaffold/user_info_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/utils/global.dart';

class UserInfoPage extends StatefulWidget {
  static const String routerName = "/userInfo";
  final UserInfo userInfo;

  const UserInfoPage({Key key, this.userInfo}) : super(key: key);

  @override
  UserInfoPageState createState() => UserInfoPageState();
}

class UserInfoPageState extends State<UserInfoPage> {
  @override
  void initState() {
    FirebaseAnalyticsUtils.instance
        .setCurrentScreen("UserInfoPage", "user_info_page.dart");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return UserInfoScaffold(
      userInfo: widget.userInfo,
      actions: <Widget>[],
      enableBarCode: true,
      onRefresh: () async {
        var userInfo = await Helper.instance.getUsersInfo();
        if (userInfo != null)
          setState(
            () => widget.userInfo
              ..name = userInfo.name
              ..department = userInfo.department
              ..className = userInfo.className
              ..pictureUrl = userInfo.pictureUrl
              ..educationSystem = userInfo.educationSystem
              ..email = userInfo.email
              ..id = userInfo.id,
          );
        return null;
      },
    );
  }
}
