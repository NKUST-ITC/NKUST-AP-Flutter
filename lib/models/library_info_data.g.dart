// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library_info_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LibraryInfoData _$LibraryInfoDataFromJson(Map<String, dynamic> json) =>
    LibraryInfoData(
      data: LibraryInfo.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LibraryInfoDataToJson(LibraryInfoData instance) =>
    <String, dynamic>{
      'data': instance.data.toJson(),
    };

LibraryInfo _$LibraryInfoFromJson(Map<String, dynamic> json) => LibraryInfo(
      department: json['department'] as String,
      libraryId: json['libraryId'] as String,
      name: json['name'] as String,
      record: Record.fromJson(json['record'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LibraryInfoToJson(LibraryInfo instance) =>
    <String, dynamic>{
      'department': instance.department,
      'libraryId': instance.libraryId,
      'name': instance.name,
      'record': instance.record.toJson(),
    };

Record _$RecordFromJson(Map<String, dynamic> json) => Record(
      borrowing: json['borrowing'] as int,
      reserveRental: json['reserve-rental'] as int,
      userFine: json['userFine'] as int,
    );

Map<String, dynamic> _$RecordToJson(Record instance) => <String, dynamic>{
      'borrowing': instance.borrowing,
      'reserve-rental': instance.reserveRental,
      'userFine': instance.userFine,
    };
