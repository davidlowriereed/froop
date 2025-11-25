//
//  PinDetails.swift
//  FroopProof
//
//  Created by David Reed on 11/27/23.
//

import SwiftUI
import MapKit

struct PassivePinDetails: View {
    @ObservedObject var mapManager = MapManager.shared
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var froopManager = FroopManager.shared

    @State var froopDropPin: FroopDropPin = FroopDropPin()
    var body: some View {
        VStack {
            Spacer()
            ZStack {
                VStack (spacing: 0){
                    HStack {
                        Text("TITLE:")
                            .font(.system(size: 12))
                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                            .fontWeight(.bold)
                            .frame(width: UIScreen.screenWidth * 0.18, alignment: .leading)
                        TextField("Tap here to edit.", text: $mapManager.froopDropPin.title)
                            .font(.system(size: 18))
                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                            .fontWeight(.light)
                            .frame(height: 50)
                            .padding(.leading, 5)
                            .padding(.trailing, 5)
                            .border(Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.25), width: 0.25)
                            .background(.white)
                            .keyboardResponsive(mapManager: mapManager)

                    }
                    .padding(.top, UIScreen.screenHeight * 0.035)
                    .padding(.top, 15)
                    .padding(.bottom, 5)
                    
                    HStack {
                        Text("SUBTITLE:")
                            .font(.system(size: 12))
                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                            .fontWeight(.bold)
                            .frame(width: UIScreen.screenWidth * 0.18, alignment: .leading)
                        TextField("Tap here to edit.", text: Binding(get: { mapManager.froopDropPin.subtitle }, set: { mapManager.froopDropPin.subtitle = $0 }))
                            .font(.system(size: 18))
                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                            .fontWeight(.light)
                            .frame(height: 50)
                            .padding(.leading, 5)
                            .padding(.trailing, 5)
                            .border(Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.25), width: 0.25)
                            .background(.white)
                            .keyboardResponsive(mapManager: mapManager)

                    }
                    .padding(.top, 5)
                    .padding(.bottom, 5)
                    
                    HStack {
                        Text("COLOR")
                            .font(.system(size: 12))
                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .padding(.bottom, UIScreen.screenHeight * 0.01)
                    .padding(.top, UIScreen.screenHeight * 0.02)
                    
                    HStack {
                        Spacer()
                        ForEach(Array(mapManager.colorLookup.keys), id: \.self) { color in
                            ColorSelectionView(color: color, uiColor: mapManager.colorLookup[color] ?? UIColor.white, mapManager: mapManager)
                        }
                        Spacer()
                    }
                    .padding(.bottom, UIScreen.screenHeight * 0.01)
                    
                    HStack {
                        Text("ICON")
                            .font(.system(size: 12))
                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .padding(.bottom, UIScreen.screenHeight * 0.01)
                    
                    HStack {
                        Spacer()
                        ForEach(["pin.fill", "mappin.circle.fill", "tent.fill", "car.fill", "balloon.fill", "camera.fill", "figure.run", "flame.fill"], id: \.self) { imageName in
                            ImageSelectionView(imageName: imageName)
                        }
                        Spacer()
                    }
                    .padding(.bottom, UIScreen.screenHeight * 0.01)
                    Spacer()
                }
                .padding(.bottom, UIScreen.screenHeight * 0.035)
                .padding(.leading, UIScreen.screenWidth * 0.05)
                .padding(.trailing, UIScreen.screenWidth * 0.05)
                
                VStack {
                    HStack {
                        ZStack {
                            Rectangle()
                                .foregroundColor(.white).opacity(0.001)
                                .frame(width: 100, height: 40)
                            Text("CANCEL")
                                .font(.system(size: 12))
                                .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255))
                                .fontWeight(.bold)
                                .padding(.leading, UIScreen.screenWidth * 0.05)
                                .frame(width: 100, alignment: .leading)
                                .onTapGesture {
                                    mapManager.newPassivePinCreation = false
                                    mapManager.showSavePassivePinView = false
                                    mapManager.froopDropPin = FroopDropPin()
                                    if let center = mapManager.cameraPosition.region?.center {
                                        mapManager.centerLatitude = center.latitude
                                        mapManager.centerLongitude = center.longitude
                                    }
                                    
                                    let froopLocation = froopManager.selectedFroopHistory.froop.froopLocationCoordinate 
                                    let myLocation = MyData.shared.coordinate // Directly accessing the property
                                    
                                    let midpoint = mapManager.midpointBetween(coordinate1: froopLocation, coordinate2: myLocation)
                                    let span = mapManager.spanToInclude(coordinate1: froopLocation, coordinate2: myLocation)
                                    let region = MKCoordinateRegion(center: midpoint, span: span)
                                    withAnimation(.easeInOut(duration: 1.0)) {
                                        mapManager.cameraPosition = .region(region)
                                    }
                                }
                        }
                        Spacer()
                        Text("ANNOTATION DETAILS")
                            .font(.system(size: 12))
                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.3))
                            .fontWeight(.bold)
                        Spacer()
                        ZStack {
                            Rectangle()
                                .foregroundColor(.white).opacity(0.001)
                                .frame(width: 100, height: 40)
                            Text("SAVE")
                                .font(.system(size: 12))
                                .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255))
                                .fontWeight(.bold)
                                .frame(width: 100, alignment: .trailing)
                                .padding(.trailing, UIScreen.screenWidth * 0.05)
                                .onTapGesture {
                                    mapManager.showSavePassivePinView = false
                                    mapManager.savePassiveFroopDropPin()
                                    if let center = mapManager.cameraPosition.region?.center {
                                        mapManager.centerLatitude = center.latitude
                                        mapManager.centerLongitude = center.longitude
                                    }
                                    
                                    let froopLocation = froopManager.selectedFroopHistory.froop.froopLocationCoordinate 
                                    let myLocation = MyData.shared.coordinate // Directly accessing the property
                                    
                                    let midpoint = mapManager.midpointBetween(coordinate1: froopLocation, coordinate2: myLocation)
                                    let span = mapManager.spanToInclude(coordinate1: froopLocation, coordinate2: myLocation)
                                    let region = MKCoordinateRegion(center: midpoint, span: span)
                                    withAnimation(.easeInOut(duration: 2.0)) {
                                        mapManager.cameraPosition = .region(region)
                                    }
                                    mapManager.froopDropPin = FroopDropPin()
                                }
                        }
                        .frame(width: 100)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    Spacer()
                }
                //                .padding(.top, 5)
            }
            .frame(height: UIScreen.screenHeight * 0.4)
        }
    }
    
    func selectColor(_ color: Color) {
        if let uiColor = mapManager.colorLookup[color] {
            mapManager.froopDropPin.color = uiColor
        }
    }
}


