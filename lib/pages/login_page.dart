import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/models/api/login_response.dart';
import 'package:nkust_ap/res/colors.dart' as Resource;
import 'package:nkust_ap/utils/global.dart';
import 'package:nkust_ap/widgets/drawer_body.dart';
import 'package:nkust_ap/widgets/progress_dialog.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  static const String routerName = "/login";

  @override
  LoginPageState createState() => new LoginPageState();
}

class LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  AppLocalizations app;
  SharedPreferences prefs;

  final TextEditingController _username = new TextEditingController();
  final TextEditingController _password = new TextEditingController();
  var isRememberPassword = true;
  var isAutoLogin = false;

  FocusNode usernameFocusNode;
  FocusNode passwordFocusNode;

  @override
  void initState() {
    super.initState();
    FA.setCurrentScreen("LoginPage", "login_page.dart");
    usernameFocusNode = FocusNode();
    passwordFocusNode = FocusNode();
    _getPreference();
    _showDialog();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _editTextStyle() => new TextStyle(
      color: Colors.white, fontSize: 18.0, decorationColor: Colors.white);

  @override
  Widget build(BuildContext context) {
    app = AppLocalizations.of(context);
    return OrientationBuilder(builder: (_, orientation) {
      return Scaffold(
          resizeToAvoidBottomPadding: orientation == Orientation.portrait,
          backgroundColor: Resource.Colors.blue,
          body: Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 30.0),
              child: orientation == Orientation.portrait
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      mainAxisSize: MainAxisSize.min,
                      children: _renderContent(orientation),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _renderContent(orientation),
                    ),
            ),
          ));
    });
  }

  _renderContent(Orientation orientation) {
    List<Widget> list = orientation == Orientation.portrait
        ? <Widget>[
            Center(
              child: Image.asset(
                "assets/images/K.png",
                width: 120.0,
                height: 120.0,
              ),
            ),
            SizedBox(height: orientation == Orientation.portrait ? 30.0 : 0.0),
          ]
        : <Widget>[
            Expanded(
              child: Image.asset(
                "assets/images/K.png",
                width: 120.0,
                height: 120.0,
              ),
            ),
            SizedBox(height: orientation == Orientation.portrait ? 30.0 : 0.0),
          ];
    List<Widget> listB = <Widget>[
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
        style: _editTextStyle(),
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
        style: _editTextStyle(),
      ),
      SizedBox(height: 8.0),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          GestureDetector(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Checkbox(
                  activeColor: Colors.white,
                  value: isAutoLogin,
                  onChanged: _onAutoLoginChanged,
                ),
                Text(app.autoLogin, style: TextStyle(color: Colors.white))
              ],
            ),
            onTap: () => _onAutoLoginChanged(!isAutoLogin),
          ),
          GestureDetector(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Checkbox(
                  activeColor: Colors.white,
                  value: isRememberPassword,
                  onChanged: _onRememberPasswordChanged,
                ),
                Text(app.remember, style: TextStyle(color: Colors.white))
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
          onPressed: _login,
          color: Colors.white,
          child: Text(
            app.login,
            style: TextStyle(color: Resource.Colors.blue, fontSize: 18.0),
          ),
        ),
      ),
    ];
    if (orientation == Orientation.portrait) {
      list.addAll(listB);
    } else {
      list.add(Expanded(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center, children: listB)));
    }
    return list;
  }

  _showDialog() async {
    prefs = await SharedPreferences.getInstance();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    await Future.delayed(Duration(milliseconds: 50));
    var currentVersion = prefs.getString(Constants.PREF_CURRENT_VERSION) ?? "";
    if (currentVersion != packageInfo.buildNumber)
      Utils.showDefaultDialog(
          context,
          app.updateNoteTitle,
          "v${packageInfo.version}\n"
          "${app.updateNoteContent}",
          app.ok, () {
        prefs.setString(
            Constants.PREF_CURRENT_VERSION, packageInfo.buildNumber);
      });
    if (!Constants.isInDebugMode) {
      final RemoteConfig remoteConfig = await RemoteConfig.instance;
      await remoteConfig.fetch(expiration: const Duration(seconds: 10));
      await remoteConfig.activateFetched();
      String url = "";
      int versionDiff = 0;
      if (Platform.isAndroid) {
        //TODO if upload play store url = "market://details?id=${packageInfo.packageName}";
        url =
            "https://drive.google.com/open?id=1IivQgMXL6_omB7nHQxQxwoENkq3GgAMn";
        versionDiff = remoteConfig.getInt(Constants.ANDROID_APP_VERSION) -
            int.parse(packageInfo.buildNumber);
      } else if (Platform.isIOS) {
        url =
            "itms-apps://itunes.apple.com/tw/app/apple-store/id1439751462?mt=8";
        versionDiff = remoteConfig.getInt(Constants.IOS_APP_VERSION) -
            int.parse(packageInfo.buildNumber);
      } else {
        url = "https://www.facebook.com/NKUST.ITC/";
        versionDiff = remoteConfig.getInt(Constants.APP_VERSION) -
            int.parse(packageInfo.buildNumber);
      }
      if (versionDiff < 5 && versionDiff > 0)
        Utils.showUpdateDialog(context, url);
      else if (versionDiff >= 5) Utils.showForceUpdateDialog(context, url);
    }
  }

  _onRememberPasswordChanged(bool value) async {
    setState(() {
      isRememberPassword = value;
      if (!isRememberPassword) isAutoLogin = false;
      prefs.setBool(Constants.PREF_AUTO_LOGIN, isAutoLogin);
      prefs.setBool(Constants.PREF_REMEMBER_PASSWORD, isRememberPassword);
    });
  }

  _onAutoLoginChanged(bool value) async {
    setState(() {
      isAutoLogin = value;
      isRememberPassword = isAutoLogin;
      prefs.setBool(Constants.PREF_AUTO_LOGIN, isAutoLogin);
      prefs.setBool(Constants.PREF_REMEMBER_PASSWORD, isRememberPassword);
    });
  }

  _getPreference() async {
    prefs = await SharedPreferences.getInstance();
    isRememberPassword =
        prefs.getBool(Constants.PREF_REMEMBER_PASSWORD) ?? true;
    isAutoLogin = prefs.getBool(Constants.PREF_AUTO_LOGIN) ?? false;
    setState(() {
      _username.text = prefs.getString(Constants.PREF_USERNAME) ?? "";
      if (isRememberPassword)
        _password.text = prefs.getString(Constants.PREF_PASSWORD) ?? "";
      if (isAutoLogin) {
        _login();
      }
    });
  }

  _login() async {
    if (_username.text.isEmpty || _password.text.isEmpty) {
      Utils.showToast(app.doNotEmpty);
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) => ProgressDialog(app.logining),
          barrierDismissible: true);
      prefs.setString(Constants.PREF_USERNAME, _username.text);
      if (isRememberPassword)
        prefs.setString(Constants.PREF_PASSWORD, _password.text);
      Helper.instance
          .login(_username.text, _password.text)
          .then((LoginResponse response) async {
        if (Navigator.canPop(context)) Navigator.pop(context, 'dialog');
        if (response.isLogin != null)
          prefs.setBool(Constants.PREF_BUS_ENABLE, response.isLogin.bus);
        prefs.setString(Constants.PREF_USERNAME, _username.text);
        if (isRememberPassword)
          prefs.setString(Constants.PREF_PASSWORD, _password.text);
        _navigateToFilterObject(context);
      }).catchError((e) {
        if (Navigator.canPop(context)) Navigator.pop(context, 'dialog');
        assert(e is DioError);
        DioError dioError = e as DioError;
        switch (dioError.type) {
          case DioErrorType.RESPONSE:
            Utils.showToast(app.loginFail);
            break;
          case DioErrorType.CANCEL:
            break;
          default:
            Utils.handleDioError(dioError, app);
            break;
        }
      });
    }
  }

  _navigateToFilterObject(BuildContext context) async {
    final result = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => HomePage()));
    print(result);
    clearSetting();
  }

  void clearSetting() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool(Constants.PREF_AUTO_LOGIN, false);
    setState(() {
      isAutoLogin = false;
      pictureUrl = "";
      userInfo = null;
    });
  }
}
