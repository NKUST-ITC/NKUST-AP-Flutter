// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reward_and_penalty_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RewardAndPenaltyData _$RewardAndPenaltyDataFromJson(
        Map<String, dynamic> json) =>
    RewardAndPenaltyData(
      data: (json['data'] as List<dynamic>)
          .map((e) => RewardAndPenalty.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RewardAndPenaltyDataToJson(
        RewardAndPenaltyData instance) =>
    <String, dynamic>{
      'data': instance.data.map((e) => e.toJson()).toList(),
    };

RewardAndPenalty _$RewardAndPenaltyFromJson(Map<String, dynamic> json) =>
    RewardAndPenalty(
      date: json['date'] as String,
      type: json['type'] as String,
      counts: json['counts'] as String,
      reason: json['reason'] as String,
    );

Map<String, dynamic> _$RewardAndPenaltyToJson(RewardAndPenalty instance) =>
    <String, dynamic>{
      'date': instance.date,
      'type': instance.type,
      'counts': instance.counts,
      'reason': instance.reason,
    };
