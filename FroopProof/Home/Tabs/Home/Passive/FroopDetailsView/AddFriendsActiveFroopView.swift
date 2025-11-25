//
//  addFriendsActiveFroopView.swift
//  FroopProof
//
//  Created by David Reed on 3/8/23.
//

import SwiftUI
import MapKit
import Firebase
import UIKit
import FirebaseFirestore
import FirebaseAuth
import SwiftUIBlurView
import Foundation
import Combine

struct AddFriendsActiveFroopView: View {
    
    
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var navLocationServices = NavLocationServices.shared
    //    @ObservedObject var froopDataListener = FroopDataListener.shared
    @ObservedObject var myData = MyData.shared
    @ObservedObject var froopDataController = FroopDataController.shared
    @ObservedObject var froopManager = FroopManager.shared

    
    var uid = FirebaseServices.shared.uid
    var db = FirebaseServices.shared.db
    @ObservedObject var friendData: UserData = UserData()
    @ObservedObject var friendViewController = FriendViewController.shared
    @ObservedObject var friendListData = FriendListData(dictionary: [:])
    @Binding var friendDetailOpen: Bool
    @State var invitedFriends: [UserData] = []
    @Binding var addFriendsOpen: Bool
    @State var inviteExternalFriendsOpen = false
    @State var selectedFriend: UserData = UserData()
    @State var addFraction = 0.3
    @State private var searchText: String = ""
    @State var refresh = false
    var timestamp: Date = Date()
    @State var fromUserID: String = ""
    @State var friendsInCommon: [String] = [""]
    @Binding var detailGuests: [UserData]
    @State var instanceFroopHistory: FroopHistory = FroopHistory(
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
    @Environment(\.presentationMode) var presentationMode
    @State var showingAlert = false
    
    
    var guestUidList: [String] {
        return invitedFriends.map { $0.froopUserID } 
    }
    
    
    @State var userFriendList: [UserData] = []
    
    var filteredFriends: [UserData] {
        return FriendViewController.shared.filteredFriends(friends: userFriendList, searchText: searchText)
    }
    
    var blurRadius = 10
    
    init(friendDetailOpen: Binding<Bool>, addFriendsOpen: Binding<Bool>, timestamp: Date, detailGuests: Binding<[UserData]>) {
        _friendDetailOpen = friendDetailOpen
        _addFriendsOpen = addFriendsOpen
        self.timestamp = timestamp
        _detailGuests = detailGuests
    }
    
    
    var body: some View {
        ZStack (alignment: .top){
            Rectangle()
                .foregroundColor(.white)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            
                .onAppear {
                    if appStateManager.appState == .active {
                        instanceFroopHistory = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI] ?? FroopManager.defaultFroopHistory()
                    }
                }
            
            
            
            VStack {
                Text("Invite Friends")
                    .font(.system(size: 36))
                    .fontWeight(.thin)
                    .multilineTextAlignment(.center)
                    .padding(.top, 100)
                    .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                
                SearchBar(text: $searchText)
                    .onAppear {
                        FirebaseServices.shared.checkSMSInvitations()
                    }
                    .padding(.leading, 25)
                    .padding(.trailing, 25)
                    .padding(.bottom, 15)
                    .padding(.top, 15)
                    .font(.system(size: 18))
                    .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        ForEach(uniqueFriends(friends: myData.myFriends, searchText: searchText).chunked(into: 3), id: \.self) { friendGroup in
                            HStack(spacing: 0) {
                                ForEach(friendGroup, id: \.id) { friend in
                                    ActiveAddFriendCardView(
                                        invitedFriends: $invitedFriends, // Provide a non-optional binding
                                        friend: friend,
                                        detailGuests: $detailGuests
                                    )
                                }
                            }
                        }
                    }
                }
                
                .searchable(text: $searchText)
                .font(.system(size: 18))
                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                .offset(y: -15)
                Spacer()
                Button(action: {
                    Task {
                        do {
                            let modifiedInvitedFriends = try await froopDataController.addInvitedFriendstoFroop(invitedFriends: invitedFriends , instanceFroopId: appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopId ?? "", instanceHostId: appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopHost ?? "" )
                            // Update the invitedFriends with the modified list
                            invitedFriends = modifiedInvitedFriends
                            self.showingAlert = true
                        } catch {
                            print("🚫Error inviting friends: \(error.localizedDescription)")
                        }
                        self.showingAlert = true
                        froopManager.updateFroopHistoryToggle.toggle()
                        appStateManager.froopManager.createFroopHistoryArray { froopHistory in
                            PrintControl.shared.printFroopManager("froopHistory created \(froopHistory.count)")
                        }
                    }
                }) {
                    Text("Send Invitations")
                        .font(.headline)
                        .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                        .font(.system(size: 24))
                        .fontWeight(.medium)
                        .padding()
                        .cornerRadius(5)
                        .border(.gray, width: 0.25)
                        .padding(.bottom, 60)
                }
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Invitations Sent"), message: Text("Your invitations have been sent."), dismissButton: .default(Text("OK")) {
                        // Dismiss the view
                        self.presentationMode.wrappedValue.dismiss()
                    })
                }
            }
        }
    }
    
    
    func fetchFroopData(froopId: String, completion: @escaping (FroopHistory?) -> Void) {
        let uid = FirebaseServices.shared.uid
        let froopRef = db.collection("users").document(uid).collection("myFroops").document(froopId)
        
        froopRef.getDocument { (document, error) in
            if let error = error {
                print("🚫Error fetching Froop data: \(error.localizedDescription)")
                completion(nil) // Pass nil in case of error
            } else {
                if let document = document, document.exists, let froopData = document.data() {
                    // Create your FroopHistory object from froopData here
                    let froopHistory = FroopHistory(
                        froop: Froop(dictionary: froopData["froopKey"] as? [String: Any] ?? [:]) ?? Froop(dictionary: [:]) ?? Froop.emptyFroop(),
                        host: UserData(dictionary: froopData["hostKey"] as? [String: Any] ?? [:]) ?? UserData(),
                        invitedFriends: [], // Parse the actual arrays from the froopData
                        confirmedFriends: [],
                        declinedFriends: [],
                        pendingFriends: [],
                        images: froopData["imagesKey"] as? [String] ?? [],
                        videos: froopData["videosKey"] as? [String] ?? [],
                        froopGroupConversationAndMessages: froopData["froopGroupConversationAndMessages"] as? ConversationAndMessages ?? ConversationAndMessages(conversation: Conversation(), messages: [], participants: []), froopMediaData: FroopMediaData(
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
                    completion(froopHistory)
                } else {
//                    print("Document does not exist")
                    completion(nil) // Pass nil if document does not exist
                }
            }
        }
    }
    
    func uniqueFriends(friends: [UserData], searchText: String) -> [UserData] {
        var uniqueFriendIDs = Set<String>()
        var uniqueFriends: [UserData] = []

        for friend in friends {
            if uniqueFriendIDs.insert(friend.froopUserID).inserted {
                if searchText.isEmpty || friend.firstName.localizedCaseInsensitiveContains(searchText) || friend.lastName.localizedCaseInsensitiveContains(searchText) {
                    uniqueFriends.append(friend)
                }
            }
        }
        return uniqueFriends
    }
    
}


