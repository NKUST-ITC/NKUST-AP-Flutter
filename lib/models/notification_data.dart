// To parse this JSON data, do
//
//     final notificationsData = notificationsDataFromJson(jsonString);

import 'dart:convert';

class NotificationsData {
  Data data;

  NotificationsData({
    this.data,
  });

  factory NotificationsData.fromRawJson(String str) =>
      NotificationsData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory NotificationsData.fromJson(Map<String, dynamic> json) =>
      new NotificationsData(
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "data": data.toJson(),
      };

  static NotificationsData sample() {
    return NotificationsData.fromRawJson(
        '{ "data": { "page": 1, "notification": [ { "link": "http://kuasnews.kuas.edu.tw/files/13-1018-70766-1.php", "info": { "id": "1", "title": "2019年高科大高雄亮點日語導覽競賽", "department": "觀光系", "date": "2019-03-13" } }, { "link": "http://gec.kuas.edu.tw/files/13-1012-70765-1.php", "info": { "id": "2", "title": "快來拿獎金!!!第22屆優質通識課程學生學習檔案e化徵選活動~", "department": "通識中心", "date": "2019-03-13" } } ] } }');
  }
}

class Data {
  int page;
  List<Notifications> notifications;

  Data({
    this.page,
    this.notifications,
  });

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => new Data(
        page: json["page"],
        notifications: new List<Notifications>.from(
            json["notification"].map((x) => Notifications.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "page": page,
        "notification":
            new List<dynamic>.from(notifications.map((x) => x.toJson())),
      };
}

class Notifications {
  String link;
  Info info;

  Notifications({
    this.link,
    this.info,
  });

  factory Notifications.fromRawJson(String str) =>
      Notifications.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Notifications.fromJson(Map<String, dynamic> json) =>
      new Notifications(
        link: json["link"],
        info: Info.fromJson(json["info"]),
      );

  Map<String, dynamic> toJson() => {
        "link": link,
        "info": info.toJson(),
      };
}

class Info {
  int id;
  String title;
  String department;
  String date;

  Info({
    this.id,
    this.title,
    this.department,
    this.date,
  });

  factory Info.fromRawJson(String str) => Info.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Info.fromJson(Map<String, dynamic> json) => new Info(
        id: json["id"],
        title: json["title"],
        department: json["department"],
        date: json["date"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "department": department,
        "date": date,
      };
}
