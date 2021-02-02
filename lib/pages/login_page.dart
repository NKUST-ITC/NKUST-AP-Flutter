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
import 'package:flutter/services.dart';
import 'package:nkust_ap/api/ap_status_code.dart';
import 'package:nkust_ap/models/login_response.dart';
import 'package:nkust_ap/pages/mobile_nkust_page.dart';
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
    FirebaseAnalyticsUtils.instance
        .setCurrentScreen("LoginPage", "login_page.dart");
    _getPreference();
    if ((!kIsWeb && (Platform.isAndroid || Platform.isIOS))) {
      KeyboardVisibility.onChange.listen(
        (bool visible) => gravity = visible ? Toast.TOP : Toast.BOTTOM,
      );
    }
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
          labelText: ap.studentId,
          autofillHints: [AutofillHints.username],
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
          autofillHints: [AutofillHints.password],
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
              text: ap.rememberPassword,
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
              MaterialPageRoute(
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
  }

  _login() async {
    if (_username.text.isEmpty || _password.text.isEmpty) {
      ApUtils.showToast(context, ap.doNotEmpty, gravity: gravity);
    } else {
      Preferences.setString(Constants.PREF_USERNAME, _username.text);
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MobileNkustPage(
            username: _username.text,
            password: _password.text,
            clearCache: true,
          ),
        ),
      );
      if (result ?? false) {
        // ShareDataWidget.of(context).data.loginResponse = response;
        Preferences.setString(Constants.PREF_USERNAME, _username.text);
        if (isRememberPassword) {
          Preferences.setStringSecurity(
              Constants.PREF_PASSWORD, _password.text);
        }
        Helper.username = _username.text;
        Helper.password = _password.text;
        Preferences.setBool(Constants.PREF_IS_OFFLINE_LOGIN, false);
        TextInput.finishAutofillContext();
        Navigator.of(context).pop(true);
      }
      // Helper.instance.login(
      //   username: _username.text,
      //   password: _password.text,
      //   callback: GeneralCallback<LoginResponse>(
      //     onSuccess: (LoginResponse response) async {
      //       Navigator.of(context, rootNavigator: true).pop();
      //       ShareDataWidget.of(context).data.loginResponse = response;
      //       Preferences.setString(Constants.PREF_USERNAME, _username.text);
      //       if (isRememberPassword) {
      //         Preferences.setStringSecurity(
      //             Constants.PREF_PASSWORD, _password.text);
      //       }
      //       Preferences.setBool(Constants.PREF_IS_OFFLINE_LOGIN, false);
      //       TextInput.finishAutofillContext();
      //       Navigator.of(context).pop(true);
      //     },
      //     onFailure: (DioError e) {
      //       Navigator.of(context, rootNavigator: true).pop();
      //       ApUtils.handleDioError(context, e, gravity: gravity);
      //       if (e.type != DioErrorType.CANCEL) _offlineLogin();
      //     },
      //     onError: (GeneralResponse response) {
      //       Navigator.of(context, rootNavigator: true).pop();
      //       String message = '';
      //       switch (response.statusCode) {
      //         case ApStatusCode.SCHOOL_SERVER_ERROR:
      //           message = ap.schoolServerError;
      //           break;
      //         case ApStatusCode.API_SERVER_ERROR:
      //           message = ap.apiServerError;
      //           break;
      //         case ApStatusCode.USER_DATA_ERROR:
      //           message = ap.loginFail;
      //           break;
      //         default:
      //           message = ap.somethingError;
      //           break;
      //       }
      //       ApUtils.showToast(context, message);
      //     },
      //   ),
      // );
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
