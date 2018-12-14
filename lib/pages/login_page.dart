import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/models/api/error_response.dart';
import 'package:nkust_ap/res/colors.dart' as Resource;
import 'package:nkust_ap/utils/utils.dart';
import 'package:nkust_ap/pages/page.dart';
import 'package:nkust_ap/widgets/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nkust_ap/config/constants.dart';
import 'package:nkust_ap/api/helper.dart';
import 'package:nkust_ap/utils/app_localizations.dart';
import 'package:nkust_ap/widgets/checkbox_title.dart';
import 'package:package_info/package_info.dart';

class LoginPage extends StatefulWidget {
  static const String routerName = "/login";

  @override
  LoginPageState createState() => new LoginPageState();
}

class LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  AppLocalizations app;
  SharedPreferences prefs;

  final TextEditingController _username = new TextEditingController();
  final TextEditingController _password = new TextEditingController();
  bool isRememberPassword = false;

  @override
  void initState() {
    super.initState();
    _isRememberPassword();
    _showDialog();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _editTextStyle() => new TextStyle(
      color: Colors.white, fontSize: 18.0, decorationColor: Colors.white);

  @override
  Widget build(BuildContext context) {
    app = AppLocalizations.of(context);
    return new Scaffold(
        backgroundColor: Resource.Colors.blue,
        resizeToAvoidBottomPadding: false,
        body: Center(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Center(
                  child: Image.asset(
                    "assets/images/K.png",
                    width: 120.0,
                  ),
                ),
                SizedBox(height: 30.0),
                TextField(
                  maxLines: 1,
                  controller: _username,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).username,
                  ),
                  style: _editTextStyle(),
                ),
                TextField(
                  obscureText: true,
                  maxLines: 1,
                  controller: _password,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).password,
                  ),
                  style: _editTextStyle(),
                ),
                GestureDetector(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Checkbox(
                        activeColor: Colors.blue,
                        value: isRememberPassword,
                        onChanged: _onChanged,
                      ),
                      Text(AppLocalizations.of(context).remember)
                    ],
                  ),
                  onTap: () => _onChanged(!isRememberPassword),
                ),
                RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(30.0),
                    ),
                  ),
                  padding: EdgeInsets.all(16.0),
                  onPressed: _login,
                  color: Colors.white,
                  child: Text(
                    AppLocalizations.of(context).login,
                    style:
                        TextStyle(color: Resource.Colors.blue, fontSize: 18.0),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  _showDialog() async {
    prefs = await SharedPreferences.getInstance();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    await Future.delayed(Duration(milliseconds: 50));
    if (prefs.getBool(Constants.PREF_FIRST_ENTER_APP) ?? true)
      Utils.showDefaultDialog(
          context,
          AppLocalizations.of(context).updateNoteTitle,
          "v${packageInfo.version}\n"
          "${AppLocalizations.of(context).updateNoteContent}",
          AppLocalizations.of(context).ok, () {
        prefs.setBool(Constants.PREF_FIRST_ENTER_APP, false);
      });
  }

  _onChanged(bool value) async {
    setState(() {
      isRememberPassword = value;
      prefs.setBool(Constants.PREF_REMEMBER_PASSWORD, isRememberPassword);
    });
  }

  _isRememberPassword() async {
    prefs = await SharedPreferences.getInstance();
    isRememberPassword =
        prefs.getBool(Constants.PREF_REMEMBER_PASSWORD) ?? false;
    _username.text = prefs.getString(Constants.PREF_USERNAME) ?? "";
    if (isRememberPassword)
      _password.text = prefs.getString(Constants.PREF_PASSWORD) ?? "";
    setState(() {});
  }

  _login() async {
    if (_username.text.isEmpty || _password.text.isEmpty) {
      Utils.showToast(AppLocalizations.of(context).doNotEmpty);
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) =>
              ProgressDialog(AppLocalizations.of(context).logining),
          barrierDismissible: true);
      prefs.setString(Constants.PREF_USERNAME, _username.text);
      if (isRememberPassword)
        prefs.setString(Constants.PREF_PASSWORD, _password.text);
      Helper.instance.login(_username.text, _password.text).then((data) async {
        if (Navigator.canPop(context)) Navigator.pop(context, 'dialog');
        prefs.setString(Constants.PREF_USERNAME, _username.text);
        if (isRememberPassword)
          prefs.setString(Constants.PREF_PASSWORD, _password.text);
        Navigator.of(context).push(HomePageRoute());
      }).catchError((e) {
        if (Navigator.canPop(context)) Navigator.pop(context, 'dialog');
        assert(e is DioError);
        DioError dioError = e as DioError;
        switch (dioError.type) {
          case DioErrorType.RESPONSE:
            Utils.showToast(AppLocalizations.of(context).loginFail);
            break;
          case DioErrorType.CANCEL:
            break;
          default:
            Utils.handleDioError(dioError, app);
            break;
        }
      });
    }
  }
}
