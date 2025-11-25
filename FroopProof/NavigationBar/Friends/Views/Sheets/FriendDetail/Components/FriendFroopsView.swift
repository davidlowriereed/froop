
//  FriendFroopsView.swift
//  FroopProof
//
//  Created by David Reed on 5/18/23.


import SwiftUI

struct FriendFroopsView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var navLocationServices = NavLocationServices.shared
    @ObservedObject var friendRequestManager = FriendRequestManager.shared
    // @ObservedObject var froopDataListener = FroopDataListener.shared
    @ObservedObject var froopManager = FroopManager.shared
    @ObservedObject var timeZoneManager:TimeZoneManager = TimeZoneManager()
    
    @ObservedObject var myData = MyData.shared
    @ObservedObject var changeView = ChangeView()
    @ObservedObject var froopData = FroopData.shared
    @State private var thisFroopType: String = ""
    
    @State private var froopFeed: [FroopHostAndFriends] = []
    @State private var walkthroughScreen: NFWalkthroughScreen? = nil
    @State var showSheet = false
    @State var froopAdded = false
    @State var showNFWalkthroughScreen = false
    @State private var currentIndex: Int = 0
    @State private var now = Date()
    @State private var loadIndex = 0
    @State private var isFroopFetchingComplete = false
    @Binding var friendDetailOpen: Bool
    
    
    var filteredFroopsForSelectedFriend: [FroopHistory] {
        let currentUserId = FirebaseServices.shared.uid // Fetch current user's UID
        
        return froopManager.froopHistory.filter {
            !$0.images.isEmpty &&
            $0.confirmedFriends.contains(where: { $0.froopUserID == currentUserId }) &&
            $0.confirmedFriends.contains(where: { $0.froopUserID == friendRequestManager.selectedFriend.froopUserID }) &&
            $0.host.froopUserID != "froop"
        }
    }

    
    var filteredFroopsForFroopFriend: [FroopHistory] {
        return froopManager.froopHistory.filter {
            $0.host.froopUserID == "froop"
        }
    }
    
    var sortedFroopsForSelectedFriend: [FroopHistory] {
        return filteredFroopsForSelectedFriend.sorted(by: { $0.froop.froopStartTime > $1.froop.froopStartTime })
    }
    
    let hVTimer = Timer.publish(every: 15, on: .main, in: .common).autoconnect()
    
    
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
            if AppStateManager.shared.appState == .active {
                return "Froop In Progress!"
            }
            return "No Froops Scheduled"
        }
    }
    
    var walkthroughView: some View {
        walkthroughScreen
            .environmentObject(changeView)
            .environmentObject(froopData)
    }
    
    var sortedIndices: [Int] {
        return froopManager.froopFeed.indices.sorted(by: { froopManager.froopFeed[$0].FH.froop.froopStartTime > froopManager.froopFeed[$1].FH.froop.froopStartTime })
    }
    
    
    init(friendDetailOpen: Binding<Bool>) {
        _friendDetailOpen = friendDetailOpen
        froopManager.fetchFroopData(fuid: friendRequestManager.selectedFriend.froopUserID)
    }
    
    var body: some View {
        ZStack (alignment: .top){
            backgroundRectangle
            content
        }
    }
    
    private var backgroundRectangle: some View {
        Rectangle()
            .frame(height: 1200)
            .foregroundColor(.white)
            .opacity(0.001)
    }
    
    private var content: some View {
        if sortedFroopsForSelectedFriend.count == 0 {
            return AnyView(emptyContent)
        } else {
            return AnyView(nonEmptyContent)
        }
    }
    
    private var emptyContent: some View {
        Text(froopManager.froopHistory.isEmpty ? "Your friend's Froops will show up here if they have decided to share them with their community." : "")
            .foregroundColor(colorScheme == .dark ? .white: Color(red: 50/255, green: 46/255, blue: 62/255))
            .font(.system(size: 20))
            .fontWeight(.regular)
            .frame(width: UIScreen.screenWidth - 100)
            .padding(.leading, 25)
            .padding(.trailing, 25)
            .padding(.top, 100)
    }
    
    private var nonEmptyContent: some View {
        VStack {
            lazyVStackContent
            Spacer()
        }
    }
    private var lazyVStackContent: some View {
        LazyVStack (alignment: .leading, spacing: 0) {
            ForEach(sortedFroopsForSelectedFriend, id: \.self, content: { index in
                MyCardsView(froopHistory: index, thisFroopType: thisFroopType, friendDetailOpen: $friendDetailOpen)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            // Increment the current index when a card finishes loading
                            currentIndex += 1
                        }
                    }
            })
        }
        .ignoresSafeArea()
        .onAppear {
            print("Number of froops in sortedFroopsForSelectedFriend: \(sortedFroopsForSelectedFriend.count)")
            print("Number of froops in froopFeed: \(froopManager.froopHistory.count)")
        }
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
    func formatTime(creationTime: Date) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .hour, .day]
        formatter.unitsStyle = .abbreviated
        
        let currentTime = Date()
        let timeSinceCreation = currentTime.timeIntervalSince(creationTime)
        
        let formattedTime = formatter.string(from: timeSinceCreation) ?? ""
        
        return formattedTime
    }
    
}



