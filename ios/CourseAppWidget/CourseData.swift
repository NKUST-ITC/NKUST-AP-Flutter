import Foundation

// MARK: - CourseData
struct CourseData: Codable {
    let courses: [Course]
    let timeCodes: [TimeCode]
}

// MARK: - Course
struct Course: Codable {
    let code: String
    let title: String
    let className: String?
    let group: String?
    let units: String?
    let hours: String?
    let required: String?
    let at: String?
    let sectionTimes: [SectionTime]
    let location: Location?
    let instructors: [String]

    enum CodingKeys: String, CodingKey {
        case code, title, className, group, units, hours
        case required, at
        case sectionTimes, location, instructors
    }
}

// MARK: - Location
struct Location: Codable {
    let building: String?
    let room: String?
}

// MARK: - SectionTime
struct SectionTime: Codable {
    let weekday: Int
    let index: Int
}

// MARK: - TimeCode
struct TimeCode: Codable {
    let title: String
    let startTime: String
    let endTime: String
}
