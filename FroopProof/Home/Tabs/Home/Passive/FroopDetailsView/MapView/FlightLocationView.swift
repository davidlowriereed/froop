//
//  TripLocationView.swift
//  FroopProof
//
//  Created by David Reed on 1/20/23.
//

import SwiftUI
import CoreLocation
import MapKit

struct FlightLocationView: View {
    @Environment(\.colorScheme) var colorScheme

    @ObservedObject var myData = MyData.shared
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var locationManager = LocationManager.shared
    @ObservedObject var froopManager = FroopManager.shared
    @ObservedObject var froopData = FroopData.shared
    @ObservedObject var timeZoneManager = TimeZoneManager.shared
    @ObservedObject var flightManager = FroopFlightDataManager.shared
    @State var distance: Double = 0.0
    
    @State private var formattedDateString: String = ""

  
    
    var distanceInKm: Double {
        return distance / 1000
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                
                
                HStack {
                    Spacer()
                    Text(formattedDateString)
                        .font(.system(size: 16))
                        .foregroundColor(colorScheme == .dark ? .white : Color(red: 50/255, green: 46/255, blue: 62/255))
                        .fontWeight(.semibold)
                    Spacer()
                }
                
                HStack {

                    Text("Flight \(froopManager.selectedFroopHistory.flightData.number ?? "") Arriving:")
                        .font(.system(size: 16))
                        .foregroundColor(colorScheme == .dark ? .white : Color(red: 50/255, green: 46/255, blue: 62/255))
                        .fontWeight(.semibold)
                    
                    Spacer()
                    

                    Text("\(timeZoneManager.formatTime(for: flightManager.dateFromUTCString(froopManager.selectedFroopHistory.flightData.arrival?.scheduledTime.utc ?? "") ?? Date(), in: TimeZone(identifier: froopManager.selectedFroopHistory.flightData.arrival?.airport.localTimeZoneIdentifier ?? "") ?? TimeZone.current))")
                        .font(.system(size: 16))
                        .fontWeight(.semibold)
                        .foregroundColor(colorScheme == .dark ? .white : Color(red: 50/255, green: 46/255, blue: 62/255))
                }
                .padding(.top, 5)
                
             
                    
                HStack {
                    Text("Leave for Pickup at:")
                        .font(.system(size: 16))
                        .foregroundColor(colorScheme == .dark ? .white : Color(red: 50/255, green: 46/255, blue: 62/255))
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    
                    let arrivalDate = flightManager.dateFromUTCString(froopManager.selectedFroopHistory.flightData.arrival?.scheduledTime.utc ?? "") ?? Date()
                    let timeZone = TimeZone(identifier: froopManager.selectedFroopHistory.flightData.arrival?.airport.localTimeZoneIdentifier ?? "") ?? TimeZone.current
                    let suggestedDepartureTime = Calendar.current.date(byAdding: .minute, value: -Int(distance), to: arrivalDate)
                    
                    Text(timeZoneManager.formatTime(for: suggestedDepartureTime ?? Date(), in: timeZone))
                        .font(.system(size: 16))
                        .foregroundColor(colorScheme == .dark ? .white : Color(red: 50/255, green: 46/255, blue: 62/255))
                        .fontWeight(.semibold)
                    
                }
                .padding(.top, 5)
                
                Divider()
                    .padding(.top, 5)

                HStack {
                    Text("Travel Time to Airport:")
                        .font(.system(size: 14))
                        .foregroundColor(colorScheme == .dark ? .white : Color(red: 50/255, green: 46/255, blue: 62/255))
                        .fontWeight(.light)
                    
                    Spacer()
                    
                    Text("\(String(format: "%.0f", distance)) minutes")
                        .font(.system(size: 14))
                        .foregroundColor(colorScheme == .dark ? .white : Color(red: 50/255, green: 46/255, blue: 62/255))
                        .fontWeight(.light)
                }
                                .padding(.top, 5)

                HStack {
                    Text("Current Travel Distance:")
                        .font(.system(size: 14))
                        .foregroundColor(colorScheme == .dark ? .white : Color(red: 50/255, green: 46/255, blue: 62/255))
                        .fontWeight(.light)
                    
                    Spacer()
                    
                    Text("\(String(format: "%.2f", calculateDistance() / 1609.34)) miles")
                        .font(.system(size: 14))
                        .foregroundColor(colorScheme == .dark ? .white : Color(red: 50/255, green: 46/255, blue: 62/255))
                        .fontWeight(.light)
                }
                //                .padding(.top, 5)
                
                
                
                
                
                
                
                
                
                Spacer()
            }
            //            Spacer()
        }
        .frame(height: UIScreen.screenHeight * 0.25)
        .padding(.top, 5)
        //        .padding(.leading, 25)
        //        .padding(.leading, 25)
        
        .onAppear {
            locationManager.calculateTravelTime(from: myData.coordinate, to: froopManager.selectedFroopHistory.froop.froopLocationCoordinate ) { travelTime in
                if let travelTime = travelTime {
                    // convert travel time to minutes
                    let travelTimeMinutes = Double(travelTime / 60)
                    distance = travelTimeMinutes
                }
            }
            
            formattedDateString = timeZoneManager.formatFlightDateDetail(passedDate: froopManager.selectedFroopHistory.froop.froopStartTime)
            
            let flightNumber = froopManager.selectedFroopHistory.flightData.number
            let date = flightManager.formatDateForJSON(date: froopManager.selectedFroopHistory.froop.froopStartTime)
            Task {
                await FroopFlightDataManager.shared.fetchAndUpdateFlightDetails(for: flightNumber ?? "", date: date, in: froopManager.selectedFroopHistory)
            }
            
        }
        
    }
    func calculateDistance() -> Double {
        //        print("-TripLocationView: Function: calculateDistance is firing!")
        guard let userLocation = LocationManager.shared.userLocation, froopManager.selectedFroopHistory.froop.froopLocationCoordinate.latitude != 0, froopManager.selectedFroopHistory.froop.froopLocationCoordinate.longitude != 0 else { return 0 }
        let userCoordinate = CLLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let location = CLLocation(latitude: froopManager.selectedFroopHistory.froop.froopLocationCoordinate.latitude , longitude: froopManager.selectedFroopHistory.froop.froopLocationCoordinate.longitude )
        let distanceInMeters = userCoordinate.distance(from: location)
        return distanceInMeters
    }
}
