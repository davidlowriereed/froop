//
//  GoogleTimeZoneAPI.swift
//  FroopProof
//
//  Created by David Reed on 4/26/24.
//

import Foundation

// Define a struct to match the JSON structure returned by Google's Time Zone API
struct TimeZoneResponse: Codable {
    var dstOffset: Int
    var rawOffset: Int
    var status: String
    var timeZoneId: String
    var timeZoneName: String

    // Coding keys to map the JSON keys to your struct's properties
    enum CodingKeys: String, CodingKey {
        case dstOffset = "dstOffset"
        case rawOffset = "rawOffset"
        case status = "status"
        case timeZoneId = "timeZoneId"
        case timeZoneName = "timeZoneName"
    }
}

class DateUtilities {
    static func formatDateForJSON(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.string(from: date)
    }

    static func adjustDateByOffsets(date: Date, dstOffset: Int?, rawOffset: Int?) -> Date {
        let totalOffset = TimeInterval((dstOffset ?? 0) + (rawOffset ?? 0))
        return date.addingTimeInterval(totalOffset)
    }
}
