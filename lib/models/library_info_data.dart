// To parse this JSON data, do
//
//     final libraryInfoData = libraryInfoDataFromJson(jsonString);

import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'library_info_data.g.dart';

@JsonSerializable()
class LibraryInfoData {
  final LibraryInfo data;

  LibraryInfoData({
    required this.data,
  });

  factory LibraryInfoData.fromJson(Map<String, dynamic> json) =>
      _$LibraryInfoDataFromJson(json);

  Map<String, dynamic> toJson() => _$LibraryInfoDataToJson(this);

  factory LibraryInfoData.fromRawJson(String str) => LibraryInfoData.fromJson(
        json.decode(str) as Map<String, dynamic>,
      );

  String toRawJson() => jsonEncode(toJson());

  static LibraryInfoData sample() {
    return LibraryInfoData.fromRawJson(
        '{ "data": { "department": "智慧商務系QQ", "libraryId": "1106133333", "name": "柯博昌", "record": { "borrowing": 1, "reserve-rental": 2, "userFine": 300 } } }');
  }
}

@JsonSerializable()
class LibraryInfo {
  String department;
  String libraryId;
  String name;
  Record record;

  LibraryInfo({
    required this.department,
    required this.libraryId,
    required this.name,
    required this.record,
  });

  factory LibraryInfo.fromJson(Map<String, dynamic> json) =>
      _$LibraryInfoFromJson(json);

  Map<String, dynamic> toJson() => _$LibraryInfoToJson(this);

  factory LibraryInfo.fromRawJson(String str) => LibraryInfo.fromJson(
        json.decode(str) as Map<String, dynamic>,
      );

  String toRawJson() => jsonEncode(toJson());
}

@JsonSerializable()
class Record {
  int borrowing;
  @JsonKey(name: 'reserve-rental')
  int reserveRental;
  int userFine;

  Record({
    required this.borrowing,
    required this.reserveRental,
    required this.userFine,
  });

  factory Record.fromJson(Map<String, dynamic> json) => _$RecordFromJson(json);

  Map<String, dynamic> toJson() => _$RecordToJson(this);

  factory Record.fromRawJson(String str) => Record.fromJson(
        json.decode(str) as Map<String, dynamic>,
      );

  String toRawJson() => jsonEncode(toJson());
}
