//
//  addFriendsFroopView.swift
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

struct AddFriendsFroopView: View {
    
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var navLocationServices = NavLocationServices.shared
//    @ObservedObject var froopDataListener = FroopDataListener.shared
    @ObservedObject var myData = MyData.shared
    @ObservedObject var froopDataController = FroopDataController.shared
    @ObservedObject var froopManager = FroopManager.shared
    
    var db = FirebaseServices.shared.db
    var uid = FirebaseServices.shared.uid
    @ObservedObject var friendData: UserData = UserData()
    @ObservedObject var userData = UserData()
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
    var timestamp: Date
    @State var fromUserID: String = ""
    @State var friendsInCommon: [String] = [""]
    @Binding var detailGuests: [UserData]
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
    @Binding var selectedFroopHistory: FroopHistory
    @Environment(\.presentationMode) var presentationMode
    @State private var showingAlert = false
    
    
    private var guestUidList: [String] {
        return invitedFriends.map { $0.froopUserID }
    }
    @State var userFriendList: [UserData] = []
    
    var filteredFriends: [UserData] {
        return FriendViewController.shared.filteredFriends(friends: userFriendList, searchText: searchText)
    }
    
    var isSelectedFroopInFilteredHistory: Bool {
        appStateManager.currentFilteredFroopHistory.contains { froopHistory in
            froopHistory.froop.froopId == froopManager.selectedFroopHistory.froop.froopId
        }
    }
    
    var blurRadius = 10
    
    var body: some View {
        ZStack (alignment: .top){
            Rectangle()
                .foregroundColor(.white)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .onAppear {
                    instanceFroop = froopManager.selectedFroopHistory
                    invitedFriends = instanceFroop.confirmedFriends
                    invitedFriends.forEach { friend in
                        print("😭 Printing Friend Details: \(friend.firstName) froopUserID: \(friend.froopUserID)")
                        print("✴️")
                    }
                }
            
            VStack {
                Text("Invite Friends")
                    .font(.system(size: 36))
                    .fontWeight(.thin)
                    .multilineTextAlignment(.center)
                    .padding(.top, 50)
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
                                    AddFriendCardView(
                                        invitedFriends: $invitedFriends, // Provide a non-optional binding
                                        friend: friend,
                                        detailGuests: $detailGuests
                                    )
                                    .onAppear {
                                        print("👩‍❤️‍👨 \(friend.firstName) \(friend.lastName) \(friend.froopUserID)")
                                    }
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

                            let modifiedInvitedFriends = try await froopDataController.addInvitedFriendstoFroop(invitedFriends: invitedFriends, instanceFroopId: instanceFroop.froop.froopId, instanceHostId: instanceFroop.froop.froopHost)
                            // Update the invitedFriends with the modified list
                            invitedFriends = modifiedInvitedFriends
                            self.showingAlert = true
                            froopManager.updateFroopHistoryToggle.toggle()
                        } catch {
                            print("🚫Error inviting friends: \(error.localizedDescription)")
                        }
                        self.showingAlert = true
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
    
    
    func fetchFroopData(froopId: String, completion: @escaping (Froop?) -> Void) {
        
        let uid = FirebaseServices.shared.uid
        let froopRef = db.collection("users").document(uid).collection("myFroops").document(froopId)
        
        froopRef.getDocument { (document, error) in
            if let error = error {
                print("🚫Error fetching Froop data: \(error.localizedDescription)")
                completion(nil)
            } else {
                if let document = document, document.exists, let data = document.data() {
                    let froop = Froop(dictionary: data)
                    completion(froop)
                } else {
                    print("Document does not exist 2")
                    completion(nil)
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


