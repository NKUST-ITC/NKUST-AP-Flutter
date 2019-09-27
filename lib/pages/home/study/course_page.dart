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
enum _ContentStyle { card, table }

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
  _ContentStyle _contentStyle = _ContentStyle.table;

  Semester selectSemester;
  SemesterData semesterData;
  CourseData courseData;

  bool isOffline = false;

  int get base => (courseData.hasHoliday) ? 6 : 8;

  double get childAspectRatio => (courseData.hasHoliday) ? 1.5 : 1.1;

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
                    _loadCourseData(semester.code);
                  else
                    _getCourseTables();
                },
              ),
              if (isOffline)
                Text(
                  app.offlineCourse,
                  style: TextStyle(color: Resource.Colors.grey),
                ),
              if (_contentStyle == _ContentStyle.table)
                Text(
                  app.courseClickHint,
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.search),
        onPressed: () {
          key.currentState.pickSemester();
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              iconSize: _contentStyle == _ContentStyle.table ? 24 : 20,
              color: _contentStyle == _ContentStyle.table
                  ? Resource.Colors.yellow
                  : Resource.Colors.grey,
              icon: Icon(Icons.grid_on),
              onPressed: () {
                setState(() {
                  _contentStyle = _ContentStyle.table;
                });
              },
            ),
            IconButton(
              iconSize: _contentStyle == _ContentStyle.card ? 24 : 20,
              color: _contentStyle == _ContentStyle.card
                  ? Resource.Colors.yellow
                  : Resource.Colors.grey,
              icon: Icon(Icons.format_list_bulleted),
              onPressed: () {
                setState(() {
                  _contentStyle = _ContentStyle.card;
                });
              },
            ),
            Container(height: 0),
          ],
        ),
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
        if (_contentStyle == _ContentStyle.card) {
          return ListView.builder(
            itemBuilder: (_, index) {
              var course = courseData.courses[index];
              return Card(
                elevation: 4.0,
                margin: EdgeInsets.all(8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
                  title: Text(
                    courseData.courses[index].title,
                    style: TextStyle(
                      height: 1.3,
                      fontSize: 20.0,
                    ),
                  ),
                  subtitle: Padding(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          flex: 2,
                          child: SelectableText.rich(
                            TextSpan(
                              style: TextStyle(
                                color: Resource.Colors.grey,
                                fontSize: 16.0,
                              ),
                              children: [
                                TextSpan(
                                    text: '${app.studentClass}：',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                TextSpan(text: '${course.className}\n'),
                                TextSpan(
                                    text: '${app.courseDialogProfessor}：',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                TextSpan(text: '${course.getInstructors()}\n'),
                                TextSpan(
                                    text: '${app.courseDialogLocation}：',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                TextSpan(
                                    text:
                                        '${course.location.building}${course.location.room}\n'),
                                TextSpan(
                                    text: '${app.courseDialogTime}：',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                TextSpan(text: '${course.times}'),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                '${course.required}',
                                style: TextStyle(
                                  color: Resource.Colors.blueAccent,
                                  fontSize: 18.0,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 16.0),
                              SelectableText.rich(
                                TextSpan(
                                  style: TextStyle(
                                    color: Resource.Colors.grey,
                                    fontSize: 16.0,
                                  ),
                                  children: [
                                    TextSpan(
                                        text: '${app.units}：',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    TextSpan(text: '${course.units}'),
                                  ],
                                ),
                              ),
                              SelectableText.rich(
                                TextSpan(
                                  style: TextStyle(
                                    color: Resource.Colors.grey,
                                    fontSize: 16.0,
                                  ),
                                  children: [
                                    TextSpan(
                                        text: '${app.courseHours}：',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    TextSpan(text: '${course.hours}'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                  ),
                ),
              );
            },
            itemCount: courseData.courses.length,
          );
        } else {
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
    if (courseData.hasHoliday) {
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
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        alignment: Alignment.center,
        child: Text(
          (course.title[0] + course.title[1]) ?? '',
          style: TextStyle(fontSize: 16.0),
          textAlign: TextAlign.center,
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
        } else {
          state = _State.finish;
        }
      });
    }
  }

  _getCourseTables() async {
    Helper.cancelToken.cancel('');
    Helper.cancelToken = CancelToken();
    Helper.instance
        .getCourseTables(selectSemester.year, selectSemester.value)
        .then((response) {
      if (mounted)
        setState(() {
          if (response == null) {
            state = _State.empty;
          } else {
            courseData = response;
            isOffline = false;
            CacheUtils.saveCourseData(selectSemester.code, courseData);
            state = _State.finish;
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
      _loadCourseData(selectSemester.code);
    });
  }
}
