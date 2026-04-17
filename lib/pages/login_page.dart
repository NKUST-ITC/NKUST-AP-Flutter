import 'package:ap_common/ap_common.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nkust_ap/api/ap_status_code.dart';
import 'package:nkust_ap/api/exceptions/api_exception.dart';
import 'package:nkust_ap/api/exceptions/api_exception_l10n.dart';
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
  bool _obscurePassword = true;

  @override
  void initState() {
    AnalyticsUtil.instance.setCurrentScreen('LoginPage', 'login_page.dart');
    _getPreference();
    super.initState();
  }

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    usernameFocusNode.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ap = context.ap;
    return LoginScaffold(
      logoMode: LogoMode.image,
      logoSource: ImageAssets.K,
      logoSubtitle: AppLocalizations.of(context).appName,
      forms: <Widget>[
        Text(
          ap.login,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24.0),
        ApTextField(
          controller: _username,
          keyboardType: TextInputType.emailAddress,
          focusNode: usernameFocusNode,
          nextFocusNode: passwordFocusNode,
          labelText: ap.studentId,
          prefixIcon: Icons.person_outline_rounded,
          autofillHints: const <String>[AutofillHints.username],
        ),
        const SizedBox(height: 12.0),
        ApTextField(
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.send,
          controller: _password,
          focusNode: passwordFocusNode,
          onSubmitted: (String text) {
            passwordFocusNode.unfocus();
            _login();
          },
          labelText: ap.password,
          prefixIcon: Icons.lock_outline_rounded,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
          autofillHints: const <String>[AutofillHints.password],
        ),
        const SizedBox(height: 12.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextCheckBox(
              text: ap.autoLogin,
              value: isAutoLogin,
              onChanged: _onAutoLoginChanged,
            ),
            const SizedBox(width: 8.0),
            TextCheckBox(
              text: ap.rememberPassword,
              value: isRememberPassword,
              onChanged: _onRememberPasswordChanged,
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        ApButton(
          text: ap.login,
          isLoading: isLoginIng,
          onPressed: () {
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
          onPressed: _searchUsername,
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
    isRememberPassword = PreferenceUtil.instance.getBool(
      Constants.prefRememberPassword,
      true,
    );
    isAutoLogin = PreferenceUtil.instance.getBool(
      Constants.prefAutoLogin,
      false,
    );
    setState(() {
      _username.text = PreferenceUtil.instance.getString(
        Constants.prefUsername,
        '',
      );
      _password.text = isRememberPassword
          ? PreferenceUtil.instance.getStringSecurity(
              Constants.prefPassword,
              '',
            )
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
      try {
        await Helper.instance.login(
          username: _username.text,
          password: _password.text,
          clearCache: true,
        );
        PreferenceUtil.instance.setString(
          Constants.prefUsername,
          _username.text,
        );
        if (isRememberPassword) {
          PreferenceUtil.instance.setStringSecurity(
            Constants.prefPassword,
            _password.text,
          );
        }
        PreferenceUtil.instance.setBool(Constants.prefIsOfflineLogin, false);
        TextInput.finishAutofillContext();
        Navigator.of(context).pop(true);
      } on ApException catch (e) {
        // Silently dismiss user-initiated cancellations (e.g. closing the
        // leave-system WebView); any other failure gets a user-visible toast.
        if (e is! CancelledException) {
          UiUtil.instance.showToast(context, e.toLocalizedMessage(context));
        }
        setState(() => isLoginIng = false);
        // Offer offline mode on network failure so the user isn't stuck
        // on a blocked login screen when their connection drops.
        if (e is NetworkException) _offlineLogin();
      } on DioException catch (e) {
        if (e.i18nMessage != null) {
          UiUtil.instance.showToast(context, e.i18nMessage!);
        }
        setState(() => isLoginIng = false);
        if (e.type != DioExceptionType.cancel) _offlineLogin();
      }
    }
  }

  Future<void> _offlineLogin() async {
    final String username = PreferenceUtil.instance.getString(
      Constants.prefUsername,
      '',
    );
    final String password = PreferenceUtil.instance.getStringSecurity(
      Constants.prefPassword,
      '',
    );
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

  Future<void> _searchUsername() async {
    final String? username = await Navigator.push<String>(
      context,
      MaterialPageRoute<String>(builder: (_) => SearchStudentIdPage()),
    );
    if (username != null) {
      setState(() => _username.text = username);
      if (!mounted) return;
      UiUtil.instance.showToast(context, ap.firstLoginHint);
    }
  }

  Future<void> clearSetting() async {
    PreferenceUtil.instance.setBool(Constants.prefAutoLogin, false);
    setState(() => isAutoLogin = false);
  }
}
