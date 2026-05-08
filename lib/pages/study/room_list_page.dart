import 'package:ap_common/ap_common.dart';
import 'package:flutter/material.dart';
import 'package:nkust_crawler/nkust_crawler.dart';
import 'package:nkust_ap/api/exceptions/api_exception_l10n.dart';
import 'package:nkust_ap/pages/study/room_course_page.dart';
import 'package:nkust_ap/l10n/nkust_localizations.dart';

enum _State { loading, finish, custom }

class RoomListPage extends StatefulWidget {
  @override
  RoomListPageState createState() => RoomListPageState();
}

class RoomListPageState extends State<RoomListPage> {
  late NkustLocalizations app;

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
    AnalyticsUtil.instance
        .setCurrentScreen('RoomListPage', 'room_list_page.dart');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    app = context.t;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.ap.roomList),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildCampusSelector(colorScheme),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _getRoomList(),
              child: _buildBody(colorScheme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCampusSelector(ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withAlpha(51),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: campusIndex,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: colorScheme.primary,
          ),
          borderRadius: BorderRadius.circular(12),
          items: List<DropdownMenuItem<int>>.generate(
            app.campuses.length,
            (int index) => DropdownMenuItem<int>(
              value: index,
              child: Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    app.campuses[index],
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          onChanged: (int? value) {
            if (value != null) {
              setState(() => campusIndex = value);
              _getRoomList();
            }
          },
        ),
      ),
    );
  }

  Widget _buildBody(ColorScheme colorScheme) {
    switch (state) {
      case _State.loading:
        return const Center(child: CircularProgressIndicator());
      case _State.finish:
        return _buildRoomList(colorScheme);
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

  Widget _buildRoomList(ColorScheme colorScheme) {
    final Map<String, Map<String, List<Room>>> groupedRooms =
        _groupRoomsByBuildingAndFloor();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: groupedRooms.length,
      itemBuilder: (BuildContext context, int index) {
        final String building = groupedRooms.keys.elementAt(index);
        final Map<String, List<Room>> floorRooms = groupedRooms[building]!;

        return _buildBuildingSection(building, floorRooms, colorScheme);
      },
    );
  }

  Map<String, Map<String, List<Room>>> _groupRoomsByBuildingAndFloor() {
    final Map<String, Map<String, List<Room>>> grouped = {};

    for (final Room room in roomData!.data) {
      final _RoomInfo info = _parseRoomInfo(room.name);
      final String building =
          info.building.isNotEmpty ? info.building : app.otherBuilding;
      final String floor = info.floor.isNotEmpty ? info.floor : '0';

      grouped.putIfAbsent(building, () => {});
      grouped[building]!.putIfAbsent(floor, () => []).add(room);
    }

    final Map<String, Map<String, List<Room>>> sortedResult = {};
    for (final String building in grouped.keys) {
      final List<String> sortedFloors = grouped[building]!.keys.toList()
        ..sort((String a, String b) {
          final int? aNum = int.tryParse(a);
          final int? bNum = int.tryParse(b);
          if (aNum != null && bNum != null) {
            return aNum.compareTo(bNum);
          }
          return a.compareTo(b);
        });

      sortedResult[building] = {};
      for (final String floor in sortedFloors) {
        sortedResult[building]![floor] = grouped[building]![floor]!;
      }
    }

    return sortedResult;
  }

  _RoomInfo _parseRoomInfo(String name) {
    String building = '';
    String roomCode = name;

    if (name.startsWith('(')) {
      int depth = 0;
      int endIndex = -1;

      for (int i = 0; i < name.length; i++) {
        if (name[i] == '(') {
          depth++;
        } else if (name[i] == ')') {
          depth--;
          if (depth == 0) {
            endIndex = i;
            break;
          }
        }
      }

      if (endIndex > 0) {
        building = name.substring(1, endIndex);
        roomCode = name.substring(endIndex + 1).trim();
      }
    }

    String floor = '';
    String roomNumber = '';

    final RegExp numRegex = RegExp(r'(\d+)');
    final RegExpMatch? numMatch = numRegex.firstMatch(roomCode);
    if (numMatch != null) {
      final String numbers = numMatch.group(1)!;
      if (numbers.length >= 3) {
        floor = numbers.substring(0, numbers.length - 2);
        roomNumber = numbers.substring(numbers.length - 2);
      } else if (numbers.length == 2) {
        floor = numbers[0];
        roomNumber = numbers[1];
      } else {
        roomNumber = numbers;
      }
    }

    final String prefix =
        roomCode.replaceAll(RegExp(r'\d+'), '').replaceAll('-', '').trim();

    return _RoomInfo(
      building: building,
      prefix: prefix,
      floor: floor,
      roomNumber: roomNumber,
      fullName: name,
    );
  }

  Widget _buildBuildingSection(
    String building,
    Map<String, List<Room>> floorRooms,
    ColorScheme colorScheme,
  ) {
    final int totalRooms = floorRooms.values
        .fold(0, (int sum, List<Room> rooms) => sum + rooms.length);
    final int floorCount = floorRooms.length;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withAlpha(128),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: false,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.only(bottom: 8),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.apartment_rounded,
              color: colorScheme.onPrimaryContainer,
              size: 24,
            ),
          ),
          title: Text(
            building,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                _buildInfoChip(
                  Icons.layers_outlined,
                  '$floorCount 層',
                  colorScheme.secondaryContainer,
                  colorScheme.onSecondaryContainer,
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  Icons.door_sliding_outlined,
                  '$totalRooms 間',
                  colorScheme.tertiaryContainer,
                  colorScheme.onTertiaryContainer,
                ),
              ],
            ),
          ),
          children:
              floorRooms.entries.map((MapEntry<String, List<Room>> entry) {
            return _buildFloorCard(entry.key, entry.value, colorScheme);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildInfoChip(
    IconData icon,
    String text,
    Color bgColor,
    Color fgColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fgColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: fgColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloorCard(
    String floor,
    List<Room> rooms,
    ColorScheme colorScheme,
  ) {
    final Color floorColor = _getFloorColor(floor, colorScheme);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: floorColor.withAlpha(60),
          ),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: false,
            tilePadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            backgroundColor: floorColor.withAlpha(10),
            collapsedBackgroundColor: floorColor.withAlpha(20),
            leading: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: floorColor,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: floorColor.withAlpha(60),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.layers_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${floor}F',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.door_sliding_outlined,
                  size: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  '${rooms.length} 間教室',
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: rooms.map((Room room) {
                  return _buildRoomChip(room, floorColor, colorScheme);
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getFloorColor(String floor, ColorScheme colorScheme) {
    final int? floorNum = int.tryParse(floor);
    if (floorNum == null) return colorScheme.primary;

    final List<Color> floorColors = [
      Colors.teal,
      Colors.blue,
      Colors.indigo,
      Colors.purple,
      Colors.pink,
      Colors.red,
      Colors.orange,
      Colors.amber,
      Colors.green,
      Colors.cyan,
    ];

    return floorColors[floorNum % floorColors.length];
  }

  Widget _buildRoomChip(Room room, Color floorColor, ColorScheme colorScheme) {
    String displayName = room.name;
    if (room.name.startsWith('(')) {
      int depth = 0;
      for (int i = 0; i < room.name.length; i++) {
        if (room.name[i] == '(') {
          depth++;
        } else if (room.name[i] == ')') {
          depth--;
          if (depth == 0) {
            displayName = room.name.substring(i + 1).trim();
            break;
          }
        }
      }
    }

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          ApUtils.pushCupertinoStyle(
            context,
            EmptyRoomPage(room: room),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: colorScheme.surface,
            border: Border.all(
              color: floorColor.withAlpha(100),
            ),
            boxShadow: [
              BoxShadow(
                color: floorColor.withAlpha(20),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.meeting_room_rounded,
                size: 16,
                color: floorColor,
              ),
              const SizedBox(width: 8),
              Text(
                displayName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _getRoomList() async {
    setState(() => state = _State.loading);
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
    } on ApException catch (e) {
      if (e is CancelledException) return;
      setState(() {
        state = _State.custom;
        customStateHint = e.toLocalizedMessage(context);
      });
      if (e is ServerException && e.httpStatusCode != null) {
        AnalyticsUtil.instance.logApiEvent(
          'getRoomCourseTables',
          e.httpStatusCode!,
          message: e.message,
        );
      }
    }
  }
}

class _RoomInfo {
  _RoomInfo({
    required this.building,
    required this.prefix,
    required this.floor,
    required this.roomNumber,
    required this.fullName,
  });

  final String building;
  final String prefix;
  final String floor;
  final String roomNumber;
  final String fullName;
}
