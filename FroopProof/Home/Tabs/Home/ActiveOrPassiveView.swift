//
//  ActiveOrPassiveView.swift
//  FroopProof
//
//  Created by David Reed on 5/18/23.
//

import SwiftUI
import Photos
import FirebaseStorage
import Firebase
import FirebaseAuth
import FirebaseFirestore
import Kingfisher
import SwiftUIBlurView
import MapKit
import Combine
import CoreLocation



struct ActiveOrPassiveView: View {
    @ObservedObject var locationManager = LocationManager.shared
    @ObservedObject var mapManager = MapManager.shared
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var froopManager = FroopManager.shared
    @ObservedObject var inviteManager = InviteManager.shared
    @State var froopDropPin: FroopDropPin = FroopDropPin()
    @State private var isSheetPresented = false
    @State private var froopListStatus: FroopListStatus = .confirmed
    @State var instanceFroop: FroopHistory = FroopHistory(
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
    @Binding var globalChat: Bool
    
    var body: some View {
        ZStack {
            //                if appStateManager.appStateToggle && appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopType == 5009 {
            //                    ActiveFlightMapView(froopHistory: instanceFroop, globalChat: $globalChat)
            //                        .background(.clear)
            //                } else {
            ActiveMapView(froopHistory: instanceFroop, globalChat: $globalChat)
                .background(.clear)
            //                }
        }
        .onAppear {
            FroopDataController.shared.loadFroopLists(forUserWithUID: MyData.shared.froopUserID) {
                FroopDataListener.shared.myConfirmedList = FroopDataController.shared.myConfirmedList
                FroopDataListener.shared.myInvitesList = FroopDataController.shared.myInvitesList
                FroopDataListener.shared.myDeclinedList = FroopDataController.shared.myDeclinedList
                FroopDataListener.shared.myArchivedList = FroopDataController.shared.myArchivedList
                
                if appStateManager.activeOrPassiveOnAppear {
                    FroopManager.shared.createFroopHistoryArray { froopHistory in
                        
                        print("Froop History Array created 1 \(FroopManager.shared.froopHistory.count)")
                        print("CurrentFiltered Active FroopHistories:  \(String(describing: appStateManager.currentFilteredFroopHistory.count))")
                        LoadingManager.shared.froopHistoryLoaded = true
                        
                    }
                    appStateManager.activeOrPassiveOnAppear = false
                }
            }
            Task {
                await inviteManager.loadPendingInvitations()
            }
        }
        if (MapManager.shared.showSavePinView) {
            VStack {
                Spacer()
                ZStack (alignment: .top) {
                    BlurView(style: .light)
                        .frame(height: MapManager.shared.onSelected ? UIScreen.screenHeight * 0.6 : UIScreen.screenHeight * 0.4)
//                        .edgesIgnoringSafeArea(.bottom)
                        .opacity(MapManager.shared.showSavePinView ? 1 : 0)
                        .ignoresSafeArea()
                        .border(Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.5), width: 0.5)
                        .animation(.easeInOut(duration: 0.3), value: MapManager.shared.showSavePinView)
                        .shadow(color: Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.3), radius: 20)

                    
                    PinDetails(froopDropPin: froopDropPin)
                    .transition(.move(edge: .bottom))
                    .opacity(MapManager.shared.showSavePinView ? 1 : 0)
                    .frame(height: UIScreen.screenHeight * 0.4)

                }
                .ignoresSafeArea()
            }
            .ignoresSafeArea()
        }
        if (MapManager.shared.showPinDetailsView) {
            VStack {
                Spacer()
                ZStack (alignment: .top) {
                    BlurView(style: .light)
                        .frame(height: MapManager.shared.onSelected ? UIScreen.screenHeight * 0.6 : UIScreen.screenHeight * 0.4)
//                        .edgesIgnoringSafeArea(.bottom)
                        .opacity(MapManager.shared.showPinDetailsView ? 1 : 0)
                        .ignoresSafeArea()
                        .border(Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.5), width: 0.5)
                        .animation(.easeInOut(duration: 0.3), value: MapManager.shared.showPinDetailsView)
                        .shadow(color: Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.3), radius: 20)

                    
                    CreatedPinDetailsView(froopDropPin: mapManager.createdPinDetail)
                    .transition(.move(edge: .bottom))
                    .opacity(MapManager.shared.showPinDetailsView ? 1 : 0)
                    .frame(height: UIScreen.screenHeight * 0.4)

                }
                .ignoresSafeArea()
            }
            .ignoresSafeArea()
            .alert(isPresented: $locationManager.showAlert) {
                Alert(title: Text("Geofence Alert"), message: Text(locationManager.alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
}


// A simple list view for selecting a Froop
struct FroopSelectionView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @ObservedObject var froopDataController = FroopDataController.shared
    @ObservedObject var appStateManager = AppStateManager.shared
    
    var body: some View {
        Rectangle ()
            .background(.ultraThinMaterial)
            .ignoresSafeArea()
        onAppear {
            froopDataController.processPastEvents()
        }
        
        List(appStateManager.currentFilteredFroopHistory , id: \.id) { froopHistory in
            Button(action: {
                appStateManager.inProgressFroop = froopHistory
                dismiss()
            }) {
                HStack {
                    KFImage(URL(string: appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopHostPic ?? ""))
                        .resizable()
                        .frame(width: 35, height: 35)
                        .scaledToFill()
                        .clipShape(Circle())
                    Text(froopHistory.froop.froopName)
                        .foregroundColor(colorScheme == .dark ? .white : Color(red: 50/255, green: 46/255, blue: 62/255))
                    
                }
            }
        }
    }
}
