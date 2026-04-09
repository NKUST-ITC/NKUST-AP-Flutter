import WidgetKit
import SwiftUI

// MARK: - Configuration

/// The App Group identifier used to share data between the main app
/// and the widget extension.
let appGroupId = "group.com.nkust.ap"

/// The UserDefaults key for course data JSON.
let courseNotifyKey = "course_notify"

// MARK: - Timeline Provider

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(text: "", shortText: "")
    }

    func getSnapshot(
        in context: Context,
        completion: @escaping (SimpleEntry) -> Void
    ) {
        let entry = SimpleEntry(
            text: "下一堂課是 9:00\n在 EC5012 的 演算法",
            shortText: "9:00 在 EC5012 的演算法"
        )
        completion(entry)
    }

    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<SimpleEntry>) -> Void
    ) {
        let (text, shortText) = loadCourseText()
        let entry = SimpleEntry(text: text, shortText: shortText)
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }

    private func loadCourseText() -> (String, String) {
        guard let defaults = UserDefaults(suiteName: appGroupId),
              let json = defaults.string(forKey: courseNotifyKey),
              let data = json.data(using: .utf8),
              let courseData = try? JSONDecoder().decode(
                  CourseData.self, from: data
              )
        else {
            return ("尚無課程資料", "尚無課程資料")
        }

        let today = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents(
            in: TimeZone.current, from: today
        )
        let weekday = components.weekday == 1
            ? 7
            : (components.weekday ?? 1) - 1

        var todayCount = 0
        var minDiff = Double.greatestFiniteMagnitude
        var text = "太好了今天已經沒有任何課"
        var shortText = "今天已經沒有任何課"

        for course in courseData.courses {
            for sectionTime in course.sectionTimes {
                guard sectionTime.weekday == weekday else { continue }
                todayCount += 1

                guard sectionTime.index < courseData.timeCodes.count
                else { continue }
                let timeCode = courseData.timeCodes[sectionTime.index]
                let startDate = parseTime(timeCode.startTime)
                let diff = startDate.timeIntervalSince1970
                    - today.timeIntervalSince1970

                if diff > 0 && diff < minDiff {
                    minDiff = diff
                    let building = course.location?.building ?? ""
                    let room = course.location?.room ?? ""
                    let location = "\(building)\(room)"
                    text = "下一節課是\(timeCode.startTime)\n"
                        + "在 \(location) 的 \(course.title)"
                    shortText = "\(timeCode.startTime)"
                        + "在 \(location) 的\(course.title)"
                }
            }
        }

        if todayCount == 0 {
            text = "太好了今天沒有任何課"
            shortText = "今天沒有任何課"
        }

        return (text, shortText)
    }

    private func parseTime(_ timeText: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = timeText.count == 4 ? "HHmm" : "HH:mm"
        let parsed = formatter.date(from: timeText) ?? Date()
        var now = Calendar.current.dateComponents(
            in: TimeZone.current, from: Date()
        )
        let courseTime = Calendar.current.dateComponents(
            in: TimeZone.current, from: parsed
        )
        now.hour = courseTime.hour
        now.minute = courseTime.minute
        return Calendar.current.date(from: now) ?? Date()
    }
}

// MARK: - Timeline Entry

struct SimpleEntry: TimelineEntry {
    var date = Date()
    let text: String
    let shortText: String
}

// MARK: - Widget Views

struct CourseAppWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.colorScheme) var colorScheme

    private var titleBackground: Color {
        Color(
            colorScheme == .dark
                ? UIColor(red: 0.08, green: 0.12, blue: 0.18, alpha: 1)
                : UIColor(red: 0.15, green: 0.45, blue: 1.00, alpha: 1)
        )
    }

    private var contentBackground: Color {
        colorScheme == .dark
            ? Color(UIColor(red: 0.07, green: 0.07, blue: 0.07, alpha: 1))
            : Color.white
    }

    private var contentTextColor: Color {
        colorScheme == .dark ? .white : .black
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Text("上課提醒")
                    .foregroundColor(.white)
                    .frame(width: geometry.size.width, height: 36)
                    .background(titleBackground)
                Text(entry.text)
                    .foregroundColor(contentTextColor)
                    .frame(maxHeight: .infinity)
                    .padding(.horizontal, 8)
                    .multilineTextAlignment(.center)
            }
            .widgetBackground(contentBackground)
        }
    }
}

@available(iOSApplicationExtension 16.0, *)
struct InlineWidgetView: View {
    var entry: Provider.Entry

    var body: some View {
        Text(entry.shortText)
    }
}

@available(iOSApplicationExtension 16.0, *)
struct CourseTextWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                AccessoryWidgetBackground()
                    .cornerRadius(8)
                Text(entry.text)
                    .font(.system(.caption, weight: .bold))
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height
                    )
                    .padding(.horizontal, 4)
                    .multilineTextAlignment(.center)
            }
            .widgetBackground(
                Color(UIColor(
                    red: 0.07, green: 0.07, blue: 0.07, alpha: 1
                ))
            )
        }
    }
}

struct ViewSizeWidgetView: View {
    let entry: SimpleEntry

    @Environment(\.widgetFamily)
    var family

    var body: some View {
        if #available(iOSApplicationExtension 16.0, *) {
            switch family {
            case .accessoryInline:
                InlineWidgetView(entry: entry)
            case .accessoryRectangular:
                CourseTextWidgetEntryView(entry: entry)
            default:
                CourseAppWidgetEntryView(entry: entry)
            }
        } else {
            CourseAppWidgetEntryView(entry: entry)
        }
    }
}

// MARK: - Widget

struct CourseHintWidget: Widget {
    let kind: String = "CourseAppWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: Provider()
        ) { entry in
            ViewSizeWidgetView(entry: entry)
        }
        .configurationDisplayName("上課提醒")
        .description("提醒本日下一堂課")
        .supportedFamiliesIfNeeded()
        .disableContentMarginsIfNeeded()
    }
}

// MARK: - Widget Bundle

@main
struct CourseWidgetBundle: WidgetBundle {
    var body: some Widget {
        CourseHintWidget()
        CourseTableWidget()
        TodayScheduleWidget()
        CountdownCourseWidget()
        StudentIdCardWidget()
    }
}

// MARK: - Extensions

extension View {
    func widgetBackground(_ backgroundView: some View) -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            return background(backgroundView)
                .containerBackground(for: .widget) {
                    backgroundView
                }
        } else {
            return background(backgroundView)
        }
    }
}

extension WidgetConfiguration {
    func disableContentMarginsIfNeeded() -> some WidgetConfiguration {
        if #available(iOSApplicationExtension 17.0, *) {
            return self.contentMarginsDisabled()
        } else {
            return self
        }
    }

    func supportedFamiliesIfNeeded() -> some WidgetConfiguration {
        if #available(iOSApplicationExtension 16, *) {
            return self.supportedFamilies([
                .systemSmall,
                .systemMedium,
                .systemLarge,
                .accessoryRectangular,
                .accessoryInline,
            ])
        } else {
            return self
        }
    }

    func supportedFamiliesForTable() -> some WidgetConfiguration {
        if #available(iOSApplicationExtension 15.0, *) {
            return self.supportedFamilies([
                .systemMedium,
                .systemLarge,
                .systemExtraLarge,
            ])
        } else {
            return self.supportedFamilies([
                .systemMedium,
                .systemLarge,
            ])
        }
    }
}
