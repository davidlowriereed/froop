//
//  FroopFlightDataManager.swift
//  FroopProof
//
//  Created by David Reed on 4/12/24.
//

import Foundation
import Combine
import FirebaseFirestore
import CoreLocation
import SwiftUI

class FroopFlightDataManager: ObservableObject {
    static let shared = FroopFlightDataManager()
    
    @Published var flightDetails: [ScheduledFlightAPI.FlightDetail] = []
    @Published var airlineCodes = AirlineCodes()
    @Published var airportCodes = AirportCodes()

    @Published var flightNumber: String = ""
    @Published var flightNumberText: String = ""
    @Published var flightCarrierText: String = ""
    @Published var flights: [ScheduledFlightAPI.FlightDetail] = []
    @Published var departureAirport: String = ""
    @Published var arrivalAirport: String = ""
    @Published var arrivalAirportText: String = ""
    @Published var flightCarrier: String = ""
    @Published var flightNum: String = ""
    
    @Published var activeFlight: ActiveFlightAPI.FlightData = ActiveFlightAPI.FlightData.empty()
    @Published var flightSearchResults: [String] = []
    @Published var airportSearchResults: [String] = []
    @Published var airportCode = ""
    @Published var airportName: String = "Enter Destination Airport Code"
    @Published var airlineCode: String = ""
    @Published var airlineName: String = "Enter Flight Number"
    @Published var flightNumberTextFieldValue: String = ""
    @Published var airportCodeTextFieldValue: String = ""
    
    @Published var showDestination: Bool = false
    @Published var list1Manage: Bool = false
    @Published var list2Manage: Bool = false
    @Published var disableAirportText: Bool = false
    @Published var showFlightData: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    @Published var showAlert = false
    @Published var isAirportPickup: Bool = false
    @Published var locDerivedTitle: String? = nil
    @Published var locDerivedSubtitle: String? = nil
    @Published var flightioData: ActiveFlightAPI.FlightData = ActiveFlightAPI.FlightData.empty()
    
    @Published var realTimeFlightDetails: ActiveFlightAPI.FlightData?
    @Published var currentFlightData: ScheduledFlightAPI.FlightDetail = ScheduledFlightAPI.FlightDetail.empty()
    @Published var thisFlightStart: Date = Date()
    @Published var thisFlightEnd: Date = Date()

    private var fetchTimer: Timer?
    
    var timeZoneManager: TimeZoneManager {
        return TimeZoneManager.shared
    }

    // Constants for API access
    private let session: URLSession
    private let baseURL = URL(string: "https://aerodatabox.p.rapidapi.com")!
    private let apiKey = Secrets.rapidAPI
    private let apiHost = "aerodatabox.p.rapidapi.com"
    private var cancellables = Set<AnyCancellable>()
        
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func fetchAirlineioData(flightNumber: String, airlineCode: String, date: String, completion: @escaping (Result<ActiveFlightAPI.FlightData, Error>) -> Void) {
        let apiKey = Secrets.flightioAPI
        let urlString = "https://api.flightapi.io/airline/6537facc0175698b26894ef8d67bc?num=33&name=DL&date=20231024"
//        "https://api.flightapi.io/airline/\(apiKey)?num=\(flightNumber)&name=\(airlineCode)&date=\(date)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "FlightDataManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        print("🦁 \(url)")
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "FlightDataManager", code: -2, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            print("🦁🦁 \(data as Any)")

            do {
                let decodedData = try JSONDecoder().decode(ActiveFlightAPI.FlightData.self, from: data)
                completion(.success(decodedData))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func startFetchingFlightData(flightIata: String) {
        stopFetchingFlightData() // Ensures to stop an existing timer if any
        
        fetchTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            self?.fetchActiveFlightData(flightIata: flightIata) { result in
                DispatchQueue.main.async {
                    switch result {
                        case .success(let flights):
                            if let firstFlight = flights.first {
                                self?.activeFlight = firstFlight
                            }
                        case .failure(let error):
                            print("Failed to fetch active flight data: \(error)")
                    }
                }
            }
        }
    }
    
    func stopFetchingFlightData() {
        fetchTimer?.invalidate()
        fetchTimer = nil
    }
    
    func updateRealTimeFlightDetails(flightNumber: String) {
        Task {
            do {
                let flightDetails = try await fetchAerodataboxFlightData(flightNumber: flightNumber)
                DispatchQueue.main.async {
                    self.realTimeFlightDetails = flightDetails
                }
            } catch {
                print("Error fetching real-time flight details: \(error)")
            }
        }
    }

    func fetchAerodataboxFlightData(flightNumber: String) async throws -> ActiveFlightAPI.FlightData {
        let endpoint = "flights"
        let urlString = "\(baseURL)/\(endpoint)?key=\(apiKey)&flightIata=\(flightNumber)"
        
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "Invalid URL", code: -1001, userInfo: nil)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "HTTP Error", code: (response as? HTTPURLResponse)?.statusCode ?? 500, userInfo: nil)
        }
        
        // Assuming ActiveFlightAPI.FlightData matches the expected data structure
        let flightData = try JSONDecoder().decode(ActiveFlightAPI.FlightData.self, from: data)
        return flightData
    }

    // Function to fetch flight details
    func fetchActiveFlightData(airportCode: String? = nil, airlineCode: String? = nil, flightIata: String? = nil, completion: @escaping (Result<[ActiveFlightAPI.FlightData], Error>) -> Void) {
        print("💠\(String(describing: flightIata))")
        let apiKey = Secrets.aviationEdgeAPI
        let baseUrl: String = "https://aviation-edge.com/v2/public/"
        
        var urlString = "\(baseUrl)flights?key=\(apiKey)"
        
        if let airportCode = airportCode {
            urlString += "&depIata=\(airportCode)"
        }
        if let airlineCode = airlineCode {
            urlString += "&airlineIata=\(airlineCode)"
        }
        if let flightIata = flightIata {
            let cleanedFlightIata = flightIata.replacingOccurrences(of: " ", with: "") // Remove spaces from flightIata
            urlString += "&flightIata=\(cleanedFlightIata)"
        }
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "InvalidURL", code: 1, userInfo: nil)))
            return
        }
        print("💠 URL ACTIVE FLIGHT: \(url)")
        URLSession.shared.dataTask(with: url) { data, response, error in
            print("💠💠\(response as Any)")
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "DataNilError", code: 2, userInfo: nil)))
                return
            }
            
            do {
                let flights = try JSONDecoder().decode([ActiveFlightAPI.FlightData].self, from: data)
                completion(.success(flights))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchFlightDetails(for flightNumber: String, date: String, completion: @escaping (Result<[ScheduledFlightAPI.FlightDetail], Error>) -> Void) {
        let urlString = "https://aerodatabox.p.rapidapi.com/flights/number/\(flightNumber)/\(date)?withAircraftImage=true&withLocation=true"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "URLCreationError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: "X-RapidAPI-Key")
        request.setValue("aerodatabox.p.rapidapi.com", forHTTPHeaderField: "X-RapidAPI-Host")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
               if let error = error {
                   completion(.failure(error))
                   return
               }
               
               guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                   completion(.failure(NSError(domain: "HTTPError", code: -2, userInfo: [NSLocalizedDescriptionKey: "Non-200 HTTP response"])))
                   return
               }
               
               guard let data = data else {
                   completion(.failure(NSError(domain: "DataError", code: -3, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                   return
               }
               
               do {
                   let flights = try JSONDecoder().decode([ScheduledFlightAPI.FlightDetail].self, from: data)
                   self.updateTimeZonesForFlights(flights: flights) { result in
                       switch result {
                       case .success(let updatedFlights):
                           completion(.success(updatedFlights))
                       case .failure(let error):
                           completion(.failure(error))
                       }
                   }
               } catch {
                   completion(.failure(error))
               }
           }.resume()
    }
    
    func updateTimeZonesForFlights(flights: [ScheduledFlightAPI.FlightDetail], completion: @escaping (Result<[ScheduledFlightAPI.FlightDetail], Error>) -> Void) {
        let updatedFlights = flights
        let group = DispatchGroup()

        for index in updatedFlights.indices {
            group.enter()
            let flight = updatedFlights[index]
            TimeZoneManager.shared.updateTimeZonesForFlight(
                departureLat: flight.departure?.airport.location.lat ?? 0.0,
                departureLon: flight.departure?.airport.location.lon ?? 0.0,
                arrivalLat: flight.arrival?.airport.location.lat ?? 0.0,
                arrivalLon: flight.arrival?.airport.location.lon ?? 0.0,
                apiKey: Secrets.googleTimeZoneAPI
            ) { departingTimeZone, arrivingTimeZone, error in
                if let error = error {
                    completion(.failure(error))
                    group.leave()
                    return
                }
                updatedFlights[index].departure?.airport.localTimeZoneIdentifier = departingTimeZone?.timeZoneId
                updatedFlights[index].arrival?.airport.localTimeZoneIdentifier = arrivingTimeZone?.timeZoneId
                group.leave()
            }
        }

        group.notify(queue: .main) {
            completion(.success(updatedFlights))
        }
    }
    
    func fetchAddressTitleAndSubtitle(for coordinate: CLLocationCoordinate2D) async -> (title: String?, subtitle: String?) {
        // Guard to check if the coordinate is valid
        guard CLLocationCoordinate2DIsValid(coordinate) else {
            print("Invalid coordinate")
            return (nil, nil)
        }

        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let geocoder = CLGeocoder()
        
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            let placemark = placemarks.first
            
            let title = placemark?.name
            let subtitleComponents = [placemark?.locality, placemark?.administrativeArea]
                .compactMap { $0 }
                .joined(separator: ", ")
            
            return (title, subtitleComponents.isEmpty ? nil : subtitleComponents)
        } catch {
            print("Failed to fetch address: \(error)")
            return (nil, nil)
        }
    }
    
    func fetchFlightDetails(for flightNumber: String, date: String) async throws -> [ScheduledFlightAPI.FlightDetail] {
        let urlString = "https://aerodatabox.p.rapidapi.com/flights/number/\(flightNumber)/\(date)?withAircraftImage=true&withLocation=true"
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "Invalid URL", code: -1001, userInfo: nil)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(Secrets.rapidAPI, forHTTPHeaderField: "X-RapidAPI-Key")
        request.setValue("aerodatabox.p.rapidapi.com", forHTTPHeaderField: "X-RapidAPI-Host")

        let (data, response) = try await URLSession.shared.data(for: request)
        print("DATA: \(String(describing: response))")

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "Received non-200 HTTP response", code: -1002, userInfo: nil)
        }

        do {
            // Log the raw JSON response
            if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) {
                print("Raw JSON Response: \(json)")
            }

            let decodedFlights = try JSONDecoder().decode([ScheduledFlightAPI.FlightDetail].self, from: data)

            await MainActor.run {
                self.isLoading = false
                self.flights = decodedFlights
                self.showFlightData = true
            }
            return decodedFlights
        } catch {
            await MainActor.run {
                self.isLoading = false
            }
            print("Decoding Error: \(error)")
            throw error
        }
    }
    
    func dateFromLocalString(_ localString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mmZ"
        return dateFormatter.date(from: localString)
    }
    
    func dateFromUTCString(_ utcString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mmZ"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return dateFormatter.date(from: utcString)
    }
        
    func formatTime(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        return dateFormatter.string(from: date)
    }
    
    func formatDateForJSON(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"  // Set the date format to what your API expects
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)  // Adjust if your API expects the date in UTC
        return dateFormatter.string(from: date)
    }
    
    func convertToDate(from dateString: String, timeZoneIdentifier: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ" // Adjust this to match your API
        if let timeZone = TimeZone(identifier: timeZoneIdentifier) {
            formatter.timeZone = timeZone
        }
        return formatter.date(from: dateString)
    }
    
}








