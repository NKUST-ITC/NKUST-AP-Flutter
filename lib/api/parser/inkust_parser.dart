Map<String, dynamic> inkustCourseTableParser(Map<String, dynamic> data) {
  Map<String, dynamic> result = {
    "courses": [],
    "coursetable": {
      "Monday": [],
      "Tuesday": [],
      'Wednesday': [],
      'Thursday': [],
      'Friday': [],
      'Saturday': [],
      'Sunday': [],
      'timeCodes': [],
    },
  };
  //reverse data type for more easy to use.
  Map<String, dynamic> _tempDateTimeChange = {};

  //timeCodes parse
  data["data"]["time"].forEach((element) {
    result["coursetable"]["timeCodes"].add("第${element["periodName"]}節");
    _tempDateTimeChange.addAll({element["period"]: element});
  });

  //courses parse
  data["data"]["course"].forEach((element) {
    result["courses"].add({
      "code": "",
      "title": element['courseName'],
      "className": element['className'],
      "group": element["courseGroup"],
      "units": element["courseCredit"],
      "hours": element["courseHour"],
      "required": element["courseOption"],
      "at": element["courseAnnual"],
      "times": element["courseTime"],
      "location": {"room": element['courseRoom']},
      "instructors": [element['courseTeacher']]
    });
  });

  Map<String, String> courseWeek = {
    "1": 'Monday',
    "2": 'Tuesday',
    "3": 'Wednesday',
    "4": 'Thursday',
    "5": 'Friday',
    "6": 'Saturday',
    "0": 'Sunday',
  };
  //coursetable parse
  data["data"]["course"].forEach((courseElement) {
    courseElement['courseTimeData'].forEach((singleCourseObject) {
      result['coursetable'][courseWeek[singleCourseObject['courseWeek']]].add({
        "title": courseElement['courseName'],
        "date": {
          "startTime":
              "${_tempDateTimeChange[singleCourseObject["coursePeriod"]]["begTime"].substring(0, 2)}:${_tempDateTimeChange[singleCourseObject["coursePeriod"]]["begTime"].substring(2, 4)}",
          "endTime":
              "${_tempDateTimeChange[singleCourseObject["coursePeriod"]]["endTime"].substring(0, 2)}:${_tempDateTimeChange[singleCourseObject["coursePeriod"]]["endTime"].substring(2, 4)}",
          "section":
              "第${_tempDateTimeChange[singleCourseObject["coursePeriod"]]["periodName"]}節"
        },
        "location": {"room": courseElement['courseRoom']},
        "instructors": [courseElement['courseTeacher']]
      });
    });
  });
  return result;
}
