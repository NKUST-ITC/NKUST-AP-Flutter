// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let courseData = try? newJSONDecoder().decode(CourseData.self, from: jsonData)

import Foundation

// MARK: - CourseData
class CourseData: Codable {
    let courses: [CourseDetail]
    let coursetable: Coursetable

    init(courses: [CourseDetail], coursetable: Coursetable) {
        self.courses = courses
        self.coursetable = coursetable
    }
}

// MARK: - Course
class CourseDetail: Codable {
    let code, title, className: String
    let group: String?
    let units: String
    let hours: String?
    let courseRequired: String?
    let times: String
    let location: Location
    let instructors: [String]

    enum CodingKeys: String, CodingKey {
        case code, title, className, group, units, hours
        case courseRequired
        case times, location, instructors
    }

    init(code: String, title: String, className: String, group: String?, units: String, hours: String?, courseRequired: String, times: String, location: Location, instructors: [String]) {
        self.code = code
        self.title = title
        self.className = className
        self.group = group
        self.units = units
        self.hours = hours
        self.courseRequired = courseRequired
        self.times = times
        self.location = location
        self.instructors = instructors
    }
}

// MARK: - Location
class Location: Codable {
    let building: String
    let room: String

    init(building: String, room: String) {
        self.building = building
        self.room = room
    }
}

// MARK: - Coursetable
class Coursetable: Codable {
    let monday, tuesday, wednesday, thursday, friday, saturday, sunday: [Course?]?
    let timeCodes: [String]

    enum CodingKeys: String, CodingKey {
        case monday = "Monday"
        case tuesday = "Tuesday"
        case wednesday = "Wednesday"
        case thursday = "Thursday"
        case friday = "Friday"
        case saturday = "Saturday"
        case sunday = "Sunday"
        case timeCodes
    }

    init(monday: [Course], tuesday: [Course], wednesday: [Course], thursday: [Course], friday: [Course], saturday: [Course], sunday: [Course], timeCodes: [String]) {
        self.monday = monday
        self.tuesday = tuesday
        self.wednesday = wednesday
        self.thursday = thursday
        self.friday = friday
        self.saturday = saturday
        self.sunday = sunday
        self.timeCodes = timeCodes
    }
    
    func getCourses(weekdayIndex:Int) -> [Course?]?{
        switch weekdayIndex {
        case 2:
            return monday
        case 3:
            return tuesday
        case 4:
            return wednesday
        case 5:
            return thursday
        case 6:
            return friday
        case 7:
            return saturday
        case 1:
            return sunday
        default:
            return sunday
        }
    }
}

// MARK: - Course
class Course: Codable {
    let title: String
    let date: DateClass
    let location: Location
    let instructors: [String]
    let detailIndex: Int

    init(title: String, date: DateClass, location: Location, instructors: [String], detailIndex: Int) {
        self.title = title
        self.date = date
        self.location = location
        self.instructors = instructors
        self.detailIndex = detailIndex
    }
}

// MARK: - DateClass
class DateClass: Codable {
    let startTime, endTime, section: String

    init(startTime: String, endTime: String, section: String) {
        self.startTime = startTime
        self.endTime = endTime
        self.section = section
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
