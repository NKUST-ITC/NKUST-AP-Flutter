// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bus_violation_records_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BusViolationRecordsData _$BusViolationRecordsDataFromJson(
        Map<String, dynamic> json) =>
    BusViolationRecordsData(
      reservations: (json['reservation'] as List<dynamic>)
          .map((e) => Reservation.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$BusViolationRecordsDataToJson(
        BusViolationRecordsData instance) =>
    <String, dynamic>{
      'reservation': instance.reservations.map((e) => e.toJson()).toList(),
    };

Reservation _$ReservationFromJson(Map<String, dynamic> json) => Reservation(
      time: const DateTimeConverter().fromJson(json['time'] as DateTime),
      startStation: json['startStation'] as String,
      endStation: json['endStation'] as String,
      homeCharteredBus: json['homeCharteredBus'] as bool,
      amountend: json['amountend'] as int,
      isPayment: json['isPayment'] as bool,
    );

Map<String, dynamic> _$ReservationToJson(Reservation instance) =>
    <String, dynamic>{
      'time': const DateTimeConverter().toJson(instance.time),
      'startStation': instance.startStation,
      'endStation': instance.endStation,
      'homeCharteredBus': instance.homeCharteredBus,
      'amountend': instance.amountend,
      'isPayment': instance.isPayment,
    };
