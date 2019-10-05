import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nkust_ap/models/error_response.dart';
import 'package:nkust_ap/models/leave_submit_info_data.dart';
import 'package:nkust_ap/models/leaves_campus_data.dart';
import 'package:nkust_ap/models/leaves_submit_data.dart';
import 'package:nkust_ap/pages/home/leaves/pick_tutor_page.dart';
import 'package:nkust_ap/res/app_icon.dart';
import 'package:nkust_ap/res/resource.dart' as Resource;
import 'package:nkust_ap/utils/global.dart';
import 'package:nkust_ap/widgets/default_dialog.dart';
import 'package:nkust_ap/widgets/hint_content.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;
import 'package:nkust_ap/widgets/progress_dialog.dart';
import 'package:nkust_ap/widgets/yes_no_dialog.dart';
import 'package:sprintf/sprintf.dart';

enum _State { loading, finish, error, empty }
enum Leave { normal, sick, official, funeral, maternity }

class LeaveApplyPage extends StatefulWidget {
  static const String routerName = "/leave/apply";

  @override
  LeaveApplyPageState createState() => LeaveApplyPageState();
}

class LeaveApplyPageState extends State<LeaveApplyPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  AppLocalizations app;

  _State state = _State.loading;

  var _formKey = GlobalKey<FormState>();

  LeavesSubmitInfoData leavesSubmitInfo;

  int typeIndex = 0;

  LeavesTeacher teacher;

  List<LeavesModel> leavesModels = [];

  bool isDelay = false;

  var _reason = TextEditingController();

  var _delayReason = TextEditingController();

  File image;

  @override
  void initState() {
    FA.setCurrentScreen("LeaveApplyPage", "leave_apply_page.dart");
    _getLeavesInfo();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    app = AppLocalizations.of(context);
    return _body();
  }

  Widget _body() {
    switch (state) {
      case _State.loading:
        return Container(
          child: CircularProgressIndicator(),
          alignment: Alignment.center,
        );
      case _State.error:
      case _State.empty:
        return FlatButton(
          onPressed: null,
          child: HintContent(
            icon: AppIcon.permIdentity,
            content: state == _State.error
                ? app.somethingError
                : app.canNotUseFeature,
          ),
        );
      default:
        return Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.symmetric(vertical: 24),
            children: <Widget>[
              SizedBox(height: 8.0),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(app.leavesType),
              ),
              SizedBox(height: 8.0),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: double.infinity),
                  child: CupertinoSegmentedControl(
                    selectedColor: Resource.Colors.blueAccent,
                    borderColor: Resource.Colors.blueAccent,
                    unselectedColor: Resource.Colors.segmentControlUnSelect,
                    groupValue: typeIndex,
                    children: this
                        .leavesSubmitInfo
                        .type
                        .map((leaveType) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(leaveType.title),
                          );
                        })
                        .toList()
                        .asMap(),
                    onValueChanged: (index) {
                      if (mounted) {
                        setState(() {
                          print(index);
                          typeIndex = index;
                        });
                      }
                      FA.logAction('segment', 'click');
                    },
                  ),
                ),
              ),
              SizedBox(height: 16),
              Divider(color: Resource.Colors.grey, height: 1),
              SizedBox(height: 16),
              FractionallySizedBox(
                widthFactor: 0.3,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(30.0),
                    ),
                  ),
                  padding: EdgeInsets.all(4.0),
                  color: Resource.Colors.blueAccent,
                  onPressed: () async {
                    final List<DateTime> picked =
                        await DateRagePicker.showDatePicker(
                      context: context,
                      initialFirstDate: DateTime.now(),
                      initialLastDate: (DateTime.now()).add(Duration(days: 7)),
                      firstDate: DateTime(2015),
                      lastDate: DateTime(2020),
                    );
                    if (picked != null && picked.length == 2) {
                      DateTime dateTime = picked[0],
                          end = picked[1].add(Duration(days: 1));
                      while (dateTime.isBefore(end)) {
                        bool hasRepeat = false;
                        for (var i = 0; i < leavesModels.length; i++) {
                          if (leavesModels[i].isSameDay(dateTime))
                            hasRepeat = true;
                        }
                        if (!hasRepeat) {
                          leavesModels.add(
                            LeavesModel(
                              dateTime,
                              leavesSubmitInfo.timeCodes.length,
                            ),
                          );
                        }
                        dateTime = dateTime.add(Duration(days: 1));
                      }
                      checkIsDelay();
                      setState(() {});
                    }
                  },
                  child: Text(
                    app.addDate,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Container(
                height: leavesModels.length == 0 ? 0 : 280,
                child: ListView.builder(
                  itemCount: leavesModels.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (_, index) {
                    return Card(
                      elevation: 4.0,
                      margin:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Column(
                          children: <Widget>[
                            SizedBox(height: 4.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Text('${leavesModels[index].dateTime.year}/'
                                    '${leavesModels[index].dateTime.month}/'
                                    '${leavesModels[index].dateTime.day}'),
                                IconButton(
                                  padding: EdgeInsets.all(0.0),
                                  icon: Icon(
                                    AppIcon.cancel,
                                    size: 20.0,
                                    color: Resource.Colors.red,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      leavesModels.removeAt(index);
                                      checkIsDelay();
                                    });
                                  },
                                ),
                              ],
                            ),
                            Container(
                              height: 200,
                              width: 200,
                              child: GridView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  childAspectRatio: 1.0,
                                ),
                                itemBuilder: (context, sectionIndex) {
                                  return FlatButton(
                                    padding: EdgeInsets.all(0.0),
                                    child: Container(
                                      margin: EdgeInsets.all(4.0),
                                      padding: EdgeInsets.all(2.0),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(4.0),
                                        ),
                                        border: Border.all(
                                            color: Resource.Colors.blueAccent),
                                        color: leavesModels[index]
                                                .selected[sectionIndex]
                                            ? Resource.Colors.blueAccent
                                            : null,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        '${leavesSubmitInfo.timeCodes[sectionIndex]}',
                                        style: TextStyle(
                                          color: leavesModels[index]
                                                  .selected[sectionIndex]
                                              ? Colors.white
                                              : Resource.Colors.blueAccent,
                                        ),
                                      ),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        leavesModels[index]
                                                .selected[sectionIndex] =
                                            !leavesModels[index]
                                                .selected[sectionIndex];
                                      });
                                    },
                                  );
                                },
                                itemCount: leavesSubmitInfo.timeCodes.length,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: leavesModels.length == 0 ? 0 : 16.0),
              Divider(color: Resource.Colors.grey, height: 1),
              ListTile(
                enabled: leavesSubmitInfo.tutor == null,
                onTap: leavesSubmitInfo.tutor == null
                    ? () async {
                        var teacher = await Navigator.of(context).push(
                          CupertinoPageRoute(builder: (BuildContext context) {
                            return PickTutorPage();
                          }),
                        );
                        if (teacher != null) {
                          setState(() {
                            this.teacher = teacher;
                          });
                        }
                      }
                    : null,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                leading: Icon(
                  AppIcon.person,
                  size: 30,
                  color: Resource.Colors.grey,
                ),
                trailing: Icon(
                  AppIcon.keyboardArrowDown,
                  size: 30,
                  color: Resource.Colors.grey,
                ),
                title: Text(
                  app.tutor,
                  style: TextStyle(fontSize: 20),
                ),
                subtitle: Text(
                  leavesSubmitInfo.tutor == null
                      ? (teacher?.name ?? app.pleasePick)
                      : (leavesSubmitInfo.tutor?.name ?? ''),
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Divider(color: Resource.Colors.grey, height: 1),
              ListTile(
                onTap: () {
                  ImagePicker.pickImage(source: ImageSource.gallery).then(
                    (image) async {
                      if (image != null) {
                        FA.logLeavesImageSize(image);
                        if ((image.lengthSync() / 1024 / 1024) >=
                            Constants.MAX_IMAGE_SIZE) {
                          resizeImage(image);
                        } else {
                          setState(() {
                            this.image = image;
                          });
                        }
                      }
                    },
                  );
                },
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                leading: Icon(
                  Icons.insert_drive_file,
                  size: 30,
                  color: Resource.Colors.grey,
                ),
                trailing: Icon(
                  AppIcon.keyboardArrowDown,
                  size: 30,
                  color: Resource.Colors.grey,
                ),
                title: Text(
                  app.leavesProof,
                  style: TextStyle(fontSize: 20),
                ),
                subtitle: Text(
                  image?.path?.split('/')?.last ?? app.leavesProofHint,
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Divider(color: Resource.Colors.grey, height: 1),
              SizedBox(height: 24),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: TextFormField(
                  maxLines: 2,
                  controller: _reason,
                  validator: (value) {
                    if (value.isEmpty) {
                      return app.doNotEmpty;
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    fillColor: Resource.Colors.blueAccent,
                    labelStyle: TextStyle(
                      color: Resource.Colors.grey,
                    ),
                    labelText: app.reason,
                  ),
                ),
              ),
              if (isDelay) ...[
                SizedBox(height: 24),
                Divider(color: Resource.Colors.grey, height: 1),
                SizedBox(height: 24),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: TextFormField(
                    maxLines: 2,
                    validator: (value) {
                      if (isDelay && value.isEmpty) {
                        return app.doNotEmpty;
                      }
                      return null;
                    },
                    controller: _delayReason,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      fillColor: Resource.Colors.blueAccent,
                      labelStyle: TextStyle(
                        color: Resource.Colors.grey,
                      ),
                      labelText: app.delayReason,
                    ),
                  ),
                ),
              ],
              SizedBox(height: 24),
              FractionallySizedBox(
                widthFactor: 0.8,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(30.0),
                    ),
                  ),
                  padding: EdgeInsets.all(14.0),
                  onPressed: () {
                    _leaveSubmit();
                    FA.logAction('leaves_submit', 'click');
                  },
                  color: Resource.Colors.blueAccent,
                  child: Text(
                    app.confirm,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24),
            ],
          ),
        );
    }
  }

  Future _getLeavesInfo() async {
    var leavesSubmitInfo = await Helper.instance.getLeavesSubmitInfo();
    if (leavesSubmitInfo != null) {
      setState(() {
        this.state = _State.finish;
        this.leavesSubmitInfo = leavesSubmitInfo;
      });
    }
  }

  void checkIsDelay() {
    isDelay = false;
    for (var i = 0; i < leavesModels.length; i++) {
      if (leavesModels[i].dateTime.isBefore(DateTime.now())) isDelay = true;
    }
    if (isDelay) {
      Utils.showToast(context, app.leavesDelayHint);
    }
  }

  void _leaveSubmit() async {
    List<Day> days = [];
    leavesModels.forEach((leavesModel) {
      bool isNotEmpty = false;
      String date = '${leavesModel.dateTime.year}/'
          '${leavesModel.dateTime.month}/'
          '${leavesModel.dateTime.day}';
      List<String> sections = [];
      for (var i = 0; i < leavesModel.selected.length; i++) {
        if (leavesModel.selected[i]) {
          isNotEmpty = true;
          sections.add(leavesSubmitInfo.timeCodes[i]);
        }
      }
      if (isNotEmpty) {
        days.add(
          Day(
            day: date,
            dayClass: sections,
          ),
        );
      }
    });
    if (days.length == 0) {
      Utils.showToast(context, app.pleasePickDateAndSection);
    } else if (leavesSubmitInfo.tutor == null && teacher == null) {
      Utils.showToast(context, app.pickTeacher);
    } else if (_formKey.currentState.validate()) {
      //TODO submit summary
      String tutorId, tutorName;
      if (leavesSubmitInfo.tutor == null) {
        tutorId = teacher.id;
        tutorName = teacher.name;
      } else {
        tutorId = leavesSubmitInfo.tutor.id;
        tutorName = leavesSubmitInfo.tutor.name;
      }
      LeavesSubmitData data = LeavesSubmitData(
        days: days,
        leaveTypeId: leavesSubmitInfo.type[typeIndex].id,
        teacherId: tutorId,
        reasonText: _reason.text ?? '',
        delayReasonText: isDelay ? (_delayReason.text ?? '') : '',
      );
      print(data.toJson());
      showDialog(
        context: context,
        builder: (BuildContext context) => YesNoDialog(
          title: app.leavesSubmit,
          contentWidgetPadding: EdgeInsets.all(0.0),
          contentWidget: SizedBox(
            height: MediaQuery.of(context).size.height *
                ((image == null) ? 0.3 : 0.5),
            width: MediaQuery.of(context).size.width * 0.7,
            child: ListView(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                    top: 16.0,
                    left: 30.0,
                    right: 30.0,
                  ),
                  child: RichText(
                    textAlign: TextAlign.left,
                    text: TextSpan(
                      style: TextStyle(
                          color: Resource.Colors.grey,
                          height: 1.5,
                          fontSize: 16.0),
                      children: [
                        TextSpan(
                          text: '${app.leavesType}：',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                            text:
                                '${leavesSubmitInfo.type[typeIndex].title}\n'),
                        TextSpan(
                          text: '${app.tutor}：',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: '$tutorName\n'),
                        TextSpan(
                          text: '${app.reason}：\n',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: '${_reason.text}'),
                        if (isDelay) ...[
                          TextSpan(
                            text: '${app.delayReason}：\n',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: '${_delayReason.text}\n'),
                        ],
                        TextSpan(
                          text: '${app.leavesDateAndSection}：\n',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        for (var day in days)
                          TextSpan(text: '${day.toString()}\n'),
                        TextSpan(
                          text:
                              '${app.leavesProof}：${(image == null ? app.none : '')}\n',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                if (image != null)
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 16.0,
                      left: 30.0,
                      right: 30.0,
                    ),
                    child: Image.file(image),
                  ),
              ],
            ),
          ),
          leftActionText: app.cancel,
          rightActionText: app.submit,
          leftActionFunction: null,
          rightActionFunction: () {
            _leaveUpload(data);
            Utils.showToast(context, '上傳中，測試功能');
          },
        ),
      );
    }
  }

  void _leaveUpload(LeavesSubmitData data) {
    showDialog(
      context: context,
      builder: (BuildContext context) => WillPopScope(
        child: ProgressDialog(app.leavesSubmitUploadHint),
        onWillPop: () async {
          return false;
        },
      ),
      barrierDismissible: false,
    );
    Helper.instance.sendLeavesSubmit(data, image).then((Response response) {
      Navigator.of(context, rootNavigator: true).pop();
      showDialog(
        context: context,
        builder: (BuildContext context) => DefaultDialog(
          title: response.statusCode == 200
              ? app.leavesSubmitSuccess
              : '${response.statusCode}',
          contentWidget: RichText(
            textAlign: TextAlign.left,
            text: TextSpan(
              style: TextStyle(
                  color: Resource.Colors.grey, height: 1.3, fontSize: 16.0),
              children: [
                TextSpan(
                  text: response.statusCode == 200
                      ? app.leavesSubmitSuccess
                      : '${response.data}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          actionText: app.iKnow,
          actionFunction: () =>
              Navigator.of(context, rootNavigator: true).pop(),
        ),
      );
    }).catchError((e) {
      Navigator.of(context, rootNavigator: true).pop();
      if (e is DioError) {
        switch (e.type) {
          case DioErrorType.RESPONSE:
            ErrorResponse errorResponse =
                ErrorResponse.fromJson(e.response.data);
            showDialog(
              context: context,
              builder: (BuildContext context) => DefaultDialog(
                title: app.busReserveFailTitle,
                contentWidget: Text(
                  errorResponse.description,
                  style: TextStyle(
                      color: Resource.Colors.grey, height: 1.3, fontSize: 16.0),
                ),
                actionText: app.iKnow,
                actionFunction: () {
                  Navigator.of(context, rootNavigator: true).pop();
                },
              ),
            );
            break;
          case DioErrorType.DEFAULT:
            setState(() {
              state = _State.error;
            });
            Utils.showToast(context, app.somethingError);
            break;
          case DioErrorType.CANCEL:
            break;
          default:
            Utils.handleDioError(context, e);
            break;
        }
      } else {
        throw e;
      }
    });
  }

  Future resizeImage(File image) async {
    File result = await Utils.resizeImageByNative(image);
    FA.logLeavesImageCompressSize(image, result);
    if ((result.lengthSync() / 1024 / 1024) <= Constants.MAX_IMAGE_SIZE) {
      Utils.showToast(
        context,
        sprintf(
          app.imageCompressHint,
          [(result.lengthSync() / 1024 / 1024)],
        ),
      );
      setState(() {
        this.image = result;
      });
    } else {
      Utils.showToast(context, app.imageTooBigHint);
      FA.logEvent('leaves_pick_fail');
    }
  }
}

class LeavesModel {
  DateTime dateTime;
  List<bool> selected = [];

  LeavesModel(this.dateTime, int count) {
    for (var i = 0; i < count; i++) {
      selected.add(false);
    }
  }

  bool isSameDay(DateTime dateTime) {
    return (dateTime.year == this.dateTime.year &&
        dateTime.month == this.dateTime.month &&
        dateTime.day == this.dateTime.day);
  }
}
