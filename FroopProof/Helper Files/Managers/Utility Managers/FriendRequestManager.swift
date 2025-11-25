//
//  FriendRequestManager.swift
//  FroopProof
//
//  Created by David Reed on 2/11/23.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import UIKit
import SwiftUI

class FriendRequestManager: ObservableObject {
    
    static let shared = FriendRequestManager(timestamp: Date())
    
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var notificationsManager = NotificationsManager.shared
    // @ObservedObject var froopDataListener = FroopDataListener.shared
    @Published var currentFriends: [UserData] = []

    @Published var selectedFriend: UserData = UserData()
    
    let db = FirebaseServices.shared.db
    var friendRequestRef: CollectionReference
    var timestamp: Date = Date()
    var friendInviteData: FriendInviteData = FriendInviteData(dictionary: [:])
    
    
    init(timestamp: Date) {
            friendRequestRef = db.collection("friendRequests")
            self.timestamp = timestamp
        }
    
    
    
    func addFriendRequest(fromUserID: String, toUserInfo: UserData) {
        PrintControl.shared.printFriend("-FriendRequestManager: Function: addFriendRequest is firing!")
        let friendRequestRef = db.collection("friendRequests").document()
        let friendRequest = FriendInviteData(dictionary: [:])

        friendRequestRef.setData(friendRequest.dictionary) { error in
            if let error = error {
                PrintControl.shared.printErrorMessages("Error sending friend request: \(error.localizedDescription)")
            } else {
                PrintControl.shared.printFriend("Friend request sent successfully")
            }
        }
        
        // Update the invite flag in the user's account
        let userRef = db.collection("users").document(friendInviteData.toUserID)
        userRef.updateData(["inviteSent": true])
    }
    
    func updateNumberOfFriendRequests(userID: String, action: String) {
        PrintControl.shared.printFriend("-FriendRequestManager: Function: updateNumberOfFriendRequests is firing!")
        let userRef = db.collection("users").document(userID)
        userRef.getDocument { (document, error) in
            if let error = error {
                PrintControl.shared.printErrorMessages("Error getting user document: \(error)")
                return
            }
            
            guard var data = document?.data() else {
                PrintControl.shared.printFriend("User document not found")
                return
            }
            
            var numberOfFriendRequests = data["numberOfFriendRequests"] as? Int ?? 0
            if action == "accept" || action == "reject" {
                numberOfFriendRequests -= 1
            }
            data["numberOfFriendRequests"] = numberOfFriendRequests

            userRef.setData(data, merge: true)
        }
    }
    
    func sendFriendRequest(uid: String, toUserID: String, status: String = "pending", timestamp: Date = Date(), completion: @escaping (Result<String, Error>) -> Void) {
        PrintControl.shared.printFriend("-FriendRequestManager: Function: sendFriendRequest is firing!")
            getFriendRequests(uid: uid) { friendInviteData in
                let friendRequestExists = friendInviteData.contains { friendInviteData in
                    friendInviteData.fromUserID == uid && friendInviteData.toUserID == toUserID
                }
                PrintControl.shared.printFriend("receiving....")
                PrintControl.shared.printFriend(uid)
                
                if !friendRequestExists {
                    let friendRequest = FriendInviteData(dictionary: [:])
                    
                    let friendRequestRef = self.db.collection("friendRequests").document()
                    friendRequestRef.setData(friendRequest.dictionary) { error in
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            let friendRequestID = friendRequestRef.documentID
                            let updatedFriendRequest = FriendInviteData(dictionary: [:])
                            friendRequestRef.setData(updatedFriendRequest.dictionary) { error in
                                if let error = error {
                                    completion(.failure(error))
                                } else {
                                    completion(.success(friendRequestID))
                                }
                            }
                        }
                    }
                    
                    // Update the number of friend requests sent to the user
                    let userRef = self.db.collection("users").document(toUserID)
                    userRef.getDocument { (document, error) in
                        if let error = error {
                            PrintControl.shared.printErrorMessages("Error getting user document: \(error)")
                            return
                        }
                        
                        guard var data = document?.data() else {
                            PrintControl.shared.printErrorMessages("User document not found")
                            return
                        }
                        
                        var numberOfFriendRequests = data["numberOfFriendRequests"] as? Int ?? 0
                        numberOfFriendRequests += 1
                        data["numberOfFriendRequests"] = numberOfFriendRequests
                        
                        userRef.setData(data, merge: true)
                    }
                } else {
                    completion(.failure(FriendRequestError.friendRequestExists))
                }
            }
        }

    
    
    
    func acceptSMSInvitation(senderUid: String, uid: String, completion: @escaping (Bool) -> Void) {
        PrintControl.shared.printFriend("-FriendRequestManager: Function: acceptSMSInvitation is firing!")
       
        let batch = db.batch()
        
        // Add the user who sent the friend request to the "friends" collection of the user who accepted the request
        let toUserFriendListRef = db.collection("users").document(uid).collection("friends").document("friendList")
        toUserFriendListRef.getDocument { (document, error) in
            if let error = error {
                PrintControl.shared.printErrorMessages("Error getting friend list: \(error)")
                return
            }
            if var friendUIDs = document?.data()?["friendUIDs"] as? [String] {
                if !friendUIDs.contains(senderUid) {
                    friendUIDs.append(senderUid)
                    batch.updateData(["friendUIDs": friendUIDs], forDocument: toUserFriendListRef)
                }
            } else {
                batch.setData(["friendUIDs": [senderUid]], forDocument: toUserFriendListRef)
            }
            
            // Add the user who accepted the friend request to the "friends" collection of the user who sent the request
            let fromUserFriendListRef = self.db.collection("users").document(senderUid).collection("friends").document("friendList")
            fromUserFriendListRef.getDocument { (document, error) in
                if let error = error {
                    PrintControl.shared.printErrorMessages("Error getting friend list: \(error)")
                    return
                }
                if var friendUIDs = document?.data()?["friendUIDs"] as? [String] {
                    if !friendUIDs.contains(uid) {
                        friendUIDs.append(uid)
                        batch.updateData(["friendUIDs": friendUIDs], forDocument: fromUserFriendListRef)
                    }
                } else {
                    batch.setData(["friendUIDs": [uid]], forDocument: fromUserFriendListRef)
                }
                
                // Delete the SMS invitation
                let smsInvitationRef = self.db.collection("smsInvitations").document(uid)
                batch.deleteDocument(smsInvitationRef)
                
                // Commit the batched updates
                batch.commit { (error) in
                    if let error = error {
                        PrintControl.shared.printErrorMessages("Error committing batched updates: \(error)")
                    } else {
                        PrintControl.shared.printFriend("SMS invitation accepted and deleted")
                        completion(true) // Indicate success
                    }
                }
            }
        }
    }
    
    

    func acceptFriendRequest(fromUserID: String, toUserID: String, completion: @escaping (Bool) -> Void) {
        PrintControl.shared.printFriend("-FriendRequestManager: Function: acceptFriendRequest is firing!")
       
        let batch = db.batch()
        
        // Add the user who sent the friend request to the "friends" collection of the user who accepted the request
        let toUserFriendListRef = db.collection("users").document(toUserID).collection("friends").document("friendList")
        toUserFriendListRef.getDocument { (document, error) in
            if let error = error {
                PrintControl.shared.printErrorMessages("Error getting friend list: \(error)")
                return
            }
            guard let document = document else {
                let data: [String: Any] = ["friendUIDs": [fromUserID]]
                self.db.collection("users").document(toUserID).collection("friends").document("friendList").setData(data) { error in
                    if let error = error {
                        PrintControl.shared.printErrorMessages("Error creating friend list: \(error)")
                    } else {
                        PrintControl.shared.printFriend("Friend list created")
                    }
                }
                return
            }
            if var friendUIDs = document.data()?["friendUIDs"] as? [String] {
                if !friendUIDs.contains(fromUserID) {
                    friendUIDs.append(fromUserID)
                    batch.updateData(["friendUIDs": friendUIDs], forDocument: toUserFriendListRef)
                }
            } else {
                batch.setData(["friendUIDs": [fromUserID]], forDocument: toUserFriendListRef)
            }
            
            // Add the user who accepted the friend request to the "friends" collection of the user who sent the request
            let fromUserFriendListRef = self.db.collection("users").document(fromUserID).collection("friends").document("friendList")
            fromUserFriendListRef.getDocument { (document, error) in
                if let error = error {
                    PrintControl.shared.printErrorMessages("Error getting friend list: \(error)")
                    
                    return
                }
                guard let document = document else {
                    let data: [String: Any] = ["friendUIDs": [toUserID]]
                    self.db.collection("users").document(fromUserID).collection("friends").document("friendList").setData(data) { error in
                        if let error = error {
                            PrintControl.shared.printErrorMessages("Error creating friend list: \(error)")
                        } else {
                            PrintControl.shared.printFriend("Friend list created")
                        }
                    }
                    return
                }
                if var friendUIDs = document.data()?["friendUIDs"] as? [String] {
                    if !friendUIDs.contains(toUserID) {
                        friendUIDs.append(toUserID)
                        batch.updateData(["friendUIDs": friendUIDs], forDocument: fromUserFriendListRef)
                    }
                } else {
                    batch.setData(["friendUIDs": [toUserID]], forDocument: fromUserFriendListRef)
                }
                
                // Update the status of the friend request to "accepted"
                let friendRequestRef = self.db.collection("friendRequests")
                friendRequestRef.whereField("fromUserID", isEqualTo: fromUserID).whereField("toUserID", isEqualTo: toUserID).getDocuments { (querySnapshot, error) in
                    if let error = error {
                        PrintControl.shared.printErrorMessages("Error getting friend request: \(error)")
                        return
                    }
                    guard let friendRequest = querySnapshot?.documents.first else {
                        PrintControl.shared.printErrorMessages("Friend request not found")
                        return
                    }
                    batch.updateData(["status": "accepted"], forDocument: friendRequest.reference)
                    // Delete the friend request
                    batch.deleteDocument(friendRequest.reference)
                    // Commit the batched updates
                    batch.commit { (error) in
                        if let error = error {
                            PrintControl.shared.printErrorMessages("Error committing batched updates: \(error)")
                        } else {
                            // Delete the friend request
                            friendRequestRef.document(friendRequest.documentID).delete { error in
                                if let error = error {
                                    PrintControl.shared.printErrorMessages("Error deleting friend request: \(error)")
                                    completion(false) // Indicate failure
                                } else {
                                    PrintControl.shared.printFriend("Friend request deleted")
                                    completion(true) // Indicate success
                                }
                            }
                            // Successfully updated friend lists and friend request status
                            // Here we can add code to create the "friends" collection and "friendList" document
                            // for either user if they don't already exist
                            let fromUserFriendsCollection = self.db.collection("users").document(fromUserID).collection("friends")
                            let toUserFriendsCollection = self.db.collection("users").document(toUserID).collection("friends")
                            
                            
                            fromUserFriendsCollection.getDocuments { (querySnapshot, error) in
                                if let error = error {
                                    PrintControl.shared.printErrorMessages("Error getting friends for user \(fromUserID): \(error)")
                                } else if querySnapshot?.documents.isEmpty ?? true {
                                    // "friends" collection doesn't exist for this user, so we create it and add the "friendList" document
                                    fromUserFriendsCollection.addDocument(data: [:]) { (error) in
                                        if let error = error {
                                            PrintControl.shared.printErrorMessages("Error creating friends collection for user \(fromUserID): \(error)")
                                        } else {
                                            PrintControl.shared.printFriend("Successfully created friends collection for user \(fromUserID)")
                                        }
                                    }
                                }
                            }
                            
                            toUserFriendsCollection.getDocuments { (querySnapshot, error) in
                                if let error = error {
                                    PrintControl.shared.printErrorMessages("Error getting friends for user \(toUserID): \(error)")
                                } else if querySnapshot?.documents.isEmpty ?? true {
                                    // "friends" collection doesn't exist for this user, so we create it and add the "friendList" document
                                    toUserFriendsCollection.addDocument(data: [:]) { (error) in
                                        if let error = error {
                                            PrintControl.shared.printErrorMessages("Error creating friends collection for user \(toUserID): \(error)")
                                        } else {
                                            PrintControl.shared.printFriend("Successfully created friends collection for user \(toUserID)")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func rejectFriendRequest(documentID: String) {
        PrintControl.shared.printFriend("-FriendRequestManager: Function: rejectFriendRequest is firing!")
        let friendRequestRef = db.collection("friendRequests").document(documentID)
        friendRequestRef.updateData(["status": "rejected"]) { error in
            if let error = error {
                PrintControl.shared.printErrorMessages("Error rejecting friend request: \(error)")
            } else {
                PrintControl.shared.printFriend("Friend request rejected")
            }
        }
    }
    
    func getFriendRequests(uid: String, completion: @escaping ([FriendInviteData]) -> Void) {
        PrintControl.shared.printFriend("-FriendRequestManager: Function: getFriendRequests is firing!")
        friendRequestRef.whereField("toUserID", isEqualTo:uid).getDocuments { (querySnapshot, error) in
            if let error = error {
                PrintControl.shared.printFriend("Error getting friend requests: \(error)")
                return
            }
            let friendRequests = querySnapshot!.documents.compactMap { document in
                do {
                    let friendInviteData = FriendInviteData(dictionary: document.data())
                    return friendInviteData
                } 
            }
            completion(friendRequests)
        }
    }
    
    func deleteFriendRequest(friendRequestID: String) {
        PrintControl.shared.printFriend("-FriendRequestManager: Function: deleteFriendRequest is firing!")
        friendRequestRef.document(friendRequestID).delete { error in
            if let error = error {
                PrintControl.shared.printErrorMessages("Error deleting friend request: \(error)")
                return
            }
            PrintControl.shared.printFriend("Friend request deleted successfully")
        }
    }
}


//MARK: Descriptions

//Here's a brief summary of what each function does:

//init(timestamp: Date): Initializes the FriendRequestManager with a timestamp.

//addFriendRequest(fromUserID: String, toUserInfo: UserData): Adds a new friend request from one user to another.

//updateNumberOfFriendRequests(userID: String, action: String): Updates the number of friend requests for a specific user.

//sendFriendRequest(fromUserID: String, toUserID: String, status: String = "pending", timestamp: Date = Date(), completion: @escaping (Result<String, Error>) -> Void): Sends a friend request from one user to another and updates the number of friend requests for the receiving user.

//acceptFriendRequest(fromUserID: String, toUserID: String): Accepts a friend request and updates the friends list of both users.

//rejectFriendRequest(documentID: String): Rejects a friend request and updates its status to "rejected".

//getFriendRequests(forUserIDuid: String, completion: @escaping ([FriendInviteData]) -> Void): Retrieves all friend requests for a specific user.

//deleteFriendRequest(friendRequestID: String): Deletes a friend request by its document ID.
