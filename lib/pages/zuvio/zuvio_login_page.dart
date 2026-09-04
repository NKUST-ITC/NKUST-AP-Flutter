import 'package:ap_common/ap_common.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/pages/zuvio/zuvio_course_list_page.dart';
import 'package:nkust_ap/pages/zuvio/zuvio_service.dart';
import 'package:nkust_ap/res/assets.dart';
import 'package:nkust_ap/utils/global.dart';

class ZuvioLoginPage extends StatefulWidget {
  static const String routerName = '/zuvio/login';

  const ZuvioLoginPage({super.key});

  @override
  ZuvioLoginPageState createState() => ZuvioLoginPageState();
}

class ZuvioLoginPageState extends State<ZuvioLoginPage> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    AnalyticsUtil.instance.setCurrentScreen(
      'ZuvioLoginPage',
      'zuvio_login_page.dart',
    );
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ApLocalizations ap = context.ap;
    return LoginScaffold(
      logoMode: LogoMode.image,
      logoSource: ImageAssets.K,
      appBarTitle: context.t.zuvioTitle,
      forms: <Widget>[
        Text(
          context.t.zuvioLogin,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          context.t.zuvioAccountHint,
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ApTextField(
          controller: _email,
          focusNode: _emailFocusNode,
          nextFocusNode: _passwordFocusNode,
          labelText: ap.studentId,
          prefixIcon: Icons.person_outline_rounded,
          autofillHints: const <String>[AutofillHints.username],
        ),
        const SizedBox(height: 12),
        ApTextField(
          controller: _password,
          focusNode: _passwordFocusNode,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.send,
          onSubmitted: (_) {
            _passwordFocusNode.unfocus();
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
        const SizedBox(height: 24),
        ApButton(
          text: ap.login,
          isLoading: _isLoading,
          onPressed: _login,
        ),
      ],
    );
  }

  Future<void> _login() async {
    if (_email.text.isEmpty || _password.text.isEmpty) {
      UiUtil.instance.showToast(context, context.ap.doNotEmpty);
      return;
    }
    setState(() => _isLoading = true);
    AnalyticsUtil.instance.logEvent('zuvio_login_click');
    try {
      await ZuvioService.instance.login(
        email: _email.text,
        password: _password.text,
      );
      if (!mounted) return;
      setState(() => _isLoading = false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(builder: (_) => const ZuvioCourseListPage()),
      );
    } on ZuvioException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      UiUtil.instance.showToast(context, e.message);
    }
  }
}
