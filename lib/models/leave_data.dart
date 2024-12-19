import 'dart:convert';

import 'package:ap_common/ap_common.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:nkust_ap/config/constants.dart';

part 'leave_data.g.dart';

@JsonSerializable()
class LeaveData {
  @JsonKey(name: 'data')
  List<Leave> leaves;
  List<String> timeCodes;

  LeaveData({
    required this.leaves,
    required this.timeCodes,
  });

  factory LeaveData.fromJson(Map<String, dynamic> json) =>
      _$LeaveDataFromJson(json);

  Map<String, dynamic> toJson() => _$LeaveDataToJson(this);

  factory LeaveData.fromRawJson(String str) => LeaveData.fromJson(
        json.decode(str) as Map<String, dynamic>,
      );

  String toRawJson() => jsonEncode(toJson());

  factory LeaveData.sample() {
    return LeaveData.fromRawJson(
      //ignore: lines_longer_than_80_chars
      '{ "leave": [ { "leaveSheetId": "", "date": "107/11/14", "instructorsComment": "", "sections": [ { "section": "5", "reason": "曠" }, { "section": "6", "reason": "曠" } ] } ], "timeCodes": [ "A", "1", "2", "3", "4", "B", "5", "6", "7", "8", "C", "11", "12", "13", "14" ] }',
    );
  }

  void save(String tag) {
    PreferenceUtil.instance.setString(
      '${Constants.prefLeaveData}_$tag',
      toRawJson(),
    );
  }

  static LeaveData? load(String tag) {
    final String rawString = PreferenceUtil.instance.getString(
      '${Constants.prefLeaveData}_$tag',
      '',
    );
    if (rawString == '') {
      return null;
    } else {
      return LeaveData.fromRawJson(rawString);
    }
  }
}

@JsonSerializable()
class Leave {
  String leaveSheetId;
  String date;
  String instructorsComment;
  @JsonKey(name: 'sections')
  List<LeaveSections> leaveSections;

  Leave({
    required this.leaveSheetId,
    required this.date,
    required this.instructorsComment,
    required this.leaveSections,
  });

  String get dateText => date.length == 7
      ? '${date.substring(3, 5)}/${date.substring(5, 7)}'
      : date;

  factory Leave.fromJson(Map<String, dynamic> json) => _$LeaveFromJson(json);

  Map<String, dynamic> toJson() => _$LeaveToJson(this);

  factory Leave.fromRawJson(String str) => Leave.fromJson(
        json.decode(str) as Map<String, dynamic>,
      );

  String toRawJson() => jsonEncode(toJson());

  String getReason(String timeCode) {
    if (leaveSections.isEmpty) return '';
    for (final LeaveSections leaveSection in leaveSections) {
      if (leaveSection.section == timeCode) return leaveSection.reason;
    }
    return '';
  }
}

@JsonSerializable()
class LeaveSections {
  String section;
  String reason;

  LeaveSections({
    required this.section,
    required this.reason,
  });

  factory LeaveSections.fromJson(Map<String, dynamic> json) =>
      _$LeaveSectionsFromJson(json);

  Map<String, dynamic> toJson() => _$LeaveSectionsToJson(this);

  factory LeaveSections.fromRawJson(String str) => LeaveSections.fromJson(
        json.decode(str) as Map<String, dynamic>,
      );

  String toRawJson() => jsonEncode(toJson());
}
