import 'dart:developer';
import 'dart:io';

import 'package:ap_common/resources/ap_icon.dart';
import 'package:ap_common/resources/ap_theme.dart';
import 'package:ap_common/utils/ap_localizations.dart';
import 'package:ap_common/utils/ap_utils.dart';
import 'package:ap_common/utils/dialog_utils.dart';
import 'package:ap_common/widgets/dialog_option.dart';
import 'package:ap_common/widgets/hint_content.dart';
import 'package:ap_common/widgets/progress_dialog.dart';
import 'package:ap_common/widgets/yes_no_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/models/error_response.dart';
import 'package:nkust_ap/models/leave_campus_data.dart';
import 'package:nkust_ap/models/leave_submit_data.dart';
import 'package:nkust_ap/models/leave_submit_info_data.dart';
import 'package:nkust_ap/pages/leave/pick_tutor_page.dart';
import 'package:nkust_ap/utils/global.dart';
import 'package:sprintf/sprintf.dart';

enum _State {
  loading,
  finish,
  error,
  userNotSupport,
  offline,
  custom,
}

enum Leave { normal, sick, official, funeral, maternity }

class LeaveApplyPage extends StatefulWidget {
  static const String routerName = '/leave/apply';

  @override
  LeaveApplyPageState createState() => LeaveApplyPageState();
}

class LeaveApplyPageState extends State<LeaveApplyPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late ApLocalizations ap;

  ImagePicker imagePicker = ImagePicker();

  _State state = _State.loading;
  String? customStateHint;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late LeaveSubmitInfoData leaveSubmitInfo;

  int typeIndex = 0;

  LeavesTeacher? teacher;

  List<LeaveModel> leaveModels = <LeaveModel>[];

  bool isDelay = false;

  final TextEditingController _reason = TextEditingController();

  final TextEditingController _delayReason = TextEditingController();

  PickedFile? image;

  String? get errorTitle {
    switch (state) {
      case _State.loading:
      case _State.finish:
        return '';
      case _State.error:
        return ap.somethingError;
      case _State.userNotSupport:
        return ap.userNotSupport;
      case _State.offline:
        return ap.offlineMode;
      case _State.custom:
        return customStateHint;
    }
  }

  @override
  void initState() {
    FirebaseAnalyticsUtils.instance
        .setCurrentScreen('LeaveApplyPage', 'leave_apply_page.dart');
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
    ap = ApLocalizations.of(context);
    return _body()!;
  }

  Widget? _body() {
    switch (state) {
      case _State.loading:
        return Container(
          alignment: Alignment.center,
          child: const CircularProgressIndicator(),
        );
      case _State.error:
      case _State.offline:
      case _State.userNotSupport:
      case _State.custom:
        return InkWell(
          onTap: _getLeavesInfo,
          child: HintContent(
            icon: state == _State.offline
                ? ApIcon.offlineBolt
                : ApIcon.permIdentity,
            content: errorTitle!,
          ),
        );
      case _State.finish:
        return _content();
    }
  }

  Widget _content() {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 24),
          children: <Widget>[
            ListTile(
              onTap: () {
                showDialog<int>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: Text(ap.leaveType),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(8),
                      ),
                    ),
                    contentPadding: EdgeInsets.zero,
                    content: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: ListView.separated(
                        shrinkWrap: true,
                        controller: ScrollController(
                          initialScrollOffset: typeIndex * 40.0,
                        ),
                        itemCount: leaveSubmitInfo.type.length,
                        itemBuilder: (BuildContext context, int index) {
                          return DialogOption(
                            text: leaveSubmitInfo.type[index].title,
                            check: typeIndex == index,
                            onPressed: () {
                              setState(() {
                                typeIndex = index;
                              });
                              Navigator.pop(context);
                            },
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return const Divider(height: 6.0);
                        },
                      ),
                    ),
                  ),
                );
                FirebaseAnalyticsUtils.instance.logEvent('leave_type_click');
              },
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 8,
              ),
              leading: Icon(
                ApIcon.insertDriveFile,
                size: 30,
                color: ApTheme.of(context).grey,
              ),
              trailing: Icon(
                ApIcon.keyboardArrowDown,
                size: 30,
                color: ApTheme.of(context).grey,
              ),
              title: Text(
                ap.leaveType,
                style: const TextStyle(fontSize: 20),
              ),
              subtitle: Text(
                leaveSubmitInfo.type[typeIndex].title,
                style: const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(height: 16),
            Divider(color: ApTheme.of(context).grey, height: 1),
            const SizedBox(height: 16),
            FractionallySizedBox(
              widthFactor: 0.3,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(30.0),
                    ),
                  ),
                  padding: const EdgeInsets.all(4.0),
                  primary: ApTheme.of(context).blueAccent,
                ),
                onPressed: () async {
                  final DateTimeRange? picked = await showDateRangePicker(
                    context: context,
                    initialDateRange: DateTimeRange(
                      start: DateTime.now(),
                      end: DateTime.now().add(const Duration(days: 7)),
                    ),
                    firstDate: DateTime(2015),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    DateTime dateTime = picked.start;
                    final DateTime end =
                        picked.end.add(const Duration(days: 1));
                    while (dateTime.isBefore(end)) {
                      bool hasRepeat = false;
                      for (int i = 0; i < leaveModels.length; i++) {
                        if (leaveModels[i].isSameDay(dateTime)) {
                          hasRepeat = true;
                        }
                      }
                      if (!hasRepeat) {
                        leaveModels.add(
                          LeaveModel(
                            dateTime,
                            leaveSubmitInfo.timeCodes.length,
                          ),
                        );
                      }
                      dateTime = dateTime.add(const Duration(days: 1));
                    }
                    checkIsDelay();
                    setState(() {});
                  }
                },
                child: Text(
                  ap.addDate,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: leaveModels.isEmpty ? 0 : 280,
              child: ListView.builder(
                itemCount: leaveModels.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (_, int index) => Card(
                  elevation: 4.0,
                  margin: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 8.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Column(
                      children: <Widget>[
                        const SizedBox(height: 4.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Text(
                              '${leaveModels[index].dateTime.year}/'
                              '${leaveModels[index].dateTime.month}/'
                              '${leaveModels[index].dateTime.day}',
                            ),
                            IconButton(
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                ApIcon.cancel,
                                size: 20.0,
                                color: ApTheme.of(context).red,
                              ),
                              onPressed: () {
                                setState(() {
                                  leaveModels.removeAt(index);
                                  checkIsDelay();
                                });
                              },
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 200,
                          width: 200,
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                            ),
                            itemBuilder:
                                (BuildContext context, int sectionIndex) {
                              return InkWell(
                                child: Container(
                                  margin: const EdgeInsets.all(4.0),
                                  padding: const EdgeInsets.all(2.0),
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(4.0),
                                    ),
                                    border: Border.all(
                                      color: ApTheme.of(context).blueAccent,
                                    ),
                                    color: leaveModels[index]
                                            .selected[sectionIndex]
                                        ? ApTheme.of(context).blueAccent
                                        : null,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    leaveSubmitInfo.timeCodes[sectionIndex],
                                    style: TextStyle(
                                      color: leaveModels[index]
                                              .selected[sectionIndex]
                                          ? Colors.white
                                          : ApTheme.of(context).blueAccent,
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  setState(() {
                                    leaveModels[index].selected[sectionIndex] =
                                        !leaveModels[index]
                                            .selected[sectionIndex];
                                  });
                                },
                              );
                            },
                            itemCount: leaveSubmitInfo.timeCodes.length,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: leaveModels.isEmpty ? 0 : 16.0),
            Divider(color: ApTheme.of(context).grey, height: 1),
            ListTile(
              enabled: leaveSubmitInfo.tutor == null,
              onTap: leaveSubmitInfo.tutor == null
                  ? () async {
                      final LeavesTeacher? teacher =
                          await Navigator.of(context).push<LeavesTeacher>(
                        MaterialPageRoute<LeavesTeacher>(
                          builder: (BuildContext context) {
                            return PickTutorPage();
                          },
                        ),
                      );
                      if (teacher != null) {
                        setState(() {
                          this.teacher = teacher;
                        });
                      }
                    }
                  : null,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 8,
              ),
              leading: Icon(
                ApIcon.person,
                size: 30,
                color: ApTheme.of(context).grey,
              ),
              trailing: Icon(
                ApIcon.keyboardArrowDown,
                size: 30,
                color: ApTheme.of(context).grey,
              ),
              title: Text(
                ap.tutor,
                style: const TextStyle(fontSize: 20),
              ),
              subtitle: Text(
                leaveSubmitInfo.tutor == null
                    ? (teacher?.name ?? ap.pleasePick)
                    : (leaveSubmitInfo.tutor?.name ?? ''),
                style: const TextStyle(fontSize: 20),
              ),
            ),
            Divider(color: ApTheme.of(context).grey, height: 1),
            ListTile(
              onTap: () async {
                if (kIsWeb || Platform.isAndroid || Platform.isIOS) {
                  imagePicker.getImage(source: ImageSource.gallery).then(
                    (PickedFile? image) async {
                      if (image != null) {
//                            FirebaseAnalyticsUtils.instance
//                                .logLeavesImageSize(image);
                        if (kIsWeb) {
                          final double size =
                              (await image.readAsBytes()).length.toDouble() /
                                  1024.0 /
                                  1024.0;
                          if (size >= Constants.maxImageSize) {
                            if (!mounted) return;
                            ApUtils.showToast(
                              context,
                              sprintf(
                                ap.imageTooBigHint,
                                <double>[Constants.maxImageSize],
                              ),
                            );
                          } else {
                            setState(() {
                              this.image = image;
                            });
                          }
                        } else {
                          final File file = File(image.path);
                          log('resize before: ${file.mb}');
                          if ((file.mb) >= Constants.maxImageSize) {
                            resizeImage(file);
                          } else {
                            setState(() {
                              this.image = image;
                            });
                          }
                        }
                      }
                    },
                  );
                } else if (!kIsWeb) {
                  final XFile? image = await ApUtils.pickImage();
                  if (image != null) {
                    final File file = File(image.path);
                    if ((file.mb) >= Constants.maxImageSize) {
                      if (!mounted) return;
                      ApUtils.showToast(
                        context,
                        sprintf(
                          ap.imageTooBigHint,
                          <double>[Constants.maxImageSize],
                        ),
                      );
                    } else {
                      setState(() {
                        this.image = PickedFile(file.path);
                      });
                    }
                  }
                }
              },
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 8,
              ),
              leading: Icon(
                ApIcon.insertDriveFile,
                size: 30,
                color: ApTheme.of(context).grey,
              ),
              trailing: Icon(
                ApIcon.keyboardArrowDown,
                size: 30,
                color: ApTheme.of(context).grey,
              ),
              title: Text(
                ap.leaveProof,
                style: const TextStyle(fontSize: 20),
              ),
              subtitle: Text(
                image?.path.split('/').last ?? ap.leaveProofHint,
                style: const TextStyle(fontSize: 20),
              ),
            ),
            Divider(color: ApTheme.of(context).grey, height: 1),
            const SizedBox(height: 36),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextFormField(
                maxLines: 2,
                controller: _reason,
                validator: (String? value) {
                  if (value!.isEmpty) {
                    return ap.doNotEmpty;
                  }
                  return null;
                },
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  fillColor: ApTheme.of(context).blueAccent,
                  labelStyle: TextStyle(
                    color: ApTheme.of(context).grey,
                  ),
                  labelText: ap.reason,
                ),
              ),
            ),
            if (isDelay) ...<Widget>[
              const SizedBox(height: 36),
              Divider(color: ApTheme.of(context).grey, height: 1),
              const SizedBox(height: 36),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextFormField(
                  maxLines: 2,
                  validator: (String? value) {
                    if (isDelay && value!.isEmpty) {
                      return ap.doNotEmpty;
                    }
                    return null;
                  },
                  controller: _delayReason,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    fillColor: ApTheme.of(context).blueAccent,
                    labelStyle: TextStyle(
                      color: ApTheme.of(context).grey,
                    ),
                    labelText: ap.delayReason,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 36),
            FractionallySizedBox(
              widthFactor: 0.8,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(30.0),
                    ),
                  ),
                  padding: const EdgeInsets.all(14.0),
                  primary: ApTheme.of(context).blueAccent,
                ),
                onPressed: () {
                  _leaveSubmit();
                  FirebaseAnalyticsUtils.instance
                      .logEvent('leave_submit_click');
                },
                child: Text(
                  ap.confirm,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _getLeavesInfo() async {
    Helper.instance.getLeavesSubmitInfo(
      callback: GeneralCallback<LeaveSubmitInfoData>(
        onSuccess: (LeaveSubmitInfoData data) {
          setState(() {
            leaveSubmitInfo = data;
            state = _State.finish;
          });
        },
        onFailure: (DioError e) {
          if (mounted) {
            switch (e.type) {
              case DioErrorType.response:
                setState(() {
                  if (e.response!.statusCode == 403) {
                    state = _State.userNotSupport;
                  } else {
                    state = _State.custom;
                    customStateHint = e.message;
                    FirebaseAnalyticsUtils.instance.logApiEvent(
                      'getLeaveSubmitInfo',
                      e.response!.statusCode!,
                      message: e.message,
                    );
                  }
                });
                break;
              case DioErrorType.other:
                setState(() => state = _State.error);
                break;
              case DioErrorType.cancel:
                break;
              default:
                setState(() {
                  state = _State.custom;
                  customStateHint = e.i18nMessage;
                });
                break;
            }
          }
          FirebaseAnalyticsUtils.instance.logEvent('get_submit_submit_fail');
        },
        onError: (GeneralResponse response) {
          setState(() {
            state = _State.custom;
            customStateHint = response.getGeneralMessage(context);
          });
          FirebaseAnalyticsUtils.instance.logEvent('get_submit_submit_fail');
        },
      ),
    );
  }

  void checkIsDelay() {
    isDelay = false;
    for (int i = 0; i < leaveModels.length; i++) {
      if (leaveModels[i].dateTime.isBefore(
            DateTime.now().add(
              const Duration(days: 7),
            ),
          )) isDelay = true;
    }
    if (isDelay) {
      ApUtils.showToast(context, ap.leaveDelayHint);
    }
  }

  Future<void> _leaveSubmit() async {
    final List<Day> days = <Day>[];
    for (final LeaveModel leaveModel in leaveModels) {
      bool isNotEmpty = false;
      final String date = '${leaveModel.dateTime.year}/'
          '${leaveModel.dateTime.month}/'
          '${leaveModel.dateTime.day}';
      final List<String> sections = <String>[];
      for (int i = 0; i < leaveModel.selected.length; i++) {
        if (leaveModel.selected[i]) {
          isNotEmpty = true;
          sections.add(leaveSubmitInfo.timeCodes[i]);
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
    }
    if (days.isEmpty) {
      ApUtils.showToast(context, ap.pleasePickDateAndSection);
    } else if (leaveSubmitInfo.tutor == null && teacher == null) {
      ApUtils.showToast(context, ap.pickTeacher);
    } else if (_formKey.currentState!.validate()) {
      //TODO submit summary
      String tutorId;
      String tutorName;
      if (leaveSubmitInfo.tutor == null) {
        tutorId = teacher!.id;
        tutorName = teacher!.name;
      } else {
        tutorId = leaveSubmitInfo.tutor!.id;
        tutorName = leaveSubmitInfo.tutor!.name;
      }
      final LeaveSubmitData data = LeaveSubmitData(
        days: days,
        leaveTypeId: leaveSubmitInfo.type[typeIndex].id,
        teacherId: tutorId,
        reasonText: _reason.text,
        delayReasonText: isDelay ? (_delayReason.text) : '',
      );
      showDialog(
        context: context,
        builder: (BuildContext context) => YesNoDialog(
          title: ap.leaveSubmit,
          contentWidgetPadding: EdgeInsets.zero,
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
                        color: ApTheme.of(context).grey,
                        height: 1.5,
                        fontSize: 16.0,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: '${ap.leaveType}：',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: '${leaveSubmitInfo.type[typeIndex].title}\n',
                        ),
                        TextSpan(
                          text: '${ap.tutor}：',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: '$tutorName\n'),
                        TextSpan(
                          text: '${ap.reason}：\n',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: _reason.text),
                        if (isDelay) ...<TextSpan>[
                          TextSpan(
                            text: '${ap.delayReason}：\n',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: '${_delayReason.text}\n'),
                        ],
                        TextSpan(
                          text: '${ap.leaveDateAndSection}：\n',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        for (Day day in days)
                          TextSpan(text: '${day.toString()}\n'),
                        TextSpan(
                          text: '${ap.leaveProof}：'
                              '${image == null ? ap.none : ''}\n',
                          style: const TextStyle(fontWeight: FontWeight.bold),
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
                    child: kIsWeb
                        ? Image.network(image!.path)
                        : Image.file(File(image!.path)),
                  ),
              ],
            ),
          ),
          leftActionText: ap.cancel,
          rightActionText: ap.submit,
          rightActionFunction: () {
            _leaveUpload(data);
          },
        ),
      );
    }
  }

  void _leaveUpload(LeaveSubmitData data) {
    showDialog(
      context: context,
      builder: (BuildContext context) => WillPopScope(
        child: ProgressDialog(ap.leaveSubmitUploadHint),
        onWillPop: () async {
          return false;
        },
      ),
      barrierDismissible: false,
    );
    Helper.instance.sendLeavesSubmit(
      data: data,
      image: image,
      callback: GeneralCallback<Response<dynamic>>(
        onSuccess: (Response<dynamic> data) {
          Navigator.of(context, rootNavigator: true).pop();
          DialogUtils.showDefault(
            context: context,
            title:
                data.statusCode == 200 ? ap.leaveSubmit : '${data.statusCode}',
            content:
                data.statusCode == 200 ? ap.leaveSubmitSuccess : '${data.data}',
          );
          FirebaseAnalyticsUtils.instance.logEvent('leave_submit_success');
        },
        onFailure: (DioError e) {
          Navigator.of(context, rootNavigator: true).pop();
          String? text;
          switch (e.type) {
            case DioErrorType.response:
              if (e.response!.data is Map<String, dynamic>) {
                text = ErrorResponse.fromJson(
                  e.response!.data as Map<String, dynamic>,
                ).description;
              } else {
                text = ap.somethingError;
              }
              break;
            case DioErrorType.other:
              text = ap.somethingError;
              break;
            case DioErrorType.cancel:
              break;
            default:
              text = e.i18nMessage;
              break;
          }
          if (text != null) {
            DialogUtils.showDefault(
              context: context,
              title: ap.leaveSubmitFail,
              content: text,
            );
          }
          FirebaseAnalyticsUtils.instance.logEvent('leave_submit_fail');
        },
        onError: (GeneralResponse response) {
          Navigator.of(context, rootNavigator: true).pop();
          DialogUtils.showDefault(
            context: context,
            title: ap.leaveSubmitFail,
            content: response.getGeneralMessage(context),
          );
          FirebaseAnalyticsUtils.instance.logEvent('leave_submit_fail');
        },
      ),
    );
  }

  Future<void> resizeImage(File image) async {
    final File result = await Utils.resizeImageByNative(image);
    log('resize after: ${result.mb}');
    FirebaseAnalyticsUtils.instance.logLeavesImageCompressSize(image, result);
    if ((result.mb) <= Constants.maxImageSize) {
      if (!mounted) return;
      ApUtils.showToast(
        context,
        sprintf(
          ap.imageCompressHint,
          <double>[
            Constants.maxImageSize,
            (result.mb),
          ],
        ),
      );
      setState(() {
        this.image = PickedFile(result.path);
      });
    } else {
      if (!mounted) return;
      ApUtils.showToast(context, ap.imageTooBigHint);
      FirebaseAnalyticsUtils.instance.logEvent('leave_pick_fail');
    }
  }
}

class LeaveModel {
  DateTime dateTime;
  List<bool> selected = <bool>[];

  LeaveModel(this.dateTime, int count) {
    for (int i = 0; i < count; i++) {
      selected.add(false);
    }
  }

  bool isSameDay(DateTime dateTime) {
    return dateTime.year == this.dateTime.year &&
        dateTime.month == this.dateTime.month &&
        dateTime.day == this.dateTime.day;
  }
}

extension FileExtension on File {
  double get mb => lengthSync() / 1024 / 1024;
}
