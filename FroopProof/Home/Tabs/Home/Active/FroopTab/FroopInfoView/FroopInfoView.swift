//
//  FroopInfoView.swift
//  FroopProof
//
//  Created by David Reed on 5/8/23.
//

import SwiftUI
import Photos
import FirebaseStorage
import Firebase
import FirebaseAuth
import FirebaseFirestore
import Kingfisher
import SwiftUIBlurView
import MapKit
import Combine

struct FroopInfoView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var navLocationServices = NavLocationServices.shared
    @ObservedObject var froopDataListener = FroopDataListener.shared
    @ObservedObject var froopManager = FroopManager.shared
    @ObservedObject var myData = MyData.shared
    @ObservedObject var friendData: UserData = UserData()
    @State private var selectedUser: UserData?
    @State private var showMap: Bool = false
    @State private var showingDeleteAlert = false
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
    
    var db = FirebaseServices.shared.db
    @ObservedObject var hostData: UserData = UserData()
    @ObservedObject var timeZoneManager:TimeZoneManager = TimeZoneManager()
    @State private var now = Date()
    @State private var opacity = 0.0
    @State var showTypeImage: Bool = false
    @State var activeHostData: UserData = UserData()
    @State var detailGuests: [UserData] = []
    @State var selectedFroopUUID: String = ""
    var timestamp: Date = Date()
    @Binding var globalChat: Bool
    
    
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    init(globalChat: Binding <Bool>) {
        UITableView.appearance().backgroundColor = .clear
        _globalChat = globalChat
    }
    
    var body: some View {
        ZStack {
            FTVBackGroundComponent()
            Rectangle()
                .foregroundColor(.clear)
                .background(.ultraThinMaterial)
                .ignoresSafeArea()
            
            ZStack {
                ScrollView(showsIndicators: false) {
                    ZStack {
                        VStack (spacing: 0){
                            //MARK: Header
                            ZStack {
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(height: 200)
                                    .background(Color.white.opacity(0.8))
                                    .cornerRadius(0)
                                    .padding(.leading, 0)
                                    .padding(.trailing, 0)
                                    .ignoresSafeArea()
                                
                                VStack {
                                    HStack {
                                        switch AppStateManager.shared.currentStage {
                                            case .starting:
                                                Text("Froop Starts in: \(timeZoneManager.formatDuration2(durationInMinutes: (appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopStartTime.timeIntervalSince(now) ?? 0.0 ) / 60))")
                                                //                                            Text("Froop Starts in:")
                                                    .font(.system(size: 16))
                                                    .fontWeight(.medium)
                                                    .multilineTextAlignment(.leading)
                                                    .foregroundColor(colorScheme == .dark ? Color(red: 249/255, green: 0/255, blue: 95/255) : Color(red: 249/255, green: 0/255, blue: 95/255))
                                            case .running:
                                                ZStack {
                                                    Text("Froop In Progress")
                                                        .font(.system(size: 16))
                                                        .fontWeight(.medium)
                                                        .foregroundColor(colorScheme == .dark ? Color(red: 249/255, green: 0/255, blue: 95/255) : Color(red: 249/255, green: 0/255, blue: 95/255))
                                                        .multilineTextAlignment(.leading)
                                                    
                                                    Image(systemName: "circle.fill")
                                                        .foregroundColor(Color(red: 249/255, green: 0/255, blue: 95/255))
                                                        .modifier(ParticleEffect(pcount: 2))
                                                        .frame(width: 2, height: 2)
                                                        .offset(x: -75)
                                                    
                                                    Image(systemName: "circle.fill")
                                                        .foregroundColor(Color(red: 249/255, green: 0/255, blue: 95/255))
                                                        .modifier(ParticleEffect(pcount: 5))
                                                        .frame(width: 2, height: 2)
                                                        .offset(x: 75)
                                                    
                                                }
                                            case .ending:
                                                Text("Froop Archive in: \(timeZoneManager.formatDuration2(durationInMinutes: ((appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopEndTime.timeIntervalSince(now) ?? 0.0 ))))")
                                                    .font(.system(size: 16))
                                                    .fontWeight(.medium)
                                                    .foregroundColor(colorScheme == .dark ? Color(red: 249/255, green: 0/255, blue: 95/255) : Color(red: 249/255, green: 0/255, blue: 95/255))
                                                    .multilineTextAlignment(.leading)
                                            case .none:
                                                Text("No Froops Scheduled")
                                                    .font(.system(size: 16))
                                                    .fontWeight(.medium)
                                                    .foregroundColor(colorScheme == .dark ? Color(red: 249/255, green: 0/255, blue: 95/255) : Color(red: 249/255, green: 0/255, blue: 95/255))
                                                    .multilineTextAlignment(.leading)
                                        }
                                    }
                                    
                                    .padding(.leading, 20)
                                    .padding(.trailing, 20)
                                    .padding(.top, 15)
                                    
                                    
                                    HStack (alignment: .top) {
                                        ZStack {
                                            Circle()
                                                .frame(width: 100, height: 100, alignment: .leading)
                                            KFImage(URL(string: appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.host.profileImageUrl ?? "" ))
                                                .placeholder {
                                                    ProgressView()
                                                }
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 100, height: 100, alignment: .leading)
                                                .clipShape(Circle())
                                                .onTapGesture {
                                                    froopManager.comeFrom = true
                                                    navLocationServices.selectedTab = .froop
                                                    froopManager.froopDetailOpen = true
                                                    //                                                froopManager.selectedFroopHistory = appStateManager.inProgressFroop
                                                    froopManager.selectedFroopUUID = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopId
                                                }
                                            
                                        }
                                        .padding(.leading, 25)
                                        .frame(height: 100, alignment: .leading)
                                        .offset(y: 40)


                                        
                                        
                                        VStack (alignment: .leading){
                                            Spacer()
                                            Text(appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopName ?? "" )
                                                .font(.system(size: 22))
                                                .fontWeight(.medium)
                                                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                                .multilineTextAlignment(.leading)
                                                .padding(.top)
                                            HStack {
                                                Text("Hosted by:")
                                                    .font(.system(size:14))
                                                    .fontWeight(.light)
                                                    .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                                    .multilineTextAlignment(.leading)
                                                Text(appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.host.firstName ?? "" )
                                                    .font(.system(size: 14))
                                                    .fontWeight(.light)
                                                    .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                                    .multilineTextAlignment(.leading)
                                                Text(appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.host.lastName ?? "" )
                                                    .font(.system(size: 14))
                                                    .fontWeight(.light)
                                                    .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                                    .multilineTextAlignment(.leading)
                                                    .padding(.leading, -5)
                                            }
                                            
                                            
                                            Text("Start: \(formatDate(for: appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopStartTime ?? Date(), in: (String(describing: TimeZoneManager.shared.userLocationTimeZone))))")
                                            
                                            //                                        Text("Start: \(formatDate(for: appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopStartTime ?? Date() ))")
                                                .font(.system(size:14))
                                                .fontWeight(.light)
                                                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                                .multilineTextAlignment(.leading)
                                                .padding(.top, 0)
                                            Text("End: \(formatDate(for: appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopEndTime ?? Date(), in: (String(describing: TimeZoneManager.shared.userLocationTimeZone))))")
                                                .font(.system(size:14))
                                                .fontWeight(.light)
                                                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                                .opacity(1)
                                                .multilineTextAlignment(.leading)
                                                .padding(.top, 5)
                                            
                                        }
                                        .frame(height: 100, alignment: .leading)
                                        .padding(.top, 5)
                                        .padding(.leading, 20)
                                        .offset(y: 25)

                                        Spacer()
                                    }
                                    .padding(.top, 5)
                                    Spacer()
                                }
                            }
                            .ignoresSafeArea()
                            
//                            ActiveFlightHeaderView()
                            
                            //MARK: Location
                            ZStack {
                                Rectangle()
                                    .frame(height: 75)
                                    .foregroundColor(Color.white.opacity(1))
                                VStack {
                                    HStack (alignment: .center) {
                                        Image(systemName: "mappin.and.ellipse")
                                            .font(.system(size: 24))
                                            .foregroundColor(colorScheme == .dark ? Color(red: 249/255, green: 0/255, blue: 98/255 ) : Color(red: 249/255, green: 0/255, blue: 98/255 ))
                                            .padding(.trailing, 15)
                                        
                                        VStack (alignment: .leading){
                                            Text(appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopLocationtitle ?? "" )
                                                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                                .opacity(1)
                                                .font(.system(size: 16))
                                                .fontWeight(.semibold)
                                            Text(appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopLocationsubtitle ?? "" )
                                                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                                .opacity(1)
                                                .font(.system(size: 12))
                                                .lineLimit(2)
                                            
                                        }
                                        
                                        Spacer()
                                        
                                        Button () {
                                            NavLocationServices.shared.selectedFroopTab = .map
                                        } label: {
                                            ZStack {
                                                
                                                Image("mapImage")
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(maxWidth: 75, maxHeight: 75)
                                                Rectangle()
                                                    .frame(width: 75, height: 75)
                                                    .foregroundColor(.white)
                                                    .opacity(0.5)
                                                
                                                VStack  {
                                                    Text("Open")
                                                        .foregroundColor(colorScheme == .dark ? Color(red: 50/255, green: 46/255, blue: 62/255) : Color(red: 50/255, green: 46/255, blue: 62/255))
                                                        .font(.system(size: 16))
                                                    Text("Map")
                                                        .foregroundColor(colorScheme == .dark ? Color(red: 50/255, green: 46/255, blue: 62/255) : Color(red: 50/255, green: 46/255, blue: 62/255))
                                                        .font(.system(size: 16))
                                                }
                                                .font(.system(size: 12))
                                            }
                                        }
                                    }
                                    .ignoresSafeArea()
                                    .padding(.leading, 25)
                                }
                            }
                            .border(.gray, width: 0.25)
                            .onTapGesture {
                                NavLocationServices.shared.selectedFroopTab = .map
                            }
                            
                            //MARK: Attending Friends
                            ZStack {
                                VStack(spacing: 1) {
                                    // First, safely access the FroopHistory item
                                    if let froopHistoryItem = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI] {
                                        // Now that you have a safe FroopHistory item, you can access its `confirmedFriends.indices`
                                        ForEach(froopHistoryItem.confirmedFriends.indices, id: \.self) { index in
                                            
                                            AttendingUserCard(
                                                friend: $appStateManager.currentFilteredFroopHistory[appStateManager.aFHI].confirmedFriends[index],
                                                globalChat: $globalChat
                                            )
                                            .shadow(color: Color.black.opacity(0.2), radius: 7, x: 7, y: 7)
                                            .shadow(color: Color.white.opacity(0.7), radius: 7, x: -4, y: -4)
                                        }
                                        
                                        ActiveFroopFriendInviteView(
                                            instanceFroop: instanceFroop,
                                            invitedFriends: Binding.constant(froopHistoryItem.confirmedFriends)
                                        )
                                        .padding(.top, 10)
                                        .padding(.bottom, 10)
                                        
                                       
                                    } else {
                                        // Handle the case where the FroopHistory item at aFHI doesn't exist
                                        EmptyView()
                                    }
                                }
                                .padding(.leading, 5)
                                .padding(.trailing, 5)
                            }
                            .padding(.top, 5)
                        }
//                        VStack {
//                            HStack {
//                                Spacer()
//                                Text("Cancel")
//                                    .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
//                                    .font(.system(size: 14))
//                                    .fontWeight(.light)
//                                    .padding()
//                                    .onTapGesture {
//                                        self.showingDeleteAlert = true
//                                    }
//                            }
//                            Spacer()
//                        }
                    }
                }
            }
        }
        .padding(.top, 95)
        .id(appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopId)
        .onReceive(timer) { _ in
            now = Date()
        }
        .opacity(appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopId == nil ? 0.5 : 1)
        .navigationTitle("\(appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopName ?? "")")
        .alert(isPresented: $showingDeleteAlert) { // Alert View
            Alert(title: Text("Delete Froop"), message: Text("Are you sure you want to delete this Froop?"), primaryButton: .destructive(Text("Delete")) {
                self.froopManager.friendDetailOpen = false
                self.froopManager.froopDetailOpen = false
                PrintControl.shared.printFroopDetails("current User UID \(FirebaseServices.shared.uid)")
                PrintControl.shared.printFroopDetails("MyData.shared.froopUserID \(MyData.shared.froopUserID)")
                FroopDataController.shared.deleteFroop(froopId: froopManager.selectedFroopHistory.froop.froopId , froopHost: myData.froopUserID) { closeSheet in
//                            print("Deleting Froop \(String(describing: froopManager.selectedFroopHistory.froop.froopId))")
                    
                }
            }, secondaryButton: .cancel())
        }
        
        .blurredSheet(.init(.ultraThinMaterial), show: $froopManager.addFriendsOpen) {
        } content: {
            ZStack {
                VStack {
                    Spacer()
                    
                    AddFriendsActiveFroopView(friendDetailOpen: $froopManager.friendDetailOpen,  addFriendsOpen: $froopManager.addFriendsOpen, timestamp: timestamp, detailGuests: $detailGuests)
                }
                
                
                VStack {
                    Rectangle()
                        .foregroundColor(.white)
                        .opacity(0.01)
                        .onTapGesture {
                            self.froopManager.addFriendsOpen = false
                            print("CLEAR TAP Froop Details View")
                            
                        }
                        .frame(maxWidth: .infinity, maxHeight: 100)
                        .ignoresSafeArea()
                    //.border(.pink)
                    Spacer()
                }
                VStack {
                    Text("tap to close")
                        .font(.system(size: 18))
                        .fontWeight(.light)
                        .foregroundColor(.black).opacity(0.75)
                        .padding(.top, 25)
                        .opacity(0.5)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 24))
                        .foregroundColor(.black).opacity(0.75)
                    Spacer()
                }
                .frame(alignment: .top)
            }
            .presentationDetents([.large])
        }
        
        
    }
    
    func formatDate(for date: Date, in timeZoneIdentifier: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d, h:mm a"
        if let timeZone = TimeZone(identifier: timeZoneIdentifier) {
            formatter.timeZone = timeZone
        }
        return formatter.string(from: date)
    }
    
    func formatDate(for date: Date) -> String {
        let localDate = TimeZoneManager.shared.convertDateToLocalTime(for: date)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d, h:mm a"
        return formatter.string(from: localDate)
    }
    
    func updateFroopEndTime() {
        // Get the Firestore database reference
        let db = Firestore.firestore()
        
        // Get the document reference for the Froop in question
        let froopRef = db.collection("users").document(appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopHost ?? "" ).collection("myFroops").document(appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopId ?? "" )
        
        // Calculate the new froopEndTime value (current date - 30 minutes)
        let newEndTime = Date().addingTimeInterval(10 * 60)
        
        // Update the froopEndTime field
        froopRef.updateData(["froopEndTime": newEndTime]) { (error) in
            if let error = error {
                print("🚫Error updating froopEndTime: \(error.localizedDescription)")
            } else {
                print("froopEndTime successfully updated!")
            }
        }
        //        self.appStateManager.setupListener() { _ in }
    }
}

