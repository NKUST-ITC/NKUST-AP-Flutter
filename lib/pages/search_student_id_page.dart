import 'package:ap_common/ap_common.dart';
import 'package:flutter/material.dart';
import 'package:nkust_crawler/nkust_crawler.dart';
import 'package:nkust_crawler/nkust_crawler.dart';
import 'package:nkust_ap/res/assets.dart';
import 'package:nkust_ap/utils/global.dart';
import 'package:sprintf/sprintf.dart';

class SearchStudentIdPage extends StatefulWidget {
  static const String routerName = '/searchUsername';

  @override
  SearchStudentIdPageState createState() => SearchStudentIdPageState();
}

class SearchStudentIdPageState extends State<SearchStudentIdPage> {
  final TextEditingController _id = TextEditingController();
  final FocusNode idFocusNode = FocusNode();

  DateTime birthday = DateTime(DateTime.now().year - 18);
  bool isAutoFill = true;
  bool isSearching = false;

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
        const SizedBox(height: 24),
        ApButton(
          text: ap.search,
          isLoading: isSearching,
          onPressed: _search,
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
    setState(() => isSearching = true);
    AnalyticsUtil.instance.logEvent('search_username_click');

    try {
      final UserInfo data = await Helper.instance.searchUsername(
        rocId: _id.text,
        birthday: birthday,
      );
      if (!mounted) return;
      setState(() => isSearching = false);
      if (isAutoFill) {
        Navigator.pop(context, data.id);
      } else {
        _showResultDialog(
          context.t.searchStudentIdFormat(
            name: data.name ?? '',
            id: data.id,
          ),
        );
      }
    } on ApException catch (e) {
      if (!mounted) return;
      setState(() => isSearching = false);
      if (e is CancelledException) return;
      // 404 means "no match found" — surface the server's own message
      // (e.g. "查無此人") instead of the generic ap.unknownError.
      final bool isNotFound = e is ServerException && e.httpStatusCode == 404;
      _showResultDialog(
        isNotFound ? e.message : context.ap.unknownError,
        showFirstHint: false,
      );
    }
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
