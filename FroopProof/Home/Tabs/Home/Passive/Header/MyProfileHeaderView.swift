//
//  MyProfileHeaderView.swift
//  FroopProof
//
//  Created by David Reed on 8/9/23.
//

import SwiftUI
import Kingfisher
import UIKit
import Combine
import MapKit

struct MyProfileHeaderView: View {
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var dataController = DataController.shared
    @ObservedObject var changeView = ChangeView.shared
    @ObservedObject var froopData = FroopData.shared
    @ObservedObject var timerServices = TimerServices.shared
    @ObservedObject var vm = LocationSearchViewModel.shared
    @State var locationManager = LocationManager.shared
    @ObservedObject var onboardingData = OnboardingData.shared
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var viewModel: MyFroopsViewModel
    
    // @ObservedObject var froopDataListener = FroopDataListener.shared
    @ObservedObject var timeZoneManager: TimeZoneManager = TimeZoneManager()
    @ObservedObject var froopManager = FroopManager.shared
    @ObservedObject var myData = MyData.shared
    @State var froopAdded = false
    @State private var walkthroughScreen: NFWalkthroughScreen? = nil
    @Binding var showNotificationSheet: Bool
    @State private var debouncedOffsetY: CGFloat = 0
    @StateObject var navLocationServices = NavLocationServices.shared
    @StateObject var notificationsManager = NotificationsManager.shared
    @State var friendInviteList: [FriendInviteData] = []
    @Binding var globalChat: Bool
    
    var size: CGSize
    var safeArea: EdgeInsets
    @State private var now = Date()
    
    var timeUntilNextFroop: TimeInterval? {
        let nextFroops = FroopDataListener.shared.myConfirmedList.filter { $0.froopStartTime > now }
        guard let nextFroop = nextFroops.min(by: { $0.froopStartTime < $1.froopStartTime }) else {
            // There are no future Froops, so return nil
            return nil
        }
        return nextFroop.froopStartTime.timeIntervalSince(now)
    }
    
    var countdownText: String {
        if let timeUntilNextFroop = timeUntilNextFroop {
            // Use the formatDuration2 function from the timeZoneManager
            return "Next Froop in: \(timeZoneManager.formatDuration2(durationInMinutes: timeUntilNextFroop + 60))"
        } else {
            if appStateManager.currentFilteredFroopHistory.count >= 1 {
                return "Froop In Progress! \(appStateManager.appState) \(appStateManager.appStateToggle)"
            }
            return "Froops Scheduled: None"
        }
    }
    
    let hVTimer = Timer.publish(every: 15, on: .main, in: .common).autoconnect()
    
    private var headerHeight: CGFloat {
        (size.height * 0.37) + safeArea.top
    }
    
    
    init(size: CGSize, safeArea: EdgeInsets, showNotificationSheet: Binding<Bool>, globalChat: Binding<Bool>, viewModel: MyFroopsViewModel) {
        self.size = size
        self.safeArea = safeArea
        self._showNotificationSheet = showNotificationSheet
        self._globalChat = globalChat
        self.viewModel = viewModel
        
        UISegmentedControl.appearance().selectedSegmentTintColor = .white
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.gray], for: .normal)
    }
    
    var body: some View {
        ZStack {
            ZStack {
                Color.offWhite
                
                Rectangle()
                    .fill(Color(red: 50/255, green: 46/255, blue: 62/255))
                    .frame(minWidth: 0,maxWidth: .infinity, minHeight: headerHeight, maxHeight: headerHeight, alignment: .top)
                    .opacity(1)
                    .offset(y: 0)
                    .padding(.top, 20)
                    .onTapGesture {
                        
                        for froopItem in ListenerStateService.shared.froops {
                            
                            print("On Tap print ListenerStateService.shared.froops.id:", String(describing: froopItem.froopStartTime))
                            
                        }
                        
                        for historyItem in FroopManager.shared.froopHistory {
                            
                            print("On Tap print FroopManager.Shared.froopHistory.froop.id:", historyItem.froop.froopId, String(describing: historyItem.froop.froopStartTime))
                            
                        }
                    }
                    .onAppear {
                        timerServices.stopAnnotationTimer()
                    }
                
                VStack(alignment: .center) {
                    
                    HStack (alignment: .top){
                        
                        Spacer()
                        
                        VStack{
                            Text("\(eveningText()) \(myData.firstName)")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                                .fontWeight(.light)
                                .padding(.bottom, 1)
                            
                            Text("Today is: \(TimerServices.shared.formatDate(for: Date()))")
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                                .fontWeight(.thin)
                                .padding(.bottom, 1)
                            
                            Text(countdownText)
                                .onReceive(appStateManager.hVTimer) { _ in
                                    now = Date()
                                    PrintControl.shared.printTime("Timer fired and updated at \(now)")
                                }
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                                .fontWeight(.medium)
                        }
                        .padding(.top, UIScreen.screenHeight * 0.07)
                        
                        Spacer()
                    }
                    .offset(y: -35)
                }
                
                ZStack {
                    VStack {
                        Spacer()
                        Rectangle()
                            .fill(Color.white)
                            .frame(height: 75)
                            .ignoresSafeArea()
                            .opacity(1.0)
                    }
                    VStack {
                        Spacer()
                        HStack(alignment: .center) {
                            Text("CREATE")
                                .font(.system(size: 18))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .opacity(0.35)
                            
                            ZStack(alignment: .center) {
                                
                                Circle()
                                    .frame(minWidth: 70,maxWidth: 70, minHeight: 75, maxHeight: 75, alignment: .center)
                                    .foregroundColor(.white)
                                    .opacity(1)
                                
                                
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 60))
                                    .fontWeight(.thin)
                                    .foregroundColor(FroopHistoryService.shared.reportSignalSent ? .pink : Color(red: 50/255, green: 46/255, blue: 62/255))
                                
                            }
                            .onTapGesture {
                                
                                TimerServices.shared.shouldCallupdateUserLocationInFirestore = false
                                changeView.froopIsEditing = false
                                TimerServices.shared.shouldCallupdateUserLocationInFirestore = false
                                TimerServices.shared.shouldCallAppStateTransition = false
                                ChangeView.shared.pageNumber = 1
                                self.walkthroughScreen = NFWalkthroughScreen(froopAdded: $froopAdded)
                                self.changeView.showNFWalkthroughScreen = true
                            }
                            
                            Text("FROOP")
                                .font(.system(size: 18))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .opacity(0.35)
                        }
                        .offset(y: -50)
                    }
                    
                    VStack {
                        Spacer()
                        
                        ZStack {
                            Picker("", selection: $viewModel.selectedTab) {
                                Text("Home").tag(0)
                                Text("Froops").tag(1)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding(.leading, 10)
                            .padding(.trailing, 10)
                            .frame(height: 50)
                            .onChange(of: viewModel.selectedTab) { oldValue, newValue in
                                if newValue == 0 {
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        viewModel.areAllCardsExpanded = true
                                    }
                                } else {
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        viewModel.areAllCardsExpanded = false
                                    }
                                }
                                print("CardsExpanded \(viewModel.areAllCardsExpanded)")
                            }
                            ZStack {
                                if FroopDataListener.shared.myInvitesList.count > 0 {
                                    Text("(\(FroopDataListener.shared.myInvitesList.count))")
                                        .font(.system(size: 14))
                                        .fontWeight(.regular)
                                        .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255))
                                        .clipShape(Circle())
                                        .offset(x: 165, y: 2)
                                }
                            }
                        }
                    }
                }
                
            }
            .frame(height: (headerHeight), alignment: .bottom)
            
            .fullScreenCover(isPresented: $changeView.showNFWalkthroughScreen) {
                NavigationView {
                    ZStack {
                        walkthroughScreen
                    }
                    .navigationTitle("Froop Creation")
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbarBackground(Color.black.opacity(0.8), for: .navigationBar)
                    .toolbarBackground(.visible, for: .navigationBar)
                    .toolbarColorScheme(.dark, for: .navigationBar)
                    .toolbar {
                        
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: {
                                self.changeView.showNFWalkthroughScreen = false
                                froopData.resetData()
                                TimerServices.shared.shouldCallupdateUserLocationInFirestore = true
                                vm.results = []
                                vm.places = []
                                vm.showDetails = false
                                vm.queryFragment = ""
                                vm.route = nil
                                vm.routeDestination = nil
                            }) {
                                HStack (spacing: 0){
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 16))
                                        .foregroundColor(colorScheme == .dark ? .white : .white)
                                    Text("Exit")
                                        .font(.system(size: 16))
                                        .foregroundColor(colorScheme == .dark ? .white : .white)
                                        .padding(.leading, 5)
                                    Spacer()
                                }
                            }
                        }
                    }
                }
            }
            .frame(height: headerHeight)
        }
       
        .onAppear {
            let activeFroops = froopManager.froopHistory.filter { $0.froop.froopStartTime < now && $0.froop.froopEndTime > now }
            if !appStateManager.activeFroops.isEmpty {
                appStateManager.currentFilteredFroopHistory = activeFroops
                appStateManager.appState = .active
                print("AppState = .active 4")
            } else {
                appStateManager.appState = .passive
                print("AppState = .passive 4")
            }
            
            Task {
                await fetchAndSetUserTimeZone()
            }
            FroopDataController.shared.loadFroopLists(forUserWithUID: MyData.shared.froopUserID) {
                FroopDataListener.shared.myConfirmedList = FroopDataController.shared.myConfirmedList
                FroopDataListener.shared.myInvitesList = FroopDataController.shared.myInvitesList
                FroopDataListener.shared.myDeclinedList = FroopDataController.shared.myDeclinedList
                FroopDataListener.shared.myArchivedList = FroopDataController.shared.myArchivedList
                
                if appStateManager.activeOrPassiveOnAppear {
                    FroopManager.shared.createFroopHistoryArray { froopHistory in
                        
                        print("Froop History Array created 2 \(FroopManager.shared.froopHistory.count)")
                        print("CurrentFiltered Active FroopHistories:  \(String(describing: appStateManager.currentFilteredFroopHistory.count))")
                        LoadingManager.shared.froopHistoryLoaded = true
                        appStateManager.showCoverScreen = false
                    }
                    appStateManager.activeOrPassiveOnAppear = false
                }
            }
            
            FroopManager.shared.createFroopHistoryArray { froopHistory in
                appStateManager.showCoverScreen = false
                print("Froop History Array created 3 \(FroopManager.shared.froopHistory.count)")
                print("CurrentFiltered Active FroopHistories:  \(String(describing: appStateManager.currentFilteredFroopHistory.count))")
            }
        }
    }
    
    func formatDate(for date: Date) -> String {
        let localDate = TimeZoneManager.shared.convertDateToLocalTime(for: date)
        
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EE, dd MM yy, HH:mm a"
        return formatter.string(from: localDate)
    }
    
    func eveningText () -> String {
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        var greeting: String
        if hour < 12 {
            greeting = "Good Morning"
        } else if hour < 17 {
            greeting = "Good Afternoon"
        } else {
            greeting = "Good Evening"
        }
        
        return greeting
    }
    
}

@MainActor
func fetchAndSetUserTimeZone() async {
    guard let location = LocationManager.shared.userLocation else {
        print("User location is not available")
        return
    }
    let latitude = location.coordinate.latitude
    let longitude = location.coordinate.longitude
    
    if let timeZone = await TimeZoneManager.shared.fetchTimeZone(latitude: latitude, longitude: longitude) {
        print("Fetched time zone: \(timeZone.identifier)")
        TimeZoneManager.shared.userLocationTimeZone = timeZone
    } else {
        print("Failed to fetch time zone")
    }
}


struct MyProfileImage: View {
    var progress: CGFloat
    var headerHeight: CGFloat
    @ObservedObject var froopManager = FroopManager.shared
    
    var body: some View {
        GeometryReader {
            let rect = $0.frame(in: .global)
            let halfScaledHeight = (rect.height * 0.4) * 0.5
            //            let halfScaledWidth = (rect.width * 0.4) * 0.5
            let midY = rect.midY - rect.height / 2
            //            let midX = rect.midX - rect.width / 2
            let bottomPadding: CGFloat = 0
            //            let leadingPadding: CGFloat = 0
            let minimumHeaderHeight = 50
            //            let minimumHeaderWidth = 50
            let resizedOffsetY = (midY - (CGFloat(minimumHeaderHeight) - halfScaledHeight - bottomPadding))
            //            let resizedOffsetX = (midX - (CGFloat(minimumHeaderWidth) - halfScaledWidth - leadingPadding))
            
            HStack {
                Spacer()
                ZStack (alignment: .center){
                    Circle()
                        .aspectRatio(contentMode: .fit)
                        .offset(y: -resizedOffsetY * progress)
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                        .font(.system(size: 30))
                        .fontWeight(.thin)
                        .offset(y: -resizedOffsetY * progress)
                }
                .frame(width: rect.width * 0.5, height: rect.height * 0.5)
                .scaleEffect(1 - (progress * 0.6), anchor: .center)
                
                Spacer()
                
            }
            .frame(width: headerHeight * 0.35, height: headerHeight * 0.35)
        }
    }
}

