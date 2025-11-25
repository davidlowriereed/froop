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


struct FroopConfirmedCardView: View {
    @ObservedObject var inviteManager = InviteManager.shared
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

    var uid = FirebaseServices.shared.uid
    var db = FirebaseServices.shared.db
   
    var timeUntilStart: String {
        let calendar = Calendar.current
        let now = Date()
        
        if froopHistoryWrapper.froopHistory.froop.froopStartTime > now {
            let components = calendar.dateComponents([.day, .hour, .minute], from: now, to: froopHistoryWrapper.froopHistory.froop.froopStartTime)
            
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
        froopHistoryWrapper.froopHistory.froop.guestApproveList.contains(uid)
    }
    
    let visibleFriendsLimit = 8
    
    init(openFroop: Binding<Bool>, froopHistoryWrapper: FroopHistoryWrapper) {
        self._openFroop = openFroop
        self.timeZoneManager = TimeZoneManager()
        self.froopHistoryWrapper = froopHistoryWrapper
    }

    var body: some View {
        
        ZStack (alignment: .top) {
            RoundedRectangle(cornerRadius: 10)
                .fill(
                    LinearGradient(gradient: Gradient(colors: [Color(red: 255/255, green: 255/255, blue: 255/255), Color(red: 244/255, green: 250/255, blue: 255/255)]), startPoint: .top, endPoint: .bottom)
                )
            
                .fill(LinearGradient(gradient: Gradient(colors: isCurrentUserApproved ? [Color(red: 255/255, green: 255/255, blue: 255/255).opacity(0.25), Color(red: 244/255, green: 255/255, blue: 250/255)] : [Color(red: 255/255, green: 255/255, blue: 255/255).opacity(0.25), Color(red: 206/255, green: 244/255, blue: 250/255)]), startPoint: .top, endPoint: .bottom))
                .shadow(color: Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.2), radius: 7, x: 7, y: 7)
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
                    withAnimation() {
                        openFroop = false
                    }
                }
               
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
                                        .font(.system(size: UIScreen.screenHeight < 925 ? 11 : 14))
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
                                
                            }
                        }
                        .padding(.trailing, 30)
                        .onTapGesture {
                            
                            if appStateManager.appState == .passive {
                                print("Status froopManager:  \(froopManager.selectedFroopHistory.froopStatus)")
                                appStateManager.appStateToggle = false
                            } else {
                                let startTime = froopHistoryWrapper.froopHistory.froop.froopStartTime
                                let endTime = froopHistoryWrapper.froopHistory.froop.froopEndTime
                                let currentTime = appStateManager.now
                                
                                appStateManager.appStateToggle = true
                                print("appStateToggle 1")
                                
                                
                                if timeZoneManager.userLocationTimeZone != nil {
                                    if currentTime > startTime && currentTime < endTime {
                                        print("Status appStateManager: \(String(describing: appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froopStatus))")
                                    } else {
                                        print("Froop Manager: \(froopManager.selectedFroopHistory.froopStatus)")
                                    }
                                }
                            }
                            
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
                                .font(.system(size: UIScreen.screenHeight < 925 ? 14 : 16))
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
                                Text(froopHistoryWrapper.froopHistory.froop.froopLocationtitle)
                                    .font(.system(size: UIScreen.screenHeight < 925 ? 14 : 16))
                                    .fontWeight(.medium)
                                    .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                Text(froopHistoryWrapper.froopHistory.froop.froopLocationsubtitle)
                                    .font(.system(size: UIScreen.screenHeight < 925 ? 12 : 14))
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
                            
                            Spacer()
                        }
                        .frame(height: 120)
                    } else {
                        EmptyView()
                    }
                    
                }
                .frame(height: 120)
                .padding(.leading, 5)
            }
            .onAppear {

                PrintControl.shared.printLists("Printing Date \(froopHistoryWrapper.froopHistory.froop.froopStartTime)")
                timeZoneManager.convertUTCToCurrent(date: froopHistoryWrapper.froopHistory.froop.froopStartTime, currentTZ: TimeZone.current.identifier) { convertedDate in
                    formattedDateString = timeZoneManager.formatDate(passedDate: convertedDate)
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Invitation Pending"), message: Text("Now that you have confirmed, the Host needs to approve your invitation before you can access the Froop's Details.  It shouldn't take long."), dismissButton: .default(Text("OK")))
            }
        }
        .frame(height: 210)

    }
    
    func printFroop () {
        print(froopHistoryWrapper.froopHistory.froop)
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



