import 'package:flutter/material.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;
import 'package:nkust_ap/api/helper.dart';
import 'package:nkust_ap/models/models.dart';

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
    return TextStyle(color: Resource.Colors.blue, fontSize: 16.0);
  }

  _textStyle() {
    return TextStyle(color: Colors.black, fontSize: 14.0);
  }

  Widget _textBorder(String text) {
    return new Container(
      decoration: new BoxDecoration(
          border: new Border.all(color: Colors.grey, width: 0.5)),
      child: FlatButton(
        onPressed: () {},
        child: Text(
          text ?? "",
          style: _textBlueStyle(),
        ),
      ),
    );
  }

  Widget _courseBorder(var data) {
    Course course = Course.fromJson(data);
    String content = "課程名稱：${course.title}\n"
        "授課老師：${course.instructors[0] ?? ""}\n"
        "教室位置：${course.building}${course.room}\n"
        "上課時間：${course.startTime}-${course.endTime}";
    return new Container(
      decoration: new BoxDecoration(
          border: new Border.all(color: Colors.grey, width: 0.5)),
      child: FlatButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                      title: const Text('課程資訊'),
                      content: Text(content),
                      actions: <Widget>[
                        FlatButton(
                          child: Text("OK"),
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
    return new Scaffold(
      // Appbar
      appBar: new AppBar(
        // Title
        title: new Text(Resource.Strings.course),
        backgroundColor: Resource.Colors.blue,
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Flex(
          direction: Axis.vertical,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
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
                                        ? "發生錯誤，點擊重試"
                                        : "Oops！本學期沒有任何課哦～\n請選擇其他學期\uD83D\uDE0B",
                                    textAlign: TextAlign.center,
                                  )
                                ],
                              ),
                            ))
                        : GridView.count(
                            mainAxisSpacing: 0.0,
                            shrinkWrap: true,
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
            builder: (BuildContext context) =>
                SimpleDialog(title: const Text('請選擇學期'), children: semesters))
        .then<void>((int position) {
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
          courseWeightList = <Widget>[
            _textBorder(""),
            _textBorder("一"),
            _textBorder("二"),
            _textBorder("三"),
            _textBorder("四"),
            _textBorder("五")
          ];
          if (response.data["coursetables"]["Saturday"] != null ||
              response.data["coursetables"]["Sunday"] != null) {
            courseWeightList.add(_textBorder("六"));
            courseWeightList.add(_textBorder("日"));
            weeks.add("Saturday");
            weeks.add("Sunday");
            base = 8;
          } else {
            base = 6;
          }
          for (var text in response.data["coursetables"]["timecode"]) {
            courseWeightList.add(_textBorder(text));
            for (var i = 0; i < base - 1; i++)
              courseWeightList.add(_textBorder(""));
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
