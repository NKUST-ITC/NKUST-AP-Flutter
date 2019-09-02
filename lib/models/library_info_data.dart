// To parse this JSON data, do
//
//     final libraryInfoData = libraryInfoDataFromJson(jsonString);

import 'dart:convert';

class LibraryInfoData {
  LibraryInfo data;

  LibraryInfoData({
    this.data,
  });

  factory LibraryInfoData.fromRawJson(String str) =>
      LibraryInfoData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LibraryInfoData.fromJson(Map<String, dynamic> json) =>
      new LibraryInfoData(
        data: LibraryInfo.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "data": data.toJson(),
      };

  static LibraryInfoData sample() {
    return LibraryInfoData.fromRawJson(
        '{ "data": { "department": "智慧商務系QQ", "libraryId": "1106133333", "name": "柯博昌", "record": { "borrowing": 1, "reserve-rental": 2, "userFine": 300 } } }');
  }
}

class LibraryInfo {
  String department;
  String libraryId;
  String name;
  Record record;

  LibraryInfo({
    this.department,
    this.libraryId,
    this.name,
    this.record,
  });

  factory LibraryInfo.fromRawJson(String str) =>
      LibraryInfo.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LibraryInfo.fromJson(Map<String, dynamic> json) => new LibraryInfo(
        department: json["department"],
        libraryId: json["libraryId"],
        name: json["name"],
        record: Record.fromJson(json["record"]),
      );

  Map<String, dynamic> toJson() => {
        "department": department,
        "libraryId": libraryId,
        "name": name,
        "record": record.toJson(),
      };
}

class Record {
  int borrowing;
  int reserveRental;
  int userFine;

  Record({
    this.borrowing,
    this.reserveRental,
    this.userFine,
  });

  factory Record.fromRawJson(String str) => Record.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Record.fromJson(Map<String, dynamic> json) => new Record(
        borrowing: json["borrowing"],
        reserveRental: json["reserve-rental"],
        userFine: json["userFine"],
      );

  Map<String, dynamic> toJson() => {
        "borrowing": borrowing,
        "reserve-rental": reserveRental,
        "userFine": userFine,
      };
}
