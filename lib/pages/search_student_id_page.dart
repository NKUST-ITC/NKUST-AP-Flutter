import 'package:ap_common/ap_common.dart';
import 'package:flutter/material.dart';
import 'package:nkust_crawler/nkust_crawler.dart';
import 'package:nkust_ap/res/assets.dart';
import 'package:nkust_ap/utils/global.dart';
import 'package:nkust_ap/widgets/turnstile_challenge_view.dart';
import 'package:sprintf/sprintf.dart';

class SearchStudentIdPage extends StatefulWidget {
  static const String routerName = '/searchUsername';

  @override
  SearchStudentIdPageState createState() => SearchStudentIdPageState();
}

class SearchStudentIdPageState extends State<SearchStudentIdPage> {
  final TextEditingController _id = TextEditingController();
  final FocusNode idFocusNode = FocusNode();

  final GlobalKey<TurnstileChallengeViewState> _challengeKey =
      GlobalKey<TurnstileChallengeViewState>();

  DateTime birthday = DateTime(DateTime.now().year - 18);
  bool isAutoFill = true;
  bool isSearching = false;

  /// Set once the inline challenge resolves; cleared when its token expires.
  String? _turnstileToken;
  String? _challengeError;

  @override
  void initState() {
    super.initState();
    AnalyticsUtil.instance.setCurrentScreen(
      'SearchUsernamePagePage',
      'search_student_id_page.dart',
    );
  }

  @override
  void dispose() {
    _id.dispose();
    idFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ApLocalizations ap = context.ap;

    return LoginScaffold(
      logoMode: LogoMode.image,
      logoSource: ImageAssets.K,
      appBarTitle: ap.searchUsername,
      forms: <Widget>[
        Text(
          context.t.searchStudentId,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        _buildDatePicker(context),
        const SizedBox(height: 16),
        ApTextField(
          controller: _id,
          focusNode: idFocusNode,
          labelText: ap.id,
          prefixIcon: Icons.badge_outlined,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _search(),
        ),
        const SizedBox(height: 16),
        TextCheckBox(
          value: isAutoFill,
          text: ap.autoFill,
          onChanged: _onAutoFillChanged,
        ),
        const SizedBox(height: 16),
        TurnstileChallengeView(
          key: _challengeKey,
          onToken: (String? token) {
            if (!mounted) return;
            setState(() {
              _turnstileToken = token;
              if (token != null) _challengeError = null;
            });
          },
          onError: (String code) {
            if (!mounted) return;
            setState(() => _challengeError = code);
          },
        ),
        if (_challengeError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '${context.t.studentIdQueryChallengeFailed}（$_challengeError）',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        const SizedBox(height: 24),
        ApButton(
          text: ap.search,
          isLoading: isSearching,
          onPressed: _turnstileToken == null ? null : _search,
        ),
      ],
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final ApLocalizations ap = context.ap;

    return InkWell(
      onTap: () async {
        final DateTime? date = await showDatePicker(
          context: context,
          initialDate: birthday,
          firstDate: DateTime(1911),
          lastDate: DateTime.now(),
        );
        if (date != null) setState(() => birthday = date);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outline.withAlpha(77),
          ),
        ),
        child: Row(
          children: <Widget>[
            Icon(
              Icons.calendar_today_outlined,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    ap.birthDay,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    sprintf(
                      '%i-%02i-%02i',
                      <int>[birthday.year, birthday.month, birthday.day],
                    ),
                    style: TextStyle(
                      fontSize: 16,
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_drop_down_rounded,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  void _onAutoFillChanged(bool? value) {
    if (value != null) setState(() => isAutoFill = value);
  }

  Future<void> _search() async {
    if (_id.text.isEmpty) {
      UiUtil.instance.showToast(context, context.ap.doNotEmpty);
      return;
    }
    final String? token = _turnstileToken;
    if (token == null) {
      UiUtil.instance.showToast(
        context,
        context.t.studentIdQueryVerifyHint,
      );
      return;
    }

    AnalyticsUtil.instance.logEvent('search_username_click');
    setState(() => isSearching = true);

    try {
      final StudentIdQueryResult result =
          await Helper.instance.queryStudentId(
        rocId: _id.text,
        birthday: birthday,
        turnstileToken: token,
      );
      if (!mounted) return;
      setState(() => isSearching = false);

      // A token is single-use, so the challenge has to be re-armed whether
      // the lookup succeeded or not.
      await _rearmChallenge();

      if (!result.isSuccess) {
        _showResultDialog(
          result.message ?? context.ap.unknownError,
          showFirstHint: false,
        );
        return;
      }

      if (!mounted) return;
      if (isAutoFill) {
        Navigator.pop(context, result.id);
      } else {
        _showResultDialog(
          context.t.searchStudentIdFormat(
            name: result.name ?? '',
            id: result.id!,
          ),
        );
      }
    } on ApException catch (e) {
      if (!mounted) return;
      setState(() => isSearching = false);
      await _rearmChallenge();
      if (e is CancelledException) return;
      // ErrorInterceptor already turns transport failures into readable
      // Chinese messages (「沒有網路連線」 etc.), so show them as-is.
      _showResultDialog(e.message, showFirstHint: false);
    }
  }

  Future<void> _rearmChallenge() async {
    if (mounted) setState(() => _turnstileToken = null);
    await _challengeKey.currentState?.reload();
  }

  void _showResultDialog(String? text, {bool showFirstHint = true}) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.ap.searchResult),
        content: SelectableText.rich(
          TextSpan(
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              height: 1.3,
              fontSize: 16.0,
            ),
            children: <TextSpan>[
              TextSpan(
                text: text,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (showFirstHint)
                TextSpan(
                  text: '\n${context.t.firstLoginHint}',
                ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            child: Text(context.ap.iKnow),
          ),
        ],
      ),
    );
  }
}
