import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/config/constants.dart';
import 'package:nkust_ap/pages/page.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;
import 'package:nkust_ap/api/helper.dart';
import 'package:nkust_ap/models/models.dart';
import 'package:nkust_ap/utils/app_localizations.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:nkust_ap/widgets/drawer_body.dart';
import 'package:nkust_ap/utils/utils.dart';

enum _Status { loading, finish, error, empty }

class UserInfoPageRoute extends MaterialPageRoute {
  UserInfoPageRoute()
      : super(builder: (BuildContext context) => new UserInfoPage());

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return new FadeTransition(opacity: animation, child: new UserInfoPage());
  }
}

class UserInfoPage extends StatefulWidget {
  static const String routerName = "/userInfo";

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
    if (userInfo == null) _getUserInfo();
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
              SizedBox(
                height: 320,
                child: AspectRatio(
                  aspectRatio: 2.0,
                  child: Hero(
                    tag: Constants.TAG_STUDENT_PICTURE,
                    child: Image.network(
                      pictureUrl,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8.0),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          title: Text(app.studentNameCht),
                          subtitle: Text(userInfo.nameCht),
                        ),
                        Divider(height: 1.0),
                        ListTile(
                          title: Text(app.educationSystem),
                          subtitle: Text(userInfo.educationSystem),
                        ),
                        Divider(height: 1.0),
                        ListTile(
                          title: Text(app.department),
                          subtitle: Text(userInfo.department),
                        ),
                        Divider(height: 1.0),
                        ListTile(
                          title: Text(app.studentClass),
                          subtitle: Text(userInfo.className),
                        ),
                        Divider(height: 1.0),
                        ListTile(
                          title: Text(app.studentId),
                          subtitle: Text(userInfo.id),
                        ),
                      ],
                    ),
                  ),
                ),
              )
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

  _getUserPicture() {
    Helper.instance.getUsersPicture().then((url) {
      if (this.mounted) {
        setState(() {
          pictureUrl = url;
        });
      }
    }).catchError((e) {
      assert(e is DioError);
      DioError dioError = e as DioError;
      switch (dioError.type) {
        case DioErrorType.RESPONSE:
          Utils.showToast(app.tokenExpiredContent);
          Navigator.popUntil(
              context, ModalRoute.withName(LoginPage.routerName));
          break;
        default:
          break;
      }
    });
  }

  _getUserInfo() {
    setState(() {
      state = _Status.loading;
    });
    Helper.instance.getUsersInfo().then((response) {
      if (this.mounted) {
        setState(() {
          userInfo = response;
          _getUserPicture();
          state = _Status.finish;
        });
      }
    }).catchError((e) {
      assert(e is DioError);
      DioError dioError = e as DioError;
      switch (dioError.type) {
        case DioErrorType.RESPONSE:
          Utils.showToast(app.tokenExpiredContent);
          Navigator.popUntil(
              context, ModalRoute.withName(LoginPage.routerName));
          break;
        default:
          break;
      }
    });
  }
}
