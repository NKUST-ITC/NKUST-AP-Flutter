import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/models/api/login_response.dart';
import 'package:nkust_ap/pages/search_student_id_page.dart';
import 'package:nkust_ap/res/assets.dart';
import 'package:nkust_ap/res/colors.dart' as Resource;
import 'package:nkust_ap/utils/global.dart';
import 'package:nkust_ap/utils/preferences.dart';
import 'package:nkust_ap/widgets/drawer_body.dart';
import 'package:nkust_ap/widgets/progress_dialog.dart';
import 'package:nkust_ap/widgets/share_data_widget.dart';

class LoginPage extends StatefulWidget {
  static const String routerName = "/login";

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  AppLocalizations app;

  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
  var isRememberPassword = true;
  var isAutoLogin = false;

  FocusNode usernameFocusNode;
  FocusNode passwordFocusNode;

  TextStyle get _editTextStyle => TextStyle(
        color: Colors.white,
        fontSize: 18.0,
        decorationColor: Colors.white,
      );

  @override
  void initState() {
    FA.setCurrentScreen("LoginPage", "login_page.dart");
    usernameFocusNode = FocusNode();
    passwordFocusNode = FocusNode();
    _getPreference();
    if (!Preferences.getBool(Constants.PREF_AUTO_LOGIN, false))
      Utils.checkUpdate(context);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    app = AppLocalizations.of(context);
    return OrientationBuilder(
      builder: (_, orientation) {
        return Scaffold(
          resizeToAvoidBottomPadding: orientation == Orientation.portrait,
          backgroundColor: Resource.Colors.blue,
          body: Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 30.0),
              child: orientation == Orientation.portrait
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: _renderContent(orientation),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _renderContent(orientation),
                    ),
            ),
          ),
        );
      },
    );
  }

  _renderContent(Orientation orientation) {
    List<Widget> section = orientation == Orientation.portrait
        ? <Widget>[
            Center(
              child: Image.asset(
                ImageAssets.K,
                width: 120.0,
                height: 120.0,
              ),
            ),
            SizedBox(height: orientation == Orientation.portrait ? 30.0 : 0.0),
          ]
        : <Widget>[
            Expanded(
              child: Image.asset(
                ImageAssets.K,
                width: 120.0,
                height: 120.0,
              ),
            ),
            SizedBox(height: orientation == Orientation.portrait ? 30.0 : 0.0),
          ];
    List<Widget> sectionInput = <Widget>[
      TextField(
        maxLines: 1,
        controller: _username,
        textInputAction: TextInputAction.next,
        focusNode: usernameFocusNode,
        onSubmitted: (text) {
          usernameFocusNode.unfocus();
          FocusScope.of(context).requestFocus(passwordFocusNode);
        },
        decoration: InputDecoration(
          labelText: app.username,
        ),
        style: _editTextStyle,
      ),
      TextField(
        obscureText: true,
        maxLines: 1,
        textInputAction: TextInputAction.send,
        controller: _password,
        focusNode: passwordFocusNode,
        onSubmitted: (text) {
          passwordFocusNode.unfocus();
          _login();
        },
        decoration: InputDecoration(
          labelText: app.password,
        ),
        style: _editTextStyle,
      ),
      SizedBox(height: 8.0),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          GestureDetector(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Theme(
                  data: ThemeData(
                    unselectedWidgetColor: Colors.white,
                  ),
                  child: Checkbox(
                    activeColor: Colors.white,
                    checkColor: Resource.Colors.blue,
                    value: isAutoLogin,
                    onChanged: _onAutoLoginChanged,
                  ),
                ),
                Text(
                  app.autoLogin,
                  style: TextStyle(color: Colors.white),
                )
              ],
            ),
            onTap: () => _onAutoLoginChanged(!isAutoLogin),
          ),
          GestureDetector(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Theme(
                  data: ThemeData(
                    unselectedWidgetColor: Colors.white,
                  ),
                  child: Checkbox(
                    activeColor: Colors.white,
                    checkColor: Resource.Colors.blue,
                    value: isRememberPassword,
                    onChanged: _onRememberPasswordChanged,
                  ),
                ),
                Text(
                  app.remember,
                  style: TextStyle(color: Colors.white),
                )
              ],
            ),
            onTap: () => _onRememberPasswordChanged(!isRememberPassword),
          ),
        ],
      ),
      SizedBox(height: 8.0),
      Container(
        width: double.infinity,
        child: RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(30.0),
            ),
          ),
          padding: EdgeInsets.all(14.0),
          onPressed: () {
            FA.logAction('login', 'click');
            _login();
          },
          color: Colors.white,
          child: Text(
            app.login,
            style: TextStyle(color: Resource.Colors.blue, fontSize: 18.0),
          ),
        ),
      ),
      Center(
        child: FlatButton(
          padding: EdgeInsets.all(0.0),
          onPressed: () {
            _offlineLogin();
          },
          child: Text(
            app.offlineLogin,
            style: TextStyle(color: Colors.white, fontSize: 16.0),
          ),
        ),
      ),
      Center(
        child: FlatButton(
          padding: EdgeInsets.all(0.0),
          onPressed: () async {
            var username = await Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (_) => SearchStudentIdPage(),
              ),
            );
            if (username != null && username is String) {
              setState(() {
                _username.text = username;
              });
              Utils.showToast(context, app.firstLoginHint);
            }
          },
          child: Text(
            app.searchUsername,
            style: TextStyle(color: Colors.white, fontSize: 16.0),
          ),
        ),
      ),
    ];
    if (orientation == Orientation.portrait) {
      section.addAll(sectionInput);
    } else {
      section.add(
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: sectionInput,
          ),
        ),
      );
    }
    return section;
  }

  _onRememberPasswordChanged(bool value) async {
    setState(() {
      isRememberPassword = value;
      if (!isRememberPassword) isAutoLogin = false;
      Preferences.setBool(Constants.PREF_AUTO_LOGIN, isAutoLogin);
      Preferences.setBool(Constants.PREF_REMEMBER_PASSWORD, isRememberPassword);
    });
  }

  _onAutoLoginChanged(bool value) async {
    setState(() {
      isAutoLogin = value;
      isRememberPassword = isAutoLogin;
      Preferences.setBool(Constants.PREF_AUTO_LOGIN, isAutoLogin);
      Preferences.setBool(Constants.PREF_REMEMBER_PASSWORD, isRememberPassword);
    });
  }

  _getPreference() async {
    isRememberPassword =
        Preferences.getBool(Constants.PREF_REMEMBER_PASSWORD, true);
    isAutoLogin = Preferences.getBool(Constants.PREF_AUTO_LOGIN, false);
    setState(() {
      _username.text = Preferences.getString(Constants.PREF_USERNAME, '');
      _password.text = isRememberPassword
          ? Preferences.getStringSecurity(Constants.PREF_PASSWORD, '')
          : '';
    });
    await Future.delayed(Duration(microseconds: 50));
    if (isAutoLogin) {
      _login();
    }
  }

  _login() async {
    if (_username.text.isEmpty || _password.text.isEmpty) {
      Utils.showToast(context, app.doNotEmpty);
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) => WillPopScope(
            child: ProgressDialog(app.logining),
            onWillPop: () async {
              return false;
            }),
        barrierDismissible: false,
      );
      Preferences.setString(Constants.PREF_USERNAME, _username.text);
      Helper.instance
          .login(_username.text, _password.text)
          .then((LoginResponse response) async {
        if (Navigator.canPop(context))
          Navigator.of(context, rootNavigator: true).pop();
        ShareDataWidget.of(context).data.loginResponse = response;
        Preferences.setString(Constants.PREF_USERNAME, _username.text);
        if (isRememberPassword) {
          Preferences.setStringSecurity(
              Constants.PREF_PASSWORD, _password.text);
        }
        Preferences.setBool(Constants.PREF_IS_OFFLINE_LOGIN, false);
        ShareDataWidget.of(context).data.isLogin = true;
        _navigateToFilterObject(context);
      }).catchError((e) {
        if (Navigator.canPop(context))
          Navigator.of(context, rootNavigator: true).pop();
        if (e is DioError) {
          switch (e.type) {
            case DioErrorType.RESPONSE:
              Utils.showToast(context, app.loginFail);
              Utils.handleResponseError(context, 'login', mounted, e);
              _offlineLogin();
              break;
            case DioErrorType.CANCEL:
              break;
            default:
              Utils.handleDioError(context, e);
              break;
          }
        } else {
          throw e;
        }
      });
    }
  }

  _offlineLogin() async {
    String username = Preferences.getString(Constants.PREF_USERNAME, '');
    String password =
        Preferences.getStringSecurity(Constants.PREF_PASSWORD, '');
    if (username.isEmpty || password.isEmpty) {
      Utils.showToast(context, app.noOfflineLoginData);
    } else {
      if (username != _username.text || password != _password.text)
        Utils.showToast(context, app.offlineLoginPasswordError);
      else {
        Preferences.setBool(Constants.PREF_IS_OFFLINE_LOGIN, true);
        Utils.showToast(context, app.loadOfflineData);
        _navigateToFilterObject(context);
      }
    }
  }

  _navigateToFilterObject(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(),
      ),
    );
    print(result);
    clearSetting();
  }

  void clearSetting() async {
    Preferences.setBool(Constants.PREF_AUTO_LOGIN, false);
    setState(() {
      isAutoLogin = false;
      pictureBytes = null;
    });
  }
}
