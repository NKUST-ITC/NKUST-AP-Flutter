// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let courseData = try? newJSONDecoder().decode(CourseData.self, from: jsonData)

import Foundation

// MARK: - CourseData
class CourseData: Codable {
    let courses: [Course]
    let timeCodes: [TimeCode]

    init(courses: [Course], timeCodes: [TimeCode]) {
        self.courses = courses
        self.timeCodes = timeCodes
    }
}

// MARK: - Course
class Course: Codable {
    let code: String
    let title: String
    let className: String?
    let group: String?
    let units: String?
    let hours: String?
    let required: String?
    let sectionTimes: [SectionTime]
    let location: Location?
    let instructors: [String]

    enum CodingKeys: String, CodingKey {
        case code, title, className, group, units, hours
        case required
        case sectionTimes, location, instructors
    }
}

// MARK: - Location
class Location: Codable {
    let building: String?
    let room: String?

    init(building: String, room: String) {
        self.building = building
        self.room = room
    }
}

class SectionTime: Codable {
    let weekday: Int
    let index: Int

    init(weekday: Int, index: Int) {
        self.weekday = weekday
        self.index = index
    }
}

class TimeCode: Codable {
    let title: String
    let startTime: String
    let endTime: String

    init(title: String, startTime: String, endTime: String) {
        self.title = title
        self.startTime = startTime
        self.endTime = endTime
    }
}

// MARK: - Course
class CourseSimple: Codable {
    let title: String
    let startTime: String
    let location: String

    init(title: String, startTime: String, location: String) {
        self.title = title
        self.startTime = startTime
        self.location = location
    }
}
// MARK: - Encode/decode helpers

class JSONNull: Codable, Hashable {

    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }

    public var hashValue: Int {
        return 0
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}
