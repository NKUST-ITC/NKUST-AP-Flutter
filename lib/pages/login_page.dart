import 'package:flutter/material.dart';
import 'package:nkust_ap/res/theme.dart' as Theme;
import 'package:nkust_ap/res/string.dart';
import 'package:nkust_ap/utils/utils.dart';
import 'package:nkust_ap/pages/home_page.dart';

class LoginPage extends StatefulWidget {
  static const String routerName = "/login";

  @override
  LoginPageState createState() => new LoginPageState();
}

class LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _username = new TextEditingController();
  final TextEditingController _password = new TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _editTextStyle() => new TextStyle(
        color: Colors.white, fontSize: 18.0, decorationColor: Colors.white);

    return new Scaffold(
        backgroundColor: Theme.Colors.blue,
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
                  keyboardType: TextInputType.number,
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
                  height: 30.0,
                ),
                Material(
                  child: RaisedButton(
                    padding: EdgeInsets.all(12.0),
                    onPressed: () {
                      if (_username.text.isEmpty || _password.text.isEmpty) {
                        Utils.showToast(Strings.do_not_empty);
                      } else
                        Navigator.of(context).push(HomePageRoute());
                    },
                    color: Colors.grey[300],
                    child: new Text(
                      Strings.login,
                      style: new TextStyle(
                          color: Theme.Colors.blue, fontSize: 18.0),
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
}
