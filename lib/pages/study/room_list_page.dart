import 'package:ap_common/ap_common.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/api/helper.dart';
import 'package:nkust_ap/models/room_data.dart';
import 'package:nkust_ap/pages/study/room_course_page.dart';
import 'package:nkust_ap/utils/app_localizations.dart';

enum _State { loading, finish, custom }

class RoomListPage extends StatefulWidget {
  @override
  _RoomListPageState createState() => _RoomListPageState();
}

class _RoomListPageState extends State<RoomListPage> {
  late AppLocalizations app;

  _State state = _State.loading;

  int campusIndex = 0;
  int roomIndex = 0;

  RoomData? roomData;
  CourseData? courseData;
  SemesterData? semesterData;
  String? customStateHint;

  @override
  void initState() {
    _getRoomList();
    AnalyticsUtil.instance.setCurrentScreen(
      'RoomListPage',
      'room_list_page.dart',
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    app = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(context.ap.roomList),
      ),
      body: Flex(
        direction: Axis.vertical,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          ItemPicker(
            dialogTitle: app.campus,
            items: app.campuses,
            currentIndex: campusIndex,
            onSelected: (int index) {
              setState(() => campusIndex = index);
              _getRoomList();
            },
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await _getRoomList();
                return;
              },
              child: body(),
            ),
          ),
        ],
      ),
    );
  }

  Widget body() {
    switch (state) {
      case _State.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );
      case _State.finish:
        return ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Text(roomData!.data[index].name),
              onTap: () {
                roomIndex = index;
                ApUtils.pushCupertinoStyle(
                  context,
                  EmptyRoomPage(
                    room: roomData!.data[roomIndex],
                  ),
                );
              },
            );
          },
          itemCount: roomData!.data.length,
        );
      case _State.custom:
        return InkWell(
          onTap: () {
            _getRoomList();
            AnalyticsUtil.instance.logEvent('retry_click');
          },
          child: HintContent(
            icon: ApIcon.classIcon,
            content: customStateHint!,
          ),
        );
    }
  }

  Future<void> _getRoomList() async {
    try {
      semesterData = await Helper.instance.getSemester();
      final RoomData data = await Helper.instance.getRoomList(
        semester: semesterData!.defaultSemester,
        campusCode: campusIndex + 1,
      );
      setState(() {
        roomData = data;
        state = _State.finish;
      });
    } on GeneralResponse catch (generalResponse) {
      setState(() {
        state = _State.custom;
        customStateHint = generalResponse.getGeneralMessage(context);
      });
    } on DioException catch (e) {
      if (e.type != DioExceptionType.cancel) {
        setState(() {
          state = _State.custom;
          customStateHint = e.i18nMessage;
        });
      }
      if (e.hasResponse) {
        AnalyticsUtil.instance.logApiEvent(
          'getRoomCourseTables',
          e.response!.statusCode!,
          message: e.message ?? '',
        );
      }
    }
  }
}
