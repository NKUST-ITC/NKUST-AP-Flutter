import WidgetKit
import SwiftUI

// MARK: - Provider

struct TodayScheduleProvider: TimelineProvider {
    func placeholder(in context: Context) -> TodayScheduleEntry {
        TodayScheduleEntry(items: [])
    }

    func getSnapshot(
        in context: Context,
        completion: @escaping (TodayScheduleEntry) -> Void
    ) {
        completion(TodayScheduleEntry(items: loadItems()))
    }

    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<TodayScheduleEntry>) -> Void
    ) {
        let entry = TodayScheduleEntry(items: loadItems())
        let next = Calendar.current.date(
            byAdding: .minute, value: 30, to: Date()
        ) ?? Date()
        completion(Timeline(entries: [entry], policy: .after(next)))
    }

    private func loadItems() -> [ScheduleItem] {
        guard let defaults = UserDefaults(suiteName: appGroupId),
              let json = defaults.string(forKey: courseNotifyKey),
              let data = json.data(using: .utf8),
              let courseData = try? JSONDecoder().decode(
                  CourseData.self, from: data
              )
        else { return [] }

        let cal = Calendar.current
        let now = Date()
        let wd = cal.component(.weekday, from: now)
        let weekday = wd == 1 ? 7 : wd - 1

        var items: [ScheduleItem] = []
        for course in courseData.courses {
            for st in course.sectionTimes {
                guard st.weekday == weekday,
                      st.index < courseData.timeCodes.count
                else { continue }
                let tc = courseData.timeCodes[st.index]
                let endDate = parseTime(tc.endTime)
                items.append(ScheduleItem(
                    title: course.title,
                    code: course.code,
                    startTime: tc.startTime,
                    endTime: tc.endTime,
                    timeIndex: st.index,
                    location: locationText(course.location),
                    color: courseColor(course.code),
                    isPast: now > endDate
                ))
            }
        }
        // Merge consecutive slots of the same course
        let sorted = items.sorted { $0.startTime < $1.startTime }
        var merged: [ScheduleItem] = []
        for item in sorted {
            if let last = merged.last,
               last.code == item.code,
               item.timeIndex == last.timeIndex + 1
            {
                merged[merged.count - 1] = ScheduleItem(
                    title: last.title,
                    code: last.code,
                    startTime: last.startTime,
                    endTime: item.endTime,
                    timeIndex: item.timeIndex,
                    location: last.location,
                    color: last.color,
                    isPast: item.isPast
                )
            } else {
                merged.append(item)
            }
        }
        return merged
    }

    private func parseTime(_ text: String) -> Date {
        let fmt = DateFormatter()
        fmt.dateFormat = text.count == 4 ? "HHmm" : "HH:mm"
        let parsed = fmt.date(from: text) ?? Date()
        var now = Calendar.current.dateComponents(
            in: TimeZone.current, from: Date()
        )
        let t = Calendar.current.dateComponents(
            in: TimeZone.current, from: parsed
        )
        now.hour = t.hour
        now.minute = t.minute
        return Calendar.current.date(from: now) ?? Date()
    }

    private func locationText(_ loc: Location?) -> String {
        guard let loc = loc else { return "" }
        return "\(loc.building ?? "")\(loc.room ?? "")"
    }

    private func courseColor(_ code: String) -> Color {
        let colors: [Color] = [
            Color(red: 0.36, green: 0.42, blue: 0.75),
            Color(red: 0.15, green: 0.65, blue: 0.60),
            Color(red: 0.94, green: 0.33, blue: 0.31),
            Color(red: 0.67, green: 0.28, blue: 0.74),
            Color(red: 0.26, green: 0.65, blue: 0.96),
            Color(red: 1.00, green: 0.44, blue: 0.26),
            Color(red: 0.40, green: 0.73, blue: 0.42),
            Color(red: 1.00, green: 0.79, blue: 0.16),
            Color(red: 0.55, green: 0.43, blue: 0.39),
            Color(red: 0.47, green: 0.56, blue: 0.61),
            Color(red: 0.93, green: 0.25, blue: 0.48),
            Color(red: 0.49, green: 0.34, blue: 0.76),
        ]
        let idx = abs(code.hashValue) % colors.count
        return colors[idx]
    }
}

// MARK: - Entry & Model

struct TodayScheduleEntry: TimelineEntry {
    var date = Date()
    let items: [ScheduleItem]
}

struct ScheduleItem {
    let title: String
    let code: String
    let startTime: String
    let endTime: String
    let timeIndex: Int
    let location: String
    let color: Color
    let isPast: Bool
}

// MARK: - View

struct TodayScheduleView: View {
    let entry: TodayScheduleEntry
    @Environment(\.colorScheme) var colorScheme

    private var headerColor: Color {
        colorScheme == .dark
            ? Color(red: 0.10, green: 0.11, blue: 0.18)
            : Color(red: 0.15, green: 0.45, blue: 1.00)
    }

    private var bgColor: Color {
        colorScheme == .dark
            ? Color(red: 0.07, green: 0.07, blue: 0.07)
            : .white
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            Text("今日課表 (\(weekdayName()))")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 28)
                .background(headerColor)

            if entry.items.isEmpty {
                Spacer()
                Text("太好了今天沒有任何課")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            } else {
                VStack(spacing: 6) {
                    ForEach(
                        Array(entry.items.enumerated()),
                        id: \.offset
                    ) { _, item in
                        scheduleRow(item)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                Spacer(minLength: 0)
            }
        }
        .widgetBackground(bgColor)
    }

    @ViewBuilder
    private func scheduleRow(_ item: ScheduleItem) -> some View {
        HStack(spacing: 8) {
            // Time
            VStack(alignment: .trailing, spacing: 0) {
                Text(item.startTime)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(
                        item.isPast ? .secondary : .primary
                    )
                Text(item.endTime)
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
            }
            .frame(width: 40)

            // Color bar
            RoundedRectangle(cornerRadius: 2)
                .fill(item.isPast ? Color.gray : item.color)
                .frame(width: 4, height: 32)

            // Info
            VStack(alignment: .leading, spacing: 1) {
                Text(item.title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(
                        item.isPast ? .secondary : .primary
                    )
                    .lineLimit(1)
                if !item.location.isEmpty {
                    Text(item.location)
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            Spacer()
        }
    }

    private func weekdayName() -> String {
        let labels = ["日", "一", "二", "三", "四", "五", "六"]
        let wd = Calendar.current.component(.weekday, from: Date())
        return labels[wd - 1]
    }
}

// MARK: - Widget

struct TodayScheduleWidget: Widget {
    let kind = "TodayScheduleWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: TodayScheduleProvider()
        ) { entry in
            TodayScheduleView(entry: entry)
        }
        .configurationDisplayName("今日課表")
        .description("顯示今天的課程行程")
        .supportedFamilies([.systemMedium, .systemLarge])
        .disableContentMarginsIfNeeded()
    }
}
