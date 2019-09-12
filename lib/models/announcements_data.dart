import 'dart:convert';

class AnnouncementsData {
  List<Announcements> data;

  AnnouncementsData({
    this.data,
  });

  factory AnnouncementsData.fromRawJson(String str) =>
      AnnouncementsData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AnnouncementsData.fromJson(Map<String, dynamic> json) =>
      AnnouncementsData(
        data: List<Announcements>.from(
            json["data"].map((x) => Announcements.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };

  static sample() {
    return AnnouncementsData.fromRawJson(
        '{ "data": [ { "title": "高科校務通IOS版 回歸", "id": 1, "nextId": 2, "lastId": 2, "imgUrl": "https://i.imgur.com/faSwvRv.jpg", "url": "https://nkustap.page.link/bCK1", "description": "重新推出 IOS 版本 高科校務通 此版本還在測試中 迎同學私訊粉專意見回饋", "publishedTime": "2019-03-16T20:16:04+08:00" }, { "title": "宿舍直達高鐵站專車", "id": 2, "nextId": -1, "lastId": 2, "imgUrl": "https://i.imgur.com/wwxD4Xa.png", "url": "", "description": "從燕巢宿舍直接發車，不用再走到公車站排隊 人數達25人即發車，一人只要30元喔", "publishedTime": "2019-03-16T20:16:04+08:00" } ] }');
  }
}

class Announcements {
  String title;
  int id;
  int nextId;
  int lastId;
  int weight;
  String imgUrl;
  String url;
  String description;
  String publishedTime;

  Announcements({
    this.title,
    this.id,
    this.nextId,
    this.lastId,
    this.weight,
    this.imgUrl,
    this.url,
    this.description,
    this.publishedTime,
  });

  factory Announcements.fromRawJson(String str) =>
      Announcements.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Announcements.fromJson(Map<String, dynamic> json) => Announcements(
        title: json["title"],
        id: json["id"],
        nextId: json["nextId"],
        lastId: json["lastId"],
        weight: json["weight"],
        imgUrl: json["imgUrl"],
        url: json["url"],
        description: json["description"],
        publishedTime: json["publishedTime"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "id": id,
        "nextId": nextId,
        "lastId": lastId,
        "weight": weight,
        "imgUrl": imgUrl,
        "url": url,
        "description": description,
        "publishedTime": publishedTime,
      };
}
