import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/models/models.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;
import 'package:nkust_ap/utils/global.dart';
import 'package:nkust_ap/widgets/hint_content.dart';

enum _State { loading, finish, error, empty }
enum Leave { normal, sick, official, funeral, maternity }

class LeaveApplyPageRoute extends MaterialPageRoute {
  LeaveApplyPageRoute()
      : super(builder: (BuildContext context) => new LeaveApplyPage());

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return new FadeTransition(opacity: animation, child: new LeaveApplyPage());
  }
}

class LeaveApplyPage extends StatefulWidget {
  static const String routerName = "/leave/apply";

  @override
  LeaveApplyPageState createState() => new LeaveApplyPageState();
}

class LeaveApplyPageState extends State<LeaveApplyPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  _State state = _State.empty;
  BusReservationsData busReservationsData;
  List<Widget> busReservationWeights = [];
  DateTime dateTime = DateTime.now();

  AppLocalizations app;

  Leave _leave = Leave.normal;

  @override
  void initState() {
    super.initState();
    FA.setCurrentScreen("LeaveApplyPage", "leave_apply_page.dart");
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    app = AppLocalizations.of(context);
    return _body();
  }

  Widget _body() {
    switch (state) {
      case _State.loading:
        return Container(
            child: CircularProgressIndicator(), alignment: Alignment.center);
      case _State.error:
      case _State.empty:
        return FlatButton(
          onPressed: null,
          child: HintContent(
            icon: Icons.perm_identity,
            content: state == _State.error
                ? app.functionNotOpen
                : app.functionNotOpen,
          ),
        );
      default:
        return Theme(
          data: ThemeData(
            accentColor: Resource.Colors.blue,
            unselectedWidgetColor: Resource.Colors.grey,
            inputDecorationTheme: InputDecorationTheme(
              hintStyle: TextStyle(fontSize: 20.0, color: Resource.Colors.blue),
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: Resource.Colors.blue),
              ),
            ),
          ),
          child: ListView(
            padding: EdgeInsets.symmetric(vertical: 24),
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: double.infinity),
                  child: CupertinoSegmentedControl(
                    selectedColor: Resource.Colors.blue,
                    borderColor: Resource.Colors.blue,
                    groupValue: _leave,
                    children: {
                      Leave.normal: Container(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text('事假'),
                      ),
                      Leave.sick: Container(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text('病假'),
                      ),
                      Leave.official: Container(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text('公假'),
                      ),
                      Leave.funeral: Container(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text('喪假'),
                      ),
                      Leave.maternity: Container(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text('產假'),
                      ),
                    },
                    onValueChanged: (Leave text) {
                      if (mounted) {
                        setState(() {
                          _leave = text;
                        });
                      }
                      FA.logAction('segment', 'click');
                    },
                  ),
                ),
              ),
              SizedBox(height: 16),
              Divider(color: Resource.Colors.grey, height: 1),
              ListTile(
                onTap: () {},
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                leading: Icon(
                  Icons.access_time,
                  size: 30,
                  color: Resource.Colors.grey,
                ),
                trailing: Icon(
                  Icons.keyboard_arrow_down,
                  size: 30,
                  color: Resource.Colors.grey,
                ),
                title: Text(
                  "時間",
                  style: TextStyle(color: Resource.Colors.grey, fontSize: 20),
                ),
                subtitle: Text(
                  "2019-04-01～2019-04-05",
                  style: TextStyle(color: Resource.Colors.grey),
                ),
              ),
              Divider(color: Resource.Colors.grey, height: 1),
              ListTile(
                onTap: () {},
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                leading: Icon(
                  Icons.person,
                  size: 30,
                  color: Resource.Colors.grey,
                ),
                trailing: Icon(
                  Icons.keyboard_arrow_down,
                  size: 30,
                  color: Resource.Colors.grey,
                ),
                title: Text(
                  "導師",
                  style: TextStyle(color: Resource.Colors.grey, fontSize: 20),
                ),
                subtitle: Text(
                  "朱紹儀",
                  style: TextStyle(color: Resource.Colors.grey, fontSize: 20),
                ),
              ),
              Divider(color: Resource.Colors.grey, height: 1),
              SizedBox(height: 24),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  maxLines: 2,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    fillColor: Resource.Colors.blue,
                    labelText: '原因',
                  ),
                ),
              ),
            ],
          ),
        );
    }
  }
}
