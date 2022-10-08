import 'dart:developer';
import 'dart:io';

import 'package:ap_common/resources/ap_icon.dart';
import 'package:ap_common/resources/ap_theme.dart';
import 'package:ap_common/utils/ap_localizations.dart';
import 'package:ap_common/utils/preferences.dart';
import 'package:ap_common/widgets/dialog_option.dart';
import 'package:ap_common/widgets/hint_content.dart';
import 'package:ap_common_firebase/utils/firebase_remote_config_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:nkust_ap/models/leave_campus_data.dart';
import 'package:nkust_ap/res/assets.dart';
import 'package:nkust_ap/utils/global.dart';

enum _State { loading, finish, error, empty }

enum _Type { campus, department, teacher }

class PickTutorPage extends StatefulWidget {
  @override
  _PickTutorPageState createState() => _PickTutorPageState();
}

class _PickTutorPageState extends State<PickTutorPage> {
  late ApLocalizations ap;

  _State state = _State.loading;

  LeavesCampusData? leavesCampusData;

  int campusIndex = 0;
  int departmentIndex = 0;
  int teacherIndex = 0;

  @override
  void initState() {
    getTeacherData();
    FirebaseAnalyticsUtils.instance.setCurrentScreen(
      'PickTutorPage',
      'pick_tutor_page.dart',
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ap = ApLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(ap.pickTeacher),
      ),
      body: _body(),
    );
  }

  Widget _body() {
    switch (state) {
      case _State.loading:
        return Container(
          alignment: Alignment.center,
          child: const CircularProgressIndicator(),
        );
      case _State.error:
      case _State.empty:
        return InkWell(
          child: HintContent(
            icon: ApIcon.permIdentity,
            content:
                state == _State.error ? ap.functionNotOpen : ap.functionNotOpen,
          ),
        );
      default:
        final LeavesCampus campus = leavesCampusData!.data[campusIndex];
        final LeavesDepartment department = campus.department[departmentIndex];
        final LeavesTeacher teacher = department.teacherList[teacherIndex];
        return ListView(
          children: <Widget>[
            const SizedBox(height: 16.0),
            ListTile(
              leading: const Icon(Icons.account_balance),
              title: Text(ap.campus),
              subtitle: Text(campus.campusName),
              onTap: () {
                pickItem(
                  _Type.campus,
                  campusIndex,
                  leavesCampusData!.data.map(
                    (LeavesCampus item) {
                      return item.campusName;
                    },
                  ).toList(),
                );
              },
              trailing: Icon(
                ApIcon.keyboardArrowDown,
                size: 30,
                color: ApTheme.of(context).grey,
              ),
            ),
            Divider(color: ApTheme.of(context).grey, height: 1),
            ListTile(
              leading: const Icon(Icons.flag),
              title: Text(ap.department),
              subtitle: Text(department.departmentName),
              onTap: () {
                pickItem(
                  _Type.department,
                  departmentIndex,
                  campus.department.map(
                    (LeavesDepartment item) {
                      return item.departmentName;
                    },
                  ).toList(),
                );
              },
              trailing: Icon(
                ApIcon.keyboardArrowDown,
                size: 30,
                color: ApTheme.of(context).grey,
              ),
            ),
            Divider(color: ApTheme.of(context).grey, height: 1),
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(ap.teacher),
              subtitle: Text(teacher.name),
              onTap: () {
                pickItem(
                  _Type.teacher,
                  teacherIndex,
                  department.teacherList.map(
                    (LeavesTeacher item) {
                      return item.name;
                    },
                  ).toList(),
                );
              },
              trailing: Icon(
                ApIcon.keyboardArrowDown,
                size: 30,
                color: ApTheme.of(context).grey,
              ),
            ),
            const SizedBox(height: 16.0),
            FractionallySizedBox(
              widthFactor: 0.8,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(30.0),
                    ),
                  ),
                  padding: const EdgeInsets.all(14.0),
                  primary: ApTheme.of(context).blueAccent,
                ),
                onPressed: () {
                  Navigator.pop(context, teacher);
                },
                child: Text(
                  ap.confirm,
                  style: const TextStyle(
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
    final DateTime start = DateTime.now();
    FirebaseRemoteConfig? remoteConfig;
    String text;
    if (kIsWeb) {
    } else if (Platform.isAndroid || Platform.isIOS) {
      remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(hours: 1),
        ),
      );
      await remoteConfig.fetchAndActivate();
    }
    if (remoteConfig != null) {
      Preferences.setString(
        Constants.leaveCampusData,
        remoteConfig.getString(Constants.leaveCampusData),
      );
    }
    text = Preferences.getString(Constants.leaveCampusData, '');
    if (text == '') {
      text = await rootBundle.loadString(FileAssets.leaveCampusData);
    }
    setState(() {
      leavesCampusData = LeavesCampusData.fromRawJson(text);
      if (leavesCampusData != null) {
        state = _State.finish;
      } else {
        state = _State.empty;
      }
    });
    log(
      'read json time = '
      '${DateTime.now().difference(start).inMilliseconds}ms',
    );
  }

  void pickItem(_Type type, int currentIndex, List<String?> items) {
    //TODO text fix
    String title = '';
    switch (type) {
      case _Type.campus:
        title = ApLocalizations.of(context).pickTeacher;
        break;
      case _Type.department:
        title = ApLocalizations.of(context).pickTeacher;
        break;
      case _Type.teacher:
        title = ApLocalizations.of(context).pickTeacher;
        break;
    }
    showDialog<int>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(8),
          ),
        ),
        contentPadding: EdgeInsets.zero,
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.7,
          child: ListView.separated(
            shrinkWrap: true,
            controller:
                ScrollController(initialScrollOffset: currentIndex * 40.0),
            itemCount: items.length,
            itemBuilder: (BuildContext context, int index) {
              return DialogOption(
                text: items[index]!,
                check: currentIndex == index,
                onPressed: () {
                  Navigator.pop(context, index);
                },
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return const Divider(height: 6.0);
            },
          ),
        ),
      ),
    ).then<void>((int? position) async {
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
