import 'package:ap_common/models/user_info.dart';
import 'package:ap_common/scaffold/user_info_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/utils/global.dart';

class UserInfoPage extends StatefulWidget {
  static const String routerName = '/userInfo';
  final UserInfo userInfo;

  const UserInfoPage({
    Key? key,
    required this.userInfo,
  }) : super(key: key);

  @override
  UserInfoPageState createState() => UserInfoPageState();
}

class UserInfoPageState extends State<UserInfoPage> {
  late UserInfo userInfo;

  @override
  void initState() {
    FirebaseAnalyticsUtils.instance
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
        }
        FirebaseAnalyticsUtils.instance.logUserInfo(userInfo);
        return null;
      },
    );
  }
}
