import 'dart:io';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:nkust_ap/config/constants.dart';
import 'package:nkust_ap/models/leave_campus_data.dart';
import 'package:nkust_ap/res/app_icon.dart';
import 'package:nkust_ap/res/assets.dart';
import 'package:nkust_ap/utils/app_localizations.dart';
import 'package:nkust_ap/utils/preferences.dart';
import 'package:nkust_ap/widgets/dialog_option.dart';
import 'package:nkust_ap/widgets/hint_content.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;

enum _State { loading, finish, error, empty }
enum _Type { campus, department, teacher }

class PickTutorPage extends StatefulWidget {
  @override
  _PickTutorPageState createState() => _PickTutorPageState();
}

class _PickTutorPageState extends State<PickTutorPage> {
  AppLocalizations app;

  _State state = _State.loading;

  LeavesCampusData leavesCampusData;

  int campusIndex = 0;
  int departmentIndex = 0;
  int teacherIndex = 0;

  @override
  void initState() {
    getTeacherData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    app = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(app.pickTeacher),
      ),
      body: _body(),
    );
  }

  Widget _body() {
    switch (state) {
      case _State.loading:
        return Container(
          child: CircularProgressIndicator(),
          alignment: Alignment.center,
        );
      case _State.error:
      case _State.empty:
        return FlatButton(
          onPressed: null,
          child: HintContent(
            icon: AppIcon.permIdentity,
            content: state == _State.error
                ? app.functionNotOpen
                : app.functionNotOpen,
          ),
        );
      default:
        var campus = leavesCampusData.data[campusIndex];
        var department = campus.department[departmentIndex];
        var teacher = department.teacherList[teacherIndex];
        return ListView(
          children: <Widget>[
            SizedBox(height: 16.0),
            ListTile(
              leading: Icon(Icons.account_balance),
              title: Text(app.campus),
              subtitle: Text('${campus.campusName}'),
              onTap: () {
                pickItem(
                  _Type.campus,
                  campusIndex,
                  leavesCampusData.data.map(
                    (item) {
                      return item.campusName;
                    },
                  ).toList(),
                );
              },
              trailing: Icon(
                AppIcon.keyboardArrowDown,
                size: 30,
                color: Resource.Colors.grey,
              ),
            ),
            Divider(color: Resource.Colors.grey, height: 1),
            ListTile(
              leading: Icon(Icons.flag),
              title: Text(app.department),
              subtitle: Text('${department.departmentName}'),
              onTap: () {
                pickItem(
                  _Type.department,
                  departmentIndex,
                  campus.department.map(
                    (item) {
                      return item.departmentName;
                    },
                  ).toList(),
                );
              },
              trailing: Icon(
                AppIcon.keyboardArrowDown,
                size: 30,
                color: Resource.Colors.grey,
              ),
            ),
            Divider(color: Resource.Colors.grey, height: 1),
            ListTile(
              leading: Icon(Icons.person),
              title: Text(app.teacher),
              subtitle: Text('${teacher.name}'),
              onTap: () {
                pickItem(
                  _Type.teacher,
                  teacherIndex,
                  department.teacherList.map(
                    (item) {
                      return item.name;
                    },
                  ).toList(),
                );
              },
              trailing: Icon(
                AppIcon.keyboardArrowDown,
                size: 30,
                color: Resource.Colors.grey,
              ),
            ),
            SizedBox(height: 16.0),
            FractionallySizedBox(
              widthFactor: 0.8,
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(30.0),
                  ),
                ),
                padding: EdgeInsets.all(14.0),
                onPressed: () {
                  Navigator.pop(context, teacher);
                },
                color: Resource.Colors.blueAccent,
                child: Text(
                  app.confirm,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                  ),
                ),
              ),
            ),
          ],
        );
    }
  }

  Future<void> getTeacherData() async {
    var start = DateTime.now();
    RemoteConfig remoteConfig;
    String text;
    if (kIsWeb) {
    } else if (Platform.isAndroid || Platform.isIOS) {
      remoteConfig = await RemoteConfig.instance;
      try {
        await remoteConfig.fetch(
          expiration: const Duration(seconds: 10),
        );
        await remoteConfig.activateFetched();
      } on FetchThrottledException catch (exception) {} catch (exception) {}
    }
    if (remoteConfig != null) {
      Preferences.setString(Constants.LEAVE_CAMPUS_DATA,
          remoteConfig.getString(Constants.LEAVE_CAMPUS_DATA));
    }
    text = Preferences.getString(Constants.LEAVE_CAMPUS_DATA, '');
    if (text == '')
      text = await rootBundle.loadString(FileAssets.leaveCampusData);
    print(text);
    setState(() {
      leavesCampusData = LeavesCampusData.fromRawJson(text);
      if (leavesCampusData != null) {
        state = _State.finish;
      } else {
        state = _State.empty;
      }
    });
    print(
        'read json time = ${DateTime.now().millisecondsSinceEpoch - start.millisecondsSinceEpoch}');
  }

  void pickItem(_Type type, int currentIndex, List<String> items) {
    showDialog<int>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(AppLocalizations.of(context).picksSemester),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(8),
          ),
        ),
        contentPadding: EdgeInsets.all(0.0),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.7,
          child: ListView.separated(
            shrinkWrap: true,
            controller:
                ScrollController(initialScrollOffset: currentIndex * 40.0),
            itemCount: items.length,
            itemBuilder: (BuildContext context, int index) {
              return DialogOption(
                text: items[index],
                check: currentIndex == index,
                onPressed: () {
                  Navigator.pop(context, index);
                },
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return Divider(height: 6.0);
            },
          ),
        ),
      ),
    ).then<void>((int position) async {
      if (position != null) {
        switch (type) {
          case _Type.campus:
            setState(() {
              campusIndex = position;
              departmentIndex = 0;
              teacherIndex = 0;
            });
            break;
          case _Type.department:
            setState(() {
              departmentIndex = position;
              teacherIndex = 0;
            });
            break;
          case _Type.teacher:
            setState(() {
              teacherIndex = position;
            });
            break;
        }
      }
    });
  }
}
