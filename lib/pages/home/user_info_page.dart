import 'package:ap_common/models/user_info.dart';
import 'package:ap_common/scaffold/user_info_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/utils/global.dart';

class UserInfoPage extends StatefulWidget {
  static const String routerName = "/userInfo";
  final UserInfo userInfo;

  const UserInfoPage({Key key, this.userInfo}) : super(key: key);

  @override
  UserInfoPageState createState() => new UserInfoPageState();
}

class UserInfoPageState extends State<UserInfoPage> {
  AppLocalizations app;

  @override
  void initState() {
    FA.setCurrentScreen("UserInfoPage", "user_info_page.dart");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    app = AppLocalizations.of(context);
    return UserInfoScaffold(
      userInfo: widget.userInfo,
      actions: <Widget>[],
    );
  }
}
