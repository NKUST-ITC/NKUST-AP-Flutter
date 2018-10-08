import 'package:flutter/material.dart';
import 'package:nkust_ap/res/colors.dart' as Resource;
import 'package:nkust_ap/res/string.dart';
import 'package:nkust_ap/utils/utils.dart';
import 'package:nkust_ap/pages/page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nkust_ap/config/constants.dart';
import 'package:nkust_ap/api/helper.dart';

class LoginPage extends StatefulWidget {
  static const String routerName = "/login";

  @override
  LoginPageState createState() => new LoginPageState();
}

class LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _username = new TextEditingController();
  final TextEditingController _password = new TextEditingController();
  bool isRememberPassword = false;

  @override
  void initState() {
    super.initState();
    _isRememberPassword();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _editTextStyle() => new TextStyle(
      color: Colors.white, fontSize: 18.0, decorationColor: Colors.white);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        backgroundColor: Resource.Colors.blue,
        body: Center(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Center(
                  child: Text(
                    "K",
                    style: TextStyle(color: Colors.white, fontSize: 128.0),
                  ),
                ),
                TextField(
                  maxLines: 1,
                  controller: _username,
                  decoration: InputDecoration(
                    labelText: Strings.username,
                  ),
                  style: _editTextStyle(),
                ),
                TextField(
                  obscureText: true,
                  maxLines: 1,
                  controller: _password,
                  decoration: InputDecoration(
                    labelText: Strings.password,
                  ),
                  style: _editTextStyle(),
                ),
                SizedBox(
                  height: 15.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Checkbox(
                      value: isRememberPassword,
                      onChanged: _onChanged,
                    ),
                    Text(Strings.remember_password)
                  ],
                ),
                Material(
                  child: RaisedButton(
                    padding: EdgeInsets.all(12.0),
                    onPressed: _login,
                    color: Colors.grey[300],
                    child: new Text(
                      Strings.login,
                      style: new TextStyle(
                          color: Resource.Colors.blue, fontSize: 18.0),
                    ),
                  ),
                  borderRadius: BorderRadius.circular(20.0),
                  shadowColor: Colors.grey,
                  elevation: 5.0,
                ),
              ],
            ),
          ),
        ));
  }

  _onChanged(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isRememberPassword = value;
      prefs.setBool(Constants.PREF_REMEMBER_PASSWORD, isRememberPassword);
    });
  }

  _isRememberPassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isRememberPassword =
        prefs.getBool(Constants.PREF_REMEMBER_PASSWORD) ?? false;
    _username.text = prefs.getString(Constants.PREF_USERNAME) ?? "";
    if (isRememberPassword)
      _password.text = prefs.getString(Constants.PREF_PASSWORD) ?? "";
    setState(() {});
  }

  _login() async {
    if (_username.text.isEmpty || _password.text.isEmpty) {
      //TODO: 改善提示
      Utils.showToast(Strings.do_not_empty);
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) => new AlertDialog(
                content: bodyProgress,
                contentPadding: EdgeInsets.all(0.0),
              ));
      var data = await Helper.instance.login(_username.text, _password.text);
      Navigator.of(context, rootNavigator: true).pop('dialog');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString(Constants.PREF_USERNAME, _username.text);
      if (isRememberPassword)
        prefs.setString(Constants.PREF_PASSWORD, _password.text);
      if (data != null)
        Navigator.of(context).push(HomePageRoute());
      else
        Utils.showToast(Strings.login_fail);
    }
  }

  var bodyProgress = new Container(
    width: 150.0,
    height: 150.0,
    alignment: AlignmentDirectional.center,
    child: new Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new Center(
          child: CircularProgressIndicator(
            value: null,
          ),
        ),
        new Container(
          margin: const EdgeInsets.only(top: 25.0),
          child: new Center(
            child: new Text(
              Strings.login_ing,
              style: new TextStyle(color: Colors.blue),
            ),
          ),
        ),
      ],
    ),
  );
}
