import 'package:ap_common/models/user_info.dart';
import 'package:ap_common/resources/ap_theme.dart';
import 'package:ap_common/scaffold/login_scaffold.dart';
import 'package:ap_common/utils/ap_localizations.dart';
import 'package:ap_common/utils/ap_utils.dart';
import 'package:ap_common/widgets/default_dialog.dart';
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

  final TextEditingController _id = TextEditingController();
  final FocusNode idFocusNode = FocusNode();

  DateTime birthday = DateTime(DateTime.now().year - 18);

  bool isAutoFill = true;

  @override
  void initState() {
    super.initState();
    FirebaseAnalyticsUtils.instance.setCurrentScreen(
      'SearchUsernamePagePage',
      'search_student_id_page.dart',
    );
  }

  @override
  Widget build(BuildContext context) {
    app = AppLocalizations.of(context);
    ap = ApLocalizations.of(context);
    return LoginScaffold(
      logoMode: LogoMode.image,
      logoSource: ImageAssets.K,
      forms: <Widget>[
        InkWell(
          onTap: () async {
            final DateTime? date = await showDatePicker(
              context: context,
              initialDate: birthday,
              firstDate: DateTime(1911),
              lastDate: DateTime.now(),
            );
            if (date != null) setState(() => birthday = date);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(ap.birthDay),
              Text(
                sprintf(
                  '%i-%02i-%02i',
                  <int>[
                    birthday.year,
                    birthday.month,
                    birthday.day,
                  ],
                ),
                style: const TextStyle(
                  fontSize: 17.0,
                ),
              ),
              Divider(
                color: ApTheme.of(context).grey,
              ),
            ],
          ),
        ),
        ApTextField(
          textInputAction: TextInputAction.send,
          controller: _id,
          focusNode: idFocusNode,
          onSubmitted: (String text) {
            idFocusNode.unfocus();
            _search();
          },
          labelText: ap.id,
        ),
        const SizedBox(height: 8.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextCheckBox(
              text: ap.autoFill,
              onChanged: _onAutoFillChanged,
              value: isAutoFill,
            ),
          ],
        ),
        const SizedBox(height: 8.0),
        ApButton(
          text: ap.search,
          onPressed: () {
            FirebaseAnalyticsUtils.instance.logEvent('search_username_click');
            _search();
          },
        )
      ],
    );
  }

  void _onAutoFillChanged(bool? value) {
    if (value != null) {
      setState(() {
        isAutoFill = value;
      });
    }
  }

  Future<void> _search() async {
    if (_id.text.isEmpty) {
      ApUtils.showToast(context, ap.doNotEmpty);
    } else {
      NKUSTHelper.instance.getUsername(
        rocId: _id.text,
        birthday: birthday,
        callback: GeneralCallback<UserInfo>(
          onSuccess: (UserInfo data) {
            if (isAutoFill) {
              Navigator.pop(context, data.id);
            } else {
              _showResultDialog(
                sprintf(
                  AppLocalizations.of(context).searchStudentIdFormat,
                  <dynamic>[
                    data.name,
                    data.id,
                  ],
                ),
              );
            }
          },
          onError: (GeneralResponse response) => _showResultDialog(
            response.statusCode == 404 ? response.message : ap.unknownError,
            showFirstHint: false,
          ),
          onFailure: (DioException e) {},
        ),
      );
    }
  }

  void _showResultDialog(
    String? text, {
    bool showFirstHint = true,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) => DefaultDialog(
        title: ap.searchResult,
        actionText: ap.iKnow,
        actionFunction: () => Navigator.of(context, rootNavigator: true).pop(),
        contentWidget: SelectableText.rich(
          TextSpan(
            style: TextStyle(
              color: ApTheme.of(context).greyText,
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
      ),
    );
  }
}
