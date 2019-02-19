import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/models/models.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;
import 'package:nkust_ap/utils/global.dart';
import 'package:nkust_ap/widgets/hint_content.dart';

enum _State { loading, finish, error, empty }

class CoursePageRoute extends MaterialPageRoute {
  CoursePageRoute()
      : super(builder: (BuildContext context) => new CoursePage());

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return new FadeTransition(opacity: animation, child: new CoursePage());
  }
}

class CoursePage extends StatefulWidget {
  static const String routerName = "/course";

  @override
  CoursePageState createState() => new CoursePageState();
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

  _textBlueStyle() {
    return TextStyle(color: Resource.Colors.blue, fontSize: 12.0);
  }

  _textStyle() {
    return TextStyle(color: Colors.black, fontSize: 14.0);
  }

  Widget _textBorder(String text,
      {bool topLeft = false,
      bool topRight = false,
      bool bottomLeft = false,
      bool bottomRight = false,
      bool isCenter = false}) {
    return new Container(
      decoration: new BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(
            topLeft ? 5.0 : 0.0,
          ),
          topRight: Radius.circular(
            topRight ? 5.0 : 0.0,
          ),
          bottomLeft: Radius.circular(
            bottomLeft ? 5.0 : 0.0,
          ),
          bottomRight: Radius.circular(
            bottomRight ? 5.0 : 0.0,
          ),
        ),
        border: Border.all(color: Colors.grey, width: 0.5),
      ),
      child: FlatButton(
        padding: EdgeInsets.all(0.0),
        onPressed: null,
        child: Text(
          text ?? "",
          textAlign: TextAlign.center,
          style: _textBlueStyle(),
        ),
      ),
    );
  }

  Widget _courseBorder(Course course) {
    String content = "${app.courseDialogName}：${course.title}\n"
        "${app.courseDialogProfessor}：${course.getInstructors()}\n"
        "${app.courseDialogLocation}：${course.building}${course.room}\n"
        "${app.courseDialogTime}：${course.startTime}-${course.endTime}";
    return new Container(
      decoration: new BoxDecoration(
          border: new Border.all(color: Colors.grey, width: 0.5)),
      child: FlatButton(
          padding: EdgeInsets.all(0.0),
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                      title: Text(
                        app.courseDialogTitle,
                        style: TextStyle(color: Resource.Colors.blue),
                      ),
                      content: Text(content),
                      actions: <Widget>[
                        FlatButton(
                          padding: EdgeInsets.all(4.0),
                          child: Text(app.ok),
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true)
                                .pop('dialog');
                          },
                        )
                      ],
                    ));
          },
          child: Text(
            (course.title[0] + course.title[1]) ?? "",
            style: _textStyle(),
          )),
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
          onPressed: state == _State.error ? _getCourseTables : _selectSemester,
          child: HintContent(
              icon: Icons.class_,
              content:
                  state == _State.error ? app.clickToRetry : app.courseEmpty),
        );
      default:
        var list = renderCourseList();
        return SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: GridView.count(
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(vertical: 16.0),
            mainAxisSpacing: 0.0,
            shrinkWrap: true,
            childAspectRatio: childAspectRatio,
            crossAxisCount: base,
            children: list ?? <Widget>[],
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    app = AppLocalizations.of(context);
    return new Scaffold(
      appBar: AppBar(
        title: Text(app.course),
        backgroundColor: Resource.Colors.blue,
      ),
      body: Builder(
        builder: (builderContext) {
          scaffold = Scaffold.of(builderContext);
          return Container(
            child: Flex(
              direction: Axis.vertical,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                SizedBox(height: 16.0),
                Expanded(
                  flex: 1,
                  child: FlatButton(
                    onPressed: _selectSemester,
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
                Expanded(
                  flex: 19,
                  child: RefreshIndicator(
                    onRefresh: () => _getCourseTables(),
                    child: _body(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _getSemester() {
    Helper.instance.getSemester().then((semesterData) {
      this.semesterData = semesterData;
      selectSemester = semesterData.defaultSemester;
      selectSemesterIndex = semesterData.defaultIndex;
      _getCourseTables();
      setState(() {});
    }).catchError((e) {
      if (e is DioError) {
        switch (e.type) {
          case DioErrorType.RESPONSE:
            Utils.showToast(app.tokenExpiredContent);
            Navigator.popUntil(
                context, ModalRoute.withName(Navigator.defaultRouteName));
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
    });
  }

  void _selectSemester() {
    var semesters = <SimpleDialogOption>[];
    if (semesterData == null) return;
    for (var semester in semesterData.semesters) {
      semesters.add(_dialogItem(semesters.length, semester.text));
    }
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

  renderCourseList() {
    List<String> weeks = [
      "Sunday",
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday"
    ];
    var courseWeightList = <Widget>[_textBorder("", topLeft: true)];
    for (var week in app.weekdaysCourse.sublist(0, 4))
      courseWeightList.add(_textBorder(week));
    if (courseData.courseTables.saturday.isEmpty &&
        courseData.courseTables.sunday.isEmpty) {
      courseWeightList.add(_textBorder(app.weekdaysCourse[4], topRight: true));
      base = 6;
      childAspectRatio = 1.5;
    } else {
      courseWeightList.add(_textBorder(app.weekdaysCourse[4]));
      courseWeightList.add(_textBorder(app.weekdaysCourse[5]));
      courseWeightList.add(_textBorder(app.weekdaysCourse[6], topRight: true));
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
      courseWeightList.add(_textBorder(text));
      for (var i = 0; i < base - 1; i++)
        courseWeightList.add(_textBorder("", isCenter: true));
    }
    var timeCodes = courseData.courseTables.timeCode;
    for (int i = 0; i < weeks.length; i++) {
      if (courseData.courseTables.getCourseList(weeks[i]) != null)
        for (var data in courseData.courseTables.getCourseList(weeks[i])) {
          for (int j = 0; j < timeCodes.length; j++) {
            if (timeCodes[j] == data.section) {
              if (i % base != 0)
                courseWeightList[(j + 1) * base + i] = _courseBorder(data);
            }
          }
        }
    }
    return courseWeightList;
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
              Utils.showToast(app.tokenExpiredContent);
              if (mounted)
                Navigator.popUntil(
                    context, ModalRoute.withName(Navigator.defaultRouteName));
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
      });
    } else {
      if (mounted)
        setState(() {
          state = _State.error;
        });
    }
  }
}
