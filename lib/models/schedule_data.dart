class ScheduleData {
  String week;
  List<String> events;

  ScheduleData({
    this.week,
    this.events,
  });

  static ScheduleData fromJson(Map<String, dynamic> json) {
    return ScheduleData(
      week: json['week'],
      events: List<String>.from(json['events']),
    );
  }

  Map<String, dynamic> toJson() => {
        'week': week,
        'events': events,
      };

  static List<ScheduleData> toList(List<dynamic> jsonArray) {
    List<ScheduleData> list = [];
    for (var item in (jsonArray ?? [])) list.add(ScheduleData.fromJson(item));
    return list;
  }
}
