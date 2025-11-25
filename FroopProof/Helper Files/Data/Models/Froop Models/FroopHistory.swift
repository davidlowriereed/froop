//
//  FroopHistory.swift
//  FroopProof
//
//  Created by David Reed on 3/15/24.
//

import Foundation
import SwiftUI
import FirebaseFirestore


class FroopHistory: ObservableObject, Identifiable, Equatable, Hashable {

    enum FroopStatus: String {
        case invited = "invited"
        case confirmed = "confirmed"
        case declined = "declined"
        case archived = "archived"
        case memory = "memory"
        case none = "none"
    }
    
    let id = UUID() // This is a unique identifier for each FroopHistory
    @Published var froop: Froop
    @Published var host: UserData
    @Published var invitedFriends: [UserData]
    @Published var confirmedFriends: [UserData]
    @Published var declinedFriends: [UserData]
    @Published var pendingFriends: [UserData]
    @Published var images: [String]
    @Published var videos: [String]
    @Published var froopStatus: FroopStatus = .none
    @Published var statusText: String = ""
    @Published var froopGroupConversationAndMessages: ConversationAndMessages = ConversationAndMessages(conversation: Conversation(), messages: [], participants: [])
    @Published var froopMediaData: FroopMediaData
    @Published var flightData: ScheduledFlightAPI.FlightDetail = ScheduledFlightAPI.FlightDetail.empty()
    var listeners: [ListenerRegistration] = []


    
    init(froop: Froop,
         host: UserData,
         invitedFriends: [UserData],
         confirmedFriends: [UserData],
         declinedFriends: [UserData],
         pendingFriends: [UserData],
         images: [String],
         videos: [String],
         froopGroupConversationAndMessages: ConversationAndMessages,
         froopMediaData: FroopMediaData,
         flightData: ScheduledFlightAPI.FlightDetail

    ){
        self.froop = froop
        self.host = host
        self.invitedFriends = invitedFriends
        self.confirmedFriends = confirmedFriends
        self.declinedFriends = declinedFriends
        self.pendingFriends = pendingFriends
        self.images = images
        self.videos = videos
        self.froopGroupConversationAndMessages = froopGroupConversationAndMessages
        self.froopMediaData = froopMediaData
        self.flightData = flightData
        determineFroopStatus()
    }
    
    static func == (lhs: FroopHistory, rhs: FroopHistory) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension FroopHistory {
    
    func findUser(byUserID userID: String) -> UserData? {
        return confirmedFriends.first { $0.froopUserID == userID }
    }
    
    func printDetails() {
        print("Froop Details:")
        print("Froop Name: \(self.froop.froopName)")
        print("Froop ID: \(self.froop.froopId)")
        print("Host Name: \(self.host.firstName)")
        print("Host ID: \(self.host.froopUserID)")
        
        printFriendListDetails("Invited Friends", friends: invitedFriends)
        printFriendListDetails("Confirmed Friends", friends: confirmedFriends)
        printFriendListDetails("Declined Friends", friends: declinedFriends)
        printFriendListDetails("Pending Friends", friends: pendingFriends)
        
        print("Images Count: \(self.images.count)")
        print("Videos Count: \(self.videos.count)")
        print("Froop Status: \(self.froopStatus.rawValue)")
    }
    
    private func printFriendListDetails(_ listName: String, friends: [UserData]) {
        print("\(listName): \(friends.count)")
        if !friends.isEmpty {
            friends.forEach { print("\($0.firstName)") }
        }
    }
}

extension FroopHistory {
    
    func debugPrintChanges() {
        print("FroopHistory changed:")
        print("Froop: \(froop)")
        print("Host: \(host)")
        print("Invited Friends: \(invitedFriends.count)")
        print("Confirmed Friends: \(confirmedFriends.count)")
        print("Declined Friends: \(declinedFriends.count)")
        print("Pending Friends: \(pendingFriends.count)")
        print("Images: \(images.count)")
        print("Videos: \(videos.count)")
        print("Status: \(froopStatus)")
        print("Status Text: \(statusText)")
        print("Group Conversation: \(froopGroupConversationAndMessages)")
        print("Media Data: \(froopMediaData)")
        print("Flight Data: \(flightData)")
    }
    
    
    func setupListeners(froopHost: String, froopId: String) {
        // Paths to listen to
        let pathsAndKeys = [
            ("invitedFriends/inviteList", "inviteList_\(froopId)"),
            ("invitedFriends/confirmedList", "confirmedList_\(froopId)"),
            ("invitedFriends/declinedList", "declinedList_\(froopId)"),
            ("invitedFriends/pendingList", "pendingList_\(froopId)")
        ]
        
        let db = Firestore.firestore()
        
        pathsAndKeys.forEach { path, key in
            let ref = db.collection("users").document(froopHost).collection("myFroops").document(froopId).collection(path)
            let listener = ref.addSnapshotListener { [weak self] querySnapshot, error in
                guard let snapshot = querySnapshot, error == nil else {
                    print("Error setting up listener for path \(path): \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                self?.handleUpdate(snapshot: snapshot, forPath: path)
            }
            // Register the listener with ListenerStateService
            ListenerStateService.shared.registerListener(listener, forKey: key)
            self.listeners.append(listener) // Keep track of the listener for later removal
        }
    }
    
    private func handleUpdate(snapshot: QuerySnapshot, forPath path: String) {
        // Update the relevant property based on the path
        switch path {
            case "invitedFriends/inviteList":
                self.invitedFriends = snapshot.documents.compactMap { UserData(dictionary: $0.data()) }
            case "invitedFriends/confirmedList":
                self.confirmedFriends = snapshot.documents.compactMap { UserData(dictionary: $0.data()) }
            case "invitedFriends/declinedList":
                self.declinedFriends = snapshot.documents.compactMap { UserData(dictionary: $0.data()) }
            case "invitedFriends/pendingList":
                self.pendingFriends = snapshot.documents.compactMap { UserData(dictionary: $0.data()) }
            default:
                break
        }
    }
}

