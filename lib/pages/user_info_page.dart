import 'package:ap_common/ap_common.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/utils/global.dart';

class UserInfoPage extends StatefulWidget {
  static const String routerName = '/userInfo';
  final UserInfo userInfo;

  const UserInfoPage({
    super.key,
    required this.userInfo,
  });

  @override
  UserInfoPageState createState() => UserInfoPageState();
}

class UserInfoPageState extends State<UserInfoPage> {
  late UserInfo userInfo;

  @override
  void initState() {
    AnalyticsUtil.instance
        .setCurrentScreen('UserInfoPage', 'user_info_page.dart');
    userInfo = widget.userInfo;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return UserInfoScaffold(
      userInfo: userInfo,
      actions: const <Widget>[],
      enableBarCode: true,
      onRefresh: () async {
        final UserInfo? userInfo = await Helper.instance.getUsersInfo();
        if (userInfo != null) {
          setState(
            () => this.userInfo = userInfo.copyWith(
              pictureBytes: this.userInfo.pictureBytes,
            ),
          );
          AnalyticsUtil.instance.logUserInfo(userInfo);
        }
        return null;
      },
    );
  }
}
