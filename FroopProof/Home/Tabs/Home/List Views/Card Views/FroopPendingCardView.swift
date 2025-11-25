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


struct FroopPendingCardView: View {
    
    @ObservedObject private var viewModel = DetailsGuestViewModel()
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var locationServices = LocationServices.shared
    // @ObservedObject var froopDataListener = FroopDataListener.shared
    @ObservedObject var froopManager = FroopManager.shared
    @ObservedObject var friendViewController = FriendViewController.shared
    @ObservedObject var myData = MyData.shared
    @ObservedObject var timeZoneManager: TimeZoneManager = TimeZoneManager()
    @Binding var openFroop: Bool
    @State private var previousAppState: AppState?
    var currentTime = Date()
    @State private var confirmedFriends: [UserData] = []
    @State private var declinedFriends: [UserData] = []
    @State private var pendingFriends: [UserData] = []
    @State private var invitedFriendsLocal: [UserData] = []
    @State private var identifiableInvitedFriends: [IdentifiableFriendData] = []
    @State var froopStartTime: Date? = Date()
    @State private var dataLoaded = false
    @State var myTimeZone: TimeZone = TimeZone.current
    @State private var formattedDateString: String = ""
    @State private var isBlinking = false
    @State var hostData: UserData = UserData()
    @State var showAlert: Bool = false
    //@Binding var froopDetailOpen: Bool
    @State var invitedFriends: [UserData] = []
    let froopHostAndFriends: FroopHistory
   
    var uid = FirebaseServices.shared.uid
    var db = FirebaseServices.shared.db
   
    var timeUntilStart: String {
        let calendar = Calendar.current
        let now = Date()
        
        if froopHostAndFriends.froop.froopStartTime > now {
            let components = calendar.dateComponents([.day, .hour, .minute], from: now, to: froopHostAndFriends.froop.froopStartTime)
            
            let days = components.day ?? 0
            let hours = components.hour ?? 0
            let minutes = components.minute ?? 0
            
            var timeUntilStart = "Starts in "
            
            if days > 9 {
                timeUntilStart += "\(days)d : "
            } else if days > 0 && days < 10 {
                timeUntilStart += "0\(days)d : "
            } else {
                timeUntilStart += "00d : "
            }
            
            
            if hours > 9 {
                timeUntilStart += "\(hours)h : "
            } else if hours > 0 && hours < 10 {
                timeUntilStart += "0\(hours)h : "
            } else {
                timeUntilStart += "00h : "
            }
            
            
            if minutes > 9 {
                timeUntilStart += "\(minutes)m"
            } else if minutes > 0 && minutes < 10 {
                timeUntilStart += "0\(minutes)m"
            } else {
                timeUntilStart += "00m"
            }
            

            return timeUntilStart.trimmingCharacters(in: .whitespaces)
        } else if froopManager.selectedFroopHistory.froop.froopEndTime < now {
            return "Froop has already started"
        } else {
            return "This Froop occured in the past"
        }
    }
    var isCurrentUserApproved: Bool {
        froopHostAndFriends.froop.guestApproveList.contains(uid)
    }
    
    let visibleFriendsLimit = 8
    let dateForm = DateForm()
    
    init(openFroop: Binding<Bool>, froopHostAndFriends: FroopHistory, invitedFriends: [UserData]) {
        self._openFroop = openFroop
        self.timeZoneManager = TimeZoneManager()
        self.froopHostAndFriends = froopHostAndFriends
        self.invitedFriends = invitedFriends

    }

    var body: some View {
        
        ZStack (alignment: .top) {
            RoundedRectangle(cornerRadius: 10)
                .fill(
                    LinearGradient(gradient: Gradient(colors: isCurrentUserApproved ?
                                                      [
                                                        Color(red: 206/255, green: 255/255, blue: 28/255).opacity(0.25), Color(red: 255/255, green: 255/255, blue: 255/255)] :
                                                        [
                                                            Color(red: 255/255, green: 97/255, blue: 97/255).opacity(0.25),
                                                            Color(red: 255/255, green: 255/255, blue: 255/255)]),
                                   startPoint: .top, endPoint: .bottom)
                )
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
                    if isCurrentUserApproved {
                        VStack (alignment: .center) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(red: 255/255, green: 49/255, blue: 97/255))
                                    .opacity(1)
                                    .frame(width: 70, height: 50)
                                    .shadow(color: Color(red: 61/255, green: 76/255, blue: 8/255).opacity(0.4), radius: 4, x: 4, y: 4)
//                                    .shadow(color: Color(red: 255/255, green: 97/255, blue: 97/255).opacity(0.9), radius: 4, x: -4, y: -4)
                                VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, content: {
                                    Text("Pending")
                                        .font(.system(size: 14))
                                        .fontWeight(.regular)
                                        .foregroundColor(.white)
                                })
                                
                            }
                        }
                        .padding(.trailing, 30)
                        .onTapGesture {
                            showAlert = true
                        }
                    } else {
                        VStack (alignment: .center) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(red: 206/255, green: 255/255, blue: 28/255))
                                    .opacity(1)
                                    .frame(width: 50, height: 50)
                                    .shadow(color: Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.4), radius: 4, x: 4, y: 4)
//                                    .shadow(color: Color(red: 206/255, green: 255/255, blue: 28/255).opacity(0.9), radius: 4, x: -4, y: -4)
                                VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, content: {
                                    Text("View")
                                        .font(.system(size: 14))
                                        .fontWeight(.light)
                                        .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                })
                                
                            }
                        }
                        .padding(.trailing, 30)
                        .onTapGesture {
                            
                            if appStateManager.appState == .passive {
                                print("Status froopManager:  \(froopManager.selectedFroopHistory.froopStatus)")
                            } else {
                                let startTime = froopHostAndFriends.froop.froopStartTime
                                let endTime = froopHostAndFriends.froop.froopEndTime
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
                            
                            if appStateManager.appState == .active && appStateManager.currentFilteredFroopHistory.contains(where: { $0.froop.froopId == froopHostAndFriends.froop.froopId }) {
                                locationServices.selectedTab = .froop
                                appStateManager.findFroopById(froopId: froopHostAndFriends.froop.froopId) { found in
                                    if found {
                                        locationServices.selectedTab = .froop
                                    } else {
                                        froopManager.selectedFroopHistory = froopHostAndFriends
                                        froopManager.selectedFroopUUID = froopHostAndFriends.froop.froopId
                                        froopManager.froopDetailOpen = true
                                        PrintControl.shared.printLists("ImageURL:  \(froopHostAndFriends.froop.froopHostPic)")
                                    }
                                }
                            } else {
                                froopManager.selectedFroopHistory = froopHostAndFriends
                                froopManager.selectedFroopUUID = froopHostAndFriends.froop.froopId
                                froopManager.froopDetailOpen = true
                                PrintControl.shared.printLists("ImageURL:  \(froopHostAndFriends.froop.froopHostPic)")
                            }
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
                HStack {
                    VStack (alignment: .leading) {
                        HStack {
                            Image(systemName: "clock")
                                .frame(width: 65, height: 30)
                                .scaledToFill()
                                .font(.system(size: 24))
                                .fontWeight(.light)
                                .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255 ))
                            
                            Text(formattedDateString)
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
                    .frame(height: 120)
                    
                    VStack {
                        if froopHostAndFriends.froop.froopHost == uid {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(.white)
                                    .opacity(0.5)
                                    .frame(width: 50, height: 50)
                                    .shadow(color: Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.4), radius: 4, x: 4, y: 4)
                                    .shadow(color: Color.white.opacity(0.9), radius: 4, x: -4, y: -4)
                                VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, content: {
                                    Text("Share")
                                        .font(.system(size: 14))
                                        .fontWeight(.light)
                                        .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                })
                            }
                            .padding(.trailing, 30)
                            .frame(width: 80)
                            .onTapGesture {
                                froopManager.selectedFroopHistory = froopHostAndFriends
                                froopManager.showInviteUrlView = true
                            }
                        }
                        
                        Spacer()
                    }
                    .frame(height: 120)
                }
                .frame(height: 120)
                .padding(.leading, 5)
                
//                Spacer()
            }
            .onAppear {
//                appStateManager.fetchHostData(uid: froopHostAndFriends.froop.froopHost) { result in
//                    switch result {
//                    case .success(let userData):
//                        self.hostData = userData
//                    case .failure(let error):
//                        print("Failed to fetch host data. Error: \(error.localizedDescription)")
//                    }
//                }
//                loadConfirmedFriends()
                PrintControl.shared.printLists("Printing Date \(froopHostAndFriends.froop.froopStartTime)")
                timeZoneManager.convertUTCToCurrent(date: froopHostAndFriends.froop.froopStartTime, currentTZ: TimeZone.current.identifier) { convertedDate in
                    formattedDateString = timeZoneManager.formatDate(passedDate: convertedDate)
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Invitation Pending"), message: Text("Now that you have confirmed, the Host needs to approve your invitation before you can access the Froop's Details.  It shouldn't take long."), dismissButton: .default(Text("OK")))
            }
        }
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

    
    func formatDateToTimeZone(passedDate: Date, timeZone: TimeZone) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d',' h:mm a"
        dateFormatter.timeZone = timeZone
        return dateFormatter.string(from: passedDate)
    }
}



