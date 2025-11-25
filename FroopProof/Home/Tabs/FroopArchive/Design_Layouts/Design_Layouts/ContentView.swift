//
//  ContentView.swift
//  Design_Layouts
//
//  Created by David Reed on 6/11/23.
//

import SwiftUI
import UIKit
import Combine
import Foundation
import MapKit


struct ContentView: View {
    //    @ObservedObject var mapManager = MapManager.shared
    @State private var isMapDraggable = true
    @State private var mapSelection: String?
    @State var testLocation: CLLocationCoordinate2D = CLLocationCoordinate2D()
    @State var lat: Double = 0.0
    @State var lon: Double = 0.0
    @State var annotationId: Int = 12345
    @State var transClock: Bool = false
    @State var datePicked: Bool = false
    @State var dateSelected: Date = Date()
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)
                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))

            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text("EWR")
                            .font(.system(size: 32))
                            .fontWeight(.bold)
                        Text("Newark")
                    }
                    .foregroundColor(.white)
                    .padding(.leading, 20)
                    
                    Spacer()
                    
                    VStack(alignment: .center) {
                        Image(systemName: "airplane.departure")
                            .foregroundColor(Color(red: 100/255, green: 255/255, blue:0/255))
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("DTW")
                            .font(.system(size: 32))
                            .fontWeight(.bold)
                        Text("Detroit")
                    }
                    .foregroundColor(.white)
                    .padding(.trailing, 20)
                }
                .padding(.top, 25)
                
                HStack {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("American Airlines")
                                .font(.system(size: 20))
                                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                            Spacer()
                            Text("AA2561")
                                .font(.system(size: 16))
                                .fontWeight(.bold)
                                .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255))
                        }
                        Text("Airbus A319")
                            .font(.system(size: 14))
                            .fontWeight(.regular)
                    }
                    .frame(height: 35)

                }
                .foregroundColor(.white)
                .padding(.top, 20)
                .padding(.leading, 20)
                .padding(.trailing, 20)
                
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Departing")
                            .font(.system(size: 14))
                            .fontWeight(.semibold)
                        
                        Text("06:50 pm")
                            .font(.system(size: 12))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(red: 100/255, green: 255/255, blue:0/255))

                        Text("Local Time")
                            .font(.system(size: 10))
                            .fontWeight(.regular)

                        Text("Scheduled")
                            .font(.system(size: 12))
                            .fontWeight(.regular)
                            .padding(.top, 25)
                        
                        Text("06:50 pm")
                            .font(.system(size: 12))
                            .fontWeight(.regular)
                            .foregroundColor(Color(red: 255/255, green: 255/255, blue:0/255))

                    }
                    .foregroundColor(.white)
                    .padding(.leading, 20)
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 5) {
                        Text("Arriving")
                            .font(.system(size: 14))
                            .fontWeight(.semibold)
                        
                        Text("06:50 pm")
                            .font(.system(size: 12))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(red: 100/255, green: 255/255, blue:0/255))
                        
                        Text("Local Time")
                            .font(.system(size: 10))
                            .fontWeight(.regular)
                        
                        Text("Scheduled")
                            .font(.system(size: 12))
                            .fontWeight(.regular)
                            .padding(.top, 25)
                        
                        Text("06:50 pm")
                            .font(.system(size: 12))
                            .fontWeight(.regular)
                            .foregroundColor(Color(red: 255/255, green: 255/255, blue:0/255))


                    }
                    .foregroundColor(.white)
                    .padding(.trailing, 20)
                }
                .padding(.top, 25)
                
                Spacer()
                VStack (spacing: 2) {
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(Color(red: 231/255, green: 229/255, blue:  236/255))
                        .padding(.leading, 5)
                        .padding(.trailing, 5)
                        .padding(.top, 25)
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color(red: 231/255, green: 229/255, blue:  236/255))
                        .padding(.leading, 25)
                        .padding(.trailing, 25)
                }
                .opacity(0.5)
                Spacer()
                
                HStack {
                    VStack(alignment: .center) {
                        Text("Is this your Flight?")
                            .font(.system(size: 22))
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    
                }
                .padding(.top, 10)
                
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: UIScreen.screenWidth * 0.25, height: 30)
                            .foregroundColor(Color(red: 232/255, green: 234/255, blue:  238/255))

                     Text("Change")
                            .font(.system(size: 12))
                            .fontWeight(.bold)
                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                    }
                    Spacer()
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: UIScreen.screenWidth * 0.25, height: 30)
                            .foregroundColor(Color(red: 232/255, green: 234/255, blue:  238/255))

                     Text("Yes")
                            .font(.system(size: 12))
                            .fontWeight(.bold)
                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                    }

                    
                }
                .padding(.top, 15)
                .padding(.leading, 50)
                .padding(.trailing, 50)
                .padding(.bottom, 50)
            }
        }
        .frame(width: UIScreen.screenWidth * 0.8, height: UIScreen.screenHeight * 0.6)
    }
}
    
    
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

    
    
    
    
    //struct CustomAnnotation: Identifiable {
    //    let id = UUID() // Conformance to Identifiable
    //    var coordinate: CLLocationCoordinate2D
    //}
    //
    //class MapManager: ObservableObject {
    //    static let shared = MapManager()
    //    @Published var annotations: [ActiveGuestAnnotation] = []
    //
    //    @Published var mapSelection: String?
    //    @Published var route: MKRoute?
    //    @Published var routeDestination: MKMapItem?
    //    @Published var cameraPosition: MapCameraPosition = .region(.myRegion)
    //    @Published var mapRegion: MKCoordinateRegion = MKCoordinateRegion.myRegion
    //    @Published var centerLatitude: Double = 0.0
    //    @Published var centerLongitude: Double = 0.0
    //    @Published var refreshMap = false
    //    @Published var routeDisplaying: Bool = false
    //    @Published var equatableCenter: EquatableCoordinate = EquatableCoordinate(coordinate: MKCoordinateRegion.myRegion.center)
    //
    //    @Published var region = MKCoordinateRegion(
    //        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
    //        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    //    )
    //
    //    func moveAnnotation() {
    //        // Example movement: Adjust the latitude and longitude
    //        let newCoordinate = CLLocationCoordinate2D(
    //            latitude: region.center.latitude + 0.01,
    //            longitude: region.center.longitude + 0.01
    //        )
    //        region.center = newCoordinate
    //    }
    //}
    //
    //struct IdentifiableCoordinate: Identifiable {
    //    let id = UUID()
    //    var coordinate: CLLocationCoordinate2D
    //}
    //
    //extension MKCoordinateRegion {
    //    static var myRegion: MKCoordinateRegion {
    //        return .init(center: .myLocation, latitudinalMeters: 1000, longitudinalMeters: 1000)
    //    }
    //}
    //
    //extension CLLocationCoordinate2D {
    //    static var myLocation: CLLocationCoordinate2D {
    //        return .init(latitude: 37.7749 , longitude: -122.4194
    //        )
    //    }
    //}
    //
    //struct EquatableCoordinate: Equatable {
    //    let coordinate: CLLocationCoordinate2D
    //
    //    static func == (lhs: EquatableCoordinate, rhs: EquatableCoordinate) -> Bool {
    //        return lhs.coordinate.latitude == rhs.coordinate.latitude &&
    //        lhs.coordinate.longitude == rhs.coordinate.longitude
    //    }
    //}
    //
    //
    //
    //struct ActiveGuestAnnotation: Identifiable, View {
    //    @ObservedObject var mapManager = MapManager.shared
    //    let id = UUID()
    //    @State var distance: Double = 0.0
    //    @State var friendDetailOpen: Bool = false
    //    private var cancellables = Set<AnyCancellable>()
    //
    //
    //    var body: some View {
    //        VStack {
    //            ZStack {
    //                Circle()
    //                    .frame(width: 52, height: 52)
    //                    .foregroundColor(.pink)
    //                    .shadow(color: Color(red: 50/255, green: 46/255, blue: 62/255), radius: 5)
    //                Image(systemName: "target")
    //                    .resizable()
    //                    .scaledToFill()
    //                    .frame(width: 50, height: 50)
    //                    .clipShape(Circle())
    //            }
    //        }
    //        ZStack {
    //            Rectangle()
    //                .frame(width: 100, height: 25)
    //                .foregroundColor(.white)
    //                .border(.green, width: 0.5)
    //                .opacity(0.75)
    //            Text("ETA \(String(format: "%.0f", 32)) min")
    //                .font(.system(size: 14))
    //                .fontWeight(.semibold)
    //                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
    //                .multilineTextAlignment(.leading)
    //        }
    //    }
    //}
    //
    //
    //
    //struct Entry {
    //    let id = UUID()
    //
    //    func getName() -> String {
    //        return "Entry with id \(id.uuidString)"
    //    }
    //}
    //
    //extension Color {
    //
    //    static let offWhite = Color(red: 225 / 255, green: 225 / 255, blue: 235 / 255 )
    //
    //    func luminosity(_ value: Double) -> Color {
    //        let uiColor = UIColor(self)
    //
    //        var hue: CGFloat = 0
    //        var saturation: CGFloat = 0
    //        var brightness: CGFloat = 0
    //        var alpha: CGFloat = 0
    //
    //        uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
    //
    //        return Color(UIColor(hue: hue, saturation: saturation, brightness: CGFloat(value), alpha: alpha))
    //    }
    //}

