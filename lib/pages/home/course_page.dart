import 'package:flutter/material.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;
import 'package:nkust_ap/api/helper.dart';
import 'package:nkust_ap/models/models.dart';
import 'package:nkust_ap/utils/app_localizations.dart';

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
  List<Widget> courseWeightList = [];
  var selectSemesterIndex;
  Semester selectSemester;

  SemesterData semesterData;

  int base = 6;

  bool isLoading = true;
  bool isError = false;
  CourseState state = CourseState.loading;

  var childAspectRatio = 0.5;

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
    return TextStyle(color: Resource.Colors.blue, fontSize: 14.0);
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

  Widget _courseBorder(var data) {
    Course course = Course.fromJson(data);
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
            (data["title"][0] + data["title"][1]) ?? "",
            style: _textStyle(),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    local = AppLocalizations.of(context);
    return new Scaffold(
      // Appbar
      appBar: new AppBar(
        // Title
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
                      style: _textBlueStyle(),
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
                child: isLoading
                    ? Container(
                        child: CircularProgressIndicator(),
                        alignment: Alignment.center)
                    : courseWeightList.length == 0
                        ? FlatButton(
                            onPressed:
                                isError ? _getCourseTables : _selectSemester,
                            child: Center(
                              child: Flex(
                                mainAxisAlignment: MainAxisAlignment.center,
                                direction: Axis.vertical,
                                children: <Widget>[
                                  SizedBox(
                                    child: Icon(
                                      Icons.class_,
                                      size: 150.0,
                                    ),
                                    width: 200.0,
                                  ),
                                  Text(
                                    isError
                                        ? local.clickToRetry
                                        : local.courseEmpty,
                                    textAlign: TextAlign.center,
                                  )
                                ],
                              ),
                            ))
                        : GridView.count(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            mainAxisSpacing: 0.0,
                            shrinkWrap: true,
                            childAspectRatio: childAspectRatio,
                            crossAxisCount: base,
                            children: courseWeightList ?? <Widget>[],
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _getSemester() {
    Helper.instance.getSemester().then((response) {
      if (response.data == null) {
      } else {
        semesterData = SemesterData.fromJson(response.data);
        selectSemester = semesterData.defaultSemester;
        selectSemesterIndex = 0;
        _getCourseTables();
        setState(() {});
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
    courseWeightList.clear();
    isLoading = true;
    setState(() {});
    var textList = semesterData.semesters[selectSemesterIndex].value.split(",");
    if (textList.length == 2) {
      Helper.instance
          .getCourseTables(textList[0], textList[1])
          .then((response) {
        //var semesterData = SemesterData.fromJson(response.data);
        if (response.data["status"] == 200) {
          var weeks = [
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
          if (response.data["coursetables"]["Saturday"] != null ||
              response.data["coursetables"]["Sunday"] != null) {
            courseWeightList.add(_textBorder(local.weekdays[4]));
            courseWeightList.add(_textBorder(local.weekdays[5]));
            courseWeightList
                .add(_textBorder(local.weekdays[6], topRight: true));
            weeks.add("Saturday");
            weeks.add("Sunday");
            base = 8;
            childAspectRatio = 1.1;
          } else {
            courseWeightList
                .add(_textBorder(local.weekdays[4], topRight: true));
            base = 6;
            childAspectRatio = 1.5;
          }
          for (String text in response.data["coursetables"]["timecode"]) {
            text = text.replaceAll(' ', '');
            if (base == 8) {
              text = text.replaceAll('第', '');
              text = text.replaceAll('節', '');
            }
            courseWeightList.add(_textBorder(text));
            for (var i = 0; i < base - 1; i++)
              courseWeightList.add(_textBorder("", isCenter: true));
          }
          var timeCodes = response.data["coursetables"]["timecode"];
          for (int i = 0; i < weeks.length; i++) {
            if (response.data["coursetables"][weeks[i]] != null)
              for (var data in response.data["coursetables"][weeks[i]]) {
                for (int j = 0; j < timeCodes.length; j++) {
                  if (timeCodes[j] == data["date"]["section"]) {
                    courseWeightList[(j + 1) * base + i] = _courseBorder(data);
                  }
                }
              }
          }
        }
        isLoading = false;
        isError = false;
        setState(() {});
      });
    } else {
      isLoading = false;
      isError = true;
      setState(() {});
    }
  }
}
