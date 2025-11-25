//
//  TimeZoneManager.swift
//  FroopProof
//
//  Created by David Reed on 3/19/23.
//

import Foundation
import CoreLocation
import SwiftUI
import Combine


class TimeZoneManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = TimeZoneManager()
    @ObservedObject var flightManager = FroopFlightDataManager.shared
    @Published var userAccountTimeZone: TimeZone?
    @Published var userLocationTimeZone: TimeZone?
    @Published var froopTimeZone: TimeZone?
    @Published var locationTimeZone: TimeZone?
    @Published var departingTimeZone: TimeZoneResponse?
    @Published var arrivingTimeZone: TimeZoneResponse?
    var currentTimeZone: TimeZone? {
        return TimeZone.current
    }
    
    private var geocoder = CLGeocoder()
    
    override init() {
        super.init()
    }
    
    func convertDateToLocalTime(for date: Date) -> Date {
        //print("convertDataToLocalTime Function is firing: ⏱️⏱️")
        //print("UTC Date: \(date) ⏱️⏱️⏱️⏱️")

        if let timeZone = currentTimeZone {
//            print("🕐🕑🕒 \(timeZone) / and \(String(describing: currentTimeZone))")
            let secondsFromGMT = timeZone.secondsFromGMT(for: date)
            let localDate = Date(timeInterval: TimeInterval(secondsFromGMT), since: date)
            //print("Local Date: \(localDate) ⏱️⏱️⏱️⏱️⏱️")

            // Create a DateFormatter to print the date in the local timezone without the UTC offset
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = timeZone
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            //print("Formatted Local Date: \(localDateString)")

            return localDate
        } else {
            print("TimeZoneManager.shared.userLocationTimeZone is nil")
        }
        return date
    }

    func formatTime(for date: Date, in timeZone: TimeZone) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.timeZone = timeZone
        return formatter.string(from: date)
    }
    
    func formatDate(for date: Date, in timeZoneIdentifier: String?, formatType: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = formatType
        if let timeZone = TimeZone(identifier: timeZoneIdentifier ?? "") {
            formatter.timeZone = timeZone
        }
        return formatter.string(from: date)
    }
    
    func timeZoneAbbreviation(from identifier: String) -> String {
        guard let timeZone = TimeZone(identifier: identifier) else {
            return "Unknown Time Zone"
        }
        
        // This will return the appropriate abbreviation based on current date and daylight saving time
        return timeZone.abbreviation() ?? identifier
    }
    
    func formatDuration(durationInSeconds: Int) -> String {
        let durationInMinutes = Int(ceil(Double(durationInSeconds) / 60))
        let roundedDurationInMinutes = Int(round(Double(durationInMinutes) / 15.0)) * 15
        let hours = roundedDurationInMinutes / 60
        let minutes = roundedDurationInMinutes % 60
        
        var durationString = ""
        
        if hours != 0 {
            durationString += "\(hours) hour"
            if hours != 1 {
                durationString += "s"
            }
        }
        
        if minutes != 0 {
            if durationString != "" {
                durationString += " "
            }
            durationString += "\(minutes) minute"
            if minutes != 1 {
                durationString += "s"
            }
        }
        
        return durationString
    }
    
    func formatDuration2(durationInMinutes: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.day, .hour, .minute]
        formatter.maximumUnitCount = 2
        return formatter.string(from: durationInMinutes) ?? ""
    }
    
    func formatDurationSinceCreation(creationDate: Date) -> String {
        let now = Date()
        let durationInMinutes = now.timeIntervalSince(creationDate)
        return formatDuration2(durationInMinutes: TimeInterval(Int(durationInMinutes)))
    }
    
    //MARK: Required Functions below
    
    func updateTimeZonesForFlight(departureLat: Double, departureLon: Double, arrivalLat: Double, arrivalLon: Double, apiKey: String, completion: @escaping (TimeZoneResponse?, TimeZoneResponse?, Error?) -> Void) {
        let dispatchGroup = DispatchGroup()

        var departingTimeZone: TimeZoneResponse?
        var arrivingTimeZone: TimeZoneResponse?
        var fetchError: Error?

        dispatchGroup.enter()
        fetchTimeZoneData(latitude: departureLat, longitude: departureLon, apiKey: apiKey) { response, error in
            departingTimeZone = response
            if error != nil { fetchError = error }
            dispatchGroup.leave()
        }

        dispatchGroup.enter()
        fetchTimeZoneData(latitude: arrivalLat, longitude: arrivalLon, apiKey: apiKey) { response, error in
            arrivingTimeZone = response
            if error != nil { fetchError = error }
            dispatchGroup.leave()
        }

        dispatchGroup.notify(queue: .main) {
            completion(departingTimeZone, arrivingTimeZone, fetchError)
        }
    }

    
    func formatLocalTime(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"  // for example, 5:00 PM
        return dateFormatter.string(from: date)
    }
    
    func formatTime(from date: Date, timeZoneIdentifier: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"  // for example, 5:00 PM

        // Convert the string identifier to a TimeZone object
        if let timeZone = TimeZone(identifier: timeZoneIdentifier) {
            dateFormatter.timeZone = timeZone
        } else {
            print("Invalid time zone identifier: \(timeZoneIdentifier)")
            dateFormatter.timeZone = TimeZone.current  // Fallback to current time zone if identifier is invalid
        }

        return dateFormatter.string(from: date)
    }
    
    func fetchTimeZoneData(latitude: Double, longitude: Double, apiKey: String, completion: @escaping (TimeZoneResponse?, Error?) -> Void) {
        let timestamp = Date().timeIntervalSince1970
        let urlString = "https://maps.googleapis.com/maps/api/timezone/json?location=\(latitude),\(longitude)&timestamp=\(timestamp)&key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let data = data else {
                completion(nil, NSError(domain: "", code: -2, userInfo: [NSLocalizedDescriptionKey: "No data received"]))
                return
            }

            do {
                let decoder = JSONDecoder()
                let timeZoneResponse = try decoder.decode(TimeZoneResponse.self, from: data)
                completion(timeZoneResponse, nil)
            } catch {
                completion(nil, error)
            }
        }
        task.resume()
    }
    
    
    func fetchTimeZone(latitude: Double, longitude: Double) async -> TimeZone? {
        print("Fetching timezone for lat: \(latitude), long: \(longitude)")
        let location = CLLocation(latitude: latitude, longitude: longitude)
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            return placemarks.first?.timeZone
        } catch {
            print("Failed to fetch timezone: \(error.localizedDescription)")
            return nil
        }
    }

        
    func fetchTimeZoneData() async {
        let latitude = MyData.shared.coordinate.latitude
        let longitude = MyData.shared.coordinate.longitude
        
        do {
            if let timeZone = await fetchTimeZone(latitude: latitude, longitude: longitude) {
                PrintControl.shared.printTimeZone("Fetched time zone: \(timeZone)")
                DispatchQueue.main.async {
                    self.locationTimeZone = timeZone
                }
            } else {
                PrintControl.shared.printTimeZone("Failed to fetch time zone")
            }
        } catch {
            PrintControl.shared.printTimeZone("Error fetching time zone: \(error)")
        }
    }

    
    func convertUTCToCurrent(date: Date, currentTZ: String, completion: @escaping (Date) -> Void) {
        PrintControl.shared.printTimeZone("One: date \(date)")
        PrintControl.shared.printTimeZone("Two: currentTZ \(currentTZ)")
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(identifier: currentTZ) ?? TimeZone(identifier: "UTC")!
        
        let currentTimeString = formatter.string(from: date)
        
        PrintControl.shared.printTimeZone("Three: currentTimeString:  \(currentTimeString)")
        
        // Convert the string back to a Date object in the specified timezone
        if let convertedDate = formatter.date(from: currentTimeString) {
            PrintControl.shared.printTimeZone("Four: convertedDate: \(convertedDate)")
            completion(convertedDate)
        } else {
            completion(date) // Return the original date if conversion fails
            PrintControl.shared.printTimeZone("Five: completion(date) \(date)")
        }
    }
    
    func convertUTCToCurrentDetail(date: Date, currentTZ: String, completion: @escaping (Date) -> Void) {
        PrintControl.shared.printTimeZone("One: date \(date)")
        PrintControl.shared.printTimeZone("Two: currentTZ \(currentTZ)")
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(identifier: currentTZ) ?? TimeZone(identifier: "UTC")!
        
        let currentTimeString = formatter.string(from: date)
        
        PrintControl.shared.printTimeZone("Three: currentTimeString:  \(currentTimeString)")
        
        // Convert the string back to a Date object in the specified timezone
        if let convertedDate = formatter.date(from: currentTimeString) {
            PrintControl.shared.printTimeZone("Four: convertedDate: \(convertedDate)")
            completion(convertedDate)
        } else {
            completion(date) // Return the original date if conversion fails
            PrintControl.shared.printTimeZone("Five: completion(date) \(date)")
        }
    }
    
    
    func convertDateToUTC(date: Date, oTZ: TimeZone) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = oTZ

        let dateString = formatter.string(from: date)
        formatter.timeZone = TimeZone(abbreviation: "UTC")

        guard let utcDate = formatter.date(from: dateString) else {
            fatalError("Failed to convert date to UTC")
        }

        return utcDate
    }
    
    func convertDateToTimeZone(dateString: String, timeZone: String, completion: @escaping (Date?, String, String) -> Void) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        guard let dateInUTC = dateFormatter.date(from: dateString) else {
            PrintControl.shared.printTimeZone("Failed to parse date string")
            completion(nil, "", "")
            return
        }
        
        let destinationTimeZone = timeZone != "" ? TimeZone(identifier: timeZone) : TimeZone.current
        
        if let destinationTimeZone = destinationTimeZone {
            let sourceTimeZone = TimeZone(identifier: "UTC")!
            let interval = TimeInterval(destinationTimeZone.secondsFromGMT() - sourceTimeZone.secondsFromGMT())
            
            let destinationDate = dateInUTC.addingTimeInterval(interval)
            
            // Date string
            dateFormatter.dateFormat = "EEEE MMM. d"
            dateFormatter.timeZone = destinationTimeZone
            let dateString = dateFormatter.string(from: destinationDate)
            
            // Time string
            dateFormatter.dateFormat = "h:mm a"
            let timeString = dateFormatter.string(from: destinationDate)
            
            completion(destinationDate, dateString, timeString)
        } else {
            PrintControl.shared.printTimeZone("Invalid time zone identifier: \(String(describing: timeZone))")
            completion(nil, "", "")
        }
    }
    
    func formatDuration(_ durationInSeconds: TimeInterval) -> String {
        let weeks = Int(durationInSeconds) / (3600 * 24 * 7)
        let days = Int(durationInSeconds) / (3600 * 24) % 7
        let hours = Int(durationInSeconds) / 3600 % 24
        let minutes = Int(durationInSeconds) / 60 % 60
        
        var durationString = ""
        
        if weeks > 0 {
            durationString += "\(weeks)w "
        }
        if days > 0 {
            durationString += "\(days)d "
        }
        if hours > 0 {
            durationString += "\(hours)h "
        }
        if minutes > 0 {
            durationString += "\(minutes)m"
        }
        
        return durationString
    }
    
    func formatDateInCurrentTimeZone(dateString: String, format: String) -> String? {
        let currentTimeZone = TimeZone.current.identifier
        var formattedDateString: String?
        
        convertDateToTimeZone(dateString: dateString, timeZone: currentTimeZone) { _, timeString, timeZone in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = format
            dateFormatter.timeZone = TimeZone(identifier: timeZone)
            formattedDateString = timeString
        }
        
        return formattedDateString
    }
    
    func formatDate(passedDate: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d',' h:mm a"
        let formattedDate = formatter.string(from: passedDate)
        return formattedDate
    }
    
    func formatDateDetail(passedDate: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, h:mm a"
        let formattedDate = formatter.string(from: passedDate)
        return formattedDate
    }
    
    func formatFlightDateDetail(passedDate: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EE MMMM d, yyyy"
        let formattedDate = formatter.string(from: passedDate)
        return formattedDate
    }
    
}
