//
//  FlightTimeManager.swift
//  FroopProof
//
//  Created by David Reed on 5/9/24.
//

import Foundation
import MapKit
import CoreLocation

/// Class responsible for managing flight-related time calculations and timers.
class FlightTimeManager: ObservableObject {
    // Shared instance for global usage
    static let shared = FlightTimeManager()

    // Published properties to observe changes
    @Published var flightData: ScheduledFlightAPI.FlightDetail = ScheduledFlightAPI.FlightDetail.empty() {
        didSet {
            updateTimePropertiesFromFlightData()
        }
    }
    @Published var flightStartTimeUTC: Date = Date()
    @Published var flightEndTimeUTC: Date = Date()
    @Published var flightStartTimeLocal: Date = Date()
    @Published var flightEndTimeLocal: Date = Date()
    @Published var flightDuration: TimeInterval = 0
    @Published var remainingTime: TimeInterval = 0
    @Published var isTimerActive: Bool = false
    @Published var timeUntilPickup: String = "0h 0m"
    @Published var distance: Double = 0.0
    // New properties
    @Published var userDepartureTime: Date = Date()
    @Published var formattedUserDepartureCountdown: String = "0h 0m"
    @Published var formattedTimeUntilLanding: String = "0h 0m"

    // Timezone information
    @Published var departureTimeZone: TimeZone = TimeZone.current
    @Published var arrivalTimeZone: TimeZone = TimeZone.current

    // Internal timer
    private var timer: Timer?

    private init() {}

    /// Computed property to calculate the remaining time until landing
    var timeUntilLanding: TimeInterval {
        let now = Date()
        return flightEndTimeUTC.timeIntervalSince(now)
    }
    
    var timeUntilLeaving: TimeInterval {
        let now = Date()
        let timeUntilLanding = flightEndTimeUTC.timeIntervalSince(now) / 60  // Time in minutes
        return timeUntilLanding - distance  // Subtract distance in minutes
    }
    
    var formattedTimeUntilLeaving: String {
        return formatLeaveTimeInterval(timeUntilLeaving)
    }

    /// Starts the timer to update the time remaining until pickup and landing.
    func startTimer() {
        stopTimer()
        isTimerActive = true
        timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(updateRemainingTimes), userInfo: nil, repeats: true)
        updateRemainingTimes()
    }

    /// Stops the timer if it is running.
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        isTimerActive = false
    }

    /// Updates the remaining time until the pickup flight time and refreshes the formatted display strings.
    @objc private func updateRemainingTimes() {
        let now = Date()

        // Update time until pickup
        remainingTime = flightStartTimeUTC.timeIntervalSince(now)
        timeUntilPickup = formatTimeInterval(remainingTime)

        // Update time until landing
        formattedTimeUntilLanding = formatTimeInterval(timeUntilLanding)

        // Update user departure countdown
        let userDepartureCountdown = userDepartureTime.timeIntervalSince(now)
        formattedUserDepartureCountdown = formatTimeInterval(userDepartureCountdown)
    }

    /// Sets the flight start and end times in UTC, calculates the flight duration, and converts times to local.
    /// - Parameters:
    ///   - startTimeUTC: The scheduled start time of the flight in UTC.
    ///   - endTimeUTC: The scheduled end time of the flight in UTC.
    ///   - departureTimeZone: The timezone of the departure location.
    ///   - arrivalTimeZone: The timezone of the arrival location.
    func setFlightTimes(startTimeUTC: Date, endTimeUTC: Date, departureTimeZone: TimeZone, arrivalTimeZone: TimeZone) {
        flightStartTimeUTC = startTimeUTC
        flightEndTimeUTC = endTimeUTC
        flightDuration = endTimeUTC.timeIntervalSince(startTimeUTC)
        self.departureTimeZone = departureTimeZone
        self.arrivalTimeZone = arrivalTimeZone

        // Convert UTC to local times
        flightStartTimeLocal = convertToTimeZone(date: flightStartTimeUTC, timeZone: departureTimeZone)
        flightEndTimeLocal = convertToTimeZone(date: flightEndTimeUTC, timeZone: arrivalTimeZone)

        updateRemainingTimes()
    }

    /// Updates time properties based on the flight data object.
    private func updateTimePropertiesFromFlightData() {
        guard let departure = flightData.departure,
              let arrival = flightData.arrival else {
            return
        }
        
        let departureTimeUTCString = departure.scheduledTime.utc
        let arrivalTimeUTCString = arrival.scheduledTime.utc
        
        guard let departureTimeUTC = dateFromUTCString(departureTimeUTCString),
              let arrivalTimeUTC = dateFromUTCString(arrivalTimeUTCString) else {
            return
        }
        
        // Fetch departure and arrival time zones
        fetchTimeZone(latitude: departure.airport.location.lat, longitude: departure.airport.location.lon) { departureTimeZone in
            self.fetchTimeZone(latitude: arrival.airport.location.lat, longitude: arrival.airport.location.lon) { arrivalTimeZone in
                DispatchQueue.main.async {
                    self.setFlightTimes(startTimeUTC: departureTimeUTC, endTimeUTC: arrivalTimeUTC,
                                        departureTimeZone: departureTimeZone ?? TimeZone.current,
                                        arrivalTimeZone: arrivalTimeZone ?? TimeZone.current)
                    self.startTimer() // Start the timer
                }
            }
        }
    }

    /// Sets the user's departure time based on their travel time to the Froop destination.
    /// - Parameters:
    ///   - currentUserLocation: The current location of the user.
    ///   - froopDestination: The coordinate of the Froop destination.
    func setUserDepartureTime(from currentUserLocation: CLLocationCoordinate2D, to froopDestination: CLLocationCoordinate2D) {
        LocationManager.shared.calculateTravelTime(from: currentUserLocation, to: froopDestination) { travelTime in
            guard let travelTime = travelTime else { return }
            let travelTimeInSeconds = TimeInterval(travelTime)
            
            // Calculate user departure time
            let userDepartureTime = self.flightStartTimeUTC.addingTimeInterval(-travelTimeInSeconds)
            DispatchQueue.main.async {
                self.userDepartureTime = userDepartureTime
                self.updateRemainingTimes() // Call `updateRemainingTimes` instead of `updateRemainingTime`
            }
        }
    }

    /// Formats the time interval to a string like "2h 30m".
    /// - Parameter interval: The time interval in seconds.
    /// - Returns: A formatted string representing the interval.
    private func formatTimeInterval(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        return "\(max(hours, 0))h \(max(minutes, 0))m"
    }
    
    private func formatLeaveTimeInterval(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 60
        let minutes = Int(interval) % 60
        return "\(max(hours, 0))h \(max(minutes, 0))m"
    }

    /// Converts a date to a specified timezone.
    /// - Parameters:
    ///   - date: The date to convert.
    ///   - timeZone: The target timezone.
    /// - Returns: A date object in the target timezone.
    private func convertToTimeZone(date: Date, timeZone: TimeZone) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = timeZone
        let dateString = formatter.string(from: date)
        formatter.timeZone = TimeZone.current
        return formatter.date(from: dateString) ?? date
    }

    /// Formats a date to a specified string format.
    /// - Parameters:
    ///   - date: The date to format.
    ///   - format: The desired date format.
    ///   - timeZone: The timezone for the output string.
    /// - Returns: A formatted date string.
    func formatDate(_ date: Date, format: String = "yyyy-MM-dd HH:mmZ", timeZone: TimeZone = TimeZone.current) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = timeZone
        return formatter.string(from: date)
    }

    /// Parses a UTC string into a Date object.
    /// - Parameter utcString: A UTC string like "2024-05-08 13:00Z".
    /// - Returns: A Date object, or nil if parsing fails.
    func dateFromUTCString(_ utcString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mmZ"
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter.date(from: utcString)
    }

    /// Calculates the flight duration between two time strings in UTC format.
    /// - Parameters:
    ///   - departureTime: The departure time in UTC format.
    ///   - arrivalTime: The arrival time in UTC format.
    /// - Returns: The duration in seconds, or nil if calculation fails.
    func calculateFlightDuration(departureTime: String, arrivalTime: String) -> TimeInterval? {
        guard let departureDate = dateFromUTCString(departureTime),
              let arrivalDate = dateFromUTCString(arrivalTime) else {
            return nil
        }
        return arrivalDate.timeIntervalSince(departureDate)
    }

    /// Formats a flight duration in seconds into a string like "5h 25m".
    /// - Parameter duration: The flight duration in seconds.
    /// - Returns: A formatted string representing the duration.
    func formattedFlightDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }

    /// Fetches the timezone information for given coordinates.
    /// - Parameters:
    ///   - latitude: Latitude of the location.
    ///   - longitude: Longitude of the location.
    ///   - completion: Closure to return the result asynchronously.
    func fetchTimeZone(latitude: Double, longitude: Double, completion: @escaping (TimeZone?) -> Void) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            guard error == nil, let placemark = placemarks?.first, let timeZone = placemark.timeZone else {
                completion(nil)
                return
            }
            completion(timeZone)
        }
    }
}
