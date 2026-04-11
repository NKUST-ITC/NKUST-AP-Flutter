import 'package:ap_common/ap_common.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/utils/global.dart';

class UserInfoPage extends StatefulWidget {
  static const String routerName = '/userInfo';
  final UserInfo userInfo;

  const UserInfoPage({super.key, required this.userInfo});

  @override
  UserInfoPageState createState() => UserInfoPageState();
}

class UserInfoPageState extends State<UserInfoPage> {
  late UserInfo userInfo;

  @override
  void initState() {
    AnalyticsUtil.instance.setCurrentScreen(
      'UserInfoPage',
      'user_info_page.dart',
    );
    userInfo = widget.userInfo;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return UserInfoScaffold(
      userInfo: userInfo,
      onRefresh: _refreshUserInfo,
      enableBarCode: true,
    );
  }

  Future<UserInfo?> _refreshUserInfo() async {
    final UserInfo newUserInfo = await Helper.instance.getUsersInfo();
    if (mounted) {
      final UserInfo updated = newUserInfo.copyWith(
        pictureBytes: userInfo.pictureBytes,
      );
      setState(() => userInfo = updated);
      AnalyticsUtil.instance.logUserInfo(newUserInfo);
      return updated;
    }
    return null;
  }
}
