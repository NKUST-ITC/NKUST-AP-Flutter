class UserInfo {
  String educationSystem;
  String department;
  String className;
  String studentId;
  String studentNameCht;
  String studentNameEng;
  int status;
  String message;

  UserInfo(
      {this.educationSystem,
      this.department,
      this.className,
      this.studentId,
      this.studentNameCht,
      this.studentNameEng,
      this.status,
      this.message});

  UserInfo.fromJson(Map<String, dynamic> json) {
    educationSystem = json['education_system'];
    department = json['department'];
    className = json['class'];
    studentId = json['student_id'];
    studentNameCht = json['student_name_cht'];
    studentNameEng = json['student_name_eng'];
    status = json['status'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['education_system'] = this.educationSystem;
    data['department'] = this.department;
    data['class'] = this.className;
    data['student_id'] = this.studentId;
    data['student_name_cht'] = this.studentNameCht;
    data['student_name_eng'] = this.studentNameEng;
    data['status'] = this.status;
    data['message'] = this.message;
    return data;
  }
}
