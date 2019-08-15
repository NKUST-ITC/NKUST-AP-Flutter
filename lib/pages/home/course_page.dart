import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/models/models.dart';
import 'package:nkust_ap/res/app_icon.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;
import 'package:nkust_ap/utils/cache_utils.dart';
import 'package:nkust_ap/utils/global.dart';
import 'package:nkust_ap/utils/preferences.dart';
import 'package:nkust_ap/widgets/default_dialog.dart';
import 'package:nkust_ap/widgets/hint_content.dart';
import 'package:nkust_ap/widgets/semester_picker.dart';

enum _State { loading, finish, error, empty, offlineEmpty }

class CoursePage extends StatefulWidget {
  static const String routerName = '/course';

  @override
  CoursePageState createState() => CoursePageState();
}

class CoursePageState extends State<CoursePage> {
  final key = GlobalKey<SemesterPickerState>();

  AppLocalizations app;
  ScaffoldState scaffold;

  _State state = _State.loading;

  Semester selectSemester;
  SemesterData semesterData;
  CourseData courseData;

  bool isOffline = false;

  bool get hasHoliday => (courseData?.courseTables?.saturday == null &&
      courseData?.courseTables?.sunday == null);

  int get base => (hasHoliday) ? 6 : 8;

  double get childAspectRatio => (hasHoliday) ? 1.5 : 1.1;

  @override
  void initState() {
    FA.setCurrentScreen('CoursePage', 'course_page.dart');
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    app = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(app.course),
        backgroundColor: Resource.Colors.blue,
      ),
      body: Builder(
        builder: (builderContext) {
          scaffold = Scaffold.of(builderContext);
          return Flex(
            direction: Axis.vertical,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              SizedBox(height: 8.0),
              SemesterPicker(
                key: key,
                onSelect: (semester, index) {
                  setState(() {
                    selectSemester = semester;
                    state = _State.loading;
                  });
                  if (Preferences.getBool(
                      Constants.PREF_IS_OFFLINE_LOGIN, false))
                    _loadCourseData(semester.value);
                  else
                    _getCourseTables();
                },
              ),
              Text(
                '${isOffline ? app.offlineCourse + ' ' : ''}'
                '${app.courseClickHint}',
                style: TextStyle(color: Resource.Colors.grey),
              ),
              SizedBox(height: 4.0),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    if (isOffline) await Helper.instance.initByPreference();
                    await _getCourseTables();
                    FA.logAction('refresh', 'swipe');
                    return null;
                  },
                  child: _body(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _body() {
    switch (state) {
      case _State.loading:
        return Container(
            child: CircularProgressIndicator(), alignment: Alignment.center);
      case _State.empty:
      case _State.error:
        return FlatButton(
          onPressed: () {
            if (state == _State.error)
              _getCourseTables();
            else
              key.currentState.pickSemester();
            FA.logAction('retry', 'click');
          },
          child: HintContent(
            icon: AppIcon.classIcon,
            content: state == _State.error ? app.clickToRetry : app.courseEmpty,
          ),
        );
      case _State.offlineEmpty:
        return HintContent(
          icon: AppIcon.classIcon,
          content: app.noOfflineData,
        );
      default:
        return SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(
                  10.0,
                ),
              ),
              border: Border.all(color: Colors.grey, width: 1.0),
            ),
            child: Table(
              defaultColumnWidth: FractionColumnWidth(1.0 / base),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              border: TableBorder.symmetric(
                inside: BorderSide(
                  color: Colors.grey,
                  width: 0,
                ),
              ),
              children: renderCourseList(),
            ),
          ),
        );
    }
  }

  List<TableRow> renderCourseList() {
    List<String> weeks = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday'
    ];
    var list = <TableRow>[
      TableRow(children: [_titleBorder('')])
    ];
    for (var week in app.weekdaysCourse.sublist(0, 4))
      list[0].children.add(_titleBorder(week));
    if (courseData.courseTables.saturday == null &&
        courseData.courseTables.sunday == null) {
      list[0].children.add(_titleBorder(app.weekdaysCourse[4]));
    } else {
      list[0].children.add(_titleBorder(app.weekdaysCourse[4]));
      list[0].children.add(_titleBorder(app.weekdaysCourse[5]));
      list[0].children.add(_titleBorder(app.weekdaysCourse[6]));
      weeks.add('Saturday');
      weeks.add('Sunday');
    }
    int maxTimeCode = courseData.courseTables.getMaxTimeCode(weeks);
    int i = 0;
    for (String text in courseData.courseTables.timeCode) {
      i++;
      if (maxTimeCode <= 11 && i > maxTimeCode) continue;
      text = text.replaceAll(' ', '');
      if (base == 8) {
        text = text.replaceAll('第', '');
        text = text.replaceAll('節', '');
      }
      list.add(TableRow(children: []));
      list[i].children.add(_titleBorder(text));
      for (var j = 0; j < base - 1; j++) list[i].children.add(_titleBorder(''));
    }
    var timeCodes = courseData.courseTables.timeCode;
    for (int i = 0; i < weeks.length; i++) {
      if (courseData.courseTables.getCourseList(weeks[i]) != null)
        for (var data in courseData.courseTables.getCourseList(weeks[i])) {
          for (int j = 0; j < timeCodes.length; j++) {
            if (timeCodes[j] == data.date.section) {
              if (i % base != 0) list[j + 1].children[i] = _courseBorder(data);
            }
          }
        }
    }
    return list;
  }

  Widget _titleBorder(String text) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      alignment: Alignment.center,
      child: Text(
        text ?? '',
        style: TextStyle(color: Resource.Colors.blueText, fontSize: 14.0),
      ),
    );
  }

  Widget _courseBorder(Course course) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) => DefaultDialog(
            title: app.courseDialogTitle,
            actionText: app.iKnow,
            actionFunction: () =>
                Navigator.of(context, rootNavigator: true).pop('dialog'),
            contentWidget: RichText(
              text: TextSpan(
                  style: TextStyle(
                      color: Resource.Colors.grey, height: 1.3, fontSize: 16.0),
                  children: [
                    TextSpan(
                        text: '${app.courseDialogName}：',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: '${course.title}\n'),
                    TextSpan(
                        text: '${app.courseDialogProfessor}：',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: '${course.getInstructors()}\n'),
                    TextSpan(
                        text: '${app.courseDialogLocation}：',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                        text:
                            '${course.location.building}${course.location.room}\n'),
                    TextSpan(
                        text: '${app.courseDialogTime}：',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                        text:
                            '${course.date.startTime}-${course.date.endTime}'),
                  ]),
            ),
          ),
        );
        FA.logAction('show_course', 'click');
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        alignment: Alignment.center,
        child: Text(
          (course.title[0] + course.title[1]) ?? '',
          style: TextStyle(fontSize: 16.0),
        ),
      ),
    );
  }

  void _loadCourseData(String value) async {
    courseData = await CacheUtils.loadCourseData(value);
    if (mounted) {
      setState(() {
        isOffline = true;
        if (this.courseData == null) {
          state = _State.offlineEmpty;
        } else if (courseData.status == 204) {
          state = _State.empty;
        } else if (courseData.status == 200) {
          state = _State.finish;
        } else {
          state = _State.error;
        }
      });
    }
  }

  _getCourseTables() async {
    Helper.cancelToken.cancel('');
    Helper.cancelToken = CancelToken();
    var textList = selectSemester.value.split(',');
    if (textList.length == 2) {
      Helper.instance
          .getCourseTables(textList[0], textList[1])
          .then((response) {
        if (mounted)
          setState(() {
            courseData = response;
            isOffline = false;
            CacheUtils.saveCourseData(selectSemester.value, courseData);
            if (courseData.status == 204) {
              state = _State.empty;
            } else if (courseData.status == 200) {
              state = _State.finish;
            } else {
              state = _State.error;
            }
          });
      }).catchError((e) {
        if (e is DioError) {
          switch (e.type) {
            case DioErrorType.RESPONSE:
              Utils.handleResponseError(context, 'getCourseTables', mounted, e);
              break;
            case DioErrorType.CANCEL:
              break;
            default:
              if (mounted)
                setState(() {
                  state = _State.error;
                });
              Utils.handleDioError(context, e);
              break;
          }
        } else {
          throw e;
        }
        _loadCourseData(selectSemester.value);
      });
    } else {
      if (mounted)
        setState(() {
          state = _State.error;
        });
    }
  }
}
