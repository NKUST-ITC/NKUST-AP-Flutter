import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nkust_ap/models/user_info.dart';
import 'package:nkust_ap/res/colors.dart' as Resource;
import 'package:nkust_ap/utils/cache_utils.dart';
import 'package:nkust_ap/utils/global.dart';
import 'package:nkust_ap/utils/preferences.dart';
import 'package:nkust_ap/widgets/drawer_body.dart';

enum _Status { loading, finish, error, empty }

class UserInfoPage extends StatefulWidget {
  static const String routerName = "/widget.userInfo";
  final UserInfo userInfo;

  const UserInfoPage({Key key, this.userInfo}) : super(key: key);

  @override
  UserInfoPageState createState() => new UserInfoPageState();
}

class UserInfoPageState extends State<UserInfoPage>
    with SingleTickerProviderStateMixin {
  _Status state = _Status.finish;
  AppLocalizations app;

  @override
  void initState() {
    super.initState();
    FA.setCurrentScreen("UserInfoPage", "user_info_page.dart");
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _homebody() {
    switch (state) {
      case _Status.loading:
        return Center(
          child: CircularProgressIndicator(),
        );
      case _Status.finish:
        return SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(height: 8.0),
              pictureBytes != null
                  ? SizedBox(
                      height: 320,
                      child: AspectRatio(
                        aspectRatio: 2.0,
                        child: Hero(
                          tag: Constants.TAG_STUDENT_PICTURE,
                          child: Image.memory(pictureBytes),
                        ),
                      ),
                    )
                  : SizedBox(height: 0.0),
              SizedBox(height: 8.0),
              Card(
                elevation: 4.0,
                margin: EdgeInsets.all(16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 8.0),
                      ListTile(
                        title: Text(app.studentNameCht),
                        subtitle: Text(widget.userInfo.name),
                      ),
                      Divider(height: 1.0),
                      ListTile(
                        title: Text(app.educationSystem),
                        subtitle: Text(widget.userInfo.educationSystem),
                      ),
                      Divider(height: 1.0),
                      ListTile(
                        title: Text(app.department),
                        subtitle: Text(widget.userInfo.department),
                      ),
                      Divider(height: 1.0),
                      ListTile(
                        title: Text(app.studentClass),
                        subtitle: Text(widget.userInfo.className),
                      ),
                      Divider(height: 1.0),
                      ListTile(
                        title: Text(app.studentId),
                        subtitle: Text(widget.userInfo.id),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    app = AppLocalizations.of(context);
    return Scaffold(
      appBar: new AppBar(
        title: new Text(app.userInfo),
        backgroundColor: Resource.Colors.blue,
      ),
      body: _homebody(),
    );
  }
}
