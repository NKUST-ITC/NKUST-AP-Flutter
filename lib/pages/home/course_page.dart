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
  var courseList;
  var selectSemesterIndex;
  var selectSemester;

  var semesterData;

  @override
  void initState() {
    super.initState();
    Helper.instance.getSemester().then((response) {
      semesterData = response;
      selectSemester = semesterData.data["default"]["text"];
      selectSemesterIndex = 0;
      _getCourseTables(semesterData.data["default"]["value"]);
      setState(() {});
    });
  }

  @override
  void dispose() {
    // Dispose of the Tab Controller
    super.dispose();
  }

  _textStyle() {
    return TextStyle(color: Colors.blue);
  }

  Widget _textBorder(String text) {
    return new Container(
      padding: const EdgeInsets.all(0.0),
      decoration: new BoxDecoration(border: new Border.all(color: Colors.blue)),
      child: FlatButton(
          onPressed: _selectSemester,
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
      body: Column(
        children: <Widget>[
          FlatButton(
              onPressed: _selectSemester,
              child: Text(
                selectSemester ?? "",
                style: _textStyle(),
              )),
          Container(
            child: GridView.count(
              shrinkWrap: true,
              crossAxisCount: 6,
              children: courseList ?? <Widget>[],
            ),
          )
        ],
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
        _getCourseTables(
            semesterData.data["semester"][selectSemesterIndex]["value"]);
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

  _getCourseTables(String value) async {
    var textList = value.split(",");
    if (textList.length == 2) {
      Helper.instance
          .getCourseTables(textList[0], textList[1])
          .then((response) {
        courseList = <Widget>[];
        for (var text in response.data["coursetables"]["timecode"]) {
          courseList.add(_textBorder(text));
          courseList.add(_textBorder(""));
          courseList.add(_textBorder(""));
          courseList.add(_textBorder(""));
          courseList.add(_textBorder(""));
          courseList.add(_textBorder(""));
        }
        setState(() {});
      });
    } else {
      //TODO 錯誤訊息
    }
  }
}
