import 'package:flutter/material.dart';
import 'package:nkust_ap/res/resource.dart';
import 'package:nkust_ap/api/helper.dart';

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
  List<Widget> courseWeightList;
  var selectSemesterIndex;
  var selectSemester;

  var semesterData;

  int base = 6;

  @override
  void initState() {
    super.initState();
    Helper.instance.getSemester().then((response) {
      semesterData = response;
      selectSemester = semesterData.data["default"]["text"];
      selectSemesterIndex = 0;
      _getCourseTables();
      setState(() {});
    });
  }

  @override
  void dispose() {
    // Dispose of the Tab Controller
    super.dispose();
  }

  _textStyle() {
    return TextStyle(color: Colors.blue, fontSize: 12.0);
  }

  Widget _textBorder(String text) {
    return new Container(
      decoration: new BoxDecoration(border: new Border.all(color: Colors.blue)),
      child: FlatButton(
          onPressed: _showCourse,
          child: Text(
            text ?? "",
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
        title: new Text(Strings.course),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FlatButton(
                onPressed: _selectSemester,
                child: Text(
                  selectSemester ?? "",
                  style: _textStyle(),
                )),
            RefreshIndicator(
              onRefresh: () => _getCourseTables(),
              child: GridView.count(
                mainAxisSpacing: 0.0,
                shrinkWrap: true,
                crossAxisCount: base,
                children: courseWeightList ?? <Widget>[],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _selectSemester() {
    var semesters = <SimpleDialogOption>[];
    for (var semester in semesterData.data["semester"]) {
      semesters.add(_dialogItem(semesters.length, semester["text"]));
    }
    showDialog<int>(
            context: context,
            builder: (BuildContext context) =>
                SimpleDialog(title: const Text('請選擇學期'), children: semesters))
        .then<void>((int position) {
      if (position != null) {
        selectSemesterIndex = position;
        selectSemester =
            semesterData.data["semester"][selectSemesterIndex]["text"];
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
    var textList =
        semesterData.data["semester"][selectSemesterIndex]["value"].split(",");
    if (textList.length == 2) {
      Helper.instance
          .getCourseTables(textList[0], textList[1])
          .then((response) {
        courseWeightList = <Widget>[
          _textBorder(""),
          _textBorder("一"),
          _textBorder("二"),
          _textBorder("三"),
          _textBorder("四"),
          _textBorder("五")
        ];
        for (var text in response.data["coursetables"]["timecode"]) {
          courseWeightList.add(_textBorder(text));
          courseWeightList.add(_textBorder(""));
          courseWeightList.add(_textBorder(""));
          courseWeightList.add(_textBorder(""));
          courseWeightList.add(_textBorder(""));
          courseWeightList.add(_textBorder(""));
        }
        var weeks = [
          "Sunday",
          "Monday",
          "Thursday",
          "Wednesday",
          "Tuesday",
          "Friday"
        ];
        var timeCodes = response.data["coursetables"]["timecode"];
        for (int i = 0; i < weeks.length; i++) {
          if (response.data["coursetables"][weeks[i]] != null)
            for (var data in response.data["coursetables"][weeks[i]]) {
              for (int j = 0; j < timeCodes.length; j++) {
                if (timeCodes[j] == data["date"]["section"]) {
                  courseWeightList[j * base + i] =
                      _textBorder(data["title"][0] + data["title"][1]);
                }
              }
            }
        }
        setState(() {});
      });
    } else {
      //TODO 錯誤訊息
    }
  }

  _showCourse() {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text('課程資訊'),
              content: Text("測試"),
              actions: <Widget>[
                FlatButton(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop('dialog');
                  },
                )
              ],
            ));
  }
}
