//
//  OnboardThree.swift
//  FroopProof
//
//  Created by David Reed on 9/21/23.
//


import SwiftUI
import MapKit

struct OnboardFive: View {
    @ObservedObject var myData = MyData.shared
    @ObservedObject var accountSetupManager = AccountSetupManager.shared
    @ObservedObject var locationManager = LocationManager.shared
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var mapManager = MapManager.shared
    @State var address: String = ""
    @State var city: String = ""
    @State var state: String = ""
    @State var zipcode: String = ""
    @State private var isMapDraggable = true
    @State private var isKeyboardShown: Bool = false
    @State private var keyboardHeight: CGFloat = 0
    var moveToNext: () -> Void
    var moveToPrevious: () -> Void
    @State private var cameraPosition: MapCameraPosition = .region(.myRegion)
    @State private var mapSelection: String?
    @State private var continueUpdating: Bool = true
    @State private var userLocation: CLLocationCoordinate2D?
    @State private var mapRegion: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @State private var userAddress: String = "Locating..."
    @State private var isRequestingAuthorization = false
    @State private var maskSize: CGFloat = 1
    
    let imageW: Font.Weight = .thin
    let fontS = Font.system(size: 35)
    
    var body: some View {
        ZStack {
            // Map view
            Map(position: $mapManager.cameraPosition, interactionModes: isMapDraggable ? .all : [], selection: $mapSelection) {
                UserAnnotation()
            }
            .mapStyle(.standard(elevation: .realistic))
            .frame(height: UIScreen.main.bounds.height)
            
            // Gradient overlay with mask
            
            Rectangle()
                .opacity(0.01)
                .background(Color("FroopPink"))
                .frame(height: UIScreen.main.bounds.height)
                .mask(
                    Rectangle()
                        .reverseMask {
                            if appStateManager.locationAuthorized {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .stroke(Color.white, lineWidth: 1)
                                    .frame(width: maskSize + 5, height: maskSize + 5)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                    .offset(y: UIScreen.screenHeight * -0.15)
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .frame(width: maskSize, height: maskSize)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                    .offset(y: UIScreen.screenHeight * -0.15)
                            }
                        }
                )
            
            VStack {
                Button {
                    moveToPrevious()
                } label: {
                    HStack {
                        Spacer()
                            .frame(width: 5)
                        Image(systemName: "arrow.backward.circle")
                            .font(.system(size: 36))
                            .foregroundColor(.white)
                            .fontWeight(.thin)
                            .padding(.top, 75)
                            .padding(.leading, 20)

                        Spacer()
                    }
                }
                Spacer()
            }
            
            // Content
            VStack {
                if !appStateManager.locationAuthorized {
                  
                    VStack (alignment: .leading) {
                        Text("Enable location sharing.")
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .foregroundColor(Color(.white).opacity(1.0))
                            .padding(.top, UIScreen.screenHeight * 0.165)
                            .padding(.bottom, 25)

                        Text("Froop uses your location to give you information about your events and activities.")
                            .font(.system(size: 42))
                            .foregroundColor(.white)
                            .opacity(0.85)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.leading)
                        HStack {
                            Spacer()
                            ZStack {
                                RoundedRectangle(cornerRadius: 40, style: .continuous)
                                    .stroke(Color.white, lineWidth: 2)
                                    .fill(Color(.black).opacity(0.4))
                                    .frame(width: UIScreen.screenWidth * 0.7, height: 80)
                                
                                VStack {
                                    Text("Tap Here")
                                        .font(.system(size: 24))
                                        .foregroundStyle(.white)
                                        .fontWeight(.bold)
                                    
                                    Text("To Calibrate Now.")
                                        .font(.system(size: 24))
                                        .foregroundStyle(.white)
                                        .fontWeight(.regular)
                                }
                            }
                            .onTapGesture {
                                isRequestingAuthorization = true
                                LocationManager.shared.requestAlwaysAuthorization()
                            }
                            Spacer()
                        }
                        .padding(.top, UIScreen.screenHeight * 0.1)
                        Spacer()
                    }
                    .padding(.leading, 25)
                    .padding(.trailing, 25)
//                    .padding(.top, UIScreen.screenHeight * 0.2)
                    
                    

                } else {
                    VStack (spacing: 10) {
                        Text("Thank You")
                            .font(.system(size: 22))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text("Your location tracking is active")
                            .font(.system(size: 18))
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    .padding(.top, UIScreen.screenHeight * 0.6)
                    
                }

                Spacer()

                // Next/Skip button
                Button {
                    moveToNext()
                } label: {
                    ZStack {
            
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color.white, lineWidth: appStateManager.locationAuthorized ? 2 : 0)
                            .frame(height: 50)
                            .padding(.horizontal, 25)
                        
                        Text(appStateManager.locationAuthorized ? "Next" : "Skip")
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
                .padding(.bottom, 100)
            }
            
        }
        .animation(.easeInOut(duration: 0.5), value: appStateManager.locationAuthorized)
        .onChange(of: locationManager.authorizationStatus) { _, newStatus in
            if newStatus == .authorizedAlways || newStatus == .authorizedWhenInUse {
                withAnimation(.easeInOut(duration: 1.5)) {
                    maskSize = max(UIScreen.screenWidth, UIScreen.main.bounds.height) / 2.5
                    appStateManager.locationAuthorized = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                    focusOnMe()
                }
            }
        }
        .onChange(of: isRequestingAuthorization) { _, _ in
            if isRequestingAuthorization {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    appStateManager.locationAuthorized = locationManager.authorizationStatus == .authorizedAlways || locationManager.authorizationStatus == .authorizedWhenInUse
                    isRequestingAuthorization = false
                }
            }
        }
        .onChange(of: locationManager.userLocation) { newValue, oldValue in
            if let newValue = newValue {
                userLocation = newValue.coordinate
                mapRegion = MKCoordinateRegion(
                    center: newValue.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
                if continueUpdating {
                    continueUpdating = false
                }
            }
        }
        .ignoresSafeArea()
    }
    
    func focusOnMe() {
        guard let location = LocationManager.shared.userLocation?.coordinate else { return }
        
        let distanceInMeters: CLLocationDistance = 10000 // Adjust this value to zoom in or out
        
        // Calculate the offset to move the center point up
        let centerOffsetRatio: CGFloat = 0.1 // This puts the center at 1/3 from the top
        let latitudeOffset = 0.025 * (1 - centerOffsetRatio) // Adjust this multiplier as needed
        
        let newCenter = CLLocationCoordinate2D(
            latitude: location.latitude - latitudeOffset,
            longitude: location.longitude
        )
        
        // Calculate the span based on the distance
        let span = MKCoordinateSpan(
            latitudeDelta: distanceInMeters / 111000, // Rough approximation
            longitudeDelta: distanceInMeters / (111000 * cos(newCenter.latitude * .pi / 180))
        )
        
        let region = MKCoordinateRegion(center: newCenter, span: span)
        
        withAnimation(.easeInOut(duration: 0.5)) {
            mapManager.cameraPosition = .region(region)
        }
    }
}
