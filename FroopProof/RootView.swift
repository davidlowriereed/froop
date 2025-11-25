//
//  RootView.swift
//  FroopProof
//
//  Created by David Reed on 2/11/23.
//

import SwiftUI
import Kingfisher
import FirebaseAuth
import AVKit
import FirebaseAuth


struct RootView: View {
    @AppStorage("ProfileCompletionCurrentPage") var ProfileCompletionCurrentPage = 1
    @Environment(\.colorScheme) var colorScheme
    @StateObject var firebaseServices = FirebaseServices.shared
    @StateObject var froopManager = FroopManager.shared
    @StateObject var froopHistoryService = FroopHistoryService.shared
    @StateObject var appStateManager = AppStateManager.shared
    @StateObject var navLocationServices = NavLocationServices.shared
    @StateObject var notificationsManager = NotificationsManager.shared
    @StateObject var printControl = PrintControl.shared
    @StateObject var froopDataController = FroopDataController.shared
    @StateObject var timeZoneManager = TimeZoneManager()
    @StateObject var mediaManager = MediaManager()
    @StateObject var locationSearchViewModel = LocationSearchViewModel()
    @StateObject var froopData = FroopData()
    @StateObject var invitationList: InvitationList = InvitationList(uid: FirebaseServices.shared.uid)
    @StateObject var changeView = ChangeView.shared
    @State private var showNavigationDropdown = false
    @ObservedObject var friendData: UserData
    @ObservedObject var photoData = PhotoData()
    @ObservedObject var myData = MyData.shared
    @ObservedObject var confirmedFroopsList: ConfirmedFroopsList
    @ObservedObject var onboardingData = OnboardingData.shared
    @ObservedObject var payManager = PayWallManager.shared
    @ObservedObject var model: PaywallModel = PaywallModel(dictionary: [:])
    
    //    @ObservedObject var versionChecker: VersionChecker = VersionChecker.shared
    @State var statusX: String = "pending"
    @State var selectedTab: Tab = .froop
    @State var froopTabPosition: Int = 1
    @State var areThereFriendRequests: Bool = false
    @State var uploadedMedia: [MediaData] = []
    @State var friendInviteList: [FriendInviteData] = []
    @State var globalChat: Bool = true
    @State var openGlobalChat: Bool = false
    @State var updateView: Bool = false
    @State private var currentHighlight: Int = 0
    
    
    var uid = Auth.auth().currentUser?.uid ?? ""
    var player: AVPlayer? {
        if let url = URL(string: froopManager.selectedFroopHistory.froop.froopIntroVideo) {
            return AVPlayer(url: url)
        } else {
            return nil
        }
    }
    
    private var selectedTabBinding: Binding<Tab> {
        Binding(
            get: { NavLocationServices.shared.selectedTab },
            set: { NavLocationServices.shared.selectedTab = $0 }
        )
    }
    
    var appDelegate: AppDelegate = AppDelegate()
    
    init(friendData: UserData, photoData: PhotoData, appDelegate: AppDelegate, confirmedFroopsList: ConfirmedFroopsList) {
        UITabBar.appearance().isHidden = false
        self.friendData = friendData
        self.photoData = photoData
        self.appDelegate = appDelegate
        self.confirmedFroopsList = confirmedFroopsList
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                if ProfileCompletionCurrentPage != 2 {
                    OnboardingView(ProfileCompletionCurrentPage: $ProfileCompletionCurrentPage)
                } else {
                    NavigationView {
                        ZStack {
                            Color.offWhite
                            VStack{
                                if NavLocationServices.shared.selectedTab == .froop {
                                    FroopTabView(friendData: friendData, viewModel: MediaGridViewModel(), uploadedMedia: $uploadedMedia, thisFroop: Froop.emptyFroop(), froopTabPosition: $froopTabPosition, globalChat: $globalChat)
                                        .tag(Tab.froop)
                                }
                            }
                        }
                        .ignoresSafeArea()
                        .navigationTitle(myData.premiumAccount ? "Froop Premium" : "Froop")
                        .foregroundColor(colorScheme == .dark ? .white : Color(red: 255/255 ,green: 255/255,blue: 255/255))
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbarBackground(Color.black.opacity(0.8), for: .navigationBar)
                        .toolbarBackground(.visible, for: .navigationBar)
                        .toolbarColorScheme(.dark, for: .navigationBar)
                        .navigationBarItems(leading: leadingNavigationBarItem(), trailing: trailingNavigationBarItem())
                        
                    }
                    .onAppear {
                        FriendViewController.shared.findFriendInvites(thisUser: Auth.auth().currentUser?.uid ?? "", statusX: statusX) { friendInviteList, error in
                            if let error = error {
                                PrintControl.shared.printErrorMessages("Error fetching friend invites: \(error.localizedDescription)")
                                return
                            }
                            self.friendInviteList = friendInviteList
                        }
                        PrintControl.shared.printStartUp("RootView Appear")
                    }
                    .onChange(of: appStateManager.appState) { oldValue, newValue in
                        if newValue == .active {
                            appStateManager.appStateToggle = true
                            print("appStateToggle 2")
                            
                        }
                    }
                    .onChange(of: myData.myFriends) { oldValue, newValue in
                        if newValue != oldValue {
                            myData.processApprovedFriendRequests(forUID: Auth.auth().currentUser?.uid ?? "")
                        }
                    }
                    .fullScreenCover(isPresented: $appStateManager.openGlobalChat) {
                    } content: {
                        FroopGlobalMessagesView(globalChat: $globalChat)
                    }
                }
                
                Group {
                    switch appStateManager.currentViewID {
                        case .home:
                            ZStack {
                                // Show ribbon if onboarding hasn't been completed and we haven't started
                                if !onboardingData.homeOnboarding && !appStateManager.hasRespondedToRibbon {
                                    SlideInRibbonView(showRibbon: $appStateManager.showHomeRibbon)
                                        .zIndex(1000)
                                        .transition(.move(edge: .bottom))
                                }
                                
                                // Show onboarding after user has responded to ribbon
                                if appStateManager.showHomeOnboarding && appStateManager.hasRespondedToRibbon {
                                    OnboardingContainerView()
                                    OverlayView(showFace: appStateManager.showFace, showFaceText: appStateManager.showFaceText)
                                }
                            }
                            .onChange(of: appStateManager.hasRespondedToRibbon) { _, newValue in
                                if newValue {
                                    withAnimation(.easeInOut) {
                                        appStateManager.showHomeRibbon = false
                                    }
                                }
                            }
                            
                        case .friends:
                            // Similar pattern for friends...
                            ZStack {
                                if !onboardingData.friendsOnboarding && !appStateManager.hasRespondedToRibbon {
                                    SlideInRibbonView(showRibbon: $appStateManager.showFriendsRibbon)
                                        .zIndex(1000)
                                        .transition(.move(edge: .bottom))
                                }
                                
                                if appStateManager.showFriendsOnboarding && appStateManager.hasRespondedToRibbon {
                                    OnboardingContainerView()
                                    OverlayView(showFace: appStateManager.showFace, showFaceText: appStateManager.showFaceText)
                                }
                            }
                            .onChange(of: appStateManager.hasRespondedToRibbon) { _, newValue in
                                if newValue {
                                    withAnimation(.easeInOut) {
                                        appStateManager.showFriendsRibbon = false
                                    }
                                }
                            }
                            
                        default:
                            EmptyView()
                    }
                }
                .animation(.spring(), value: appStateManager.currentViewID)
                
                
                CoverScreen()
            }
            
            .ignoresSafeArea()
        }
        
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                appStateManager.updateRibbonState(for: appStateManager.currentViewID)
            }
        }
        .onChange(of: appStateManager.currentViewID) { _, newValue in
            appStateManager.updateRibbonState(for: newValue)
        }
        .onChange(of: notificationsManager.openGlobalChat) {
            print("☎️ \(String(describing: notificationsManager.openGlobalChat))")
            print("☎️☎️ \(String(describing: appStateManager.openGlobalChat))")
        }
        
        .onChange(of: appStateManager.openGlobalChat) {
            print("🧯 \(String(describing: notificationsManager.openGlobalChat))")
            print("🧯🧯 \(String(describing: appStateManager.openGlobalChat))")
        }
    }
}

struct OverlayView: View {
    let showFace: Bool
    let showFaceText: Bool
    
    var body: some View {
        HStack {
            VStack {
                Image(systemName: "face.smiling.inverse")
                    .foregroundColor(.white)
                    .font(.system(size: 40))
                    .frame(width: 25, height: 25)
                    .padding(.top, 10)
                    .opacity(showFace ? 1.0 : 0.0)
                
                Text("Tap Anywhere to Start.")
                    .foregroundColor(.white)
                    .font(.system(size: 16))
                    .fontWeight(.thin)
                    .padding(.top, 20)
                    .opacity(showFaceText ? 1.0 : 0.0)
            }
        }
    }
}

extension RootView {
    @ViewBuilder
    private func leadingNavigationBarItem() -> some View {
        if appStateManager.appStateToggle && navLocationServices.selectedFroopTab == .map {
            Button(action: MapManager.shared.onAddPinButtonTapped) {
                HStack(spacing: 2) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 18))
                        .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255))
                    Text("+")
                        .fontWeight(.semibold)
                        .font(.system(size: 18))
                        .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255))
                }
            }
        } else {
            ZStack {
                Image(systemName: "person.2.fill")
                    .foregroundColor(.white)
                    .opacity(notificationsManager.totalUnreadMessages > 0 ? 1.0 : 0.75)
                Text("\(friendInviteList.count)")
                    .fontWeight(.semibold)
                    .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255))
                    .offset(x: 15, y: -15)
                    .opacity(friendInviteList.count > 0 ? 1.0 : 0.0)
//                Text("\(notificationsManager.totalUnreadMessages)")
//                    .fontWeight(.light)
//                    .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255))
//                    .offset(y: -2)
//                    .opacity(notificationsManager.totalUnreadMessages > 0 ? 1.0 : 0)
            }
            .onTapGesture {
                if notificationsManager.openGlobalChat == false {
                    notificationsManager.openGlobalChat = true
                    appStateManager.openGlobalChat = true
                    print("tapping \(String(describing: notificationsManager.openGlobalChat)) \(String(describing: appStateManager.openGlobalChat))")
                }
            }
        }
    }
    
    @ViewBuilder
    private func trailingNavigationBarItem() -> some View {
        if appStateManager.appStateToggle && navLocationServices.selectedFroopTab == .map {
            NavigationAppsButton()
        } else {
            NavigationLink(destination: ProfileView(globalChat: $globalChat)) {
                profileImageLinkView()
            }
        }
    }
    
    // New struct for the Navigation Apps Button
    struct NavigationAppsButton: View {
        @State private var showNavigationDropdown = false
        
        var body: some View {
            ZStack(alignment: .topTrailing) {
                Button(action: {
                    showNavigationDropdown = true
                }) {
                    Image(systemName: "arrow.up.left.and.down.right.and.arrow.up.right.and.down.left")
                        .foregroundColor(.white)
                        .frame(width: 35, height: 35)
                }
                
                if showNavigationDropdown {
                    NavigationAppsDropdown(isShowing: $showNavigationDropdown)
                    //                        .offset(y: 250) // Adjust this value to position the dropdown below the button
                }
            }
        }
    }
    
    @ViewBuilder
    private func profileImageLinkView() -> some View {
        ZStack {
            KFImage(URL(string: MyData.shared.profileImageUrl))
                .resizable()
                .scaledToFill()
                .clipShape(Circle())
                .frame(width: 35, height: 35)
            Text("\(friendInviteList.count)")
                .fontWeight(.semibold)
                .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255))
                .offset(x: 15, y: -15)
                .opacity(friendInviteList.count > 0 ? 1.0 : 0.0)
        }
    }
}

extension MyProfileHeaderView {
    @ViewBuilder
    func leadingNavigationBarItem() -> some View {
        if appStateManager.appStateToggle && navLocationServices.selectedFroopTab == .map {
            Button(action: MapManager.shared.onAddPinButtonTapped) {
                HStack(spacing: 2) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 18))
                        .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255))
                    Text("+")
                        .fontWeight(.semibold)
                        .font(.system(size: 18))
                        .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255))
                }
            }
        } else {
            ZStack {
                Image(systemName: "person.2.fill")
                    .foregroundColor(.white)
                    .opacity(notificationsManager.totalUnreadMessages > 0 ? 1.0 : 0.75)
                Text("\(friendInviteList.count)")
                    .fontWeight(.semibold)
                    .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255))
                    .offset(x: 15, y: -15)
                    .opacity(friendInviteList.count > 0 ? 1.0 : 0.0)
//                Text("\(notificationsManager.totalUnreadMessages)")
//                    .fontWeight(.light)
//                    .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255))
//                    .offset(y: -2)
//                    .opacity(notificationsManager.totalUnreadMessages > 0 ? 1.0 : 0)
            }
            .onTapGesture {
                if notificationsManager.openGlobalChat == false {
                    notificationsManager.openGlobalChat = true
                    appStateManager.openGlobalChat = true
                }
            }
        }
    }
    
    //    @ViewBuilder
    //    func trailingNavigationBarItem() -> some View {
    //        if appStateManager.appStateToggle && navLocationServices.selectedFroopTab == .map {
    //            Image("wazeLogoRound")
    //                .resizable()
    //                .scaledToFill()
    //                .clipShape(Circle())
    //                .frame(width: 35, height: 35)
    //                .onTapGesture {
    //                    MapManager.shared.openWaze()
    //                }
    //        } else {
    //            NavigationLink(destination: ProfileView(globalChat: $globalChat)) {
    //                profileImageLinkView()
    //            }
    //        }
    //    }
    
    @ViewBuilder
    private func profileImageLinkView() -> some View {
        ZStack {
            KFImage(URL(string: MyData.shared.profileImageUrl))
                .resizable()
                .scaledToFill()
                .clipShape(Circle())
                .frame(width: 35, height: 35)
            Text("\(friendInviteList.count)")
                .fontWeight(.semibold)
                .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255))
                .offset(x: 15, y: -15)
                .opacity(friendInviteList.count > 0 ? 1.0 : 0.0)
        }
    }
}
