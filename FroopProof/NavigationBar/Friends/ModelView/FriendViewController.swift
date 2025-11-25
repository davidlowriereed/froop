//
//  FriendViewController.swift
//  FroopProof
//
//  Created by David Reed on 3/10/23.
//

import Foundation
 
import CoreLocation
import Firebase
import SwiftUI
import FirebaseFirestore
import MessageUI


class FriendViewController: NSObject, ObservableObject, MFMessageComposeViewControllerDelegate {
    static let shared = FriendViewController()
    
//    var appStateManager: AppStateManager {
//        return AppStateManager.shared
//    }
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var navLocationServices = NavLocationServices.shared
    // @ObservedObject var froopDataListener = FroopDataListener.shared
    @ObservedObject var myData = MyData.shared
    
    var db = FirebaseServices.shared.db
    @Published var friendDataList: [UserData] = []
    @Published var userFriendsList: [String] = []
    @Published var uidFriendsList: [String] = []
    @Published var friendsInCommonList: [String] = []
    @Published var friendLookUpResultList: [String] = []
    @Published var friendInviteList: [FriendInviteData] = []
    @Published var propertyList: [String] = []
    @Published var extractedFD: UserData = UserData()
    @Published var fetchedFriendsList: [UserData] = []
    @Published var friends: [UserData] = []
    @Published var invitedFriends: [UserData] = []
    
    func sendInvitation(froopId: String, froopHost: String, friendId: String, completion: @escaping (Bool, Error?) -> Void) {
        let inviteData: [String: Any] = [
            "froopId": froopId,
            "froopHost": froopHost,
            "friendId": friendId,
            "status": "pending" // or whatever status you use for new invites
        ]
        
        let inviteRef = db.collection("users").document(friendId).collection("froopDecisions").document("froopLists").collection("myInvitesList").document(froopId)
        
        inviteRef.setData(inviteData) { error in
            if let error = error {
                print("🚫Error sending invitation: \(error.localizedDescription)")
                completion(false, error)
            } else {
                print("Invitation sent to friend \(friendId) for froop \(froopId)")
                completion(true, nil)
            }
        }
    }
    
    func checkForExistingInvitation(froopId: String, froopHost: String, friendId: String, completion: @escaping (Bool, Bool) -> Void) {
        let friendRef = db.collection("users").document(friendId)
        let inviteRef = friendRef.collection("froopDecisions").document("froopLists").collection("myInvitesList").document(froopId)
        let declinedRef = friendRef.collection("froopDecisions").document("froopLists").collection("myDeclinedList").document(froopId)
        
        let dispatchGroup = DispatchGroup()

        var hasExistingInvite = false
        var hasDeclinedInvite = false

        dispatchGroup.enter()
        inviteRef.getDocument { (document, error) in
            if let document = document, document.exists {
                hasExistingInvite = true
            }
            dispatchGroup.leave()
        }

        dispatchGroup.enter()
        declinedRef.getDocument { (document, error) in
            if let document = document, document.exists {
                hasDeclinedInvite = true
            }
            dispatchGroup.leave()
        }

        dispatchGroup.notify(queue: .main) {
            completion(hasExistingInvite, hasDeclinedInvite)
        }
    }

    
    
    func filteredFriends(friends: [UserData], searchText: String) -> [UserData] {
        guard !searchText.isEmpty else {
            return friends
        }
        return friends.filter { friend in
            friend.firstName.localizedCaseInsensitiveContains(searchText) ||
            friend.lastName.localizedCaseInsensitiveContains(searchText)
        }
    }

    func acceptPendingInvitesForNewUser(phoneNumber: String, newUserID: String) {
        guard !phoneNumber.isEmpty, !newUserID.isEmpty else {
            print("🚫Error: Phone number or new user ID is empty")
            return
        }
        findFriendsByPhoneNumber(phoneNumber: phoneNumber, uid: MyData.shared) { friendLookUpResultList, error in
            if let error = error {
                print("🚫Error finding friends by phone number: \(error.localizedDescription)")
                return
            }
            for friendID in friendLookUpResultList {
                let friendRequestManager = FriendRequestManager(timestamp: Date())
                friendRequestManager.acceptFriendRequest(fromUserID: friendID, toUserID: newUserID) { (success) in
                    print("success")
                }
            }
        }
    }

    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch result {
        case .cancelled:
            print("SMS message was cancelled")
        case .failed:
            print("SMS message failed")
        case .sent:
            print("SMS message was sent")
        @unknown default:
            print("Unknown error occurred while sending SMS message")
        }
        controller.dismiss(animated: true, completion: nil)
    }

    func extractFriendData<T>(_ searchValue: String, from friendDataList: [T], propertyName: String, completion: @escaping (UserData?, Error?) -> Void) where T: UserData {
        guard !searchValue.isEmpty, !propertyName.isEmpty else {
            completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Search value or property name is empty"]))
            return
        }
        if let foundFriend = friendDataList.first(where: { "\(($0 as AnyObject).value(forKey: propertyName)!)" == searchValue }) {
            print("Found FriendData Object with \(propertyName) == \(searchValue)")
            completion(foundFriend, nil)
        } else {
            print("No FriendData Objects Found with \(propertyName)")
            completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No FriendData Objects Found with \(propertyName)"]))
        }
    }

    func getSinglePropertyList<T>(_ dataObjects: [T], objectType: T.Type, propertyName: String, completion: @escaping ([String], Error?) -> Void) {
        guard !propertyName.isEmpty else {
            completion([], NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Property name is empty"]))
            return
        }
        var propertyList: [String] = []
        for dataObject in dataObjects {
            let mirror = Mirror(reflecting: dataObject)
            if let property = mirror.children.first(where: { $0.label == propertyName }) {
                propertyList.append("\(property.value)")
            } else {
                completion([], NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Property \(propertyName) not found in \(objectType)"]))
                return
            }
        }
        completion(propertyList, nil)
    }

    func convertIDToFriendData(uid: String, completion: @escaping (UserData?, Error?) -> Void) {
        guard !uid.isEmpty else {
            print("🚫Error: uid is empty")
            completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "UID is empty"]))
            return
        }
        
        let userRef = db.collection("users").document(uid)
        userRef.getDocument { document, error in
            if let error = error {
                print("🚫Error fetching user: \(error.localizedDescription)")
                completion(nil, error)
            } else if let document = document, let data = document.data() {
                let friendData = UserData(dictionary: data)
                completion(friendData, nil)
            } else {
                completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Error fetching user"]))
            }
        }
    }

    func convertListToFriendData(uidList: [String], completion: @escaping ([UserData], Error?) -> Void) {
        print("🚫froopId array \(uidList)")
        guard !uidList.isEmpty else {
            completion([], NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "UID list is empty"]))
            return
        }
        let dispatchGroup = DispatchGroup()
        var friendDataArray = [UserData]()
        
        for uid in uidList {
            dispatchGroup.enter()
            let userRef = db.collection("users").document(uid)
            userRef.getDocument { document, error in
                if let document = document, let data = document.data() {
                    let friendData = UserData(dictionary: data)
                    friendDataArray.append(friendData ?? UserData())
                } else if let error = error {
                    friendDataArray = []
                    print("🚫Error fetching user: \(error.localizedDescription)")
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            if friendDataArray.isEmpty {
                completion([], NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No friend data found"]))
            } else {
                completion(friendDataArray, nil)
                self.friendDataList = friendDataArray
                print("friendDataList: \(self.friendDataList)")
            }
        }
    }
    
    func getFroopInvitedFriends(froopId: String, hostId: String, completion: @escaping ([String], Error?) -> Void) {
        guard !froopId.isEmpty else {
            print("🚫froopId: \(froopId), / hostId: \(hostId)")
            completion([], NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Froop ID is empty"]))
            return
        }
        let froopRef = db.collection("users").document(hostId).collection("myFroops").document(froopId)
        froopRef.getDocument { document, error in
            if let document = document, document.exists, let froopInvitedFriends = document.data()?["froopInvitedFriends"] as? [String] {
                completion(froopInvitedFriends, nil)
            } else {
                completion([], error ?? NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Friend UIDs not found"]))
            }
        }
    }
    
    func getUserFriends(userID: String, completion: @escaping ([String], Error?) -> Void) {
        guard !userID.isEmpty else {
            completion([], NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User ID is empty"]))
            return
        }
        let userRef = db.collection("users").document(userID)
        let friendListRef = userRef.collection("friends").document("friendList")
        friendListRef.getDocument { document, error in
            if let document = document, document.exists, let friendUIDs = document.data()?["friendUIDs"] as? [String] {
                completion(friendUIDs, nil)
            } else {
                completion([], error ?? NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Friend UIDs not found"]))
            }
        }
    }

    func getuidFriends() {
        
        let uid = FirebaseServices.shared.uid
        
        let uidFriendListRef = db.collection("users").document(uid).collection("friends").document("friendList")
        uidFriendListRef.getDocument { document, error in
            if let document = document, document.exists, let friends = document.data()?["friendUIDs"] as? [String] {
                DispatchQueue.main.async {
                    self.uidFriendsList = friends
                }
            } else {
                print("🚫Error fetching current user's friends: \(error?.localizedDescription ?? "unknown error")")
            }
        }
    }

    func findCommonFriends(userFriendsList: [String], uidFriendsList: [String], completion: @escaping ([String], Error?) -> Void) {
        guard !userFriendsList.isEmpty, !uidFriendsList.isEmpty else {
            completion([], NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "One or both friend lists are empty"]))
            return
        }
        let commonFriends = Set(userFriendsList).intersection(uidFriendsList)
        completion(Array(commonFriends), nil)
    }

    func findFriendsByPhoneNumber(phoneNumber: String, uid: MyData, completion: @escaping ([String], Error?) -> Void) {
        let formattedPhoneNumber = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        guard !formattedPhoneNumber.isEmpty else {
            completion([], NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Phone number is empty or invalid"]))
            return
        }
        let userRef = db.collection("users")
        if formattedPhoneNumber == myData.phoneNumber {
            completion([], NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Phone number belongs to current user."]))
            return
        }
        userRef.whereField("phoneNumber", isEqualTo: formattedPhoneNumber).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("🚫Error searching for user with phone number \(phoneNumber): \(error.localizedDescription)")
                completion([], error)
                return
            }
            guard let documents = querySnapshot?.documents else {
                print("No documents found for user with phone number \(phoneNumber)")
                completion([], NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No documents found for user with phone number \(phoneNumber)"]))
                return
            }
            let friendLookUpResultList = documents.map { $0.documentID }
            completion(friendLookUpResultList, nil)
        }
    }

    func findFriendInvites(thisUser: String, statusX: String, completion: @escaping ([FriendInviteData], Error?) -> Void) {
        guard !thisUser.isEmpty, !statusX.isEmpty else {
            completion([], NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User ID or status is empty"]))
            return
        }
        let friendRequestsRef = db.collection("friendRequests")
            .whereField("toUserID", isEqualTo: thisUser)
            .whereField("status", isEqualTo: statusX)
        friendRequestsRef.addSnapshotListener { querySnapshot, error in
            if let error = error {
                print("🚫Error fetching friend requests: \(error.localizedDescription)")
                completion([], error)
                return
            }
            guard let snapshot = querySnapshot else {
                completion([], NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Error fetching friend requests"]))
                return
            }
            var friendInviteList: [FriendInviteData] = []
            for document in snapshot.documents {
                let toUserInfo = document.data()["toUserInfo"] as? String ?? ""
                let fromUserID = document.data()["fromUserID"] as? String ?? ""
                let documentID = document.documentID
                let status = "pending"
                let friendInvite = FriendInviteData(dictionary: [
                    "toUserInfo": toUserInfo,
                    "fromUserID": fromUserID,
                    "documentID": documentID,
                    "status": status
                ])
                friendInviteList.append(friendInvite)
            }
            completion(friendInviteList, nil)
        }
    }

    
    func findRejectedFriendInvites(thisUser: String, completion: @escaping ([FriendInviteData], Error?) -> Void) {
        guard !thisUser.isEmpty else {
            completion([], NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User ID is empty"]))
            return
        }
        let friendRequestsRef = db.collection("friendRequests")
            .whereField("toUserID", isEqualTo: thisUser)
            .whereField("status", isEqualTo: "rejected")
        friendRequestsRef.addSnapshotListener { querySnapshot, error in
            if let error = error {
                print("🚫Error fetching friend requests: \(error.localizedDescription)")
                completion([], error)
                return
            }
            guard let snapshot = querySnapshot else {
                completion([], NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Error fetching friend requests"]))
                return
            }
            var friendInviteList: [FriendInviteData] = []
            for document in snapshot.documents {
                let toUserInfo = document.data()["toUserInfo"] as? String ?? ""
                let fromUserID = document.data()["fromUserID"] as? String ?? ""
                let documentID = document.documentID
                let status = "rejected"
                let friendInvite = FriendInviteData(dictionary: [
                    "toUserInfo": toUserInfo,
                    "fromUserID": fromUserID,
                    "documentID": documentID,
                    "status": status
                ])
                friendInviteList.append(friendInvite)
            }
            completion(friendInviteList, nil)
        }
    }

}
