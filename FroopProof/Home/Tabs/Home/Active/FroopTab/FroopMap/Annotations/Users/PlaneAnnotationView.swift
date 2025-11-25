//
//  PlaneAnnotationView.swift
//  FroopProof
//
//  Created by David Reed on 5/9/24.
//

import SwiftUI
import MapKit
import CoreLocation

struct PlaneAnnotationView: View {
    @ObservedObject var dataController = DataController.shared
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var locationManager = LocationManager.shared
    @ObservedObject var mapManager = MapManager.shared
    @ObservedObject var flightManager = FroopFlightDataManager.shared
    @ObservedObject var timeZoneManager = TimeZoneManager.shared
    @ObservedObject var flightTimeManager = FlightTimeManager.shared
    let departureCoordinate: CLLocationCoordinate2D
    let arrivalCoordinate: CLLocationCoordinate2D
    @State var flightETA: Double = 0.0
    @State var arrivalTime: String = ""
    @State private var formattedDateString: String = ""
    @State private var arrivalTZ: String = ""
    @State private var departureTZ: String = ""
    @State var bearing: Double = 0.0
    @State var test: Date = Date()
    
    let now = Date()
    
    @State private var planeRotation: Double = 0.0
    
    var body: some View {
        ZStack {
            Image(systemName: "airplane")
                .font(.system(size: 32))
                .foregroundColor(.white)
                .rotationEffect(.degrees(bearing - 90))
                .shadow(color: Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.5), radius: 2, x: 1, y: 1)
                .shadow(color: Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.5), radius: -2, x: -1, y: -1)
               
            ZStack {
                Rectangle()
                    .frame(width: 100, height: 25)
                    .foregroundColor(.white)
                    .border(.green, width: 0.5)
                    .opacity(0.75)
                Text("ETA: \(flightTimeManager.formattedTimeUntilLanding)")
                    .font(.system(size: 12))
                    .fontWeight(.semibold)
                    .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                    .multilineTextAlignment(.leading)
                
            }
            .opacity(flightETA < 1 ? 1 : 1.0)
            .offset(y: 50)
        }
        .onAppear{
            bearing = getBearingBetweenTwoPoints1(point1: departureCoordinate, point2: arrivalCoordinate)
            print("PLANE ROTATION: \(planeRotation)")
            if appStateManager.aFHI >= 0 && appStateManager.aFHI < appStateManager.currentFilteredFroopHistory.count {
                
                formattedDateString = timeZoneManager.formatFlightDateDetail(passedDate: flightManager.dateFromLocalString(appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.flightData.arrival?.revisedTime?.local ?? "") ?? Date())
                
                let flightNumber = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.flightData.number
                let date = flightManager.formatDateForJSON(date: appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopStartTime ?? Date())
                Task {
                    await FroopFlightDataManager.shared.fetchAndUpdateFlightDetails(for: flightNumber ?? "", date: date, in: appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI] ??
                                                                                    FroopHistory(
                                                                                        froop: Froop(dictionary: [:]) ?? Froop(dictionary: [:]) ?? Froop.emptyFroop(),
                                                                                        host: UserData(),
                                                                                        invitedFriends: [],
                                                                                        confirmedFriends: [],
                                                                                        declinedFriends: [],
                                                                                        pendingFriends: [],
                                                                                        images: [],
                                                                                        videos: [],
                                                                                        froopGroupConversationAndMessages: ConversationAndMessages(conversation: Conversation(), messages: [], participants: []), froopMediaData: FroopMediaData(
                                                                                            froopImages: [],
                                                                                            froopDisplayImages: [],
                                                                                            froopThumbnailImages: [],
                                                                                            froopIntroVideo: "",
                                                                                            froopIntroVideoThumbnail: "",
                                                                                            froopVideos: [],
                                                                                            froopVideoThumbnails: []
                                                                                        ),
                                                                                        flightData: ScheduledFlightAPI.FlightDetail.empty()
                                                                                    )
                    )
                }
                arrivalTZ = getArrivalTZ()
                departureTZ = getDepartureTZ()
                if appStateManager.aFHI >= 0 && appStateManager.aFHI < appStateManager.currentFilteredFroopHistory.count {
                    test = flightManager.convertToDate(from: appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.flightData.arrival?.revisedTime?.utc ?? "", timeZoneIdentifier: getArrivalTZ()) ?? Date()
                }
                
            }
            
        }
        .onChange(of: departureCoordinate) {
            bearing = getBearingBetweenTwoPoints1(point1: departureCoordinate, point2: arrivalCoordinate)
        }
    }
    
    
    
    func degreesToRadians(degrees: Double) -> Double {
        return degrees * .pi / 180.0
    }
    func radiansToDegrees(radians: Double) -> Double {
        return radians * 180.0 / .pi
    }
    func normalizeBearing(degrees: Double) -> Double {
        return (degrees + 360).truncatingRemainder(dividingBy: 360)
    }
    func getBearingBetweenTwoPoints1(point1: CLLocationCoordinate2D, point2: CLLocationCoordinate2D) -> Double {
        let lat1 = degreesToRadians(degrees: point1.latitude)
        let lon1 = degreesToRadians(degrees: point1.longitude)

        let lat2 = degreesToRadians(degrees: point2.latitude)
        let lon2 = degreesToRadians(degrees: point2.longitude)

        let dLon = lon2 - lon1

        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radiansBearing = atan2(y, x)

        // Convert to degrees and normalize to [0, 360)
        let bearing = radiansToDegrees(radians: radiansBearing)
        print("GET BEARING: \(normalizeBearing(degrees: bearing))")

        return normalizeBearing(degrees: bearing)
    }
    func getDepartureTZ() -> String {
        guard let timeZoneIdentifier = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.flightData.departure?.airport.localTimeZoneIdentifier else {
            return "Unknown Time Zone"
        }

        return timeZoneManager.timeZoneAbbreviation(from: timeZoneIdentifier)
    }
    func getArrivalTZ() -> String {
        guard let timeZoneIdentifier = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.flightData.arrival?.airport.localTimeZoneIdentifier else {
            return "Unknown Time Zone"
        }

        return timeZoneManager.timeZoneAbbreviation(from: timeZoneIdentifier)
    }
}
