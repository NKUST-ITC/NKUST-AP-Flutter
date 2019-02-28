class LeaveResponse {
  int status;
  String messages;
  List<Leaves> leaves;
  List<String> timeCode;

  LeaveResponse({this.status, this.messages, this.leaves, this.timeCode});

  LeaveResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    messages = json['messages'];
    if (json['leaves'] != null) {
      leaves = new List<Leaves>();
      json['leaves'].forEach((v) {
        leaves.add(new Leaves.fromJson(v));
      });
    }
    if (json['timecode'] != null) timeCode = json['timecode'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['messages'] = this.messages;
    if (this.leaves != null) {
      data['leaves'] = this.leaves.map((v) => v.toJson()).toList();
    }
    data['timecode'] = this.timeCode;
    return data;
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

  Leaves.fromJson(Map<String, dynamic> json) {
    leaveSheetId = json['leave_sheet_id'];
    date = json['date'];
    instructorsComment = json['instructors_comment'];
    if (json['leave_sections'] != null) {
      leaveSections = new List<LeaveSections>();
      json['leave_sections'].forEach((v) {
        leaveSections.add(new LeaveSections.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['leave_sheet_id'] = this.leaveSheetId;
    data['date'] = this.date;
    data['instructors_comment'] = this.instructorsComment;
    if (this.leaveSections != null) {
      data['leave_sections'] =
          this.leaveSections.map((v) => v.toJson()).toList();
    }
    return data;
  }

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
