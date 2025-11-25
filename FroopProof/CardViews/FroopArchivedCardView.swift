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
import EventKit


struct FroopArchivedCardView: View {
    
    @ObservedObject private var viewModel = DetailsGuestViewModel()
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var navLocationServices = NavLocationServices.shared
    @ObservedObject var froopHistoryWrapper: FroopHistoryWrapper
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
//    @State var hostData: UserData = UserData()
    //@Binding var froopDetailOpen: Bool
    @State var invitedFriends: [UserData] = []
    @State private var showAlert = false
    
    let uid = FirebaseServices.shared.uid
    let db = FirebaseServices.shared.db
    
    var isCurrentUserInvited: Bool {
        // Check if the currentUserUID exists in the invitedFriends array of froopHostAndFriends
        return froopHistoryWrapper.froopHistory.invitedFriends.contains { friend in
            friend.froopUserID == uid
        }
    }
    
    var timeUntilStart: String {
        let calendar = Calendar.current
        let now = Date()
        
        if froopHistoryWrapper.froopHistory.froop.froopStartTime > now {
            let components = calendar.dateComponents([.day, .hour, .minute], from: now, to: froopHistoryWrapper.froopHistory.froop.froopStartTime)
            
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
    
    init(openFroop: Binding<Bool>, froopHistoryWrapper: FroopHistoryWrapper) {
        self._openFroop = openFroop
        self.froopHistoryWrapper = froopHistoryWrapper
        self.timeZoneManager = TimeZoneManager()
    }
    
    var body: some View {
        
        ZStack (alignment: .top) {
            RoundedRectangle(cornerRadius: 10)
                .fill(
                    LinearGradient(gradient: Gradient(colors: [Color(red: 255/255, green: 255/255, blue: 255/255), Color(red: 244/255, green: 250/255, blue: 255/255)]), startPoint: .top, endPoint: .bottom)
                )                .shadow(color: Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.2), radius: 7, x: 7, y: 7)
                .shadow(color: Color.white.opacity(0.7), radius: 7, x: -4, y: -4)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 0.5)
                )
                .frame(height: 210)
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
                    if appStateManager.currentFilteredFroopHistory.contains(where: { $0.froop.froopId == froopHistoryWrapper.froopHistory.froop.froopId }) {
                        Text("IN PROGRESS")
                            .font(.system(size: 12))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255 ))
                            .opacity(1.0)
                            .onChange(of: appStateManager.appState, initial: previousAppState != nil) { oldValue, newValue in
                                // Check if the newValue is different from the previous state, if necessary
                                // If they are the same, you may wish to skip any updates.
                                guard newValue != oldValue else { return }
                                
                                withAnimation(Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                                    self.isBlinking = true
                                }
                                
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
                    HostProfilePhotoView(imageUrl: froopHistoryWrapper.froopHistory.host.profileImageUrl)
                        .scaledToFill()
                        .frame(width: 65, height: 35)
                        .padding(.leading, 5)
                    
                    
                    VStack (alignment: .leading) {
                        Text(froopHistoryWrapper.froopHistory.froop.froopName)
                            .font(.system(size: UIScreen.screenHeight < 925 ? 14 : 16))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                            .frame(alignment: .leading)
                        
                        Text(timeUntilStart)
                            .font(.system(size: UIScreen.screenHeight < 925 ? 11 : 14))
                            .fontWeight(.regular)
                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                            .frame(alignment: .leading)
                        //                            .padding(.top, 5)
                        
                        Text("Host: \(froopHistoryWrapper.froopHistory.host.firstName) \(froopHistoryWrapper.froopHistory.host.lastName)")
                            .font(.system(size: UIScreen.screenHeight < 925 ? 11 : 14))
                            .fontWeight(.light)
                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                            .multilineTextAlignment(.leading)
                    }
                    Spacer()
                    
                    if isCurrentUserInvited {
                        
                        VStack (alignment: .center) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(isCurrentUserInvited ? Color(red: 255/255, green: 0/255, blue: 98/255)
                                          : Color(red: 0/255, green: 223/255, blue: 252/255))
                                    .opacity(isCurrentUserInvited ? 1.0 : 0.5)
                                    .frame(width: 50, height: 50)
                                    .shadow(color: Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.4), radius: 4, x: 4, y: 4)
                                    .shadow(color: Color.white.opacity(0.9), radius: 4, x: -4, y: -4)
                                
                                VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, content: {
                                    Text("Join")
                                        .font(.system(size: 14))
                                        .fontWeight(.bold)
                                        .foregroundColor(Color.white)
                                })
                                
                            }
                        }
                        .padding(.trailing, 30)
                        .onTapGesture {
                            print("join button tapped")
                            FroopDataController.shared.moveArchivedInvitation(uid: uid, froopId: froopHistoryWrapper.froopHistory.froop.froopId, froopHost: froopHistoryWrapper.froopHistory.host.froopUserID)
                            createCalendarEvent()
                        }
                        
                    } else {
                        
                        VStack (alignment: .center) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(red: 50/255, green: 46/255, blue: 62/255))
                                    .opacity(1.0)
                                    .frame(width: 50, height: 50)
                                    .shadow(color: Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.4), radius: 4, x: 4, y: 4)
                                    .shadow(color: Color.white.opacity(0.9), radius: 4, x: -4, y: -4)
                                
                                VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, content: {
                                    Text("View")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white)
                                        .fontWeight(.light)
                                        .foregroundColor(Color.white)
                                })
                                
                            } // View Button
                        }
                        .padding(.trailing, 30)
                        .onTapGesture {
                            print("App State:  \(appStateManager.appState)")
                            
                            if appStateManager.appState == .passive {
                                print("Status froopManager:  \(froopManager.selectedFroopHistory.froopStatus)")
                            } else {
                                let startTime = froopHistoryWrapper.froopHistory.froop.froopStartTime
                                let endTime = froopHistoryWrapper.froopHistory.froop.froopEndTime
                                let currentTime = appStateManager.now
                                
                                if timeZoneManager.userLocationTimeZone != nil {
                                    if currentTime > startTime && currentTime < endTime {
                                        print("Status appStateManager: \(String(describing: appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froopStatus))")
                                    } else {
                                        print("Froop Manager: \(froopManager.selectedFroopHistory.froopStatus)")
                                    }
                                }
                            }
                            
                            appStateManager.appStateToggle = false
                            let froopHistoryInstance = froopManager.froopHistory[0]
                            print(froopHistoryInstance)
                            
                            if appStateManager.appState == .active && appStateManager.currentFilteredFroopHistory.contains(where: { $0.froop.froopId == froopHistoryWrapper.froopHistory.froop.froopId }) {
                                navLocationServices.selectedTab = .froop
                                appStateManager.findFroopById(froopId: froopHistoryWrapper.froopHistory.froop.froopId) { found in
                                    if found {
                                        navLocationServices.selectedTab = .froop
                                    } else {
                                        froopManager.selectedFroopHistory = froopHistoryWrapper.froopHistory
                                        froopManager.selectedFroopUUID = froopHistoryWrapper.froopHistory.froop.froopId
                                        froopManager.froopDetailOpen = true
                                        PrintControl.shared.printLists("ImageURL:  \(froopHistoryWrapper.froopHistory.froop.froopHostPic)")
                                    }
                                }
                            } else {
                                froopManager.selectedFroopHistory = froopHistoryWrapper.froopHistory
                                froopManager.selectedFroopUUID = froopHistoryWrapper.froopHistory.froop.froopId
                                froopManager.froopDetailOpen = true
                                PrintControl.shared.printLists("ImageURL:  \(froopHistoryWrapper.froopHistory.froop.froopHostPic)")
                            }
                        }
                }
                        
                    }
                    .frame(height: 50)
                    .padding(.top, 10)
                    .padding(.leading, 10)
                    
                    Divider()
                        .padding(.leading, 15)
                        .padding(.trailing, 100)
                        .padding(1)
                        .padding(1)
                HStack {
                    VStack (alignment: .leading) {
                        HStack {
                            Image(systemName: "clock")
                                .frame(width: 65, height: 30)
                                .scaledToFill()
                                .font(.system(size: 24))
                                .fontWeight(.light)
                                .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255 ))
                            
                            Text(formatDate(for: froopHistoryWrapper.froopHistory.froop.froopStartTime))
                                .font(.system(size: UIScreen.screenHeight < 925 ? 14 : 16))
                                .fontWeight(.medium)
                                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                .padding(.leading, -15)
                            Spacer()
                        } // Clock Icon and Frop Time
                        HStack {
                            Image(systemName: "mappin.and.ellipse")
                                .frame(width: 65, height: 30)
                                .scaledToFill()
                                .font(.system(size: 24))
                                .fontWeight(.light)
                                .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255 ))
                            VStack (alignment: .leading){
                                Text(froopHistoryWrapper.froopHistory.froop.froopLocationtitle)
                                    .font(.system(size: UIScreen.screenHeight < 925 ? 14 : 16))
                                    .fontWeight(.medium)
                                    .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                Text(froopHistoryWrapper.froopHistory.froop.froopLocationsubtitle)
                                    .font(.system(size: UIScreen.screenHeight < 925 ? 11 : 14))
                                    .fontWeight(.light)
                                    .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                    .lineLimit(2)
                                    .padding(.trailing, 25)
                            }
                            .padding(.leading, -15)
                            Spacer()
                        } // Map Pin Icon and Location
                    }
                    .frame(height: 120)
                    
                    VStack {
                        
                        if froopHistoryWrapper.froopHistory.host.premiumAccount || froopHistoryWrapper.froopHistory.host.professionalAccount {
                            VStack {
                                if froopHistoryWrapper.froopHistory.froop.froopHost == uid {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color(red: 249/255, green: 0/255, blue: 98/255))
                                            .frame(width: 50, height: 50)
                                            .shadow(color: Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.4), radius: 4, x: 4, y: 4)
                                            .shadow(color: Color.white.opacity(0.9), radius: 4, x: -4, y: -4)
                                        VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, content: {
                                            Text("Share")
                                                .font(.system(size: 14))
                                                .fontWeight(.light)
                                                .foregroundColor(.white)
                                        })
                                    }
                                    .padding(.trailing, 30)
                                    .frame(width: 80)
                                    .onTapGesture {
                                        froopManager.selectedFroopHistory = froopHistoryWrapper.froopHistory
                                        froopManager.showInviteUrlView = true
                                    }
                                }
                            }
                        } else {
                            EmptyView()
                        } // Share Button
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.white)
                                .frame(width: 50, height: 50)
                                .shadow(color: Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.4), radius: 4, x: 4, y: 4)
                                .shadow(color: Color.white.opacity(0.9), radius: 4, x: -4, y: -4)
                            VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, content: {
                                Text(froopHistoryWrapper.froopHistory.froop.hidden.contains(uid) ? "Unhide" : "Hide")
                                    .font(.system(size: 14))
                                    .fontWeight(.light)
                                    .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                            })
                        } // Hide Button
                        .padding(.trailing, 30)
                        .padding(.top, 10)
                        .frame(width: 80)
                        .onTapGesture {
                            Task {
                                do {
                                    if froopHistoryWrapper.froopHistory.froop.hidden.contains(uid) {
                                        try await froopManager.removeCurrentUserFromHiddenArray(froopUserID: froopHistoryWrapper.froopHistory.froop.froopHost, froopId: froopHistoryWrapper.froopHistory.froop.froopId)
                                    } else {
                                        try await froopManager.addCurrentUserToHiddenArray(froopUserID: froopHistoryWrapper.froopHistory.froop.froopHost, froopId: froopHistoryWrapper.froopHistory.froop.froopId)
                                    }
                                } catch {
                                    // Handle the error here
                                    print("🚫Error occurred: \(error)")
                                }
                            }
                        }
                        Spacer()
                    }
                    .frame(height: 120)
                }
                .frame(height: 120)
                .padding(.leading, 5)
                    
                }
                .onAppear {
                    PrintControl.shared.printLists("Printing Date \(froopManager.selectedFroopHistory.froop.froopStartTime )")
                    timeZoneManager.convertUTCToCurrent(date: froopManager.selectedFroopHistory.froop.froopStartTime , currentTZ: TimeZone.current.identifier) { convertedDate in
                        formattedDateString = timeZoneManager.formatDate(passedDate: convertedDate)
                    }
                }
        }
        .frame(height: 210)

        .alert(isPresented: $showAlert) {
            Alert(title: Text("Geofence Alert"), message: Text("This Froop has been added to your calendar."), dismissButton: .default(Text("OK")))
        }
    }
    
    func createCalendarEvent() {
        let eventStore = EKEventStore()
        
        requestCalendarAccess { granted in
            if granted {
                let event = EKEvent(eventStore: eventStore)
                event.title = froopManager.selectedFroopHistory.froop.froopName
                event.startDate = froopManager.selectedFroopHistory.froop.froopStartTime
                event.endDate = froopManager.selectedFroopHistory.froop.froopEndTime
                
                // Construct the URL string using your app's URL scheme
                let urlString = "froopproof://event?id=\(froopManager.selectedFroopHistory.froop.froopId)"
                
                // Adding a URL to the event notes
                event.notes = """
                \(froopManager.selectedFroopHistory.froop.froopLocationtitle) at \(froopManager.selectedFroopHistory.froop.froopLocationsubtitle)
                For more details, open in Froop: \(urlString)
                """
                
                event.calendar = eventStore.defaultCalendarForNewEvents

                do {
                    try eventStore.save(event, span: .thisEvent)
                    print("Event saved successfully")
                    showAlert = true
                } catch {
                    PrintControl.shared.printErrorMessages("Error saving event: \(error.localizedDescription)")
                }
            } else {
                PrintControl.shared.printErrorMessages("Calendar access not granted")
            }
        }
    }
    
    func requestCalendarAccess(completion: @escaping (Bool) -> Void) {
        let eventStore = EKEventStore()
        
        eventStore.requestFullAccessToEvents { (granted, error) in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    func printFroop () {
        print(froopManager.selectedFroopHistory.froop)
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
    

    
    func formatDate(for date: Date) -> String {
//        let localDate = TimeZoneManager.shared.convertDateToLocalTime(for: date)

        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d',' h:mm a"
        return formatter.string(from: date)
    }
    
    func formatDateToTimeZone(passedDate: Date, timeZone: TimeZone) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d',' h:mm a"
        dateFormatter.timeZone = timeZone
        return dateFormatter.string(from: passedDate)
    }
}



