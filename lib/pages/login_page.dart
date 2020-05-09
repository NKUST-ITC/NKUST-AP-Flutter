import 'dart:io';

import 'package:ap_common/callback/general_callback.dart';
import 'package:ap_common/scaffold/login_scaffold.dart';
import 'package:ap_common/utils/ap_localizations.dart';
import 'package:ap_common/utils/ap_utils.dart';
import 'package:ap_common/utils/preferences.dart';
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
import 'package:nkust_ap/widgets/share_data_widget.dart';

class LoginPage extends StatefulWidget {
  static const String routerName = "/login";

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  ApLocalizations ap;

  final _username = TextEditingController();
  final _password = TextEditingController();

  final usernameFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();

  var isRememberPassword = true;
  var isAutoLogin = false;

  int gravity = Toast.BOTTOM;

  @override
  void initState() {
    FirebaseAnalyticsUtils.instance.setCurrentScreen("LoginPage", "login_page.dart");
    _getPreference();
    KeyboardVisibilityNotification().addNewListener(
      onShow: () {
        gravity = Toast.TOP;
      },
      onHide: () {
        gravity = Toast.BOTTOM;
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ap = ApLocalizations.of(context);
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
          labelText: ap.username,
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
          labelText: ap.password,
        ),
        SizedBox(height: 8.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextCheckBox(
              text: ap.autoLogin,
              value: isAutoLogin,
              onChanged: _onAutoLoginChanged,
            ),
            TextCheckBox(
              text: ap.remember,
              value: isRememberPassword,
              onChanged: _onRememberPasswordChanged,
            ),
          ],
        ),
        SizedBox(height: 8.0),
        ApButton(
          text: ap.login,
          onPressed: () {
            FirebaseAnalyticsUtils.instance.logAction('login', 'click');
            _login();
          },
        ),
        ApFlatButton(
          text: ap.offlineLogin,
          onPressed: _offlineLogin,
        ),
        ApFlatButton(
          text: ap.searchUsername,
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
              ApUtils.showToast(context, ap.firstLoginHint);
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
      ApUtils.showToast(context, ap.doNotEmpty, gravity: gravity);
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) => WillPopScope(
            child: ProgressDialog(ap.logining),
            onWillPop: () async {
              return false;
            }),
        barrierDismissible: false,
      );
      Preferences.setString(Constants.PREF_USERNAME, _username.text);
      Helper.instance.login(
        username: _username.text,
        password: _password.text,
        callback: GeneralCallback<LoginResponse>(
          onSuccess: (LoginResponse response) async {
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
          },
          onFailure: (DioError e) {
            Navigator.of(context, rootNavigator: true).pop();
            ApUtils.handleDioError(context, e, gravity: gravity);
            if (e.type != DioErrorType.CANCEL) _offlineLogin();
          },
          onError: (GeneralResponse response) {
            Navigator.of(context, rootNavigator: true).pop();
            String message = '';
            switch (response.statusCode) {
              case Helper.SCHOOL_SERVER_ERROR:
                message = ap.schoolSeverError;
                break;
              case Helper.API_SERVER_ERROR:
                message = ap.apiSeverError;
                break;
              case Helper.USER_DATA_ERROR:
                message = ap.loginFail;
                break;
              default:
                message = ap.somethingError;
                break;
            }
            ApUtils.showToast(context, message);
          },
        ),
      );
    }
  }

  _offlineLogin() async {
    String username = Preferences.getString(Constants.PREF_USERNAME, '');
    String password =
        Preferences.getStringSecurity(Constants.PREF_PASSWORD, '');
    if (username.isEmpty || password.isEmpty) {
      ApUtils.showToast(context, ap.noOfflineLoginData);
    } else {
      if (username != _username.text || password != _password.text)
        ApUtils.showToast(context, ap.offlineLoginPasswordError);
      else {
        Preferences.setBool(Constants.PREF_IS_OFFLINE_LOGIN, true);
        ApUtils.showToast(context, ap.loadOfflineData);
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
