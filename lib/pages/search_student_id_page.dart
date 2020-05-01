import 'package:ap_common/models/user_info.dart';
import 'package:ap_common/widgets/default_dialog.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/res/assets.dart';
import 'package:nkust_ap/res/colors.dart' as Resource;
import 'package:nkust_ap/utils/app_localizations.dart';
import 'package:nkust_ap/utils/firebase_analytics_utils.dart';
import 'package:nkust_ap/utils/nkust_helper.dart';
import 'package:nkust_ap/utils/utils.dart';
import 'package:sprintf/sprintf.dart';

class SearchStudentIdPage extends StatefulWidget {
  static const String routerName = "/searchUsername";

  @override
  SearchStudentIdPageState createState() => SearchStudentIdPageState();
}

class SearchStudentIdPageState extends State<SearchStudentIdPage> {
  final TextEditingController _id = TextEditingController();

  AppLocalizations app;

  FocusNode idFocusNode;
  bool isAutoFill = true;

  @override
  void initState() {
    super.initState();
    FA.setCurrentScreen(
        "SearchUsernamePagePage", "search_student_id_page.dart");
    idFocusNode = FocusNode();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _editTextStyle() => TextStyle(
      color: Colors.white, fontSize: 18.0, decorationColor: Colors.white);

  @override
  Widget build(BuildContext context) {
    app = AppLocalizations.of(context);
    return OrientationBuilder(
      builder: (_, orientation) {
        return Scaffold(
          backgroundColor: Resource.Colors.blue,
          resizeToAvoidBottomPadding: orientation == Orientation.portrait,
          body: Container(
            alignment: Alignment(0, 0),
            padding: EdgeInsets.symmetric(horizontal: 30.0),
            child: orientation == Orientation.portrait
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    mainAxisSize: MainAxisSize.min,
                    children: _renderContent(orientation),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _renderContent(orientation),
                  ),
          ),
        );
      },
    );
  }

  _renderContent(Orientation orientation) {
    List<Widget> list = orientation == Orientation.portrait
        ? <Widget>[
            Center(
              child: Image.asset(
                ImageAssets.K,
                width: 120.0,
                height: 120.0,
              ),
            ),
            SizedBox(height: orientation == Orientation.portrait ? 30.0 : 0.0),
          ]
        : <Widget>[
            Expanded(
              child: Image.asset(
                ImageAssets.K,
                width: 120.0,
                height: 120.0,
              ),
            ),
            SizedBox(height: orientation == Orientation.portrait ? 30.0 : 0.0),
          ];
    List<Widget> listB = <Widget>[
      TextField(
        maxLines: 1,
        textInputAction: TextInputAction.send,
        controller: _id,
        focusNode: idFocusNode,
        onSubmitted: (text) {
          idFocusNode.unfocus();
          _search();
        },
        decoration: InputDecoration(
          labelText: app.id,
        ),
        style: _editTextStyle(),
      ),
      SizedBox(height: 8.0),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          GestureDetector(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Theme(
                  data: ThemeData(
                    unselectedWidgetColor: Colors.white,
                  ),
                  child: Checkbox(
                    activeColor: Colors.white,
                    checkColor: Color(0xff2574ff),
                    value: isAutoFill,
                    onChanged: _onAutoFillChanged,
                  ),
                ),
                Text(
                  app.autoFill,
                  style: TextStyle(color: Colors.white),
                )
              ],
            ),
            onTap: () => _onAutoFillChanged(!isAutoFill),
          ),
        ],
      ),
      SizedBox(height: 8.0),
      Container(
        width: double.infinity,
        child: RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(30.0),
            ),
          ),
          padding: EdgeInsets.all(14.0),
          onPressed: () {
            FA.logAction('search_username', 'click');
            _search();
          },
          color: Colors.white,
          child: Text(
            app.search,
            style: TextStyle(color: Resource.Colors.blue, fontSize: 18.0),
          ),
        ),
      ),
    ];
    if (orientation == Orientation.portrait) {
      list.addAll(listB);
    } else {
      list.add(
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: listB,
          ),
        ),
      );
    }
    return list;
  }

  _onAutoFillChanged(bool value) async {
    setState(() {
      isAutoFill = value;
    });
  }

  _search() async {
    if (_id.text.isEmpty) {
      Utils.showToast(context, app.doNotEmpty);
    } else {
      UserInfo result = await NKUSTHelper.instance.getUsername(_id.text);
      if (result != null && isAutoFill) {
        Navigator.pop(context, result.id);
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) => DefaultDialog(
            title: app.searchResult,
            actionText: app.iKnow,
            actionFunction: () =>
                Navigator.of(context, rootNavigator: true).pop('dialog'),
            contentWidget: RichText(
              text: TextSpan(
                style: TextStyle(
                  color: Resource.Colors.grey,
                  height: 1.3,
                  fontSize: 16.0,
                ),
                children: [
                  TextSpan(
                    text: result == null
                        ? app.searchStudentIdError
                        : sprintf(
                            app.searchStudentIdFormat,
                            [
                              result.name,
                              result.id,
                            ],
                          ),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (result != null)
                    TextSpan(
                      text: '\n${app.firstLoginHint}',
                    ),
                ],
              ),
            ),
          ),
        );
      }
    }
  }
}
