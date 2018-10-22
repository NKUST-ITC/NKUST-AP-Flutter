class NotificationData {
  int page;
  List<NotificationModel> notifications;

  NotificationData({
    this.page,
    this.notifications,
  });

  static NotificationData fromJson(Map<String, dynamic> json) {
    return NotificationData(
      page: json['page'],
      notifications: NotificationModel.toList(json['notification']),
    );
  }

  Map<String, dynamic> toJson() => {
        'page': page,
        'notification': notifications,
      };
}

class NotificationModel {
  String link;
  Info info;

  NotificationModel({
    this.link,
    this.info,
  });

  static NotificationModel fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      link: json['link'],
      info: Info.fromJson(json['info']),
    );
  }

  Map<String, dynamic> toJson() => {
        'link': link,
        'info': info,
      };

  static List<NotificationModel> toList(List<dynamic> jsonArray) {
    List<NotificationModel> list = [];
    for (var item in (jsonArray ?? [])) list.add(NotificationModel.fromJson(item));
    return list;
  }
}

class Info {
  String id;
  String title;
  String department;
  String date;

  Info({
    this.id,
    this.title,
    this.department,
    this.date,
  });

  static Info fromJson(Map<String, dynamic> json) {
    return Info(
      id: json['id'],
      title: json['title'],
      department: json['department'],
      date: json['date'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'department': department,
        'date': date,
      };
}
