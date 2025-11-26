import 'package:ap_common/ap_common.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/api/nkust_helper.dart';
import 'package:nkust_ap/res/assets.dart';
import 'package:nkust_ap/utils/global.dart';
import 'package:sprintf/sprintf.dart';

class SearchStudentIdPage extends StatefulWidget {
  static const String routerName = '/searchUsername';

  @override
  SearchStudentIdPageState createState() => SearchStudentIdPageState();
}

class SearchStudentIdPageState extends State<SearchStudentIdPage> {
  late AppLocalizations app;
  late ApLocalizations ap;

  final _id = TextEditingController();
  final idFocusNode = FocusNode();

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
    app = AppLocalizations.of(context);
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
          child: Column(
            children: <Widget>[
              _buildAppBar(colorScheme, isDark),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        _buildLogo(colorScheme, isDark),
                        const SizedBox(height: 32),
                        _buildSearchCard(colorScheme, isDark),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(ColorScheme colorScheme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: isDark ? colorScheme.onSurface : colorScheme.onPrimary,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Text(
              ap.searchUsername,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isDark ? colorScheme.onSurface : colorScheme.onPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildLogo(ColorScheme colorScheme, bool isDark) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.primaryContainer
            : colorScheme.onPrimary.withAlpha(51),
        borderRadius: BorderRadius.circular(20),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: colorScheme.shadow.withAlpha(26),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          ImageAssets.K,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildSearchCard(ColorScheme colorScheme, bool isDark) {
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              '查詢學號',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildDatePicker(colorScheme),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _id,
              focusNode: idFocusNode,
              labelText: ap.id,
              prefixIcon: Icons.badge_outlined,
              colorScheme: colorScheme,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _search(),
            ),
            const SizedBox(height: 16),
            _buildCheckbox(
              value: isAutoFill,
              label: ap.autoFill,
              onChanged: _onAutoFillChanged,
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: isSearching ? null : _search,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isSearching
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.onPrimary,
                      ),
                    )
                  : Text(
                      ap.search,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(ColorScheme colorScheme) {
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

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String labelText,
    required IconData prefixIcon,
    required ColorScheme colorScheme,
    TextInputAction textInputAction = TextInputAction.done,
    ValueChanged<String>? onSubmitted,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      textInputAction: textInputAction,
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
      onSubmitted: onSubmitted,
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
          mainAxisAlignment: MainAxisAlignment.center,
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
            Text(
              label,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onAutoFillChanged(bool? value) {
    if (value != null) {
      setState(() => isAutoFill = value);
    }
  }

  Future<void> _search() async {
    if (_id.text.isEmpty) {
      UiUtil.instance.showToast(context, ap.doNotEmpty);
    } else {
      setState(() => isSearching = true);
      AnalyticsUtil.instance.logEvent('search_username_click');

      NKUSTHelper.instance.getUsername(
        rocId: _id.text,
        birthday: birthday,
        callback: GeneralCallback<UserInfo>(
          onSuccess: (data) {
            setState(() => isSearching = false);
            if (isAutoFill) {
              Navigator.pop(context, data.id);
            } else {
              _showResultDialog(
                sprintf(
                  AppLocalizations.of(context).searchStudentIdFormat,
                  <String?>[data.name, data.id],
                ),
              );
            }
          },
          onError: (response) {
            setState(() => isSearching = false);
            _showResultDialog(
              response.statusCode == 404 ? response.message : ap.unknownError,
              showFirstHint: false,
            );
          },
          onFailure: (_) {
            setState(() => isSearching = false);
          },
        ),
      );
    }
  }

  void _showResultDialog(String? text, {bool showFirstHint = true}) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(ap.searchResult),
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
                  text: '\n${AppLocalizations.of(context).firstLoginHint}',
                ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            child: Text(ap.iKnow),
          ),
        ],
      ),
    );
  }
}
