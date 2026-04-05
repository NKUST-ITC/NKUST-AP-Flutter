import WidgetKit
import SwiftUI
import CoreImage.CIFilterBuiltins

// MARK: - Provider

struct StudentIdProvider: TimelineProvider {
    func placeholder(in context: Context) -> StudentIdEntry {
        StudentIdEntry(info: nil)
    }

    func getSnapshot(
        in context: Context,
        completion: @escaping (StudentIdEntry) -> Void
    ) {
        completion(StudentIdEntry(info: loadInfo()))
    }

    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<StudentIdEntry>) -> Void
    ) {
        let entry = StudentIdEntry(info: loadInfo())
        // Student info doesn't change often; refresh every 6 hours.
        let next = Calendar.current.date(
            byAdding: .hour, value: 6, to: Date()
        ) ?? Date()
        completion(Timeline(entries: [entry], policy: .after(next)))
    }

    private func loadInfo() -> StudentInfo? {
        guard let defaults = UserDefaults(suiteName: appGroupId),
              let json = defaults.string(forKey: "user_info"),
              let data = json.data(using: .utf8)
        else { return nil }
        return try? JSONDecoder().decode(StudentInfo.self, from: data)
    }
}

// MARK: - Entry & Model

struct StudentIdEntry: TimelineEntry {
    var date = Date()
    let info: StudentInfo?
}

struct StudentInfo: Codable {
    let id: String
    let name: String
    let department: String?
    let className: String?
}

// MARK: - View

struct StudentIdView: View {
    let entry: StudentIdEntry
    @Environment(\.colorScheme) var colorScheme

    private var headerColor: Color {
        colorScheme == .dark
            ? Color(red: 0.10, green: 0.11, blue: 0.18)
            : Color(red: 0.15, green: 0.45, blue: 1.00)
    }

    private var bgColor: Color {
        colorScheme == .dark
            ? Color(red: 0.12, green: 0.12, blue: 0.12)
            : .white
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            Text("學生證")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 28)
                .background(headerColor)

            if let info = entry.info {
                infoContent(info)
            } else {
                Spacer()
                Text("請先登入")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
        .widgetBackground(bgColor)
    }

    @ViewBuilder
    private func infoContent(_ info: StudentInfo) -> some View {
        VStack(spacing: 4) {
            Spacer().frame(height: 8)
            // Name
            Text(info.name)
                .font(.system(size: 16, weight: .bold))

            // Department
            if let dept = info.department, !dept.isEmpty {
                Text(dept)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }

            Spacer().frame(height: 6)

            // Student ID
            Text(info.id)
                .font(.system(
                    size: 22,
                    weight: .bold,
                    design: .monospaced
                ))
                .tracking(3)

            Spacer().frame(height: 6)

            // Barcode
            if let barcodeImage = generateBarcode(info.id) {
                Image(uiImage: barcodeImage)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 40)
            }

            Text("可持本條碼於圖書館借書")
                .font(.system(size: 9))
                .foregroundColor(.secondary)
            Spacer().frame(height: 4)
        }
        .frame(maxWidth: .infinity)
    }

    private func generateBarcode(_ text: String) -> UIImage? {
        let filter = CIFilter.code128BarcodeGenerator()
        filter.message = Data(text.utf8)
        filter.quietSpace = 2

        guard let output = filter.outputImage else { return nil }
        let scale = CGAffineTransform(scaleX: 3, y: 3)
        let scaled = output.transformed(by: scale)
        let context = CIContext()
        guard let cgImage = context.createCGImage(
            scaled, from: scaled.extent
        ) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}

// MARK: - Widget

struct StudentIdCardWidget: Widget {
    let kind = "StudentIdWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: StudentIdProvider()
        ) { entry in
            StudentIdView(entry: entry)
        }
        .configurationDisplayName("學生證")
        .description("顯示學號與條碼")
        .supportedFamilies([.systemMedium])
        .disableContentMarginsIfNeeded()
    }
}
