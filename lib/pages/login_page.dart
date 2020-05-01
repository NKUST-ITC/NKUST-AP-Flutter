import 'dart:io';

import 'package:ap_common/scaffold/login_scaffold.dart';
import 'package:ap_common/widgets/progress_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_autofill/flutter_autofill.dart';
import 'package:nkust_ap/models/login_response.dart';
import 'package:nkust_ap/pages/search_student_id_page.dart';
import 'package:nkust_ap/res/assets.dart';
import 'package:nkust_ap/utils/global.dart';
import 'package:nkust_ap/utils/preferences.dart';
import 'package:nkust_ap/widgets/share_data_widget.dart';

class LoginPage extends StatefulWidget {
  static const String routerName = "/login";

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  AppLocalizations app;

  final _username = TextEditingController();
  final _password = TextEditingController();

  final usernameFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();

  var isRememberPassword = true;
  var isAutoLogin = false;

  @override
  void initState() {
    FA.setCurrentScreen("LoginPage", "login_page.dart");
    _getPreference();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    app = AppLocalizations.of(context);
    return LoginScaffold(
      logoMode: LogoMode.image,
      logoSource: ImageAssets.K,
      forms: <Widget>[
        ApTextField(
          controller: _username,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          focusNode: usernameFocusNode,
          nextFocusNode: passwordFocusNode,
          labelText: app.username,
        ),
        ApTextField(
          obscureText: true,
          textInputAction: TextInputAction.send,
          controller: _password,
          focusNode: passwordFocusNode,
          onSubmitted: (text) {
            passwordFocusNode.unfocus();
            _login();
          },
          labelText: app.password,
        ),
        SizedBox(height: 8.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextCheckBox(
              text: app.autoLogin,
              value: isAutoLogin,
              onChanged: _onAutoLoginChanged,
            ),
            TextCheckBox(
              text: app.remember,
              value: isRememberPassword,
              onChanged: _onRememberPasswordChanged,
            ),
          ],
        ),
        SizedBox(height: 8.0),
        ApButton(
          text: app.login,
          onPressed: () {
            FA.logAction('login', 'click');
            _login();
          },
        ),
        ApFlatButton(
          text: app.offlineLogin,
          onPressed: _offlineLogin,
        ),
        ApFlatButton(
          text: app.searchUsername,
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
        )
      ],
    );
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
        Navigator.of(context).pop(true);
        if (!kIsWeb && Platform.isAndroid) await FlutterAutofill.commit();
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
        Navigator.of(context).pop(true);
      }
    }
  }

  void clearSetting() async {
    Preferences.setBool(Constants.PREF_AUTO_LOGIN, false);
    setState(() {
      isAutoLogin = false;
    });
  }
}
