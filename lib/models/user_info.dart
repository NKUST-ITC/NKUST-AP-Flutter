

class UserInfo{
  String educationSystem;
  String department;
  String className;
  String id;
  String nameCht;
  String nameEng;

  UserInfo({
  this.educationSystem,this.department,this.className,this.id,this.nameCht,this.nameEng,
  });

  static UserInfo fromJson(Map<String,dynamic> json){
  return UserInfo(
  educationSystem: json['education_system'],
  department: json['department'],
  className: json['class'],
  id: json['student_id'],
  nameCht: json['student_name_cht'],
  nameEng: json['student_name_eng'],
  );
  }

  Map<String, dynamic> toJson() => {
  'education_system': educationSystem,
  'department': department,
  'class': className,
  'student_id': id,
  'student_name_cht': nameCht,
  'student_name_eng': nameEng,
  };
}