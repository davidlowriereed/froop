//
//  UserDetailView.swift
//  FroopProof
//
//  Created by David Reed on 2/16/23.
//

import SwiftUI
import UserNotifications

struct UserDetailView: View {
    @ObservedObject var dataController = DataController.shared
    @ObservedObject var froopManager = FroopManager.shared
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var navLocationServices = NavLocationServices.shared
    @ObservedObject var froopListStatus = HomeView2ViewModel()
    @ObservedObject var payManager = PayWallManager.shared

    @State private var mapState = MapViewState.locationSelected
    @State var showInviteView = false
    @State var profileView: Bool = true
    @State var detailFroopData: Froop = (Froop(dictionary: [:]) ?? Froop(dictionary: [:]) ?? Froop.emptyFroop())
    @State var selectedFroopUUID = FroopManager.shared.selectedFroopUUID
    @State var froopDetailsOpen = FroopManager.shared.froopDetailOpen
    @State var invitedFriends: [UserData] = []
    @State var instanceFroop: FroopHistory
    @State var froopAdded = false

    
    @Binding var friendDetailOpen: Bool
    @Binding var globalChat: Bool
    var uid = FirebaseServices.shared.uid
    
    
    var body: some View {
        ZStack {
            Color.white
            GeometryReader {
                let size = $0.size
                let safeArea = $0.safeAreaInsets
                
                MyUserPublicView(size: size, safeArea: safeArea, friendDetailOpen: $friendDetailOpen, globalChat: $globalChat)
                    .ignoresSafeArea()
                
            }
        }

        .fullScreenCover(isPresented: $froopManager.froopDetailOpen) {
            
        } content: {
            ZStack (alignment: .top) {
                
                VStack {
                    Spacer()
                    switch froopListStatus.froopListStatus {
                            
                        case .invites:
                            EmptyView()
                            
                        case .confirmed:
                            FroopDetailsView(detailFroopData: $detailFroopData, froopAdded: $froopAdded, globalChat: $globalChat)
                            
                        case .declined:
                            FroopDetailsView(detailFroopData: $detailFroopData, froopAdded: $froopAdded, globalChat: $globalChat)
                            
                        case .archived:
                            FroopDetailsView(detailFroopData: $detailFroopData, froopAdded: $froopAdded, globalChat: $globalChat)
                            
                        case .pending:
                            FroopDetailsView(detailFroopData: $detailFroopData, froopAdded: $froopAdded, globalChat: $globalChat)
                            
                    }
                }
                .ignoresSafeArea()
                if payManager.showIAPView == false {
                    HStack {
                        Spacer()
                        ZStack {
                            Image(systemName: "circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.clear).opacity(0.5)
                                .background(.ultraThinMaterial)
                                .mask {
                                    Circle()
                                }
                            
                            Image(systemName: "xmark")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.trailing, 25)
                    .opacity(froopManager.froopMapOpen ? 0 : 1.0)
                    .onTapGesture {
                        if appStateManager.appState == .active && froopManager.comeFrom {
                            froopManager.froopDetailOpen = false
                            navLocationServices.selectedTab = .froop
                            navLocationServices.selectedFroopTab = .info
                            froopManager.comeFrom = false
                        } else {
                            froopManager.froopDetailOpen = false
                            froopManager.froopListener?.remove()
                        }
                    }
                    .frame(alignment: .center)
                    .padding(.top, UIScreen.screenHeight * 0.005)
                }
            }
            .presentationDetents([.large])
        }
    }
}

