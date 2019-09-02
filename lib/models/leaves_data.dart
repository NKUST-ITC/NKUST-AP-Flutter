import 'dart:convert';

class LeavesData {
  List<Leaves> leaves;
  List<String> timeCodes;

  LeavesData({
    this.leaves,
    this.timeCodes,
  });

  factory LeavesData.fromRawJson(String str) =>
      LeavesData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LeavesData.fromJson(Map<String, dynamic> json) => new LeavesData(
        leaves:
            new List<Leaves>.from(json["data"].map((x) => Leaves.fromJson(x))),
        timeCodes: json["timeCodes"] == null
            ? null
            : new List<String>.from(json["timeCodes"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "data": new List<dynamic>.from(leaves.map((x) => x.toJson())),
        "timeCodes": new List<dynamic>.from(timeCodes.map((x) => x)),
      };

  static LeavesData sample() {
    return LeavesData.fromRawJson(
        '{ "leave": [ { "leaveSheetId": "", "date": "107/11/14", "instructorsComment": "", "sections": [ { "section": "5", "reason": "曠" }, { "section": "6", "reason": "曠" } ] } ], "timeCodes": [ "A", "1", "2", "3", "4", "B", "5", "6", "7", "8", "C", "11", "12", "13", "14" ] }');
  }
}

class Leaves {
  String leaveSheetId;
  String date;
  String instructorsComment;
  List<LeaveSections> leaveSections;

  Leaves(
      {this.leaveSheetId,
      this.date,
      this.instructorsComment,
      this.leaveSections});

  factory Leaves.fromRawJson(String str) => Leaves.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Leaves.fromJson(Map<String, dynamic> json) => new Leaves(
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
            new List<dynamic>.from(leaveSections.map((x) => x.toJson())),
      };

  String getReason(String timeCode) {
    if (leaveSections == null) return "";
    if (leaveSections.length == 0) return "";
    for (var leaveSection in leaveSections) {
      if (leaveSection.section == timeCode) return leaveSection.reason;
    }
    return "";
  }
}

class LeaveSections {
  String section;
  String reason;

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
