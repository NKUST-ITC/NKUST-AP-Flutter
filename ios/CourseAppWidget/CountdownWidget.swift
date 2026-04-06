import WidgetKit
import SwiftUI

// MARK: - Provider

struct CountdownProvider: TimelineProvider {
    func placeholder(in context: Context) -> CountdownEntry {
        CountdownEntry(result: nil)
    }

    func getSnapshot(
        in context: Context,
        completion: @escaping (CountdownEntry) -> Void
    ) {
        completion(CountdownEntry(result: findNext()))
    }

    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<CountdownEntry>) -> Void
    ) {
        let entry = CountdownEntry(result: findNext())
        // Refresh every minute for accurate countdown.
        let next = Calendar.current.date(
            byAdding: .minute, value: 1, to: Date()
        ) ?? Date()
        completion(Timeline(entries: [entry], policy: .after(next)))
    }

    private func findNext() -> NextCourse? {
        guard let defaults = UserDefaults(suiteName: appGroupId),
              let json = defaults.string(forKey: courseNotifyKey),
              let data = json.data(using: .utf8),
              let courseData = try? JSONDecoder().decode(
                  CourseData.self, from: data
              )
        else { return nil }

        let now = Date()
        let cal = Calendar.current
        let wd = cal.component(.weekday, from: now)
        let weekday = wd == 1 ? 7 : wd - 1

        var best: NextCourse?
        var bestDiff: TimeInterval = .greatestFiniteMagnitude

        for course in courseData.courses {
            for st in course.sectionTimes {
                guard st.weekday == weekday,
                      st.index < courseData.timeCodes.count
                else { continue }
                let tc = courseData.timeCodes[st.index]
                let startDate = parseTime(tc.startTime)
                let diff = startDate.timeIntervalSince(now)
                if diff > 0 && diff < bestDiff {
                    bestDiff = diff
                    let loc = [
                        course.location?.building,
                        course.location?.room,
                    ]
                    .compactMap { $0 }
                    .filter { !$0.isEmpty }
                    .joined()
                    best = NextCourse(
                        title: course.title,
                        startTime: tc.startTime,
                        location: loc,
                        minutesLeft: Int(diff / 60)
                    )
                }
            }
        }
        return best
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
}

// MARK: - Entry & Model

struct CountdownEntry: TimelineEntry {
    var date = Date()
    let result: NextCourse?
}

struct NextCourse {
    let title: String
    let startTime: String
    let location: String
    let minutesLeft: Int
}

// MARK: - View

struct CountdownView: View {
    let entry: CountdownEntry
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.widgetFamily) var family

    private var bgColor: Color {
        colorScheme == .dark
            ? Color(red: 0.10, green: 0.11, blue: 0.18)
            : .white
    }

    private var accent: Color {
        Color(red: 0.15, green: 0.45, blue: 1.00)
    }

    var body: some View {
        if #available(iOSApplicationExtension 16.0, *),
           family == .accessoryCircular
        {
            circularView
        } else {
            standardView
        }
    }

    private var standardView: some View {
        VStack(spacing: 4) {
            if let r = entry.result {
                Text("\(r.minutesLeft)")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(accent)
                Text("分鐘後上課")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                Spacer().frame(height: 4)
                Text(r.title)
                    .font(.system(size: 13, weight: .medium))
                    .lineLimit(1)
                Text("\(r.startTime) · \(r.location)")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            } else {
                Text("🎉")
                    .font(.system(size: 28))
                Text("今天已經沒有任何課")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .widgetBackground(bgColor)
    }

    @available(iOSApplicationExtension 16.0, *)
    private var circularView: some View {
        ZStack {
            if let r = entry.result {
                AccessoryWidgetBackground()
                VStack(spacing: 0) {
                    Text("\(r.minutesLeft)")
                        .font(.system(size: 22, weight: .bold))
                    Text("min")
                        .font(.system(size: 9))
                }
            } else {
                AccessoryWidgetBackground()
                Image(systemName: "checkmark")
                    .font(.system(size: 20))
            }
        }
    }
}

// MARK: - Widget

struct CountdownCourseWidget: Widget {
    let kind = "CountdownWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: CountdownProvider()
        ) { entry in
            CountdownView(entry: entry)
        }
        .configurationDisplayName("上課倒數")
        .description("距離下一堂課的倒數計時")
        .countdownFamilies()
        .disableContentMarginsIfNeeded()
    }
}

extension WidgetConfiguration {
    func countdownFamilies() -> some WidgetConfiguration {
        if #available(iOSApplicationExtension 16, *) {
            return self.supportedFamilies([
                .systemSmall,
                .accessoryCircular,
            ])
        } else {
            return self.supportedFamilies([.systemSmall])
        }
    }
}
