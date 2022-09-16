// To parse this JSON data, do
//
//     final rewardAndPenaltyData = rewardAndPenaltyDataFromJson(jsonString);

import 'dart:convert';

class RewardAndPenaltyData {
  List<RewardAndPenalty>? data;

  RewardAndPenaltyData({
    this.data,
  });

  factory RewardAndPenaltyData.fromRawJson(String str) =>
      RewardAndPenaltyData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory RewardAndPenaltyData.fromJson(Map<String, dynamic> json) =>
      new RewardAndPenaltyData(
        data: new List<RewardAndPenalty>.from(
            json["data"].map((x) => RewardAndPenalty.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "data": new List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

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

  factory RewardAndPenalty.fromRawJson(String str) =>
      RewardAndPenalty.fromJson(json.decode(str));

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

  String toRawJson() => json.encode(toJson());

  factory RewardAndPenalty.fromJson(Map<String, dynamic> json) =>
      new RewardAndPenalty(
        date: json["date"],
        type: json["type"],
        counts: json["counts"],
        reason: json["reason"],
      );

  Map<String, dynamic> toJson() => {
        "date": date,
        "type": type,
        "counts": counts,
        "reason": reason,
      };
}
