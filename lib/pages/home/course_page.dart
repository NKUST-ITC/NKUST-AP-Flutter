import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;
import 'package:nkust_ap/api/helper.dart';
import 'package:nkust_ap/models/models.dart';
import 'package:nkust_ap/utils/app_localizations.dart';
import 'package:nkust_ap/utils/utils.dart';
import 'package:nkust_ap/widgets/hint_content.dart';

enum CourseState { loading, finish, error, empty }

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

// SingleTickerProviderStateMixin is used for animation
class CoursePageState extends State<CoursePage>
    with SingleTickerProviderStateMixin {
  CourseState state = CourseState.loading;
  List<Widget> courseWeightList = [];
  var selectSemesterIndex;
  Semester selectSemester;

  SemesterData semesterData;
  CourseData courseData;

  int base = 6;
  double childAspectRatio = 0.5;

  AppLocalizations local;

  @override
  void initState() {
    super.initState();
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
        border: new Border.all(color: Colors.grey, width: 0.5),
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
    String content = "${local.courseDialogName}：${course.title}\n"
        "${local.courseDialogProfessor}：${course.instructors[0] ?? ""}\n"
        "${local.courseDialogLocation}：${course.building}${course.room}\n"
        "${local.courseDialogTime}：${course.startTime}-${course.endTime}";
    return new Container(
      decoration: new BoxDecoration(
          border: new Border.all(color: Colors.grey, width: 0.5)),
      child: FlatButton(
          padding: EdgeInsets.all(0.0),
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                      title: Text(local.courseDialogTitle),
                      content: Text(content),
                      actions: <Widget>[
                        FlatButton(
                          padding: EdgeInsets.all(4.0),
                          child: Text(local.ok),
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
      case CourseState.loading:
        return Container(
            child: CircularProgressIndicator(), alignment: Alignment.center);
      case CourseState.empty:
      case CourseState.error:
        return FlatButton(
          onPressed:
              state == CourseState.error ? _getCourseTables : _selectSemester,
          child: HintContent(
              icon: Icons.class_,
              content: state == CourseState.error
                  ? local.clickToRetry
                  : local.courseEmpty),
        );
      default:
        return GridView.count(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          mainAxisSpacing: 0.0,
          shrinkWrap: true,
          childAspectRatio: childAspectRatio,
          crossAxisCount: base,
          children: courseWeightList ?? <Widget>[],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    local = AppLocalizations.of(context);
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(local.course),
        backgroundColor: Resource.Colors.blue,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Flex(
          direction: Axis.vertical,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            SizedBox(height: 8.0),
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
                          color: Resource.Colors.blue, fontSize: 14.0),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: Resource.Colors.blue,
                    )
                  ],
                ),
              ),
            ),
            SizedBox(height: 8.0),
            Expanded(
              flex: 19,
              child: RefreshIndicator(
                onRefresh: () => _getCourseTables(),
                child: _body(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _getSemester() {
    Helper.instance.getSemester().then((semesterData) {
      this.semesterData = semesterData;
      selectSemester = semesterData.defaultSemester;
      selectSemesterIndex = 0;
      _getCourseTables();
      setState(() {});
    }).catchError((e) {
      assert(e is DioError);
      DioError dioError = e as DioError;
      switch (dioError.type) {
        case DioErrorType.RESPONSE:
          Utils.showToast(AppLocalizations.of(context).tokenExpiredContent);
          Navigator.popUntil(
              context, ModalRoute.withName(Navigator.defaultRouteName));
          break;
        case DioErrorType.CANCEL:
          break;
        default:
          state = CourseState.error;
          Utils.handleDioError(dioError, local);
          break;
      }
    });
  }

  void _selectSemester() {
    var semesters = <SimpleDialogOption>[];
    for (var semester in semesterData.semesters) {
      semesters.add(_dialogItem(semesters.length, semester.text));
    }
    showDialog<int>(
        context: context,
        builder: (BuildContext context) => SimpleDialog(
            title: Text(local.picksSemester),
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
    courseWeightList.clear();
    state = CourseState.loading;
    setState(() {});
    var textList = semesterData.semesters[selectSemesterIndex].value.split(",");
    if (textList.length == 2) {
      Helper.instance
          .getCourseTables(textList[0], textList[1])
          .then((response) {
        courseData = response;
        if (courseData.status == 200) {
          List<String> weeks = [
            "Sunday",
            "Monday",
            "Tuesday",
            "Wednesday",
            "Thursday",
            "Friday"
          ];
          courseWeightList = <Widget>[_textBorder("", topLeft: true)];
          for (var week in local.weekdays.sublist(0, 4))
            courseWeightList.add(_textBorder(week));
          if (courseData.courseTables.saturday.isEmpty &&
              courseData.courseTables.sunday.isEmpty) {
            courseWeightList
                .add(_textBorder(local.weekdays[4], topRight: true));
            base = 6;
            childAspectRatio = 1.5;
          } else {
            courseWeightList.add(_textBorder(local.weekdays[4]));
            courseWeightList.add(_textBorder(local.weekdays[5]));
            courseWeightList
                .add(_textBorder(local.weekdays[6], topRight: true));
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
              for (var data
                  in courseData.courseTables.getCourseList(weeks[i])) {
                for (int j = 0; j < timeCodes.length; j++) {
                  if (timeCodes[j] == data.section) {
                    courseWeightList[(j + 1) * base + i] = _courseBorder(data);
                  }
                }
              }
          }
        }
        setState(() {
          if (courseWeightList.length == 0)
            state = CourseState.empty;
          else
            state = CourseState.finish;
        });
      }).catchError((e) {
        assert(e is DioError);
        DioError dioError = e as DioError;
        switch (dioError.type) {
          case DioErrorType.RESPONSE:
            Utils.showToast(AppLocalizations.of(context).tokenExpiredContent);
            Navigator.popUntil(
                context, ModalRoute.withName(Navigator.defaultRouteName));
            break;
          case DioErrorType.CANCEL:
            break;
          default:
            setState(() {
              state = CourseState.error;
            });
            Utils.handleDioError(dioError, local);
            break;
        }
      });
    } else {
      setState(() {
        state = CourseState.error;
      });
    }
  }
}
