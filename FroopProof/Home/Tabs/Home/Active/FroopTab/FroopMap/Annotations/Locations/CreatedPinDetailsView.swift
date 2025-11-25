//
//  CreatedPinDetailsView.swift
//  FroopProof
//
//  Created by David Reed on 11/27/23.
//

import SwiftUI
import MapKit

struct CreatedPinDetailsView: View {
    @ObservedObject var mapManager = MapManager.shared
    @ObservedObject var appStateManager = AppStateManager.shared
    @State var user: UserData = UserData()
    @State private var showingDeleteAlert = false
    @State private var pinToDelete: String?
    
    
    @State var froopDropPin: FroopDropPin = FroopDropPin()
    var body: some View {
        VStack {
            Spacer()
            ZStack {
                VStack (spacing: 0){
                    VStack (alignment: .leading) {
                        Text("Message from: \(user.firstName) \(user.lastName)")
                            .font(.system(size: 16))
                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                            .fontWeight(.bold)
                            .padding(.leading, 5)
                            .padding(.trailing, 5)
                        TextEditor(text: $mapManager.froopDropPin.messageBody)
                            .font(.system(size: 14))
                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                            .fontWeight(.light)
                            .frame(height: 150)
                            .padding(5) // Padding inside the TextEditor
                            .border(Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.25), width: 0.25)
                            .background(Color.white)
                            .keyboardResponsive(mapManager: mapManager)
                            .multilineTextAlignment(.leading) // Align text to the upper left
                        
                    }
                    .padding(.top, UIScreen.screenHeight * 0.035)
                    .padding(.top, 25)
                    .padding(.bottom, 5)
                    Spacer()
                    if froopDropPin.creatorUID == MyData.shared.froopUserID || MyData.shared.froopUserID == appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.host.froopUserID {
                        ZStack {
                            Rectangle()
                                .frame(width: UIScreen.screenWidth * 0.25, height: 30)
                                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                .opacity(0.1)
                                .border(Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.5), width: 0.25)
                            
                            Text("Delete Pin")
                                .font(.system(size: 18))
                                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                .fontWeight(.thin)
                        }
                        .padding(.bottom, 20)
                        .onTapGesture {
                            self.pinToDelete = froopDropPin.id.uuidString // Set the ID of the pin to delete
                            self.showingDeleteAlert = true
                            
                        }
                        .alert(isPresented: $showingDeleteAlert) {
                            Alert(
                                title: Text("Delete Pin"),
                                message: Text("Are you sure you want to delete this pin permanently?"),
                                primaryButton: .destructive(Text("Delete")) {
                                    if let pinId = pinToDelete {
                                        mapManager.deleteFroopDropPin(pinId: pinId)
                                    }
                                },
                                secondaryButton: .cancel()
                            )
                        }
                    }
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
                                    mapManager.newPinCreation = false
                                    mapManager.tabUp = true
                                    mapManager.showPinDetailsView = false
                                    mapManager.showPassivePinDetailsView = false
                                    mapManager.froopDropPin = FroopDropPin()
                                    mapManager.pinEnlarge = false
                                    
                                    if let center = mapManager.cameraPosition.region?.center {
                                        mapManager.centerLatitude = center.latitude
                                        mapManager.centerLongitude = center.longitude
                                    }
                                    
                                    let froopLocation = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopLocationCoordinate ?? CLLocationCoordinate2D()
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
                        if froopDropPin.creatorUID == MyData.shared.froopUserID {
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
                                        mapManager.tabUp = true
                                        mapManager.showPinDetailsView = false
                                        mapManager.showPassivePinDetailsView = false
                                        mapManager.updateFroopDropPin()
                                        mapManager.pinEnlarge = false
                                        
                                        if let center = mapManager.cameraPosition.region?.center {
                                            mapManager.centerLatitude = center.latitude
                                            mapManager.centerLongitude = center.longitude
                                        }
                                        
                                        let froopLocation = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopLocationCoordinate ?? CLLocationCoordinate2D()
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
                        } else {
                            Text("")
                                .font(.system(size: 12))
                                .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255))
                                .fontWeight(.bold)
                                .frame(width: 100, alignment: .trailing)
                                .padding(.trailing, UIScreen.screenWidth * 0.05)
                        }
                    }
                    Spacer()
                    .padding(.horizontal)
                    .padding(.top, 10)
                }
                //                .padding(.top, 5)
            }
            .onAppear {
//                print("Creator UID: \(froopDropPin.creatorUID)")
                if let foundUser = findUser(byUserID: froopDropPin.creatorUID, in: appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI] ?? FroopManager.defaultFroopHistory()) {
                    user = foundUser
//                    print("Found user: \(user.firstName) \(user.lastName)")
                } else {
                    PrintControl.shared.printErrorMessages("User not found in confirmed friends")
                }
            }
            //            .frame(height: UIScreen.screenHeight * 0.4)
        }
    }
    func findUser(byUserID userID: String, in froopHistory: FroopHistory) -> UserData? {
        return froopHistory.confirmedFriends.first { $0.froopUserID == userID }
    }
    
    func selectColor(_ color: Color) {
        if let uiColor = mapManager.colorLookup[color] {
            mapManager.froopDropPin.color = uiColor
        }
    }
}
