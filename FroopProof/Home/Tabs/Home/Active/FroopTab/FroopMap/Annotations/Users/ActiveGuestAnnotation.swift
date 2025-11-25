//
//  ActiveGuestAnnotation.swift
//  FroopProof
//
//  Created by David Reed on 10/31/23.
//

import SwiftUI
import MapKit
import Kingfisher
import Combine

struct ActiveGuestAnnotation: View {
    @ObservedObject var dataController = DataController.shared
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var locationManager = LocationManager.shared
    @ObservedObject var mapManager = MapManager.shared
    @ObservedObject var flightTimeManager = FlightTimeManager.shared
    @State var distance: Double = 0.0
    @State var friendDetailOpen: Bool = false
    @Binding var globalChat: Bool
    var coordinate: CLLocationCoordinate2D {
        return guest.coordinate
    }
    
    @State var guest: UserData
    private var cancellables = Set<AnyCancellable>()

    init(guest: UserData, globalChat: Binding<Bool>) {
        self._guest = State(initialValue: guest)
        self._globalChat = globalChat
        
        // Subscribe to updates
        appStateManager.$currentFilteredFroopHistory
            .compactMap { $0[safe: AppStateManager.shared.aFHI]?.confirmedFriends }
            .flatMap { $0.publisher }
            .filter { $0.froopUserID == guest.froopUserID }
            .assign(to: \.guest, on: self)
            .store(in: &cancellables)
    }
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .frame(width: 52, height: 52)
                    .foregroundColor(getAnnotationColor())
                    .shadow(color: Color(red: 50/255, green: 46/255, blue: 62/255), radius: 5)
                KFImage(URL(string: guest.profileImageUrl))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            }
            .onTapGesture {
                appStateManager.inMapChat = true
                globalChat = false
                friendDetailOpen = true
                
                let newRegion = MKCoordinateRegion(center: guest.coordinate, latitudinalMeters: 500, longitudinalMeters: 500) // Adjust the meters for desired zoom level
                mapManager.cameraPosition = .region(newRegion)
            }
            ZStack {
                Rectangle()
                    .frame(width: 100, height: 25)
                    .foregroundColor(.white)
                    .border(.green, width: 0.5)
                    .opacity(0.75)
                Text("ETA \(String(format: "%.0f", distance)) min")
                    .font(.system(size: 14))
                    .fontWeight(.semibold)
                    .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                    .multilineTextAlignment(.leading)
            }
            .opacity(distance < 1 ? 0.0 : 1.0)
               
              
        }
        
        .onAppear {
            if appStateManager.aFHI >= 0 && appStateManager.aFHI < appStateManager.currentFilteredFroopHistory.count {
                LocationManager.shared.calculateTravelTime(from: guest.coordinate, to: appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopLocationCoordinate ?? CLLocationCoordinate2D()) { travelTime in
                    if let travelTime = travelTime {
                        // convert travel time to minutes
                        let travelTimeMinutes = Double(travelTime / 60)
                        distance = travelTimeMinutes
                        flightTimeManager.distance = travelTimeMinutes
                    }
                }
            }
        }
        .onChange(of: guest.coordinate) {
            if appStateManager.aFHI >= 0 && appStateManager.aFHI < appStateManager.currentFilteredFroopHistory.count {
                LocationManager.shared.calculateTravelTime(from: guest.coordinate, to: appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopLocationCoordinate ?? CLLocationCoordinate2D()) { travelTime in
                    if let travelTime = travelTime {
                        // convert travel time to minutes
                        let travelTimeMinutes = Double(travelTime / 60)
                        distance = travelTimeMinutes
                        flightTimeManager.distance = travelTimeMinutes
                    }
                }
            }
        }
        
        .fullScreenCover(isPresented: $friendDetailOpen) {
            //                friendListViewOpen = false
        } content: {
            ZStack {
                VStack {
                    Spacer()
                    UserDetailView3(selectedMapFriend: $guest, friendDetailOpen: $friendDetailOpen, globalChat: $globalChat)
//                        .ignoresSafeArea()
                }
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "xmark")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .blendMode(.difference)
                            .padding(.trailing, 40)
                            .padding(.top, UIScreen.screenHeight * 0.005)
                            .onTapGesture {
                                dataController.allSelected = 0
                                appStateManager.inMapChat = false
                                self.friendDetailOpen = false
                            }
                    }
                    .frame(alignment: .trailing)
                    Spacer()
                }
            }
        }
        
    }
    func getAnnotationColor() -> Color {
        // Check if the index is within the bounds of the array
        if appStateManager.aFHI >= 0,
           appStateManager.aFHI < appStateManager.currentFilteredFroopHistory.count {
            let froopHistory = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]
            
            // Now it's safe to access properties of froopHistory
            if guest.froopUserID == froopHistory?.host.froopUserID {
                return Color(red: 249/255, green: 0/255, blue: 98/255)
            }
        }
        return .white  // Default color if index is out of bounds or condition is not met
    }

}

struct PassiveGuestAnnotation: View {
    @ObservedObject var dataController = DataController.shared
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var froopManager = FroopManager.shared
    @ObservedObject var locationManager = LocationManager.shared
    @ObservedObject var mapManager = MapManager.shared
    @State var distance: Double = 0.0
    @State var friendDetailOpen: Bool = false
    @Binding var globalChat: Bool
    var coordinate: CLLocationCoordinate2D {
        return guest.coordinate
    }
    
    @State var guest: UserData
    private var cancellables = Set<AnyCancellable>()

    init(guest: UserData, globalChat: Binding<Bool>) {
        self._guest = State(initialValue: guest)
        self._globalChat = globalChat
    }
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .frame(width: 52, height: 52)
                    .foregroundColor(getAnnotationColor())
                    .shadow(color: Color(red: 50/255, green: 46/255, blue: 62/255), radius: 5)
                KFImage(URL(string: guest.profileImageUrl))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            }
            .onTapGesture {
                appStateManager.inMapChat = true
                globalChat = false
                friendDetailOpen = true
                
                let newRegion = MKCoordinateRegion(center: guest.coordinate, latitudinalMeters: 500, longitudinalMeters: 500) // Adjust the meters for desired zoom level
                mapManager.cameraPosition = .region(newRegion)
            }
            ZStack {
                Rectangle()
                    .frame(width: 100, height: 25)
                    .foregroundColor(.white)
                    .border(.green, width: 0.5)
                    .opacity(0.75)
                Text("ETA \(String(format: "%.0f", distance)) min")
                    .font(.system(size: 14))
                    .fontWeight(.semibold)
                    .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                    .multilineTextAlignment(.leading)
            }
            .opacity(distance < 1 ? 0.0 : 1.0)
               
              
        }
        
        .onAppear {
                LocationManager.shared.calculateTravelTime(from: guest.coordinate, to: appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopLocationCoordinate ?? CLLocationCoordinate2D()) { travelTime in
                    if let travelTime = travelTime {
                        // convert travel time to minutes
                        let travelTimeMinutes = Double(travelTime / 60)
                        distance = travelTimeMinutes
                    }
                }
        }
        
        .fullScreenCover(isPresented: $friendDetailOpen) {
        } content: {
            ZStack {
                VStack {
                    Spacer()
                    UserDetailView3(selectedMapFriend: $guest, friendDetailOpen: $friendDetailOpen, globalChat: $globalChat)
                }
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "xmark")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .blendMode(.difference)
                            .padding(.trailing, 40)
                            .padding(.top, UIScreen.screenHeight * 0.005)
                            .onTapGesture {
                                dataController.allSelected = 0
                                appStateManager.inMapChat = false
                                self.friendDetailOpen = false
                            }
                    }
                    .frame(alignment: .trailing)
                    Spacer()
                }
            }
        }
    }
    func getAnnotationColor() -> Color {

        if guest.froopUserID == froopManager.selectedFroopHistory.host.froopUserID {
                return Color(red: 249/255, green: 0/255, blue: 98/255)
            }
        return .white
    }

}



