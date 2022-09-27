// To parse this JSON data, do
//
//     final rewardAndPenaltyData = rewardAndPenaltyDataFromJson(jsonString);

import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'reward_and_penalty_data.g.dart';

@JsonSerializable()
class RewardAndPenaltyData {
  List<RewardAndPenalty>? data;

  RewardAndPenaltyData({
    this.data,
  });

  factory RewardAndPenaltyData.fromJson(Map<String, dynamic> json) =>
      _$RewardAndPenaltyDataFromJson(json);

  Map<String, dynamic> toJson() => _$RewardAndPenaltyDataToJson(this);

  factory RewardAndPenaltyData.fromRawJson(String str) =>
      RewardAndPenaltyData.fromJson(
        json.decode(str) as Map<String, dynamic>,
      );

  String toRawJson() => jsonEncode(toJson());
}

@JsonSerializable()
class RewardAndPenalty {
  String? date;
  String? type;
  String? counts;
  String? reason;

  RewardAndPenalty({
    this.date,
    this.type,
    this.counts,
    this.reason,
  });

  get isReward {
    switch (type) {
      case '警告':
      case '小過':
      case '大過':
      case '申誡':
        return false;
      case '嘉獎':
      case '小功':
      case '大功':
      default:
        return true;
    }
  }

  factory RewardAndPenalty.fromJson(Map<String, dynamic> json) =>
      _$RewardAndPenaltyFromJson(json);

  Map<String, dynamic> toJson() => _$RewardAndPenaltyToJson(this);

  factory RewardAndPenalty.fromRawJson(String str) => RewardAndPenalty.fromJson(
        json.decode(str) as Map<String, dynamic>,
      );

  String toRawJson() => jsonEncode(toJson());
}
