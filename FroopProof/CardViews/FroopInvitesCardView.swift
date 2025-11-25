//
//  FroopCardView.swift
//  FroopProof
//
//  Created by David Reed on 2/6/23.
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
import FirebaseCrashlytics

struct FroopInvitesCardView: View {
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
    @State var froopStartTime: Date? = Date()
    @State private var dataLoaded = false
    @State var hostData: UserData = UserData()
    @State var invitedFriends: [UserData] = []
    @State var confirmedFriends: [UserData] = []
    @State var declinedFriends: [UserData] = []
    @State var pendingFriends: [UserData] = []
    @State private var showAlert = false
    let froopHistory: FroopHistory = FroopHistory(froop: Froop(), host: UserData(), invitedFriends: [], confirmedFriends: [], declinedFriends: [], pendingFriends: [], images: [], videos: [], froopGroupConversationAndMessages: ConversationAndMessages(conversation: Conversation(), messages: [], participants: []), froopMediaData: FroopMediaData(froopImages: [], froopDisplayImages: [], froopThumbnailImages: [], froopIntroVideo: "", froopIntroVideoThumbnail: "", froopVideos: [], froopVideoThumbnails: []), flightData: ScheduledFlightAPI.FlightDetail.empty())
    
    private var cardHeight: CGFloat = 350
    
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
    
    let visibleFriendsLimit = 8
    @State private var formattedDateString: String = ""

    
    init(openFroop: Binding<Bool>, froopHistoryWrapper: FroopHistoryWrapper) {
        self._openFroop = openFroop
        self.froopHistoryWrapper = froopHistoryWrapper
        self.timeZoneManager = TimeZoneManager()
    }
    
    var body: some View {
        
        ZStack (alignment: .top){
            RoundedRectangle(cornerRadius: 10)
                .fill(
                    LinearGradient(gradient: Gradient(colors: [Color(red: 255/255, green: 255/255, blue: 255/255), Color(red: 244/255, green: 250/255, blue: 255/255)]), startPoint: .top, endPoint: .bottom)
                )
                .fill(LinearGradient(gradient: Gradient(colors: [Color(red: 255/255, green: 255/255, blue: 255/255).opacity(0.25), Color(red: 206/255, green: 244/255, blue: 250/255)]), startPoint: .top, endPoint: .bottom))
                .shadow(color: Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.2), radius: 7, x: 7, y: 7)
                .shadow(color: Color.white.opacity(0.7), radius: 7, x: -4, y: -4)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 0.5)
                )
                .frame(height: cardHeight)
                .foregroundColor(.white)
                .padding(.leading, 10)
                .padding(.trailing, 10)
                .onTapGesture {
                    withAnimation() {
                        openFroop = false
                    }
                }
            
            RoundedRectangle(cornerRadius: 10)
                .frame(height: 135)
                .foregroundColor(.white)
                .padding(.leading, 10)
                .padding(.trailing, 10)
                .onTapGesture {
                    froopManager.selectedFroopUUID = froopHistoryWrapper.froopHistory.froop.froopId
                    froopManager.selectedFroopHistory.froop = froopHistoryWrapper.froopHistory.froop
                    froopManager.selectedHost = hostData
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
                        HStack {
                            Text(froopHistoryWrapper.froopHistory.froop.froopName)
                                .font(.system(size: 16))
                                .fontWeight(.semibold)
                                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                .multilineTextAlignment(.leading)
                            Spacer()
                            Text(froopHistoryWrapper.froopHistory.textForStatus())
                                .font(.system(size: 14))
                                .fontWeight(.semibold)
                                .foregroundColor(froopHistoryWrapper.froopHistory.colorForStatus())
                                .multilineTextAlignment(.leading)
                                .padding(.trailing, 15)
                        }
                        .offset(y: -10)
                        
                        Text(formatDate(for: froopHistory.froop.froopStartTime))
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
                
                }
                .frame(height: 50)
                .padding(.top, 20)
                .padding(.leading, 10)
                
                Divider()
                    .padding(.leading, 15)
                    .padding(.trailing, 15)
                    .padding(1)
                    .padding(1)
                
                
                HStack {
                    Spacer()
                    
                    let uid = FirebaseServices.shared.uid
                    
                    Button(action: {
                        FroopDataController.shared.moveFroopInvitation(uid: uid, froopId: froopHistoryWrapper.froopHistory.froop.froopId, froopHost: froopHistoryWrapper.froopHistory.froop.froopHost, decision: "accept")
//                        appStateManager.setupListener() {_ in
//                            print("Accepted")
//                        }
                         
                        //selectedTab = 1
                        createCalendarEvent()
                    }) {
                        ZStack {
                            Rectangle()
                                .border(Color(red: 50/255, green: 46/255, blue: 62/255), width: 0.25)
                                .foregroundColor(.clear)
                                .frame(width: 150, height: 40)
                            Text("Accept")
                                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                .font(.system(size: 18))
                                .fontWeight(.light)
                        }
                    }
                    .buttonStyle(FroopButtonStyle())
                    
                    Button(action: {
                        FroopDataController.shared.moveFroopInvitation(uid: uid, froopId: froopHistoryWrapper.froopHistory.froop.froopId, froopHost: froopHistoryWrapper.froopHistory.froop.froopHost, decision: "decline")
                    }) {
                        ZStack {
                            Rectangle()
                                .border(Color(red: 50/255, green: 46/255, blue: 62/255), width: 0.25)
                                .foregroundColor(.clear)
                                .frame(width: 150, height: 40)
                            Text("Decline")
                                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                .font(.system(size: 18))
                                .fontWeight(.light)
                        }
                    }
                    .buttonStyle(FroopButtonStyle())
                    
                    Spacer()
                }
                
                
//                Divider()
//                    .padding(.leading, 15)
//                    .padding(.trailing, 15)
//                    .padding(1)
//                    .padding(1)
                

            }
            .onAppear {
                timeZoneManager.convertUTCToCurrent(date: froopHistoryWrapper.froopHistory.froop.froopStartTime, currentTZ: TimeZone.current.identifier) { convertedDate in
                    formattedDateString = timeZoneManager.formatDate(passedDate: convertedDate)
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Calendar Update"), message: Text("This Froop has been added to your calendar."), dismissButton: .default(Text("OK")))
            }
        }
        .frame(height: cardHeight)
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

    func requestCalendarAccess(completion: @escaping (Bool) -> Void) {
        let eventStore = EKEventStore()
        
        eventStore.requestFullAccessToEvents { (granted, error) in
            DispatchQueue.main.async {
                completion(granted)
            }
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
    func formatDate(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE MMM.dd.yyyy 'at' h:mm a"
        return formatter.string(from: date)
    }
}




