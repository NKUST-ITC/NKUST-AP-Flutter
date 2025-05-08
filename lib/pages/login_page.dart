import 'package:ap_common/ap_common.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nkust_ap/api/ap_status_code.dart';
import 'package:nkust_ap/models/login_response.dart';
import 'package:nkust_ap/pages/search_student_id_page.dart';
import 'package:nkust_ap/res/assets.dart';
import 'package:nkust_ap/utils/global.dart';

class LoginPage extends StatefulWidget {
  static const String routerName = '/login';

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  late ApLocalizations ap;

  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();

  final FocusNode usernameFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();

  bool isRememberPassword = true;
  bool isAutoLogin = false;

  bool isLoginIng = false;

  @override
  void initState() {
    AnalyticsUtil.instance.setCurrentScreen(
      'LoginPage',
      'login_page.dart',
    );
    _getPreference();
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
          focusNode: usernameFocusNode,
          nextFocusNode: passwordFocusNode,
          labelText: ap.studentId,
          autofillHints: const <String>[AutofillHints.username],
        ),
        ApTextField(
          obscureText: true,
          textInputAction: TextInputAction.send,
          controller: _password,
          focusNode: passwordFocusNode,
          onSubmitted: (String text) {
            passwordFocusNode.unfocus();
            _login();
          },
          labelText: ap.password,
          autofillHints: const <String>[AutofillHints.password],
        ),
        const SizedBox(height: 8.0),
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
        const SizedBox(height: 8.0),
        ApButton(
          text: ap.login,
          onPressed: isLoginIng
              ? null
              : () {
                  AnalyticsUtil.instance.logEvent('login_click');
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
            final String? username = await Navigator.push<String>(
              context,
              MaterialPageRoute<String>(
                builder: (_) => SearchStudentIdPage(),
              ),
            );
            if (username != null) {
              setState(() {
                _username.text = username;
              });
              if (!context.mounted) return;
              UiUtil.instance.showToast(context, ap.firstLoginHint);
            }
          },
        ),
      ],
    );
  }

  void _onRememberPasswordChanged(bool? value) {
    if (value != null) {
      setState(() {
        isRememberPassword = value;
        if (!isRememberPassword) isAutoLogin = false;
        PreferenceUtil.instance.setBool(Constants.prefAutoLogin, isAutoLogin);
        PreferenceUtil.instance.setBool(
          Constants.prefRememberPassword,
          isRememberPassword,
        );
      });
    }
  }

  void _onAutoLoginChanged(bool? value) {
    if (value != null) {
      setState(() {
        isAutoLogin = value;
        isRememberPassword = isAutoLogin;
        PreferenceUtil.instance.setBool(Constants.prefAutoLogin, isAutoLogin);
        PreferenceUtil.instance.setBool(
          Constants.prefRememberPassword,
          isRememberPassword,
        );
      });
    }
  }

  Future<void> _getPreference() async {
    isRememberPassword =
        PreferenceUtil.instance.getBool(Constants.prefRememberPassword, true);
    isAutoLogin =
        PreferenceUtil.instance.getBool(Constants.prefAutoLogin, false);
    setState(() {
      _username.text =
          PreferenceUtil.instance.getString(Constants.prefUsername, '');
      _password.text = isRememberPassword
          ? PreferenceUtil.instance
              .getStringSecurity(Constants.prefPassword, '')
          : '';
    });
    await Future<void>.delayed(const Duration(microseconds: 50));
  }

  Future<void> _login() async {
    if (_username.text.isEmpty || _password.text.isEmpty) {
      UiUtil.instance.showToast(context, ap.doNotEmpty);
    } else {
      setState(() => isLoginIng = true);
      PreferenceUtil.instance.setString(Constants.prefUsername, _username.text);
      Helper.instance.login(
        context: context,
        username: _username.text,
        password: _password.text,
        clearCache: true,
        callback: GeneralCallback<LoginResponse?>(
          onSuccess: (LoginResponse? response) async {
            PreferenceUtil.instance
                .setString(Constants.prefUsername, _username.text);
            if (isRememberPassword) {
              PreferenceUtil.instance.setStringSecurity(
                Constants.prefPassword,
                _password.text,
              );
            }
            PreferenceUtil.instance
                .setBool(Constants.prefIsOfflineLogin, false);
            TextInput.finishAutofillContext();
            Navigator.of(context).pop(true);
          },
          onFailure: (DioException e) {
            if (e.i18nMessage != null) {
              UiUtil.instance.showToast(context, e.i18nMessage!);
            }
            setState(() => isLoginIng = false);
            if (e.type != DioExceptionType.cancel) _offlineLogin();
          },
          onError: (GeneralResponse response) {
            String? message = '';
            switch (response.statusCode) {
              case ApStatusCode.schoolServerError:
                message = ap.schoolServerError;
              case ApStatusCode.apiServerError:
                message = ap.apiServerError;
              case ApStatusCode.userDataError:
                message = ap.loginFail;
              case ApStatusCode.passwordFiveTimesError:
                //TODO i18n
                message = '您先前已登入失敗達5次!!請30分鐘後再嘗試登入!!';
              case ApStatusCode.cancel:
                message = null;
              default:
                message = ap.somethingError;
            }
            if (message != null) UiUtil.instance.showToast(context, message);
            setState(() => isLoginIng = false);
          },
        ),
      );
    }
  }

  Future<void> _offlineLogin() async {
    final String username =
        PreferenceUtil.instance.getString(Constants.prefUsername, '');
    final String password =
        PreferenceUtil.instance.getStringSecurity(Constants.prefPassword, '');
    if (username.isEmpty || password.isEmpty) {
      UiUtil.instance.showToast(context, ap.noOfflineLoginData);
    } else {
      if (username != _username.text || password != _password.text) {
        UiUtil.instance.showToast(context, ap.offlineLoginPasswordError);
      } else {
        PreferenceUtil.instance.setBool(Constants.prefIsOfflineLogin, true);
        UiUtil.instance.showToast(context, ap.loadOfflineData);
        Navigator.of(context).pop(true);
      }
    }
  }

  Future<void> clearSetting() async {
    PreferenceUtil.instance.setBool(Constants.prefAutoLogin, false);
    setState(() {
      isAutoLogin = false;
    });
  }
}
