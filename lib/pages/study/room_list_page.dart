import 'package:ap_common/ap_common.dart';
import 'package:flutter/material.dart';
import 'package:nkust_ap/api/helper.dart';
import 'package:nkust_ap/models/room_data.dart';
import 'package:nkust_ap/pages/study/room_course_page.dart';
import 'package:nkust_ap/utils/app_localizations.dart';

enum _State { loading, finish, custom }

class RoomListPage extends StatefulWidget {
  @override
  RoomListPageState createState() => RoomListPageState();
}

class RoomListPageState extends State<RoomListPage> {
  late AppLocalizations app;

  _State state = _State.loading;
  int campusIndex = 0;
  int roomIndex = 0;
  RoomData? roomData;
  CourseData? courseData;
  String? customStateHint;

  @override
  void initState() {
    _getRoomList();
    AnalyticsUtil.instance.setCurrentScreen('RoomListPage', 'room_list_page.dart');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    app = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(ApLocalizations.of(context).roomList)),
      body: Flex(
        direction: Axis.vertical,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ItemPicker(
            dialogTitle: app.campus,
            items: app.campuses,
            currentIndex: campusIndex,
            onSelected: (index) {
              setState(() => campusIndex = index);
              _getRoomList();
            },
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _getRoomList(),
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
        return const Center(child: CircularProgressIndicator());
      case _State.finish:
        return ListView.builder(
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(roomData!.data[index].name),
              onTap: () {
                roomIndex = index;
                ApUtils.pushCupertinoStyle(
                  context,
                  EmptyRoomPage(room: roomData!.data[roomIndex]),
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
          child: HintContent(icon: ApIcon.classIcon, content: customStateHint!),
        );
    }
  }

  Future<void> _getRoomList() async {
    Helper.instance.getRoomList(
      campusCode: campusIndex + 1,
      callback: GeneralCallback<RoomData>(
        onSuccess: (data) {
          setState(() {
            roomData = data;
            if (roomData != null) {
              state = _State.finish;
            } else {
              state = _State.custom;
              customStateHint = ApLocalizations.of(context).somethingError;
            }
          });
        },
        onFailure: (e) async {
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
        },
        onError: (response) async {
          setState(() {
            state = _State.custom;
            customStateHint = response.getGeneralMessage(context);
          });
        },
      ),
    );
  }
}
