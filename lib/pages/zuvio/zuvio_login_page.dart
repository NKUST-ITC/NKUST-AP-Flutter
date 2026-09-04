import 'package:ap_common/ap_common.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/pages/zuvio/ui/zuvio_ui.dart';
import 'package:nkust_ap/pages/zuvio/zuvio_course_list_page.dart';
import 'package:nkust_ap/pages/zuvio/zuvio_service.dart';
import 'package:nkust_ap/utils/global.dart';

class ZuvioLoginPage extends StatefulWidget {
  static const String routerName = '/zuvio/login';

  const ZuvioLoginPage({super.key});

  @override
  ZuvioLoginPageState createState() => ZuvioLoginPageState();
}

class ZuvioLoginPageState extends State<ZuvioLoginPage> {
  final TextEditingController _id = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final FocusNode _idFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  bool _isLoading = false;
  bool _obscure = true;

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
    _id.dispose();
    _password.dispose();
    _idFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ApLocalizations ap = context.ap;
    return Scaffold(
      backgroundColor: context.zc.screen,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(ZGap.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    height: 56,
                    width: 56,
                    decoration: BoxDecoration(
                      color: context.zc.accentSoft,
                      borderRadius: ZRadii.card,
                    ),
                    child: Icon(
                      Icons.co_present_outlined,
                      color: context.zc.onAccentSoft,
                    ),
                  ),
                  const SizedBox(height: ZGap.l),
                  Text(context.t.zuvioLogin, style: context.zt.pageTitle),
                  const SizedBox(height: ZGap.s),
                  Text(
                    context.t.zuvioAccountHint,
                    style: context.zt.supporting,
                  ),
                  const SizedBox(height: ZGap.xxl),
                  ZTextField(
                    controller: _id,
                    focusNode: _idFocus,
                    label: ap.studentId,
                    icon: Icons.person_outline_rounded,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => _passwordFocus.requestFocus(),
                    autofillHints: const <String>[AutofillHints.username],
                  ),
                  const SizedBox(height: ZGap.sm),
                  ZTextField(
                    controller: _password,
                    focusNode: _passwordFocus,
                    label: ap.password,
                    icon: Icons.lock_outline_rounded,
                    obscure: _obscure,
                    onToggleObscure: () =>
                        setState(() => _obscure = !_obscure),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _login(),
                    autofillHints: const <String>[AutofillHints.password],
                  ),
                  const SizedBox(height: ZGap.xl),
                  ZButton(
                    label: ap.login,
                    loading: _isLoading,
                    onPressed: _login,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    if (_id.text.isEmpty || _password.text.isEmpty) {
      UiUtil.instance.showToast(context, context.ap.doNotEmpty);
      return;
    }
    setState(() => _isLoading = true);
    AnalyticsUtil.instance.logEvent('zuvio_login_click');
    try {
      await ZuvioService.instance.login(
        email: _id.text,
        password: _password.text,
      );
      await PreferenceUtil.instance
          .setBool(Constants.prefZuvioSignedOut, false);
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
