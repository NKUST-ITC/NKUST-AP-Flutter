import 'package:flutter_test/flutter_test.dart';
import 'package:nkust_ap/models/leave_data.dart';
import 'package:nkust_ap/models/reward_and_penalty_data.dart';

void main() {
  test('Reward and Penalty Data parser', () {
    final rawData =
        '{"data":[{"date":"1040618","type":"\u5c0f\u529f","counts":"2","reason":"\u64d4\u4efb\u5e79\u90e8\u8a8d\u771f\u8ca0\u8cac(\u526f\u73ed\u9577)"},{"date":"1040624","type":"\u5609\u734e","counts":"1","reason":"\u64d4\u4efb\u5e79\u90e8\u8a8d\u771f\u8ca0\u8cac"},{"date":"1040629","type":"\u5609\u734e","counts":"1","reason":"\u8fa6\u7406\u7cfb\u5b78\u6703\u6d3b\u52d5\u76e1\u5fc3\u76e1\u529b"}]}';
    final data = RewardAndPenaltyData.fromRawJson(rawData);

    expect(data.data.length, 3);
    expect(data.data.first.date, "1040618");
    expect(data.data.first.type, "小功");
    expect(data.data.first.isReward, true);
  });

  test('Leave Data parser', () {
    final rawData =
        '{ "data": [ { "leaveSheetId": "", "date": "1071114", "instructorsComment": "", "sections": [ { "section": "5", "reason": "曠" }, { "section": "6", "reason": "曠" } ] } ], "timeCodes": [ "A", "1", "2", "3", "4", "B", "5", "6", "7", "8", "C", "11", "12", "13", "14" ] }';
    final data = LeaveData.fromRawJson(rawData);

    expect(data.leaves.length, 1);
    expect(data.leaves.first.date, "1071114");
    expect(data.leaves.first.dateText, "11/14");
    expect(data.leaves.first.leaveSections.length, 2);
    expect(data.leaves.first.leaveSections.first.reason, "曠");
  });
}
