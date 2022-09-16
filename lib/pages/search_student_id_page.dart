import 'package:ap_common/models/user_info.dart';
import 'package:ap_common/resources/ap_theme.dart';
import 'package:ap_common/scaffold/login_scaffold.dart';
import 'package:ap_common/utils/ap_localizations.dart';
import 'package:ap_common/utils/ap_utils.dart';
import 'package:ap_common/widgets/default_dialog.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/res/assets.dart';
import 'package:nkust_ap/utils/app_localizations.dart';
import 'package:nkust_ap/utils/global.dart';
import 'package:nkust_ap/api/nkust_helper.dart';
import 'package:sprintf/sprintf.dart';

class SearchStudentIdPage extends StatefulWidget {
  static const String routerName = "/searchUsername";

  @override
  SearchStudentIdPageState createState() => SearchStudentIdPageState();
}

class SearchStudentIdPageState extends State<SearchStudentIdPage> {
  AppLocalizations? app;
  late ApLocalizations ap;

  final _id = TextEditingController();
  final idFocusNode = FocusNode();

  DateTime birthday = DateTime(DateTime.now().year - 18);

  bool? isAutoFill = true;

  @override
  void initState() {
    super.initState();
    FirebaseAnalyticsUtils.instance.setCurrentScreen(
        "SearchUsernamePagePage", "search_student_id_page.dart");
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
            var date = await showDatePicker(
              context: context,
              initialDate: birthday,
              firstDate: DateTime(1911),
              lastDate: DateTime.now(),
            );
            if (date != null) setState(() => birthday = date);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ap.birthDay),
              Text(
                sprintf(
                  "%i-%02i-%02i",
                  [
                    birthday.year,
                    birthday.month,
                    birthday.day,
                  ],
                ),
                style: TextStyle(
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
          onSubmitted: (text) {
            idFocusNode.unfocus();
            _search();
          },
          labelText: ap.id,
        ),
        SizedBox(height: 8.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextCheckBox(
              text: ap.autoFill,
              onChanged: _onAutoFillChanged,
              value: isAutoFill!,
            ),
          ],
        ),
        SizedBox(height: 8.0),
        ApButton(
          text: ap.search,
          onPressed: () {
            FirebaseAnalyticsUtils.instance
                .logEvent('search_username_click');
            _search();
          },
        )
      ],
    );
  }

  _onAutoFillChanged(bool? value) async {
    setState(() {
      isAutoFill = value;
    });
  }

  _search() async {
    if (_id.text.isEmpty) {
      ApUtils.showToast(context, ap.doNotEmpty);
    } else {
      NKUSTHelper.instance!.getUsername(
        rocId: _id.text,
        birthday: birthday,
        callback: GeneralCallback(
          onSuccess: (UserInfo data) {
            if (data != null && isAutoFill!) {
              Navigator.pop(context, data.id);
            } else {
              _showResultDialog(
                sprintf(
                  app!.searchStudentIdFormat,
                  [
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
          onFailure: (DioError e) {},
        ),
      );
    }
  }

  _showResultDialog(
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
            children: [
              TextSpan(
                text: text,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              if (showFirstHint)
                TextSpan(
                  text: '\n${app!.firstLoginHint}',
                ),
            ],
          ),
        ),
      ),
    );
  }
}
