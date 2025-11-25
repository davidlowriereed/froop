//
//  InviteManager.swift
//  FroopProof
//
//  Created by David Reed on 3/5/24.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseFirestore


class InviteManager: ObservableObject {
    static var shared = InviteManager()
    @ObservedObject var myData = MyData.shared
    @ObservedObject var froopDC = FroopDataController.shared
    @Published var pendingInvitations: [PendingInvitation] = []
    @Published var inviteData: InviteData?
    @Published var friends: [UserData] = []
    var db = FirebaseServices.shared.db
    var uid = FirebaseServices.shared.uid
    
    func isFriend(froopUserID: String) -> Bool {
        let isFriend = myData.myFriends.contains { $0.froopUserID == froopUserID }
        print("Checking if \(froopUserID) is a friend: \(isFriend)")
        return isFriend
    }
    
    func fetchFriendList(for userID: String, completion: @escaping (Result<[UserData], Error>) -> Void) {
        let friendsRef = db.collection("users").document(userID).collection("friends").document("friendList")
        
        friendsRef.getDocument { document, error in
            guard let document = document, document.exists, let data = document.data() else {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.failure(NSError(domain: "FroopManager", code: 1002, userInfo: [NSLocalizedDescriptionKey: "Friend list document not found."])))
                }
                return
            }
            
            if let friendUIDs = data["friendUIDs"] as? [String] {
                self.fetchUserDatas(for: friendUIDs, completion: completion)
            } else {
                completion(.failure(NSError(domain: "FroopManager", code: 1003, userInfo: [NSLocalizedDescriptionKey: "Invalid format for friendUIDs."])))
            }
        }
    }
    
    private func fetchUserDatas(for uids: [String], completion: @escaping (Result<[UserData], Error>) -> Void) {
            var friends: [UserData] = []
            let group = DispatchGroup()

            for uid in uids {
                group.enter()
                FroopManager.shared.fetchUserData(for: uid) { result in
                    switch result {
                    case .success(let userData):
                        friends.append(userData)
                    case .failure(let error):
                        print("Failed to fetch user data for UID \(uid): \(error)")
                    }
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                completion(.success(friends))
            }
        }
    
    func loadPendingInvitations() async {
        print("Loading pending invitations for UID: \(uid)")
        guard !uid.isEmpty else {
            print("UID is empty. Cannot load pending invitations.")
            return
        }

        let guestListRef = db.collection("users").document(uid).collection("froopDecisions").document("froopLists").collection("myPendingList")

        do {
            let snapshot = try await guestListRef.getDocuments()
            self.pendingInvitations = snapshot.documents.compactMap { doc -> PendingInvitation? in
                let data = doc.data()
                guard let froopHost = data["froopHost"] as? String, let froopId = data["froopId"] as? String else {
                    return nil
                }
                return PendingInvitation(id: doc.documentID, froopHost: froopHost, froopId: froopId)
            }
            print("Successfully loaded pending invitations")
        } catch {
            print("🚫Error loading pending invitations: \(error)")
        }
    }
    
    func handleInvitation(inviteUid: String) async {
        print("🍒 \(inviteUid)")
        guard let inviteData = await fetchInviteDataAndAddUser(inviteUid: inviteUid) else {
            print("Failed to fetch invite data")
            return
        }
        
        do {
            try await processCurrentUserInvitation(inviteData: inviteData)
            print("Invitation processed successfully.")
        } catch {
            print("Failed to process invitation: \(error)")
        }
    }
    
    func fetchInviteDataAndAddUser(inviteUid: String) async -> InviteData? {
        let db = Firestore.firestore()
        let inviteRef = db.collection("froopUrlInvites").document(inviteUid)
        
        do {
            // Fetch the current invite document
            let document = try await inviteRef.getDocument()
            guard let data = document.data(), document.exists else {
                print("Document does not exist")
                return nil
            }
            
            let inviteData = InviteData(dictionary: data)
            
            // Increment openCount directly
            let newOpenCount = inviteData.openCount + 1
            inviteData.openCount = newOpenCount
            
            // Manually append the uid to the respondingUsers array
            inviteData.respondingUsers.append(uid) // This will allow duplicates
            
            // Update the document in Firestore with the new openCount and the manually updated respondingUsers array
            try await inviteRef.updateData([
                "openCount": newOpenCount,
                "respondingUsers": inviteData.respondingUsers // Directly set the updated array
            ])
            
            print("Updated invite data with new openCount and added current user to respondingUsers.")
            return inviteData
        } catch {
            print("An error occurred while fetching and updating invite data: \(error)")
            return nil
        }
    }
    
    func processCurrentUserInvitation(inviteData: InviteData) async throws {
        print("🍉 processCurrentUserInvitation Function Firing")
        let instanceFroopId = inviteData.froopId
        
        let guestRef = db.collection("users").document(uid)
        let guestListRef = guestRef.collection("froopDecisions").document("froopLists")
        
        
        let hostRef = db.collection("users").document(inviteData.hostId)
        let hostFroopRef = hostRef.collection("myFroops").document(instanceFroopId)
        let hostFroopListRef = hostFroopRef.collection("invitedFriends")
        
        let inviteListRef = hostFroopListRef.document("inviteList")
        let confirmedListRef = hostFroopListRef.document("confirmedList")
        let declinedListRef = hostFroopListRef.document("declinedList")
        let pendingListRef = hostFroopListRef.document("pendingList")
        
        let friendsRef = guestRef.collection("friends").document("friendList")
        let friendListDoc = try await friendsRef.getDocument()
        let friendUIDs = friendListDoc.data()?["friendUIDs"] as? [String] ?? []
        
        let isInInviteList = await isGuestUIDPresent(in: inviteListRef, guestUID: uid)
        let isInConfirmedList = await isGuestUIDPresent(in: confirmedListRef, guestUID: uid)
        let isInDeclinedList = await isGuestUIDPresent(in: declinedListRef, guestUID: uid)
        let isInPendingList = await isGuestUIDPresent(in: pendingListRef, guestUID: uid)
        
        print("Retrieved friendUIDs: \(friendUIDs)")
        
        if isInInviteList || isInConfirmedList || isInDeclinedList || isInPendingList {
                print("Guest UID already present in one of the lists. Abandoning further processing.")
        } else {
            if friendUIDs.contains(inviteData.hostId) {
                print("⭕️ Host is a friend")
                try await froopDC.addFroopToInvitesList(in: guestListRef.collection("myInvitesList"), froopHost: inviteData.hostId, froopId: inviteData.froopId)
                try await froopDC.addInvitedGuestUIDToInviteList(in: inviteListRef, newInvitedFriendUIDs: [uid])
            } else {
                print("🚷 Host is not a friend")
                try await froopDC.addFroopToInvitesList(in: guestListRef.collection("myInvitesList"), froopHost: inviteData.hostId, froopId: inviteData.froopId)
                try await froopDC.addInvitedGuestUIDToInviteList(in: inviteListRef, newInvitedFriendUIDs: [uid])
                try await froopDC.addFroopToInvitesList(in: guestListRef.collection("myPendingList"), froopHost: inviteData.hostId, froopId: inviteData.froopId)
                try await froopDC.addInvitedGuestUIDToInviteList(in: pendingListRef, newInvitedFriendUIDs: [uid])
                Task {
                    do {
                        try await updateFroopGuestApproveList(inviteData: inviteData)
                        print("Success updating guestApproveList")
                    } catch {
                        // Handle the error
                        print("Failed to update guestApproveList: \(error)")
                    }
                }
            }
            Task {
                await loadPendingInvitations()
            }
        }
    }
    
    func updateFroopGuestApproveList(inviteData: InviteData) async throws {

        // Get the Firestore database reference
        let db = Firestore.firestore()

        // Get the document reference for the Froop in question
        let froopRef = db.collection("users").document(inviteData.hostId).collection("myFroops").document(inviteData.froopId)
        print("Host: \(inviteData.hostId) and Froop: \(inviteData.froopId)")
        // Use FieldValue.arrayUnion to append the UID to the existing array in guestApproveList
        do {
            try await froopRef.updateData([
                "guestApproveList": FieldValue.arrayUnion([uid])
            ])
            print("guestApproveList successfully updated with new UID!")
        } catch {
            print("🚫Error updating guestApproveList: \(error.localizedDescription)")
            throw error // Rethrow the error if you need to handle it elsewhere
        }
    }


    
    func isGuestUIDPresent(in documentRef: DocumentReference, guestUID: String) async -> Bool {
        do {
            let documentSnapshot = try await documentRef.getDocument()
            if documentSnapshot.exists {
                if let uidArray = documentSnapshot.data()?["uid"] as? [String], uidArray.contains(guestUID) {
                    // UID is found in the list
                    print("UID found in the list")
                    return true
                }
            }
        } catch {
            print("An error occurred while checking for guest UID: \(error)")
        }
        // UID is not found in the list or an error occurred
        return false
    }
}

struct PendingInvitation: Identifiable {
    let id: String  // Use the document's UID as the unique ID
    let froopHost: String
    let froopId: String
}
