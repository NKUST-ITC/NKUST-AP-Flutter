// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bus_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BusData _$BusDataFromJson(Map<String, dynamic> json) => BusData(
      canReserve: json['canReserve'] as bool,
      description: json['description'] as String?,
      timetable: (json['data'] as List<dynamic>)
          .map((e) => BusTime.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$BusDataToJson(BusData instance) => <String, dynamic>{
      'canReserve': instance.canReserve,
      'description': instance.description,
      'data': instance.timetable.map((e) => e.toJson()).toList(),
    };

BusTime _$BusTimeFromJson(Map<String, dynamic> json) => BusTime(
      endEnrollDateTime: json['endEnrollDateTime'] == null
          ? null
          : DateTime.parse(json['endEnrollDateTime'] as String),
      departureTime: DateTime.parse(json['departureTime'] as String),
      startStation: json['startStation'] as String,
      endStation: json['endStation'] as String,
      busId: json['busId'] as String,
      reserveCount: json['reserveCount'] as int,
      limitCount: json['limitCount'] as int,
      isReserve: json['isReserve'] as bool,
      specialTrain: json['specialTrain'] as String?,
      description: json['description'] as String?,
      cancelKey: json['cancelKey'] as String?,
      homeCharteredBus: json['homeCharteredBus'] as bool,
      canBook: json['canBook'] as bool?,
    );

Map<String, dynamic> _$BusTimeToJson(BusTime instance) => <String, dynamic>{
      'endEnrollDateTime': instance.endEnrollDateTime?.toIso8601String(),
      'departureTime': instance.departureTime.toIso8601String(),
      'startStation': instance.startStation,
      'endStation': instance.endStation,
      'busId': instance.busId,
      'reserveCount': instance.reserveCount,
      'limitCount': instance.limitCount,
      'isReserve': instance.isReserve,
      'specialTrain': instance.specialTrain,
      'description': instance.description,
      'cancelKey': instance.cancelKey,
      'homeCharteredBus': instance.homeCharteredBus,
      'canBook': instance.canBook,
    };
