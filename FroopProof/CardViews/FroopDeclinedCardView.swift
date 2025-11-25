//
//  FroopCardView.swift
//  FroopProof
//
//  Created by David Reed on 2/6/23.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth
import MapKit


struct FroopDeclinedCardView: View {
    
    @ObservedObject private var viewModel = DetailsGuestViewModel()
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var navLocationServices = NavLocationServices.shared
    // @ObservedObject var froopDataListener = FroopDataListener.shared
    @ObservedObject var froopManager = FroopManager.shared
    @ObservedObject var friendViewController = FriendViewController.shared
    @ObservedObject var myData = MyData.shared
    @ObservedObject var timeZoneManager: TimeZoneManager = TimeZoneManager()
    @Binding var openFroop: Bool
    @State private var previousAppState: AppState?

    @State private var confirmedFriends: [UserData] = []
    @State private var declinedFriends: [UserData] = []
    @State private var invitedFriendsLocal: [UserData] = []
    @State private var identifiableInvitedFriends: [IdentifiableFriendData] = []
    @State var froopStartTime: Date? = Date()
    @State private var dataLoaded = false
    @State var myTimeZone: TimeZone = TimeZone.current
    @State private var formattedDateString: String = ""
    @State private var isBlinking = false
    @State var hostData: UserData = UserData()
    //@Binding var froopDetailOpen: Bool
    @State var invitedFriends: [UserData] = []
    let froopHostAndFriends: FroopHistory
   
    var db = FirebaseServices.shared.db
   
    var timeUntilStart: String {
        let calendar = Calendar.current
        let now = Date()

        if froopHostAndFriends.froop.froopStartTime > now {
            let components = calendar.dateComponents([.day, .hour, .minute], from: now, to: froopHostAndFriends.froop.froopStartTime)

            let days = components.day ?? 0
            let hours = components.hour ?? 0
            let minutes = components.minute ?? 0

            var timeUntilStart = "Starts in: "
            if days > 0 {
                timeUntilStart += "\(days) day(s) "
            }
            if hours > 0 {
                timeUntilStart += "\(hours) hour(s) "
            }
            if minutes > 0 {
                timeUntilStart += "\(minutes) minute(s) "
            }

            return timeUntilStart.trimmingCharacters(in: .whitespaces)
        } else {
            return "This Froop occured in the past"
        }
    }

    
    let visibleFriendsLimit = 8

    
    init(openFroop: Binding<Bool>, froopHostAndFriends: FroopHistory, invitedFriends: [UserData]) {
        self._openFroop = openFroop
        self.timeZoneManager = TimeZoneManager()
        self.froopHostAndFriends = froopHostAndFriends
        self.invitedFriends = invitedFriends

    }
    
    var body: some View {
        
        ZStack (alignment: .top) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(red: 241/255, green: 241/255, blue: 255/255))
                .shadow(color: Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.2), radius: 7, x: 7, y: 7)
                .shadow(color: Color.white.opacity(0.7), radius: 7, x: -4, y: -4)
                .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 0.5)
                    )                .frame(height: 210)
                .foregroundColor(.white)
                .padding(.leading, 10)
                .padding(.trailing, 10)
                .onTapGesture {
                    withAnimation(.spring()) {
                        openFroop = false
                    }
                }
               
            
            VStack {
                HStack {
                    Spacer()
                    if appStateManager.currentFilteredFroopHistory.contains(where: { $0.froop.froopId == froopHostAndFriends.froop.froopId }) {
                        Text("IN PROGRESS")
                            .font(.system(size: 12))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255 ))
                            .opacity(isBlinking ? 0.0 : 1.0)
                            .onChange(of: appStateManager.appState, initial: previousAppState != nil) { oldValue, newValue in
                                // Check if the newValue is different from the previous state, if necessary
                                // If they are the same, you may wish to skip any updates.
                                guard newValue != oldValue else { return }

                                // Update the previous state after processing the changes
                                previousAppState = newValue
                            }

                    }
                }
                Spacer()
            }
            .frame(height: 185)
            .padding(.top, 5)
            .padding(.trailing, 35)
            
            
            
            VStack (alignment: .leading) {
                HStack (alignment: .center){
                    HostProfilePhotoView(imageUrl: froopHostAndFriends.host.profileImageUrl)
                        .scaledToFill()
                        .frame(width: 65, height: 35)
                        .padding(.leading, 5)
                       
                    
                    VStack (alignment: .leading) {
                        Text(froopHostAndFriends.froop.froopName)
                            .font(.system(size: 16))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                            .frame(alignment: .leading)
                        
                        Text(timeUntilStart)
                            .font(.system(size: 14))
                            .fontWeight(.regular)
                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                            .frame(alignment: .leading)
//                            .padding(.top, 5)
                        
                        Text("Host: \(froopHostAndFriends.host.firstName) \(froopHostAndFriends.host.lastName)")
                            .font(.system(size: 14))
                            .fontWeight(.light)
                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                            .multilineTextAlignment(.leading)
                    }
                    Spacer()
                    
                    VStack (alignment: .center) {
                        ZStack {
                            Rectangle()
                                .foregroundColor(.clear)
                                .background(.ultraThinMaterial)
                                .frame(width: 50, height: 50)
                            
                            Image(systemName: "rectangle.expand.vertical")
                                .font(.system(size: 24))
                                .fontWeight(.light)
                                .foregroundColor(Color(red: 255/255, green: 49/255, blue: 97/255))
                                .frame(alignment: .leading)
                            
                        }
                    }
                    .padding(.trailing, 30)
                    .onTapGesture {
                        if appStateManager.appState == .active && appStateManager.currentFilteredFroopHistory.contains(where: { $0.froop.froopId == froopHostAndFriends.froop.froopId }) {
                            navLocationServices.selectedTab = .froop
                            appStateManager.findFroopById(froopId: froopHostAndFriends.froop.froopId) { found in
                                if found {
                                    navLocationServices.selectedTab = .froop
                                } else {
                                    froopManager.froopDetailOpen = true
                                    PrintControl.shared.printLists("ImageURL:  \(froopHostAndFriends.froop.froopHostPic)")
                                }
                            }
                        } else {
                            froopManager.selectedFroopUUID = froopHostAndFriends.froop.froopId
                            froopManager.froopDetailOpen = true
                            PrintControl.shared.printLists("ImageURL:  \(froopHostAndFriends.froop.froopHostPic)")
                        }
                    }
                }
                .frame(height: 50)
                .padding(.top, 10)
                .padding(.leading, 10)
                
                Divider()
                    .padding(.leading, 15)
                    .padding(.trailing, 15)
                    .padding(1)
                    .padding(1)
                VStack (alignment: .leading) {
                    HStack {
                        Image(systemName: "clock")
                            .frame(width: 65, height: 30)
                            .scaledToFill()
                            .font(.system(size: 24))
                            .fontWeight(.light)
                            .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255 ))
                       
                        Text(formatDate(for: froopHostAndFriends.froop.froopStartTime))
                            .font(.system(size: 16))
                            .fontWeight(.medium)
                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                            .padding(.leading, -15)
                        Spacer()
                    }
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                            .frame(width: 65, height: 30)
                            .scaledToFill()
                            .font(.system(size: 24))
                            .fontWeight(.light)
                            .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255 ))
                        VStack (alignment: .leading){
                            Text(froopHostAndFriends.froop.froopLocationtitle)
                                .font(.system(size: 16))
                                .fontWeight(.medium)
                                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                            Text(froopHostAndFriends.froop.froopLocationsubtitle)
                                .font(.system(size: 14))
                                .fontWeight(.light)
                                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                .lineLimit(2)
                                .padding(.trailing, 25)
                        }
                        .padding(.leading, -15)
                        Spacer()
                    }
                }
                .padding(.leading, 5)
                
//                Spacer()
            }
            .onAppear {

                PrintControl.shared.printLists("Printing Date \(froopHostAndFriends.froop.froopStartTime)")
                timeZoneManager.convertUTCToCurrent(date: froopHostAndFriends.froop.froopStartTime, currentTZ: TimeZone.current.identifier) { convertedDate in
                    formattedDateString = timeZoneManager.formatDate(passedDate: convertedDate)
                }
            }

        }
        .frame(height: 210)

    }
        
    func printFroop () {
        print(froopHostAndFriends.froop)
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
    
    func loadInvitedFriends() {
        let uid = FirebaseServices.shared.uid
        let froopRef = db.collection("users").document(uid).collection("myFroops").document(froopHostAndFriends.froop.froopId).collection("invitedFriends").document("inviteList")

        froopRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let invitedFriendUIDs = document.data()?["uid"] as? [String] ?? []
                self.fetchFriendsData(from: invitedFriendUIDs) { invitedFriends in
                    self.invitedFriends = invitedFriends
                }
            } else {
                print("No friends found in the invite list.")
            }
        }
    }


    func loadDeclinedFriends() {
        let uid = FirebaseServices.shared.uid
        let froopRef = db.collection("users").document(uid).collection("myFroops").document(froopHostAndFriends.froop.froopId).collection("invitedFriends").document("declinedList")

        froopRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let declinedFriendUIDs = document.data()?["uid"] as? [String] ?? []
                self.fetchFriendsData(from: declinedFriendUIDs) { declinedFriends in
                    self.declinedFriends = declinedFriends
                }
            } else {
                print("No friends found in the declined list.")
            }
        }
    }
    

    func fetchFriendsData(from friendUIDs: [String], completion: @escaping ([UserData]) -> Void) {
     
        let usersRef = db.collection("users")
        var friends: [UserData] = []

        let group = DispatchGroup()

        for friendUID in friendUIDs {
            group.enter()

            usersRef.document(friendUID).getDocument { document, error in
                if let document = document, document.exists, let friendData = document.data() {
                    let friend = UserData(dictionary: friendData)
                    friends.append(friend ?? UserData())
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            completion(friends)
        }
    }
    
    func formatDate(for date: Date) -> String {
        let localDate = TimeZoneManager.shared.convertDateToLocalTime(for: date)

        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, dd MMMM yyyy"   
        return formatter.string(from: localDate)
    }
    
    func formatDateToTimeZone(passedDate: Date, timeZone: TimeZone) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d',' h:mm a"
        dateFormatter.timeZone = timeZone
        return dateFormatter.string(from: passedDate)
    }
}



