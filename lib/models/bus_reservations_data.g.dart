// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bus_reservations_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BusReservationsData _$BusReservationsDataFromJson(Map<String, dynamic> json) =>
    BusReservationsData(
      reservations: (json['data'] as List<dynamic>)
          .map((e) => BusReservation.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$BusReservationsDataToJson(
        BusReservationsData instance) =>
    <String, dynamic>{
      'data': instance.reservations.map((e) => e.toJson()).toList(),
    };

BusReservation _$BusReservationFromJson(Map<String, dynamic> json) =>
    BusReservation(
      dateTime: json['dateTime'] as String,
      endTime: json['endTime'] as String?,
      cancelKey: json['cancelKey'] as String,
      start: json['start'] as String,
      end: json['end'] as String,
      state: json['state'] as String,
      travelState: json['travelState'] as String,
    );

Map<String, dynamic> _$BusReservationToJson(BusReservation instance) =>
    <String, dynamic>{
      'dateTime': instance.dateTime,
      'endTime': instance.endTime,
      'cancelKey': instance.cancelKey,
      'start': instance.start,
      'end': instance.end,
      'state': instance.state,
      'travelState': instance.travelState,
    };
