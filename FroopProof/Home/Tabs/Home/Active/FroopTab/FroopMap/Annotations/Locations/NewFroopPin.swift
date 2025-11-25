//
//  NewFroopPin.swift
//  FroopProof
//
//  Created by David Reed on 12/11/23.
//

import SwiftUI
import MapKit

struct NewFroopPin: View {
    @ObservedObject var mapManager = MapManager.shared
    var froopDropPin: FroopDropPin
    var pinImage: String = ""
    @State private var appear = true
    
    var body: some View {
        VStack {
            // Custom pin image
            ZStack {
                Image(systemName: froopDropPin.pinImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundColor(froopDropPin.color == .green || froopDropPin.color == .yellow ? Color(red: 50/255, green: 46/255, blue: 62/255) : .white)
                    .font(.system(size: 32))
                    .fontWeight(.semibold)
                    .padding(5)
                    .background(Color(uiColor: froopDropPin.color ?? UIColor(red: 50/255, green: 46/255, blue: 62/255, alpha: 1.0)))
                    .clipShape(Circle())
                    .scaleEffect(appear ? 1.0 : 0.8)
                    .animation(Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: appear)
            }
            VStack {
                Text(froopDropPin.title )
                    .font(.caption)
                    .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                Text(froopDropPin.subtitle )
                    .font(.caption)
                    .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
            }
        }
        .onAppear {
            froopDropPin.creatorUID = MyData.shared.froopUserID
        }
    }
}

struct CreatedPassiveFroopPin: View {
    @ObservedObject var mapManager = MapManager.shared
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var froopManager = FroopManager.shared

    var froopDropPin: FroopDropPin
    @State private var appear = true
    @State var user: UserData = UserData()
    @State var enlarge = false

    
    var body: some View {
        VStack {
            ZStack {
                Image(systemName: froopDropPin.pinImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: mapManager.pinEnlarge && enlarge ? 50 : 25, height: mapManager.pinEnlarge && enlarge ? 50 : 25)
                    .foregroundColor(self.pinForegroundColor)
                    .font(.system(size: mapManager.pinEnlarge && enlarge ? 40 : 20))
                    .fontWeight(.semibold)
                    .padding(5)
                    .background(self.pinBackgroundColor)
                    .clipShape(Circle())
                    .scaleEffect(appear ? 1.0 : 0.8)
                    .animation(Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: appear)
            }
            VStack {
                Text("by: \(user.firstName) \(user.lastName)")
                    .font(.caption)
                    .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.5))
                Text(froopDropPin.title )
                    .font(.caption)
                    .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                Text(froopDropPin.subtitle )
                    .font(.caption)
                    .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
            }
        }
        .onTapGesture {
            mapManager.froopDropPin = FroopDropPin()
            mapManager.newPinCreation = false
            mapManager.showSavePassivePinView = false
            mapManager.showPassivePinDetailsView = true
            mapManager.pinEnlarge = true
            enlarge = true
            mapManager.createdPinDetail = froopDropPin
            withAnimation(.easeInOut(duration: 1.0)) {
                // Calculate the offset to move the center upwards
                let offset = mapManager.mapRegion.span.latitudeDelta / 20
                
                // Adjust the center point upwards
                let adjustedCenter = CLLocationCoordinate2D(
                    latitude: froopDropPin.coordinate.latitude - offset,
                    longitude: froopDropPin.coordinate.longitude
                )
                
                // Create a new region with the adjusted center
                
                let adjustedRegion = MKCoordinateRegion(
                    center: adjustedCenter,
                    latitudinalMeters: 250,
                    longitudinalMeters: 250
                )
                
                // Update cameraPosition to frame this new region
                
                MapManager.shared.cameraPosition = .region(adjustedRegion)
            }
            
        }
        .onChange(of: mapManager.pinEnlarge, initial: mapManager.pinEnlarge) { oldValue, newValue in
            if newValue == false {
                enlarge = false
            }
        }
        .onAppear {
            if let foundUser = findUser(byUserID: froopDropPin.creatorUID, in: froopManager.selectedFroopHistory) {
                user = foundUser
            } else {
                PrintControl.shared.printErrorMessages("User not found in confirmed friends")
            }
        }
//        .opacity(mapManager.tapLatitudeDelta < 0.02 ? 1 : 0.0)
    }

    private var pinForegroundColor: Color {
        // Specific color conditions can be added here
        if froopDropPin.color == UIColor.green || froopDropPin.color == UIColor.yellow {
            return (Color(red: 50/255, green: 46/255, blue: 62/255))
        } else {
            return .white
        }
    }
    
    private var pinBackgroundColor: Color {
        // Ensure proper conversion from hex to UIColor
        if let hexColor = froopDropPin.color?.toHexString() {
            return Color(uiColor: UIColor(hex: hexColor) ?? UIColor.gray)
        } else {
            return Color.gray // Default color
        }
    }

    func findUser(byUserID userID: String, in froopHistory: FroopHistory) -> UserData? {
        return froopHistory.confirmedFriends.first { $0.froopUserID == userID }
    }
}

struct CreatedFroopPin: View {
    @ObservedObject var mapManager = MapManager.shared
    @ObservedObject var appStateManager = AppStateManager.shared
    var froopDropPin: FroopDropPin
    @State private var appear = true
    @State var user: UserData = UserData()
    @State var enlarge = false

    
    var body: some View {
        VStack {
            ZStack {
                Image(systemName: froopDropPin.pinImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: mapManager.pinEnlarge && enlarge ? 50 : 25, height: mapManager.pinEnlarge && enlarge ? 50 : 25)
                    .foregroundColor(self.pinForegroundColor)
                    .font(.system(size: mapManager.pinEnlarge && enlarge ? 40 : 20))
                    .fontWeight(.semibold)
                    .padding(5)
                    .background(self.pinBackgroundColor)
                    .clipShape(Circle())
                    .scaleEffect(appear ? 1.0 : 0.8)
                    .animation(Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: appear)
            }
            VStack {
                Text("by: \(user.firstName) \(user.lastName)")
                    .font(.caption)
                    .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.5))
                Text(froopDropPin.title )
                    .font(.caption)
                    .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                Text(froopDropPin.subtitle )
                    .font(.caption)
                    .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
            }
        }
        .onTapGesture {
            mapManager.froopDropPin = FroopDropPin()
            mapManager.newPinCreation = false
            mapManager.showSavePinView = false
            mapManager.showPinDetailsView = true
            mapManager.pinEnlarge = true
            mapManager.tabUp = false
            enlarge = true
            mapManager.createdPinDetail = froopDropPin
            withAnimation(.easeInOut(duration: 1.0)) {
                // Calculate the offset to move the center upwards
                let offset = mapManager.mapRegion.span.latitudeDelta / 20
                
                // Adjust the center point upwards
                let adjustedCenter = CLLocationCoordinate2D(
                    latitude: froopDropPin.coordinate.latitude - offset,
                    longitude: froopDropPin.coordinate.longitude
                )
                
                // Create a new region with the adjusted center
                
                let adjustedRegion = MKCoordinateRegion(
                    center: adjustedCenter,
                    latitudinalMeters: 250,
                    longitudinalMeters: 250
                )
                
                // Update cameraPosition to frame this new region
                
                MapManager.shared.cameraPosition = .region(adjustedRegion)
            }
            
        }
        .onChange(of: mapManager.pinEnlarge, initial: mapManager.pinEnlarge) { oldValue, newValue in
            if newValue == false {
                enlarge = false
            }
        }
        .onAppear {
            if let foundUser = findUser(byUserID: froopDropPin.creatorUID, in: appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI] ?? FroopManager.defaultFroopHistory()) {
                user = foundUser
            } else {
                PrintControl.shared.printErrorMessages("User not found in confirmed friends")
            }
        }
//        .opacity(mapManager.tapLatitudeDelta < 0.02 ? 1 : 0.0)
    }

    private var pinForegroundColor: Color {
        // Specific color conditions can be added here
        if froopDropPin.color == UIColor.green || froopDropPin.color == UIColor.yellow {
            return (Color(red: 50/255, green: 46/255, blue: 62/255))
        } else {
            return .white
        }
    }
    
    private var pinBackgroundColor: Color {
        // Ensure proper conversion from hex to UIColor
        if let hexColor = froopDropPin.color?.toHexString() {
            return Color(uiColor: UIColor(hex: hexColor) ?? UIColor.gray)
        } else {
            return Color.gray // Default color
        }
    }

    func findUser(byUserID userID: String, in froopHistory: FroopHistory) -> UserData? {
        return froopHistory.confirmedFriends.first { $0.froopUserID == userID }
    }
}


struct ColorSelectionView: View {
    var color: Color
    var uiColor: UIColor
    @ObservedObject var mapManager = MapManager.shared

    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .frame(width: UIScreen.screenHeight * 0.04, height: UIScreen.screenHeight * 0.04)
            .foregroundColor(color)
            .opacity(mapManager.froopDropPin.color == uiColor ? 1 : 0.5)
            .shadow(radius: mapManager.froopDropPin.color == uiColor ? 10 : 0)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(red: 50/255, green: 46/255, blue: 62/255), lineWidth: 0.25)
            )
            .onTapGesture {
                mapManager.froopDropPin.color = uiColor
                mapManager.refreshMap.toggle()
//                print(mapManager.froopDropPin.color as Any)
            }
    }
}

struct ImageSelectionView: View {
    var imageName: String
    @ObservedObject var mapManager = MapManager.shared

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .frame(width: UIScreen.screenHeight * 0.04, height: UIScreen.screenHeight * 0.04)
                .foregroundColor(mapManager.froopDropPin.pinImage == imageName ? Color(red: 50/255, green: 46/255, blue: 62/255) : .gray)
            Image(systemName: imageName)
                .font(.system(size: 26))
                .foregroundColor(.white)
                .fontWeight(.light)
        }
        .onTapGesture {
            mapManager.froopDropPin.pinImage = imageName
            mapManager.refreshMap.toggle()
            print(mapManager.froopDropPin.pinImage)

        }
    }
}
