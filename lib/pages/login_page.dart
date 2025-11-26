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

  final _username = TextEditingController();
  final _password = TextEditingController();
  final usernameFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();

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
    ap = ApLocalizations.of(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? <Color>[
                    colorScheme.surface,
                    colorScheme.surfaceContainerLowest,
                  ]
                : <Color>[
                    colorScheme.primary,
                    colorScheme.primaryContainer,
                  ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _buildLogo(colorScheme, isDark),
                  const SizedBox(height: 48),
                  _buildLoginCard(colorScheme, isDark),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(ColorScheme colorScheme, bool isDark) {
    return Column(
      children: <Widget>[
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: isDark
                ? colorScheme.primaryContainer
                : colorScheme.onPrimary.withAlpha(51),
            borderRadius: BorderRadius.circular(24),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: colorScheme.shadow.withAlpha(26),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.asset(
              ImageAssets.K,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '高科校務通',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isDark ? colorScheme.onSurface : colorScheme.onPrimary,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard(ColorScheme colorScheme, bool isDark) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: colorScheme.shadow.withAlpha(26),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                ap.login,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _buildTextField(
                controller: _username,
                focusNode: usernameFocusNode,
                nextFocusNode: passwordFocusNode,
                labelText: ap.studentId,
                prefixIcon: Icons.person_outline_rounded,
                keyboardType: TextInputType.text,
                autofillHints: const <String>[AutofillHints.username],
                colorScheme: colorScheme,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _password,
                focusNode: passwordFocusNode,
                labelText: ap.password,
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                autofillHints: const <String>[AutofillHints.password],
                colorScheme: colorScheme,
                onSubmitted: (_) => _login(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _buildCheckbox(
                      value: isAutoLogin,
                      label: ap.autoLogin,
                      onChanged: _onAutoLoginChanged,
                      colorScheme: colorScheme,
                    ),
                  ),
                  Expanded(
                    child: _buildCheckbox(
                      value: isRememberPassword,
                      label: ap.rememberPassword,
                      onChanged: _onRememberPasswordChanged,
                      colorScheme: colorScheme,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: isLoginIng ? null : _login,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoginIng
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.onPrimary,
                        ),
                      )
                    : Text(
                        ap.login,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _offlineLogin,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  ap.offlineLogin,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _searchUsername,
                child: Text(
                  ap.searchUsername,
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    FocusNode? nextFocusNode,
    required String labelText,
    required IconData prefixIcon,
    required ColorScheme colorScheme,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    TextInputAction textInputAction = TextInputAction.next,
    List<String>? autofillHints,
    Widget? suffixIcon,
    ValueChanged<String>? onSubmitted,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      style: TextStyle(
        color: colorScheme.onSurface,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          color: colorScheme.onSurfaceVariant,
        ),
        prefixIcon: Icon(
          prefixIcon,
          color: colorScheme.onSurfaceVariant,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.outline.withAlpha(77),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 2,
          ),
        ),
      ),
      onSubmitted: onSubmitted ??
          (_) {
            if (nextFocusNode != null) {
              FocusScope.of(context).requestFocus(nextFocusNode);
            }
          },
    );
  }

  Widget _buildCheckbox({
    required bool value,
    required String label,
    required ValueChanged<bool?> onChanged,
    required ColorScheme colorScheme,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: value,
                onChanged: onChanged,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
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
      Helper.instance.login(
        context: context,
        username: _username.text,
        password: _password.text,
        clearCache: true,
        callback: GeneralCallback<LoginResponse?>(
          onSuccess: (response) async {
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
            PreferenceUtil.instance.setBool(
              Constants.prefIsOfflineLogin,
              false,
            );
            TextInput.finishAutofillContext();
            Navigator.of(context).pop(true);
          },
          onFailure: (e) {
            if (e.i18nMessage != null) {
              UiUtil.instance.showToast(context, e.i18nMessage!);
            }
            setState(() => isLoginIng = false);
            if (e.type != DioExceptionType.cancel) _offlineLogin();
          },
          onError: (response) {
            String? message;
            switch (response.statusCode) {
              case ApStatusCode.schoolServerError:
                message = ap.schoolServerError;
              case ApStatusCode.apiServerError:
                message = ap.apiServerError;
              case ApStatusCode.userDataError:
                message = ap.loginFail;
              case ApStatusCode.passwordFiveTimesError:
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
