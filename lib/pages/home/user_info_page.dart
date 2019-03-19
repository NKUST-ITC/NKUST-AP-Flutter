import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/models/user_info.dart';
import 'package:nkust_ap/res/colors.dart' as Resource;
import 'package:nkust_ap/utils/global.dart';
import 'package:nkust_ap/widgets/drawer_body.dart';

enum _Status { loading, finish, error, empty }

class UserInfoPageRoute extends MaterialPageRoute {
  final UserInfo userInfo;

  UserInfoPageRoute(this.userInfo)
      : super(
            builder: (BuildContext context) =>
                new UserInfoPage(userInfo: userInfo));

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return new FadeTransition(
        opacity: animation, child: new UserInfoPage(userInfo: userInfo));
  }
}

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
    if (pictureUrl == null || pictureUrl.isEmpty) _getUserPicture();
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
                  child: pictureUrl != ""
                      ? Hero(
                          tag: Constants.TAG_STUDENT_PICTURE,
                          child: CachedNetworkImage(
                            imageUrl: pictureUrl,
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ),
                        )
                      : null,
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
                          subtitle: Text(widget.userInfo.studentNameCht),
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
                          subtitle: Text(widget.userInfo.studentId),
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
          Utils.handleResponseError(context, 'getUserPicture', mounted, e);
          break;
        default:
          break;
      }
    });
  }
}
