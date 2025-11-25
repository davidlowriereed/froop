//
//  TripLocationsView.swift
//  FroopProof
//
//  Created by David Reed on 1/20/23.
//

import SwiftUI
import CoreLocation
import MapKit

struct TripLocationsView: View {
    
    
    @ObservedObject var myData = MyData.shared
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var locationManager = LocationManager.shared
    @ObservedObject var vm = LocationSearchViewModel.shared

    // @ObservedObject var froopDataListener = FroopDataListener.shared
    @ObservedObject var froopData = FroopData.shared
    @EnvironmentObject var viewModel: LocationSearchViewModel
    
    @State private var addressString: String = "Loading address..."
    @State var distance: Double = 0.0
    
    var distanceInKm: Double {
        return distance / 1000
    }
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                VStack {
                    VStack {
                        Rectangle()
                            .foregroundColor(.primary)
                            .frame(width: 8, height: 8)
                        
                        Rectangle()
                            .frame(width: 1, height: 60)
                            .foregroundColor(.primary)
                        
                        Circle()
                            .frame(width: 8, height: 8)
                            .foregroundColor(.primary)
                        Spacer()
                        
                    }
                    .padding(.top, UIScreen.screenWidth * 0.025)
                    .padding(.leading, 25)
                    
                }
                .frame(width: UIScreen.screenWidth * 0.1, height: UIScreen.screenHeight * 0.3)
//                .border(.red, width: 2)
                
                
                VStack(alignment: .leading) {
                    
                    Text(froopData.froopLocationtitle)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                        .padding(.bottom, 2)
                    
                    Text(froopData.froopLocationsubtitle)
                        .font(.system(size: 16, weight: .light))
                        .foregroundColor(.primary)
                        .lineLimit(2, reservesSpace: true)
                        .padding(.bottom, 6)
                        .padding(.trailing, 15)
                    
                    Text("Current Location")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                        .padding(.top, 1)
                        .padding(.bottom, 2)
                    
                    Text(locationManager.addressString)
                        .font(.system(size: 16, weight: .light))
                        .foregroundColor(.primary)
                        .lineLimit(2, reservesSpace: true)
                        .padding(.trailing, 15)
                        .onAppear {
                            if let userLocation = locationManager.userLocation {
                                locationManager.getAddress(from: userLocation)
                            } else {
                                addressString = "User location not available."
                            }
                        }
                    
                    HStack {
                        Text("Distance: \(String(format: "%.2f", calculateDistance() / 1609.34))")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Text("Driving Time: \(String(format: "%.0f", (vm.route?.expectedTravelTime ?? 0.0) / 60)) min")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.primary)
                            .padding(.leading, 15)
                    }
                    .padding(.top, 1)

                    Spacer()
                }
                .frame(width: UIScreen.screenWidth * 0.9, height: UIScreen.screenHeight * 0.3)
//                .border(.green, width: 2)
                
                
            }
            .frame(height: UIScreen.screenHeight * 0.4)
//            .border(.purple, width: 3)
            .onAppear {
                locationManager.calculateTravelTime(from: myData.coordinate, to: froopData.froopLocationCoordinate) { travelTime in
                    if let travelTime = travelTime {
                        // convert travel time to minutes
                        let travelTimeMinutes = Double(travelTime / 60)
                        distance = travelTimeMinutes
                    }
                }
            }
            Spacer()
        }
    }
    func calculateDistance() -> Double {
//        print("-TripLocationView: Function: calculateDistance is firing!")
        guard let userLocation = LocationManager.shared.userLocation, froopData.froopLocationCoordinate.latitude != 0, froopData.froopLocationCoordinate.longitude != 0 else { return 0 }
        let userCoordinate = CLLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let location = CLLocation(latitude: froopData.froopLocationCoordinate.latitude, longitude: froopData.froopLocationCoordinate.longitude)
        let distanceInMeters = userCoordinate.distance(from: location)
        return distanceInMeters
    }
}
