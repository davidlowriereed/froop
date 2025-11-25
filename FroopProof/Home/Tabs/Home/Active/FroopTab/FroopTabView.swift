//
//  FroopTabView.swift
//  FroopProof
//
//  Created by David Reed on 5/5/23.
//

import SwiftUI
import SwiftUIBlurView
import Kingfisher
import Firebase
import FirebaseAuth
import FirebaseFirestore
import Foundation
import MapKit
import EventKit


struct FroopTabView: View {
    
    @ObservedObject var friendStore = FriendStore.shared
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var appStateManager = AppStateManager.shared
    //    @ObservedObject var froopDataListener = FroopDataListener.shared
    @ObservedObject var locationManager = LocationManager.shared
    @ObservedObject var notificationsManager = NotificationsManager.shared
    @ObservedObject var mapManager = MapManager.shared
    
    @ObservedObject var friendData: UserData
    @ObservedObject var myData = MyData.shared
    @ObservedObject private var viewModel: MediaGridViewModel
    
    @ObservedObject var froopManager = FroopManager.shared
    @Binding var uploadedMedia: [MediaData]
    @State private var showFroopInfoView = false
    @State private var showFroopMapView = false
    @State private var showFroopMessagesView = false
    @State private var showFroopMediaView = false
    @State private var showPhotoLibrary = false
    @State private var froopLocation: CLLocationCoordinate2D = CLLocationCoordinate2D()
    @State private var guestLocatinos: [GuestLocation] = []
    @State private var currentGuestLocations: [GuestLocation] = []
    @State var detailGuests: [UserData] = []
    @State var froopLatitude: Double = 0.0
    @State var froopLongitude: Double = 0.0
    @Binding var froopTabPosition: Int
    @State private var currentTab: FroopTab = .info
    @State private var thisFroopType: String = ""
    @State private var currentIndex: Int = 0
    @State private var openFroops: Set<UUID> = []

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
    let uid = FirebaseServices.shared.uid
    
    @State private var internalRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 39.50, longitude: -98.35),
        span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
    )
    
    var guestLocations: [GuestLocation] {
        return detailGuests.map { friendData in
            let userCoordinate = LocationManager.shared.userLocation?.coordinate ?? CLLocationCoordinate2D()
            
            
            return GuestLocation(
                location: userCoordinate,
                profileImageUrl: friendData.profileImageUrl,
                name: "\(friendData.firstName) \(friendData.lastName)",
                froopUserID: friendData.froopUserID,
                phoneNumber: friendData.phoneNumber,
                currentDistance: nil,
                etaToFroop: nil
            )
        }
    }
    
    private var thisFroop: Froop
    
    public init(friendData: UserData, viewModel: MediaGridViewModel, uploadedMedia: Binding<[MediaData]>, thisFroop: Froop, froopTabPosition: Binding <Int>, globalChat: Binding <Bool>) {
        self.friendData = friendData
        _viewModel = ObservedObject(wrappedValue: viewModel)
        _uploadedMedia = uploadedMedia
        self.thisFroop = thisFroop
        _froopTabPosition = froopTabPosition
        _globalChat = globalChat
    }
    //@State var showTypeImage: Bool = true
    
    var filteredFroopsForSelectedFriend: [FroopHistory] {
        return displayedFroops.filter {
            !$0.images.isEmpty &&
            ($0.host.froopUserID == froopManager.myData.froopUserID ||
             $0.confirmedFriends.contains(where: { $0.froopUserID == froopManager.myData.froopUserID }))
        }
    }
    
    var sortedFroopsForUser: [FroopHistory] {
        //        froopManager.hostedFroopCount = displayedFroops.count
        return displayedFroops.sorted(by: { $0.froop.froopStartTime > $1.froop.froopStartTime })
    }
    
    var sortedFroopsForSelectedFriend: [FroopHistory] {
        return filteredFroopsForSelectedFriend.sorted(by: { $0.froop.froopStartTime > $1.froop.froopStartTime })
    }
    
    var displayedFroops: [FroopHistory] {
        let now = Date()
        return FroopManager.shared.displayFroopHistory.filter { froopHistory in
            let isActive = froopHistory.froop.froopStartTime <= now && froopHistory.froop.froopEndTime > now
            
            switch froopHistory.froopStatus {
            case .invited, .confirmed:
                return isActive
            case .archived, .memory:
                return false // We don't want to show archived or memory Froops in the active list
            case .declined:
                return isActive && froopHistory.froop.froopHost == uid
            case .none:
                return false
            }
        }
    }
    
    
    var body: some View {
        ZStack (alignment: .top){
            ZStack (alignment: .top) {
                
                ZStack {
                    switch NavLocationServices.shared.selectedFroopTab {
                        case .info:
                            FroopInfoView(globalChat: $globalChat)
                        case .map:
                            ActiveOrPassiveView(globalChat: $globalChat)
                        case .messages:
                            FroopMessagesView()
                        case .media:
                            FroopMediaShareViewParent()
                        case .selection:
                            ZStack {
                                ZStack {
                                    ScrollView {
                                        VStack {
                                            VStack(alignment: .leading, spacing: 5) {
                                                ForEach(Array(displayedFroops.enumerated()), id: \.element.id) { index, froopHistory in
                                                    MyMinCardsViewActive(
                                                        openFroop: Binding(
                                                            get: { openFroops.contains(froopHistory.id) },
                                                            set: { newValue in
                                                                if newValue {
                                                                    openFroops.insert(froopHistory.id)
                                                                } else {
                                                                    openFroops.remove(froopHistory.id)
                                                                }
                                                            }
                                                        ), froopHistory: froopHistory
                                                    )
                                                    .id(froopHistory.id)
                                                    .onTapGesture {
                                                        if !openFroops.contains(froopHistory.id) {
                                                            appStateManager.aFHI = index
                                                            print(appStateManager.aFHI)
                                                            NavLocationServices.shared.selectedFroopTab = .map
                                                        }
                                                    }
                                                }
                                            }
                                            Spacer()
                                        }
                                        .padding(.top, 10)
                                        .padding(.bottom, 75)
                                    }
                                }
                                .padding(.top, 100)
                                
                                VStack {
                                    ZStack {
                                        Rectangle()
                                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                            .opacity(1)
                                            .frame(height: 100)
                                            .offset(y: -5)
                                        
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .frame(width: 275, height: 40)
                                            .foregroundColor(.clear) // Use `.background` if you want to fill color
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 25, style: .continuous)
                                                    .stroke(Color.white, lineWidth: 0.25)
                                            )
                                        
                                        HStack {
                                            Spacer()
                                            Text("Back to Home")
                                                .font(.system(size: 24))
                                                .fontWeight(.light)
                                                .foregroundColor(.white)
                                            Spacer()
                                        }
                                        Spacer()
                                    }
                                    Spacer()
                                }
                                .onTapGesture {
                                    print("tapped 'Open My Froops View'")
                                    appStateManager.appStateToggle = false
                                    NavLocationServices.shared.selectedFroopTab = .map
                                    print(appStateManager.appStateToggle)
                                }
                            }
                            .padding(.top, 95)
                    }
                    
                    VStack {
                        Spacer()
                        FroopTabBarView()
                    }
                    
                    FroopPassiveView(instanceFroop: instanceFroop, globalChat: $globalChat)
                        .opacity(appStateManager.appState == .passive || !appStateManager.appStateToggle ? 1.0 : 0.0)
                        .onChange(of: appStateManager.appState) { oldValue, newValue in
                            print("FroopPassiveView: appState changed from \(oldValue) to \(newValue)")
                        }
                        .onChange(of: appStateManager.appStateToggle) { oldValue, newValue in
                            print("FroopPassiveView: appStateToggle changed from \(oldValue) to \(newValue)")
                        }
                }
                .frame(width: UIScreen.screenWidth, height: UIScreen.screenHeight)
            }
        }
    }
    
    
    @ViewBuilder
    private func tabButton(title: String, tab: FroopTab) -> some View {
        Button(action: {
            if AppStateManager.shared.appState != .passive {
                NavLocationServices.shared.selectedFroopTab = tab
            }
            if NavLocationServices.shared.selectedFroopTab == .map {
                TimerServices.shared.startAnnotationTimer()
            }
        }) {
            Image(systemName: title)
                .font(.system(size: 30))
                .foregroundColor(NavLocationServices.shared.selectedFroopTab == tab ? Color(red: 249/255, green: 0/255, blue: 98/255) : Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.75))
                .fontWeight(.thin)
                .opacity(AppStateManager.shared.appState == .active ? 1.0 : 0.0)
        }
    }
}


struct FroopTabBarView: View {
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var navLocationServices = NavLocationServices.shared
    @ObservedObject var mapManager = MapManager.shared

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .foregroundColor(.white)
                .frame(width: UIScreen.screenWidth * 0.9, height: AppStateManager.shared.appState == .active ? 50 : 0)
                .shadow(color: Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.2), radius: 7, x: 7, y: 7)
                .opacity(1)

            HStack(spacing: 35) {
                tabButton(title: "info.square.fill", tab: .info)
                tabButton(title: "map.fill", tab: .map)
                tabButton(title: "message.fill", tab: .messages)
                tabButton(title: "photo.on.rectangle.angled", tab: .media)
                tabButton(title: "square.2.layers.3d.top.filled", tab: .selection)
            }
            .fontWeight(.light)
        }
        .padding(.horizontal)
        .offset(y: appStateManager.appState == .active || appStateManager.appStateToggle ? -25 : 100)
        .offset(y: mapManager.tabUp ? -25 : 100)
        .animation(.smooth(duration: 0.3), value: appStateManager.appStateToggle)
        .animation(.easeInOut(duration: 0.3), value: appStateManager.isFroopTabUp)
        .animation(.easeInOut(duration: 0.3), value: mapManager.tabUp)
    }

    @ViewBuilder
    private func tabButton(title: String, tab: FroopTab) -> some View {
        Button(action: {
            if AppStateManager.shared.appState != .passive {
                navLocationServices.selectedFroopTab = tab
            }
            if navLocationServices.selectedFroopTab == .map {
                TimerServices.shared.startAnnotationTimer()
            }
        }) {
            Image(systemName: title)
                .font(.system(size: 30))
                .foregroundColor(navLocationServices.selectedFroopTab == tab ? Color(red: 249/255, green: 0/255, blue: 98/255) : Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.75))
                .fontWeight(.thin)
                .opacity(AppStateManager.shared.appState == .active ? 1.0 : 0.0)
        }
    }
}
