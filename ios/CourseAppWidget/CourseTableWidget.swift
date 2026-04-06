import WidgetKit
import SwiftUI

// MARK: - Timeline Provider

struct CourseTableProvider: TimelineProvider {
    func placeholder(in context: Context) -> CourseTableEntry {
        CourseTableEntry(courseData: nil)
    }

    func getSnapshot(
        in context: Context,
        completion: @escaping (CourseTableEntry) -> Void
    ) {
        let entry = CourseTableEntry(courseData: loadData())
        completion(entry)
    }

    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<CourseTableEntry>) -> Void
    ) {
        let entry = CourseTableEntry(courseData: loadData())
        // Refresh at the start of next hour.
        let nextUpdate = Calendar.current.date(
            byAdding: .hour, value: 1, to: Date()
        ) ?? Date()
        let timeline = Timeline(
            entries: [entry],
            policy: .after(nextUpdate)
        )
        completion(timeline)
    }

    private func loadData() -> CourseData? {
        guard let defaults = UserDefaults(suiteName: appGroupId),
              let json = defaults.string(forKey: courseNotifyKey),
              let data = json.data(using: .utf8),
              let courseData = try? JSONDecoder().decode(
                  CourseData.self, from: data
              ),
              !courseData.courses.isEmpty
        else {
            return nil
        }
        return courseData
    }
}

// MARK: - Entry

struct CourseTableEntry: TimelineEntry {
    var date = Date()
    let courseData: CourseData?
}

// MARK: - Color Palette (matching Flutter)

private let courseColorPalette: [Color] = [
    Color(red: 0.36, green: 0.42, blue: 0.75), // Indigo
    Color(red: 0.15, green: 0.65, blue: 0.60), // Teal
    Color(red: 0.94, green: 0.33, blue: 0.31), // Red
    Color(red: 0.67, green: 0.28, blue: 0.74), // Purple
    Color(red: 0.26, green: 0.65, blue: 0.96), // Blue
    Color(red: 1.00, green: 0.44, blue: 0.26), // Deep Orange
    Color(red: 0.40, green: 0.73, blue: 0.42), // Green
    Color(red: 1.00, green: 0.79, blue: 0.16), // Amber
    Color(red: 0.55, green: 0.43, blue: 0.39), // Brown
    Color(red: 0.47, green: 0.56, blue: 0.61), // Blue Grey
    Color(red: 0.93, green: 0.25, blue: 0.48), // Pink
    Color(red: 0.49, green: 0.34, blue: 0.76), // Deep Purple
]

// MARK: - Course Table View

struct CourseTableView: View {
    let courseData: CourseData?
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.widgetFamily) var family

    private var headerColor: Color {
        colorScheme == .dark
            ? Color(red: 0.10, green: 0.11, blue: 0.18)
            : Color(red: 0.15, green: 0.45, blue: 1.00)
    }

    private var surfaceColor: Color {
        colorScheme == .dark
            ? Color(red: 0.07, green: 0.07, blue: 0.07)
            : Color(red: 0.97, green: 0.97, blue: 0.98)
    }

    private var gridLineColor: Color {
        colorScheme == .dark
            ? Color.white.opacity(0.08)
            : Color.black.opacity(0.06)
    }

    private var secondaryText: Color {
        colorScheme == .dark
            ? Color.gray
            : Color(red: 0.46, green: 0.46, blue: 0.50)
    }

    private let weekdayLabels = ["一", "二", "三", "四", "五", "六", "日"]
    private let weekdayLabelsEn = [
        "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun",
    ]

    var body: some View {
        if let data = courseData {
            courseGrid(data)
                .widgetBackground(surfaceColor)
        } else {
            VStack {
                Text("尚無課程資料")
                    .foregroundColor(secondaryText)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .widgetBackground(surfaceColor)
        }
    }

    @ViewBuilder
    private func courseGrid(_ data: CourseData) -> some View {
        let hasHoliday = data.courses.contains { course in
            course.sectionTimes.contains { $0.weekday >= 6 }
        }
        let weekdayCount = hasHoliday ? 7 : 5
        let (minIdx, maxIdx) = timeRange(data)
        let lookup = buildLookup(data)
        let colorMap = buildColorMap(
            lookup: lookup,
            weekdayCount: weekdayCount,
            minIdx: minIdx,
            maxIdx: maxIdx
        )
        let todayWeekday = currentWeekday()
        let isCompact = family == .systemSmall

        GeometryReader { geo in
            let timeLabelWidth: CGFloat = isCompact ? 24 : 30
            let headerHeight: CGFloat = isCompact ? 18 : 22
            let availableWidth = geo.size.width - timeLabelWidth
            let cellWidth = availableWidth / CGFloat(weekdayCount)
            let availableHeight = geo.size.height - headerHeight
            let rowCount = CGFloat(maxIdx - minIdx + 1)
            let cellHeight = max(
                availableHeight / max(rowCount, 1), 28
            )

            VStack(spacing: 0) {
                // Weekday header
                HStack(spacing: 0) {
                    Color.clear.frame(
                        width: timeLabelWidth,
                        height: headerHeight
                    )
                    ForEach(1...weekdayCount, id: \.self) { d in
                        Text(weekdayLabels[d - 1])
                            .font(.system(
                                size: isCompact ? 8 : 10,
                                weight: d == todayWeekday
                                    ? .bold : .regular
                            ))
                            .foregroundColor(
                                d == todayWeekday
                                    ? headerColor : secondaryText
                            )
                            .frame(
                                width: cellWidth,
                                height: headerHeight
                            )
                    }
                }

                // Pre-compute spans for merging consecutive slots
                let spans = buildSpanMap(
                    lookup: lookup,
                    weekdayCount: weekdayCount,
                    minIdx: minIdx,
                    maxIdx: maxIdx
                )

                // Grid rows
                ForEach(minIdx...maxIdx, id: \.self) { t in
                    HStack(spacing: 0) {
                        // Time label
                        VStack(spacing: 0) {
                            let tc = t < data.timeCodes.count
                                ? data.timeCodes[t] : nil
                            Text(tc?.title ?? "\(t)")
                                .font(.system(
                                    size: isCompact ? 7 : 9,
                                    weight: .medium
                                ))
                                .foregroundColor(secondaryText)
                            if !isCompact, let tc = tc {
                                Text(tc.startTime)
                                    .font(.system(size: 6))
                                    .foregroundColor(
                                        secondaryText.opacity(0.7)
                                    )
                            }
                        }
                        .frame(
                            width: timeLabelWidth,
                            height: cellHeight
                        )

                        // Course cells
                        ForEach(1...weekdayCount, id: \.self) { d in
                            let course = lookup[d]?[t]
                            let spanLen = spans[d]?[t] ?? 0
                            let isFirst = spanLen > 0
                            let isContinuation =
                                !isFirst && course != nil
                            let nextSame = course != nil
                                && lookup[d]?[t + 1]?.code
                                    == course!.code
                                && (spans[d]?[t + 1] ?? 0) == 0

                            cellView(
                                course: isFirst ? course : nil,
                                continuationColor: isContinuation
                                    ? colorMap[
                                        course!.code,
                                        default: courseColorPalette[0]
                                    ]
                                    : nil,
                                color: course != nil
                                    ? colorMap[
                                        course!.code,
                                        default: courseColorPalette[0]
                                    ]
                                    : .clear,
                                width: cellWidth,
                                height: cellHeight,
                                isCompact: isCompact,
                                span: isFirst ? spanLen : 1,
                                hasMore: (isFirst && spanLen > 1)
                                    || (isContinuation && nextSame)
                            )
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func cellView(
        course: Course?,
        continuationColor: Color?,
        color: Color,
        width: CGFloat,
        height: CGFloat,
        isCompact: Bool,
        span: Int = 1,
        hasMore: Bool = false
    ) -> some View {
        if let course = course {
            // First slot of a (possibly merged) course
            let maxChars = isCompact
                ? 2
                : (span > 1 ? 8 : 4)
            let displayTitle = course.title.count > maxChars
                ? String(course.title.prefix(maxChars))
                : course.title
            let corners: UIRectCorner = hasMore
                ? [.topLeft, .topRight]
                : [.allCorners]
            VStack(spacing: 0) {
                Text(displayTitle)
                    .font(.system(
                        size: isCompact
                            ? 7
                            : (span > 1 ? 9 : 8),
                        weight: .bold
                    ))
                    .foregroundColor(.white)
                    .lineLimit(span > 1 ? 3 : 2)
                    .multilineTextAlignment(.center)

                if !isCompact,
                   let loc = course.location,
                   let room = loc.room, !room.isEmpty
                {
                    Text(
                        "\(loc.building ?? "")\(room)"
                    )
                    .font(.system(size: 6))
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(1)
                }
            }
            .frame(
                width: width - 2,
                height: height - (hasMore ? 1 : 2)
            )
            .background(
                SpecificRoundedRect(
                    corners: corners,
                    radius: 4
                ).fill(color)
            )
            .padding(.horizontal, 1)
            .padding(.top, 1)
            .padding(.bottom, hasMore ? 0 : 1)
        } else if let contColor = continuationColor {
            // Continuation slot (middle/last of merged span)
            let corners: UIRectCorner = hasMore
                ? [] : [.bottomLeft, .bottomRight]
            Rectangle()
                .fill(Color.clear)
                .frame(width: width, height: height)
                .overlay(
                    SpecificRoundedRect(
                        corners: corners,
                        radius: hasMore ? 0 : 4
                    )
                    .fill(contColor)
                    .padding(.horizontal, 1)
                    .padding(.bottom, hasMore ? 0 : 1)
                )
        } else {
            Rectangle()
                .fill(Color.clear)
                .frame(width: width, height: height)
                .overlay(
                    Rectangle()
                        .stroke(gridLineColor, lineWidth: 0.5)
                )
        }
    }

    // MARK: - Helpers

    private func timeRange(
        _ data: CourseData
    ) -> (Int, Int) {
        var minIdx = Int.max
        var maxIdx = 0
        for course in data.courses {
            for t in course.sectionTimes {
                if t.index < minIdx { minIdx = t.index }
                if t.index > maxIdx { maxIdx = t.index }
            }
        }
        if minIdx > maxIdx { return (0, 0) }
        return (minIdx, maxIdx)
    }

    private func buildLookup(
        _ data: CourseData
    ) -> [Int: [Int: Course]] {
        var lookup: [Int: [Int: Course]] = [:]
        for course in data.courses {
            for t in course.sectionTimes {
                if lookup[t.weekday] == nil {
                    lookup[t.weekday] = [:]
                }
                lookup[t.weekday]?[t.index] = course
            }
        }
        return lookup
    }

    /// Assign colors by grid scan order (weekday → timeIndex)
    /// to match Flutter's `_getCourseColor` iteration order.
    private func buildColorMap(
        lookup: [Int: [Int: Course]],
        weekdayCount: Int,
        minIdx: Int,
        maxIdx: Int
    ) -> [String: Color] {
        var map: [String: Color] = [:]
        var idx = 0
        for d in 1...weekdayCount {
            guard let dayMap = lookup[d] else { continue }
            for t in minIdx...maxIdx {
                guard let course = dayMap[t] else { continue }
                if map[course.code] == nil {
                    map[course.code] = courseColorPalette[
                        idx % courseColorPalette.count
                    ]
                    idx += 1
                }
            }
        }
        return map
    }

    private func buildSpanMap(
        lookup: [Int: [Int: Course]],
        weekdayCount: Int,
        minIdx: Int,
        maxIdx: Int
    ) -> [Int: [Int: Int]] {
        var spans: [Int: [Int: Int]] = [:]
        for d in 1...weekdayCount {
            guard let dayMap = lookup[d] else { continue }
            var starts: [Int: Int] = [:]
            var t = minIdx
            while t <= maxIdx {
                if let course = dayMap[t] {
                    var span = 1
                    while t + span <= maxIdx,
                          dayMap[t + span]?.code == course.code
                    {
                        span += 1
                    }
                    starts[t] = span
                    t += span
                } else {
                    t += 1
                }
            }
            spans[d] = starts
        }
        return spans
    }

    private func currentWeekday() -> Int {
        let cal = Calendar.current
        let wd = cal.component(.weekday, from: Date())
        return wd == 1 ? 7 : wd - 1
    }
}

// MARK: - Rounded corners helper

private struct SpecificRoundedRect: Shape {
    let corners: UIRectCorner
    let radius: CGFloat

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Widget

struct CourseTableWidget: Widget {
    let kind: String = "CourseTableWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: CourseTableProvider()
        ) { entry in
            CourseTableView(courseData: entry.courseData)
        }
        .configurationDisplayName("學期課表")
        .description("顯示每週課表")
        .supportedFamiliesForTable()
        .disableContentMarginsIfNeeded()
    }
}
