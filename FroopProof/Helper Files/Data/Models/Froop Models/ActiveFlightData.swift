struct ActiveFlightAPI {
    
    struct FlightData: Codable {
        let aircraft: Aircraft?
        let airline: Airline?
        let arrival: Airport?
        let departure: Airport?
        let flight: FlightInfo?
        let geography: Geography?
        let speed: Speed?
        let status: String?
        let system: SystemInfo?
        
        static func empty() -> FlightData {
            return FlightData(
                aircraft: Aircraft(iataCode: nil, icao24: nil, icaoCode: nil, regNumber: nil),
                airline: Airline(iataCode: nil, icaoCode: nil),
                arrival: Airport(iataCode: nil, icaoCode: nil),
                departure: Airport(iataCode: nil, icaoCode: nil),
                flight: FlightInfo(iataNumber: nil, icaoNumber: nil, number: nil),
                geography: Geography(altitude: nil, direction: nil, latitude: nil, longitude: nil),
                speed: Speed(horizontal: nil, isGround: nil, vspeed: nil),
                status: nil,
                system: SystemInfo(squawk: nil, updated: nil)
            )
        }
    }
    
    struct Aircraft: Codable {
        let iataCode: String?
        let icao24: String?
        let icaoCode: String?
        let regNumber: String?
    }
    
    struct Airline: Codable {
        let iataCode: String?
        let icaoCode: String?
    }
    
    struct Airport: Codable {
        let iataCode: String?
        let icaoCode: String?
    }
    
    struct FlightInfo: Codable {
        let iataNumber: String?
        let icaoNumber: String?
        let number: String?
    }
    
    struct Geography: Codable {
        let altitude: Double?
        let direction: Double?
        let latitude: Double?
        let longitude: Double?
    }
    
    struct Speed: Codable {
        let horizontal: Double?
        let isGround: Int?
        let vspeed: Double?
    }
    
    struct SystemInfo: Codable {
        let squawk: String?
        let updated: Int?
    }
}
