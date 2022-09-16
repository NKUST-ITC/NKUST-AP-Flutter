import 'dart:convert';

import 'package:ap_common/utils/preferences.dart';
import 'package:nkust_ap/config/constants.dart';

class LeaveData {
  List<Leave>? leaves;
  List<String>? timeCodes;

  LeaveData({
    this.leaves,
    this.timeCodes,
  });

  factory LeaveData.fromRawJson(String str) =>
      LeaveData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LeaveData.fromJson(Map<String, dynamic> json) => new LeaveData(
        leaves:
            new List<Leave>.from(json["data"].map((x) => Leave.fromJson(x))),
        timeCodes: json["timeCodes"] == null
            ? null
            : new List<String>.from(json["timeCodes"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "data": new List<dynamic>.from(leaves!.map((x) => x.toJson())),
        "timeCodes": new List<dynamic>.from(timeCodes!.map((x) => x)),
      };

  static LeaveData sample() {
    return LeaveData.fromRawJson(
        '{ "leave": [ { "leaveSheetId": "", "date": "107/11/14", "instructorsComment": "", "sections": [ { "section": "5", "reason": "曠" }, { "section": "6", "reason": "曠" } ] } ], "timeCodes": [ "A", "1", "2", "3", "4", "B", "5", "6", "7", "8", "C", "11", "12", "13", "14" ] }');
  }

  void save(String tag) {
    Preferences.setString(
      '${Constants.PREF_LEAVE_DATA}_$tag',
      this.toRawJson(),
    );
  }

  static LeaveData? load(String tag) {
    String rawString = Preferences.getString(
      '${Constants.PREF_LEAVE_DATA}_$tag',
      '',
    );
    if (rawString == '')
      return null;
    else
      return LeaveData.fromRawJson(rawString);
  }
}

class Leave {
  String? leaveSheetId;
  String? date;
  String? instructorsComment;
  List<LeaveSections>? leaveSections;

  Leave(
      {this.leaveSheetId,
      this.date,
      this.instructorsComment,
      this.leaveSections});

  factory Leave.fromRawJson(String str) => Leave.fromJson(json.decode(str));

  String get dateText =>
      (date!.length == 7
          ? "${date!.substring(3, 5)}/${date!.substring(5, 7)}"
          : date) ??
      "";

  String toRawJson() => json.encode(toJson());

  factory Leave.fromJson(Map<String, dynamic> json) => new Leave(
        leaveSheetId: json["leaveSheetId"],
        date: json["date"],
        instructorsComment: json["instructorsComment"],
        leaveSections: new List<LeaveSections>.from(
            json["sections"].map((x) => LeaveSections.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "leaveSheetId": leaveSheetId,
        "date": date,
        "instructorsComment": instructorsComment,
        "sections":
            new List<dynamic>.from(leaveSections!.map((x) => x.toJson())),
      };

  String? getReason(String timeCode) {
    if (leaveSections == null) return "";
    if (leaveSections!.length == 0) return "";
    for (var leaveSection in leaveSections!) {
      if (leaveSection.section == timeCode) return leaveSection.reason;
    }
    return "";
  }
}

class LeaveSections {
  String? section;
  String? reason;

  LeaveSections({this.section, this.reason});

  LeaveSections.fromJson(Map<String, dynamic> json) {
    section = json['section'];
    reason = json['reason'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['section'] = this.section;
    data['reason'] = this.reason;
    return data;
  }
}
