import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/models/models.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;
import 'package:nkust_ap/utils/cache_utils.dart';
import 'package:nkust_ap/utils/global.dart';
import 'package:nkust_ap/widgets/default_dialog.dart';
import 'package:nkust_ap/widgets/hint_content.dart';

enum _State { loading, finish, error, empty }

class CoursePageRoute extends MaterialPageRoute {
  CoursePageRoute() : super(builder: (BuildContext context) => CoursePage());

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return FadeTransition(opacity: animation, child: CoursePage());
  }
}

class CoursePage extends StatefulWidget {
  static const String routerName = "/course";

  @override
  CoursePageState createState() => CoursePageState();
}

class CoursePageState extends State<CoursePage>
    with SingleTickerProviderStateMixin {
  AppLocalizations app;
  ScaffoldState scaffold;

  _State state = _State.loading;

  int base = 6;
  int selectSemesterIndex;
  double childAspectRatio = 0.5;

  Semester selectSemester;
  SemesterData semesterData;
  CourseData courseData;

  bool isOffline = false;

  @override
  void initState() {
    super.initState();
    FA.setCurrentScreen("CoursePage", "course_page.dart");
    _getSemester();
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
              SizedBox(height: 16.0),
              Expanded(
                flex: 1,
                child: FlatButton(
                  onPressed: (semesterData != null) ? _selectSemester : null,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        selectSemester == null ? "" : selectSemester.text,
                        style: TextStyle(
                            color: Resource.Colors.blue, fontSize: 18.0),
                      ),
                      SizedBox(width: 8.0),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: Resource.Colors.blue,
                      )
                    ],
                  ),
                ),
              ),
              Container(
                child: isOffline
                    ? Text(
                        app.offlineCourse,
                        style: TextStyle(color: Resource.Colors.grey),
                      )
                    : null,
              ),
              Expanded(
                flex: 19,
                child: RefreshIndicator(
                  onRefresh: () {
                    _getCourseTables();
                    FA.logAction('refresh', 'swipe');
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
              _selectSemester();
            FA.logAction('retry', 'click');
          },
          child: HintContent(
              icon: Icons.class_,
              content:
                  state == _State.error ? app.clickToRetry : app.courseEmpty),
        );
      default:
        var list = renderCourseList();
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
              children: list,
            ),
          ),
        );
    }
  }

  List<TableRow> renderCourseList() {
    List<String> weeks = [
      "Sunday",
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday"
    ];
    var list = <TableRow>[
      TableRow(children: [_titleBorder("")])
    ];
    for (var week in app.weekdaysCourse.sublist(0, 4))
      list[0].children.add(_titleBorder(week));
    if (courseData.courseTables.saturday == null &&
        courseData.courseTables.sunday == null) {
      list[0].children.add(_titleBorder(app.weekdaysCourse[4]));
      base = 6;
      childAspectRatio = 1.5;
    } else {
      list[0].children.add(_titleBorder(app.weekdaysCourse[4]));
      list[0].children.add(_titleBorder(app.weekdaysCourse[5]));
      list[0].children.add(_titleBorder(app.weekdaysCourse[6]));
      weeks.add("Saturday");
      weeks.add("Sunday");
      base = 8;
      childAspectRatio = 1.1;
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
      for (var j = 0; j < base - 1; j++) list[i].children.add(_titleBorder(""));
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
        style: TextStyle(color: Resource.Colors.blue, fontSize: 12.0),
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
                          color: Resource.Colors.grey,
                          height: 1.3,
                          fontSize: 16.0),
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
          (course.title[0] + course.title[1]) ?? "",
          style: TextStyle(color: Colors.black, fontSize: 14.0),
        ),
      ),
    );
  }

  void _getSemester() {
    _loadSemesterData();
    Helper.instance.getSemester().then((semesterData) {
      this.semesterData = semesterData;
      CacheUtils.saveSemesterData(semesterData);
      if (mounted) {
        setState(() {
          selectSemester = semesterData.defaultSemester;
          selectSemesterIndex = semesterData.defaultIndex;
          _getCourseTables();
        });
      }
    }).catchError((e) {
      if (e is DioError) {
        switch (e.type) {
          case DioErrorType.RESPONSE:
            Utils.handleResponseError(context, 'getSemester', mounted, e);
            break;
          case DioErrorType.CANCEL:
            break;
          default:
            state = _State.error;
            Utils.handleDioError(e, app);
            break;
        }
      } else {
        throw e;
      }
      _loadCourseData(selectSemester.value);
    });
  }

  void _loadSemesterData() async {
    this.semesterData = await CacheUtils.loadSemesterData();
    if (this.semesterData == null) return;
    setState(() {
      selectSemester = semesterData.defaultSemester;
      selectSemesterIndex = semesterData.defaultIndex;
    });
  }

  void _loadCourseData(String value) async {
    courseData = await CacheUtils.loadCourseData(value);
    if (this.courseData == null) return;
    isOffline = true;
    if (mounted) {
      setState(() {
        if (courseData.status == 204) {
          state = _State.empty;
        } else if (courseData.status == 200) {
          state = _State.finish;
        } else {
          state = _State.error;
        }
      });
    }
  }

  void _selectSemester() {
    var semesters = <SimpleDialogOption>[];
    if (semesterData == null) return;
    for (var semester in semesterData.semesters) {
      semesters.add(_dialogItem(semesters.length, semester.text));
    }
    FA.logAction('pick_yms', 'click');
    showDialog<int>(
        context: context,
        builder: (BuildContext context) => SimpleDialog(
            title: Text(app.picksSemester),
            children: semesters)).then<void>((int position) {
      if (position != null) {
        selectSemesterIndex = position;
        selectSemester = semesterData.semesters[selectSemesterIndex];
        _getCourseTables();
        setState(() {});
      }
    });
  }

  SimpleDialogOption _dialogItem(int index, String text) {
    return SimpleDialogOption(
        child: Text(text),
        onPressed: () {
          Navigator.pop(context, index);
        });
  }

  _getCourseTables() async {
    Helper.cancelToken.cancel("");
    Helper.cancelToken = CancelToken();
    if (mounted) {
      setState(() {
        state = _State.loading;
      });
    }
    if (semesterData == null) {
      _getSemester();
      return;
    }
    var textList = semesterData.semesters[selectSemesterIndex].value.split(",");
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
              Utils.handleDioError(e, app);
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
