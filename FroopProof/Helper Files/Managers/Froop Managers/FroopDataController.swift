//
//  FroopDataController.swift
//  FroopProof
//
//  Created by David Reed on 3/25/23.
//

import Foundation
 
import CoreLocation
import Firebase
import Combine
import SwiftUI
import UIKit
import FirebaseFirestore
import MessageUI
import FirebaseAuth
import MapKit

class FroopDataController: NSObject, ObservableObject, MFMessageComposeViewControllerDelegate {
    static let shared = FroopDataController()
    
    var db = FirebaseServices.shared.db
    @ObservedObject var myData = MyData.shared
//    @ObservedObject var froopManager = FroopManager.shared
    @ObservedObject var notificationsManager = NotificationsManager.shared
    
    @Published var myInvitesList: [Froop] = []
    @Published var myConfirmedList: [Froop] = []
    @Published var myDeclinedList: [Froop] = []
    @Published var myArchivedList: [Froop] = []
    @Published var isLoading: Bool = false
    @Published var collectedFroops: [Froop] = []
    
    
    let timeZoneManager = TimeZoneManager()
    
    enum FroopListStatus {
        case invites, confirmed, declined, archived
    }
    
    private override init () {}
    
    lazy var froopManager: FroopManager = {
        return FroopManager()
    }()
    
    var appStateManager: AppStateManager {
        return AppStateManager.shared
    }
    
    var printControl: PrintControl {
        return PrintControl.shared
    }
    
    var froopDataListener: FroopDataListener {
        return FroopDataListener.shared
    }
    
    var froopDataController: FroopDataController {
        return FroopDataController.shared
    }
    
    var navLocationServices: NavLocationServices {
        return NavLocationServices.shared
    }
    
    var locationManager: LocationManager {
        return LocationManager.shared
    }
    
    // The function is used to handle the result of sending SMS message
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        PrintControl.shared.printFroopDataController("-function messageComposeViewController firing")
        
        switch result {
            case .cancelled:
                printControl.printErrorMessages("SMS message was cancelled")
            case .failed:
                printControl.printErrorMessages("SMS message failed")
            case .sent:
                printControl.printImage("SMS message was sent")
            @unknown default:
                printControl.printErrorMessages("Unknown error occurred while sending SMS message")
        }
        
        controller.dismiss(animated: true, completion: nil)
    }
    
    //MARK: DELETE FUNCTIONS
    
    func deleteFroop(froopId: String, froopHost: String, completion: @escaping (String) -> Void) {
        guard !froopId.isEmpty, !froopHost.isEmpty else {
            PrintControl.shared.printFroopDataController("Error: Function: deleteFroop: Froop ID or Froop Host cannot be empty")
            return
        }
        PrintControl.shared.printFroopDataController("-function deleteFroop firing")
        PrintControl.shared.printFroopDataController("Deleting froop...")
        
        let hostFroopDocRef = db.collection("users").document(froopHost).collection("myFroops").document(froopId)
        
        hostFroopDocRef.getDocument { [weak self] (documentSnapshot, error) in
            guard let self = self else { return }
            
            PrintControl.shared.printFroopDataController("Checking for host froop document...")
            if let error = error {
                PrintControl.shared.printFroopDataController("Error getting host froop document: \(error)")
                completion(froopId)
                return
            }
            
            guard let document = documentSnapshot, document.exists else {
                PrintControl.shared.printFroopDataController("Host froop document does not exist.")
                completion(froopId)
                return
            }
            
            let dispatchGroup = DispatchGroup()
            
            dispatchGroup.enter()
            self.deleteFlightDetails(forFroopId: froopId, froopHost: froopHost) { flightDetailsError in
                if let flightDetailsError = flightDetailsError {
                    print("Error deleting flight details: \(flightDetailsError)")
                } else {
                    print("Successfully deleted froop and associated flight details")
                }
                dispatchGroup.leave()
            }
            
            dispatchGroup.enter()
            self.deleteFroopChatDetails(forFroopId: froopId, froopHost: froopHost) { froopChatsError in
                if let froopChatsError = froopChatsError {
                    print("Error deleting froop chat: \(froopChatsError)")
                } else {
                    print("Successfully deleted froop and associated froop chats")
                }
                dispatchGroup.leave()
            }
            
            dispatchGroup.enter()
            self.deleteFroopPins(forFroopId: froopId, froopHost: froopHost) { froopPinsError in
                if let froopPinsError = froopPinsError {
                    print("Error deleting froop pins: \(froopPinsError)")
                } else {
                    print("Successfully deleted froop and associated froop pins")
                }
                dispatchGroup.leave()
            }
            
            dispatchGroup.enter()
            self.getGuestDeleteList(hostFroopDocRef: hostFroopDocRef, froopId: froopId, froopHost: froopHost)
            dispatchGroup.leave()
            
            dispatchGroup.notify(queue: .main) {
                hostFroopDocRef.delete { error in
                    if let error = error {
                        PrintControl.shared.printFroopDataController("Error deleting host froop document: \(error)")
                    } else {
                        PrintControl.shared.printFroopDataController("Deleted host froop document.")
                        
                        // Remove the Froop from FroopManager
                        DispatchQueue.main.async {
                            FroopManager.shared.removeFroop(froopId: froopId)
                        }
                    }
                    completion(froopId)
                }
            }
        }
    }
    
    func deleteFroopPins(forFroopId froopId: String, froopHost: String, completion: @escaping (Error?) -> Void) {
        // Get the reference to the froop document in the Firestore database
        let froopDocRef = db.collection("users").document(froopHost).collection("myFroops").document(froopId)
        
        // Navigate to the flightDetails sub-collection
        let froopPinsCollectionRef = froopDocRef.collection("froopPins")
        
        // Fetch all documents in the flightDetails collection
        froopPinsCollectionRef.getDocuments { snapshot, error in
            guard let snapshot = snapshot else {
                completion(error ?? NSError(domain: "FroopDataController", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to fetch froop Pin details"]))
                return
            }
            
            // Create a batch to delete all documents in a single operation
            let batch = self.db.batch()
            
            // Add each flight detail document to the batch delete operation
            for document in snapshot.documents {
                batch.deleteDocument(document.reference)
            }
            
            // Commit the batch operation
            batch.commit { error in
                if let error = error {
                    completion(error)
                } else {
                    print("Successfully deleted all froop Pin details for froop with ID \(froopId)")
                    completion(nil)
                }
            }
        }
    }
    
    func deleteFroopChatDetails(forFroopId froopId: String, froopHost: String, completion: @escaping (Error?) -> Void) {
        // Get the reference to the froop document in the Firestore database
        let froopDocRef = db.collection("users").document(froopHost).collection("myFroops").document(froopId)
        
        // Navigate to the flightDetails sub-collection
        let froopChatDetailsCollectionRef = froopDocRef.collection("chats")
        
        // Fetch all documents in the flightDetails collection
        froopChatDetailsCollectionRef.getDocuments { snapshot, error in
            guard let snapshot = snapshot else {
                completion(error ?? NSError(domain: "FroopDataController", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to fetch flight details"]))
                return
            }
            
            // Create a batch to delete all documents in a single operation
            let batch = self.db.batch()
            
            // Add each flight detail document to the batch delete operation
            for document in snapshot.documents {
                batch.deleteDocument(document.reference)
            }
            
            // Commit the batch operation
            batch.commit { error in
                if let error = error {
                    completion(error)
                } else {
                    print("Successfully deleted all froop chats for froop with ID \(froopId)")
                    completion(nil)
                }
            }
        }
    }
    
    func deleteFlightDetails(forFroopId froopId: String, froopHost: String, completion: @escaping (Error?) -> Void) {
        // Get the reference to the froop document in the Firestore database
        let froopDocRef = db.collection("users").document(froopHost).collection("myFroops").document(froopId)
        
        // Navigate to the flightDetails sub-collection
        let flightDetailsCollectionRef = froopDocRef.collection("flightDetails")
        
        // Fetch all documents in the flightDetails collection
        flightDetailsCollectionRef.getDocuments { snapshot, error in
            guard let snapshot = snapshot else {
                completion(error ?? NSError(domain: "FroopDataController", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to fetch flight details"]))
                return
            }
            
            // Create a batch to delete all documents in a single operation
            let batch = self.db.batch()
            
            // Add each flight detail document to the batch delete operation
            for document in snapshot.documents {
                batch.deleteDocument(document.reference)
            }
            
            // Commit the batch operation
            batch.commit { error in
                if let error = error {
                    completion(error)
                } else {
                    print("Successfully deleted all flight details for froop with ID \(froopId)")
                    completion(nil)
                }
            }
        }
    }
    
    func getGuestDeleteList(hostFroopDocRef: DocumentReference, froopId: String, froopHost: String) {
        var guestDelete: [String] = []
        PrintControl.shared.printFroopDataController("Getting guest delete list...")
        
        let hostInviteFriendsRef = hostFroopDocRef.collection("invitedFriends")
        let hostConfirmedListRef = hostInviteFriendsRef.document("confirmedList")
        let hostDeclinedListRef = hostInviteFriendsRef.document("declinedList")
        let hostInviteListRef = hostInviteFriendsRef.document("inviteList")
        
        hostInviteFriendsRef.getDocuments { (querySnapshot, error) in
            PrintControl.shared.printFroopDataController("Checking for invite friends documents...")
            if let error = error {
                PrintControl.shared.printFroopDataController("Error getting invite friends documents: \(error)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                PrintControl.shared.printFroopDataController("Invite friends documents do not exist.")
                return
            }
            
            for document in documents {
                if let uidArray = document.data()["uid"] as? [String] {
                    guestDelete += uidArray
                }
            }
            
            // Get uid arrays from confirmed, declined, and invite lists
            let listRefs = [hostConfirmedListRef, hostDeclinedListRef, hostInviteListRef]
            let listNames = ["confirmed list", "declined list", "invite list"]
            
            for (index, listRef) in listRefs.enumerated() {
                listRef.getDocument { (documentSnapshot, error) in
                    PrintControl.shared.printFroopDataController("Checking for \(listNames[index]) document...")
                    if let error = error {
                        PrintControl.shared.printFroopDataController("Error getting \(listNames[index]) document: \(error)")
                        return
                    }
                    
                    if let uidArray = documentSnapshot?.data()?["uid"] as? [String] {
                        guestDelete += uidArray
                    }
                    
                    // If this is the last list, proceed to delete documents in guests' froopLists collections
                    if index == listRefs.count - 1 {
                        self.deleteDocumentsInGuestsFroopLists(guestDelete: guestDelete, froopId: froopId, froopHost: froopHost)
                    }
                }
            }
        }
    }
    
    func deleteDocumentsInGuestsFroopLists(guestDelete: [String], froopId: String, froopHost: String) {
        for uid in guestDelete {
            let guestRef = self.db.collection("users").document(uid).collection("froopDecisions").document("froopLists")
            
            deleteDocumentsInCollection(collectionRef: guestRef.collection("myInvitesList"), froopId: froopId, collectionName: "myInvitesList")
            deleteDocumentsInCollection(collectionRef: guestRef.collection("myConfirmedList"), froopId: froopId, collectionName: "myConfirmedList")
            deleteDocumentsInCollection(collectionRef: guestRef.collection("myDeclinedList"), froopId: froopId, collectionName: "myDeclinedList")
            deleteDocumentsInCollection(collectionRef: guestRef.collection("myArchivedList"), froopId: froopId, collectionName: "myArchivedList")
        }
        
        deleteFroopIdFromHostUserLists(froopId: froopId, froopHost: froopHost)
    }

    func deleteDocumentsInCollection(collectionRef: CollectionReference, froopId: String, collectionName: String) {
        collectionRef.whereField("froopId", isEqualTo: froopId).getDocuments { (querySnapshot, error) in
            PrintControl.shared.printFroopDataController("Deleting \(collectionName) document...")
            if let error = error {
                PrintControl.shared.printFroopDataController("Error deleting \(collectionName) document: \(error)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                PrintControl.shared.printFroopDataController("\(collectionName) documents do not exist.")
                return
            }
            
            for document in documents {
                document.reference.delete()
            }
        }
    }

    func deleteFroopIdFromHostUserLists(froopId: String, froopHost: String) {
        let froopListsRef = self.db.collection("users").document(froopHost).collection("froopDecisions").document("froopLists")
        
        deleteFroopIdFromCollection(collectionRef: froopListsRef.collection("myConfirmedList"), froopId: froopId, collectionName: "myConfirmedList")
        deleteFroopIdFromCollection(collectionRef: froopListsRef.collection("myInvitesList"), froopId: froopId, collectionName: "myInvitesList")
        deleteFroopIdFromCollection(collectionRef: froopListsRef.collection("myDeclinedList"), froopId: froopId, collectionName: "myDeclinedList")
        deleteFroopIdFromCollection(collectionRef: froopListsRef.collection("myArchivedList"), froopId: froopId, collectionName: "myArchivedList")
        
        deleteHostFroopDocument(froopId: froopId, froopHost: froopHost)
    }

    func deleteFroopIdFromCollection(collectionRef: CollectionReference, froopId: String, collectionName: String) {
        collectionRef.whereField("froopId", isEqualTo: froopId).getDocuments { (querySnapshot, error) in
            PrintControl.shared.printFroopDataController("Deleting froopId from host user's \(collectionName)...")
            if let error = error {
                PrintControl.shared.printFroopDataController("Error deleting froopId from host user's \(collectionName): \(error)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                PrintControl.shared.printFroopDataController("Documents in host user's \(collectionName) do not exist.")
                return
            }
            
            for document in documents {
                document.reference.delete()
            }
        }
    }

    func deleteHostFroopDocument(froopId: String, froopHost: String) {
        let hostFroopDocRef = db.collection("users").document(froopHost).collection("myFroops").document(froopId)
        
        hostFroopDocRef.collection("invitedFriends").document("confirmedList").delete { error in
            if let error = error {
                PrintControl.shared.printFroopDataController("Error deleting confirmedList document: \(error)")
                return
            }
            
            PrintControl.shared.printFroopDataController("Deleted confirmedList document.")
            
            hostFroopDocRef.collection("invitedFriends").document("declinedList").delete { error in
                if let error = error {
                    PrintControl.shared.printFroopDataController("Error deleting declinedList document: \(error)")
                    return
                }
                
                PrintControl.shared.printFroopDataController("Deleted declinedList document.")
                
                hostFroopDocRef.collection("invitedFriends").document("inviteList").delete { error in
                    if let error = error {
                        PrintControl.shared.printFroopDataController("Error deleting inviteList document: \(error)")
                        return
                    }
                    
                    PrintControl.shared.printFroopDataController("Deleted inviteList document.")
                    
                    hostFroopDocRef.delete { error in
                        if let error = error {
                            PrintControl.shared.printFroopDataController("Error deleting host froop document: \(error)")
                            return
                        }
                        FroopManager.shared.createFroopHistoryArray { froopHistory in
                            PrintControl.shared.printData("After Deleting Froop:  froopHistory created \(froopHistory.count)")
                        }
                        PrintControl.shared.printFroopDataController("Deleted host froop document.")
                    }
                }
            }
        }
    }
    
    func moveArchivedInvitation(uid: String, froopId: String, froopHost: String) {
        print("♻️ moveArchivedInvitation function firing")
        print("♻️ uid: \(uid), froopId: \(froopId), froopHost: \(froopHost)")
        guard !uid.isEmpty, !froopId.isEmpty, !froopHost.isEmpty else {
            PrintControl.shared.printFroopDataController("Error: Function: moveFroopInvitation: UID, Froop ID, or Froop Host cannot be empty")
            return
        }
        PrintControl.shared.printFroopDataController("-function moveFroopInvitation firing")
        PrintControl.shared.printFroopDataController("UID: \(uid), Froop ID: \(froopId), Froop Host: \(froopHost)")
        
        // References
        let userDocRef = db.collection("users").document(uid).collection("froopDecisions").document("froopLists")
        let froopCollectionRef = db.collection("users").document(froopHost).collection("myFroops").document(froopId)
        
        // Move the document in the myInvitesList to the correct location
        let sourceCollection = "myArchivedList"
        let destinationCollection = "myArchivedList"

        // Find the document in the source collection
        userDocRef.collection(sourceCollection).whereField("froopId", isEqualTo: froopId).getDocuments { (querySnapshot, error) in
            if let error = error {
                PrintControl.shared.printFroopDataController("Error getting documents: \(error)")
            } else if let document = querySnapshot?.documents.first {
                let sourceDocRef = userDocRef.collection(sourceCollection).document(document.documentID)
                let destinationDocRef = userDocRef.collection(destinationCollection).document(froopId)
                
                // Run a batch operation to ensure atomicity
                let batch = self.db.batch()
                
                // Move the document from source to destination
                batch.deleteDocument(sourceDocRef)
                batch.setData([
                    "froopId": froopId,
                    "froopHost": froopHost
                ], forDocument: destinationDocRef)
                
                // Update the froop's inviteList
                let inviteListDocRef = froopCollectionRef.collection("invitedFriends").document("inviteList")
                let confirmedListDocRef = froopCollectionRef.collection("invitedFriends").document("confirmedList")
                let declinedListDocRef = froopCollectionRef.collection("invitedFriends").document("declinedList")
                
                batch.setData(["uid": FieldValue.arrayRemove([uid])], forDocument: inviteListDocRef, merge: true)
            
                batch.setData(["uid": FieldValue.arrayUnion([uid])], forDocument: confirmedListDocRef, merge: true)
                
                
                
                // Commit the batch
                batch.commit { error in
                    if let error = error {
                        PrintControl.shared.printFroopDataController("Error updating froop invitation: \(error)")
                    } else {
                        PrintControl.shared.printFroopDataController("Froop invitation successfully updated")
                    }
                }
            }
        }
    }
    
    func moveFroopInvitation(uid: String, froopId: String, froopHost: String, decision: String) {
        guard !uid.isEmpty, !froopId.isEmpty, !froopHost.isEmpty else {
            PrintControl.shared.printFroopDataController("Error: Function: moveFroopInvitation: UID, Froop ID, or Froop Host cannot be empty")
            return
        }
        PrintControl.shared.printFroopDataController("-function moveFroopInvitation firing")
        PrintControl.shared.printFroopDataController("UID: \(uid), Froop ID: \(froopId), Froop Host: \(froopHost), Decision: \(decision)")
        
        
        // References
        let userDocRef = db.collection("users").document(uid).collection("froopDecisions").document("froopLists")
        let froopCollectionRef = db.collection("users").document(froopHost).collection("myFroops").document(froopId)
        
        // Move the document in the myInvitesList to the correct location
        let sourceCollection: String
        let destinationCollection: String
        
        switch decision {
            case "accept":
                sourceCollection = "myInvitesList"
                destinationCollection = "myConfirmedList"
//                if let makeCount = notificationsManager.badgeCounts[.make], makeCount > 0 {
//                    notificationsManager.badgeCounts[.make] = makeCount - 1
//                }
            case "decline":
                sourceCollection = "myInvitesList"
                destinationCollection = "myDeclinedList"
//                if let makeCount = notificationsManager.badgeCounts[.make], makeCount > 0 {
//                    notificationsManager.badgeCounts[.make] = makeCount - 1
//                }
            default:
                PrintControl.shared.printData("Invalid decision")
                return
        }

        
        // Find the document in the source collection
        userDocRef.collection(sourceCollection).whereField("froopId", isEqualTo: froopId).getDocuments { (querySnapshot, error) in
            if let error = error {
                PrintControl.shared.printFroopDataController("Error getting documents: \(error)")
            } else if let document = querySnapshot?.documents.first {
                let sourceDocRef = userDocRef.collection(sourceCollection).document(document.documentID)
                let destinationDocRef = userDocRef.collection(destinationCollection).document(froopId)
                
                // Run a batch operation to ensure atomicity
                let batch = self.db.batch()
                
                // Move the document from source to destination
                batch.deleteDocument(sourceDocRef)
                batch.setData([
                    "froopId": froopId,
                    "froopHost": froopHost
                ], forDocument: destinationDocRef)
                
                // Update the froop's inviteList
                let inviteListDocRef = froopCollectionRef.collection("invitedFriends").document("inviteList")
                let confirmedListDocRef = froopCollectionRef.collection("invitedFriends").document("confirmedList")
                let declinedListDocRef = froopCollectionRef.collection("invitedFriends").document("declinedList")
                
                batch.setData(["uid": FieldValue.arrayRemove([uid])], forDocument: inviteListDocRef, merge: true)
                
                if decision == "accept" {
                    batch.setData(["uid": FieldValue.arrayUnion([uid])], forDocument: confirmedListDocRef, merge: true)
                } else {
                    batch.setData(["uid": FieldValue.arrayUnion([uid])], forDocument: declinedListDocRef, merge: true)
                }
                
                // Commit the batch
                batch.commit { error in
                    if let error = error {
                        PrintControl.shared.printFroopDataController("Error updating froop invitation: \(error)")
                    } else {
                        PrintControl.shared.printFroopDataController("Froop invitation successfully updated")
                    }
                }
            }
        }
    }
    
    func loadFroopLists(forUserWithUID uid: String, completion: @escaping () -> Void) {
        guard !uid.isEmpty else {
            printControl.printErrorMessages("Function: loadFroopLists: UID cannot be empty")
            completion()
            return
        }
        printControl.printFroopDataController("-Function loadFroopLists firing for user with UID: \(uid)")
        
        let dispatchGroup = DispatchGroup()
        
        // Block to fetch froops based on the status
        let fetchFroops = { (status: FroopListStatus) in
            dispatchGroup.enter()
            self.getCollectedFroops(forUserWithUID: uid, status: status) { (froops, error) in
                if let error = error {
                    self.printControl.printErrorMessages("Error getting \(status) froops: \(error.localizedDescription)")
                } else {
                    switch status {
                    case .invites: self.myInvitesList = froops ?? []
                    case .confirmed: self.myConfirmedList = froops ?? []
                    case .declined: self.myDeclinedList = froops ?? []
                    case .archived: self.myArchivedList = froops ?? []
                    }
                }
                dispatchGroup.leave()
            }
        }
        
        // Load all the froop lists
        fetchFroops(.invites)
        fetchFroops(.confirmed)
        fetchFroops(.declined)
        fetchFroops(.archived)
        
        dispatchGroup.notify(queue: .main) {
            PrintControl.shared.printFroopDataController("Finished loading froop lists")
            PrintControl.shared.printFroopDataController("Number of Froops in myInvitesList: \(self.myInvitesList.count)")
            PrintControl.shared.printFroopDataController("Number of Froops in myConfirmedList: \(self.myConfirmedList.count)")
            PrintControl.shared.printFroopDataController("Number of Froops in myDeclinedList: \(self.myDeclinedList.count)")
            PrintControl.shared.printFroopDataController("Number of Froops in myArchivedList: \(self.myArchivedList.count)")
            completion()
        }
    }
    
    func getCollectedFroops(forUserWithUID uid: String, status: FroopListStatus, completion: @escaping ([Froop]?, Error?) -> Void) {
        guard !uid.isEmpty else {
            PrintControl.shared.printFroopDataController("Error: Function: getCollectedFroops: UID cannot be empty")
            completion(nil, NSError(domain: "FroopDataController", code: 0, userInfo: [NSLocalizedDescriptionKey: "UID cannot be empty"]))
            return
        }
        
        let collectionName: String
        switch status {
            case .invites: collectionName = "myInvitesList"
            case .confirmed: collectionName = "myConfirmedList"
            case .declined: collectionName = "myDeclinedList"
            case .archived: collectionName = "myArchivedList"
        }

        var collectedFroops: [Froop] = []
        let dispatchGroup = DispatchGroup()
        
        db.collection("users").document(uid).collection("froopDecisions").document("froopLists").collection(collectionName).getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(nil, error)
            } else {
                querySnapshot?.documents.forEach { document in
                    if let froopId = document.get("froopId") as? String,
                       let froopHost = document.get("froopHost") as? String {
                        dispatchGroup.enter()
                        
                        // Get the main Froop data
                        self.db.collection("users").document(froopHost).collection("myFroops").document(froopId).getDocument { (froopDocument, error) in
                            if let froopData = froopDocument?.data(), froopDocument?.exists == true {
                                // After getting Froop, fetch associated flight details
                                let flightDetailsRef = self.db.collection("users").document(froopHost).collection("myFroops").document(froopId).collection("flightDetails")
                                flightDetailsRef.getDocuments { (snapshot, flightError) in
                                    let froop = Froop(dictionary: froopData) // Initialize Froop with main data
                                    if let flightDocuments = snapshot?.documents, !flightDocuments.isEmpty {
                                        // Assuming only one flight detail is relevant, adjust if multiple are expected
                                        if let flightData = flightDocuments.first?.data(),
                                           let flightDetail = ScheduledFlightAPI.FlightDetail(dictionary: flightData) {
                                            froop?.flightData = flightDetail
                                        }
                                    }
                                    collectedFroops.append(froop ?? Froop(dictionary: [:]) ?? Froop.emptyFroop())
                                    dispatchGroup.leave()
                                }
                            } else {
                                dispatchGroup.leave()
                            }
                        }
                    } else {
                        PrintControl.shared.printFroopDataController("Skipping placeholder document or invalid froopId/froopHost")
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                    completion(collectedFroops, nil)
                }
            }
        }
    }

    
    func fetchUserDocumentNames(listType: String, completion: @escaping ([String]?, Error?) -> Void) {
        PrintControl.shared.printFroopDataController("-function fetchUserDocumentNames firing")
        let uid = FirebaseServices.shared.uid
        
        guard ["myInvitesList", "myConfirmedList", "myDeclinedList"].contains(listType) else {
            PrintControl.shared.printFroopDataController("Invalid list type")
            completion(nil, nil)
            return
        }
        
        db.collection("users").document(uid).collection("froopDecisions").document("froopLists").collection(listType).getDocuments { (querySnapshot, error) in
            if let error = error {
                PrintControl.shared.printFroopDataController("Error fetching documents: \(error)")
                completion(nil, error)
            } else {
                if let querySnapshot = querySnapshot {
                    let documentNames = querySnapshot.documents.map { $0.documentID }
                    PrintControl.shared.printFroopDataController("User document names: \(documentNames)")
                    completion(documentNames, nil)
                } else {
                    PrintControl.shared.printFroopDataController("Error: querySnapshot is nil")
                    completion(nil, nil)
                }
            }
        }
    }
    
    func getFroopDataForDoc(listType: String, name: String, completion: @escaping ([String: Any]?, Error?) -> Void) {
        let uid = MyData.shared.froopUserID
        
        guard !uid.isEmpty, !name.isEmpty else {
            PrintControl.shared.printFroopDataController("Error: Function: getFroopDataForDoc:uid or name cannot be empty")
            completion(nil, nil)
            return
        }
        PrintControl.shared.printFroopDataController("-function getFroopDataForDoc firing")
        
        guard ["myInvitesList", "myConfirmedList", "myDeclinedList"].contains(listType) else {
            PrintControl.shared.printFroopDataController("Invalid list type")
            completion(nil, nil)
            return
        }
        
        let froopListsRef = db.collection("users").document(uid).collection("froopDecisions").document("froopLists")
        let collectionName = froopListsRef.collection(listType)
        
        collectionName.document(name).getDocument { (document, error) in
            if let error = error {
                PrintControl.shared.printFroopDataController("Error getting froop data: \(error.localizedDescription)")
                completion(nil, error)
            } else if let document = document, document.exists {
                let froopData = document.data()
                completion(froopData, nil)
            } else {
                completion(nil, nil)
            }
        }
    }
    
    
    
    func addInvitedFriendstoFroop(invitedFriends: [UserData], instanceFroopId: String, instanceHostId: String) async throws -> [UserData] {
        print("🚦 FirebaseServices.shared.uid:  \(FirebaseServices.shared.uid)")
        print(instanceFroopId)
        let uid = FirebaseServices.shared.uid

        let userRef = db.collection("users").document(uid)
        print("🌐 \(invitedFriends.count)")

        print("🚦🚦\(userRef.path)")

        let invitedFriendsRef = userRef.collection("myFroops").document(instanceFroopId).collection("invitedFriends")
        print("🚦🚦🚦\(invitedFriendsRef.path)")

        let froopListRef = userRef.collection("froopDecisions").document("froopLists")
        print("🚦🚦🚦🚦\(froopListRef.path)")

        let inviteListRef = invitedFriendsRef.document("inviteList")
        print("🚦🚦🚦🚦🚦\(inviteListRef.path)")

        let confirmedListRef = invitedFriendsRef.document("confirmedList")
        print("🚦🚦🚦🚦🚦🚦\(confirmedListRef.path)")

        let declinedListRef = invitedFriendsRef.document("declinedList")
        print("🚦🚦🚦🚦🚦🚦🚦\(declinedListRef.path)")

        let invitedListCollectionRef = froopListRef.collection("myInvitedList")
        print("🚦🚦🚦🚦🚦🚦🚦🚦\(invitedListCollectionRef.path)")

        let confirmedListCollectionRef = froopListRef.collection("myConfirmedList")
        print("🚦🚦🚦🚦🚦🚦🚦🚦🚦\(confirmedListCollectionRef.path)")

        let declinedListCollectionRef = froopListRef.collection("myDeclinedList")
        print("🚦🚦🚦🚦🚦🚦🚦🚦🚦🚦 \(declinedListCollectionRef.path)")
        

        // Extract the UIDs from the invitedFriends array
        let invitedFriendUIDs = invitedFriends.map { $0.froopUserID }

        // Check if the current user's UID is in the list of invitedFriends
        let isCurrentUserInvited = invitedFriendUIDs.contains(uid)

        // Remove friends that are not in the invitedFriendUIDs list
        let modifiedInvitedFriends = invitedFriends.filter { invitedFriendUIDs.contains($0.froopUserID) }

        // Process each invited friend
        for invitedFriend in modifiedInvitedFriends {
            let invitedGuestRef = db.collection("users").document(invitedFriend.froopUserID).collection("froopDecisions").document("froopLists")

            let froopIdExistsInInvitesList = try await checkIfFroopIdExists(in: invitedGuestRef.collection("myInvitesList"), froopId: instanceFroopId)
            let froopIdExistsInConfirmedList = try await checkIfFroopIdExists(in: invitedGuestRef.collection("myConfirmedList"), froopId: instanceFroopId)
            let froopIdExistsInDeclinedList = try await checkIfFroopIdExists(in: invitedGuestRef.collection("myDeclinedList"), froopId: instanceFroopId)
            if froopIdExistsInInvitesList {
                    try await confirmGuestUIDInList(in: inviteListRef, guestUID: invitedFriend.froopUserID)
                } else if froopIdExistsInConfirmedList {
                    try await confirmGuestUIDInList(in: confirmedListRef, guestUID: invitedFriend.froopUserID)
                } else if froopIdExistsInDeclinedList {
                    try await confirmGuestUIDInList(in: declinedListRef, guestUID: invitedFriend.froopUserID)
                } else {
                    // If the current user is the invited friend and they are the host, add them to the confirmedList
                    if invitedFriend.froopUserID == uid && isCurrentUserInvited {
                        try await addFroopToConfirmedList(in: invitedGuestRef.collection("myConfirmedList"), froopHost: instanceHostId, froopId: instanceFroopId)
                        try await addInvitedGuestUIDToConfirmedList(in: confirmedListRef, newInvitedFriendUIDs: [invitedFriend.froopUserID])
                    } else {
                        // Otherwise, add the invitation document to the guest's myInvitationsList
                        try await addFroopToInvitesList(in: invitedGuestRef.collection("myInvitesList"), froopHost: instanceHostId, froopId: instanceFroopId)
                        try await addInvitedGuestUIDToInviteList(in: inviteListRef, newInvitedFriendUIDs: [invitedFriend.froopUserID])
                    }
                }
            }
            return modifiedInvitedFriends
    }
    
    func addInvitedGuestUIDToConfirmedList(in documentRef: DocumentReference, newInvitedFriendUIDs: [String]) async throws {
        let documentSnapshot = try await documentRef.getDocument()
        if documentSnapshot.exists {
            try await documentRef.updateData([
                "uid": FieldValue.arrayUnion(newInvitedFriendUIDs)
            ])
        } else {
            // Document doesn't exist, create it
            try await documentRef.setData(["uid": newInvitedFriendUIDs])
        }
    }
    
    func addFroopToConfirmedList(in collectionRef: CollectionReference, froopHost: String, froopId: String) async throws {
        let documentId = UUID().uuidString
        try await collectionRef.document(documentId).setData([
            "froopHost": froopHost,
            "froopId": froopId,
            "documentID": documentId
        ])
    }

    func checkIfFroopIdExists(in collectionRef: CollectionReference, froopId: String) async throws -> Bool {
        let querySnapshot = try await collectionRef.whereField("froopId", isEqualTo: froopId).getDocuments()
        print("Checking the \(collectionRef) to see if user is present.")
        return !querySnapshot.documents.isEmpty
    }

    func addFroopToInvitesList(in collectionRef: CollectionReference, froopHost: String, froopId: String) async throws {
        let documentId = UUID().uuidString
        try await collectionRef.document(documentId).setData([
            "froopHost": froopHost,
            "froopId": froopId,
            "documentID": documentId
        ])
    }

    func confirmGuestUIDInList(in documentRef: DocumentReference, guestUID: String) async throws {
        let documentSnapshot = try await documentRef.getDocument()
        if documentSnapshot.exists {
            PrintControl.shared.printFroopDataController("document exists")
            if var uidArray = documentSnapshot.data()?["uid"] as? [String], !uidArray.contains(guestUID) {
                uidArray.append(guestUID)
                try await documentRef.updateData(["uid": uidArray])
            }
        } else {
            // Document doesn't exist, create it
            try await documentRef.setData(["uid": [guestUID]])
        }
    }
    
    func addInvitedGuestUIDToInviteList(in documentRef: DocumentReference, newInvitedFriendUIDs: [String]) async throws {
        let documentSnapshot = try await documentRef.getDocument()
        if documentSnapshot.exists {
            try await documentRef.updateData([
                "uid": FieldValue.arrayUnion(newInvitedFriendUIDs)
            ])
        } else {
            // Document doesn't exist, create it
            try await documentRef.setData(["uid": newInvitedFriendUIDs])
        }
    }
    
    func processPastEvents() {
        PrintControl.shared.printFroopDataController("-function processPastEvents firing")
        
        let uid = FirebaseServices.shared.uid
        let userRef = db.collection("users").document(uid)
        let froopListRef = userRef.collection("froopDecisions").document("froopLists")
        let confirmedListCollectionRef = froopListRef.collection("myConfirmedList")
        let archivedListCollectionRef = froopListRef.collection("myArchivedList")
        let inviteListCollectionRef = froopListRef.collection("myInvitesList")
        
        let currentTime = Date()
        PrintControl.shared.printFroopDataController("CurrentTime in ProcessPastEvents \(currentTime)")
        let currentTimeUTC = timeZoneManager.convertDateToUTC(date: currentTime, oTZ: TimeZone.current)
        PrintControl.shared.printFroopDataController("CurrentTimeUTC in ProcessPastEvents \(currentTimeUTC)")
        PrintControl.shared.printFroopDataController("######## 0. Current Time (UTC): \(currentTime)")
        PrintControl.shared.printFroopDataController("######## 0.1 Current Time: \(currentTime)")
        
        //Process myConfirmedList
        PrintControl.shared.printFroopDataController("######## 1. Processing myConfirmedList")
        confirmedListCollectionRef.getDocuments { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                PrintControl.shared.printFroopDataController("Error fetching documents: \(String(describing: error))")
                return
            }
            PrintControl.shared.printFroopDataController("########2. Fetched documents successfully: \(documents.count) documents found")
            for document in documents {
                //                print("######## 3. Looping through document: \(document.documentID)")
                let froopId = document.data()["froopId"] as? String ?? ""
                let froopHost = document.data()["froopHost"] as? String ?? ""
                
                if froopId.isEmpty || froopHost.isEmpty {
                    PrintControl.shared.printFroopDataController("Skipping empty froopId or froopHost in confirmedListCollection")
                    continue
                }
                
                PrintControl.shared.printFroopDataController("######## 4. Fetching froop document")
                self.db.collection("users").document(froopHost).collection("myFroops").document(froopId).getDocument { (froopDocument, error) in
                    if let error = error {
                        PrintControl.shared.printFroopDataController("Error fetching Froop data: \(error.localizedDescription)")
                    } else if let froopDocument = froopDocument, froopDocument.exists, let froopData = froopDocument.data() {
                        let froop = Froop(dictionary: froopData)
                        let endTimeUTC = froop?.froopEndTime
                        
                        let endTime = endTimeUTC  // Updated line
                        PrintControl.shared.printFroopDataController("######## 4.1 Froop Start Time: \(String(describing: froop?.froopStartTime))")
                        PrintControl.shared.printFroopDataController("######## 4.2 Froop End Time: \(String(describing: endTime))")
                        PrintControl.shared.printFroopDataController("######## 4.3 Froop Duration: \( String(describing: froop?.froopDuration))") 
                        
                        
                        if endTime?.addingTimeInterval(30 * 60) ?? Date() < currentTime {
                            PrintControl.shared.printFroopDataController("######## 5. Moving Froop \(froopId) to myArchivedList")
                            let sourceRef = confirmedListCollectionRef.document(document.documentID) // Use document.documentID instead of froopId
                            let destinationRef = archivedListCollectionRef.document(document.documentID)
                            self.moveDocument(sourceRef: sourceRef, destinationRef: destinationRef)
                        } else {
                            PrintControl.shared.printFroopDataController("######## 5.1 Froop \(froopId) is still active")
                        }
                        
                    }
                }
            }
        }
        
        PrintControl.shared.printFroopDataController("######## 6. Processing myInvitesList")
        inviteListCollectionRef.getDocuments { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                PrintControl.shared.printFroopDataController("Error fetching documents: \(String(describing: error))")
                return
            }
            PrintControl.shared.printFroopDataController("######## 7. Fetched documents successfully: \(documents.count) documents found")
            for document in documents {
                PrintControl.shared.printFroopDataController("######## 8. Looping through document: \(document.documentID)")
                let froopId = document.data()["froopId"] as? String ?? ""
                let froopHost = document.data()["froopHost"] as? String ?? ""
                
                if document.documentID == "placeholder" {
                    PrintControl.shared.printFroopDataController("Skipping placeholder document in inviteListCollection")
                    continue
                }
                
                
                if froopId.isEmpty || froopHost.isEmpty {
                    PrintControl.shared.printFroopDataController("Skipping empty froopId or froopHost in inviteListCollection")
                    continue
                }
                
                PrintControl.shared.printFroopDataController("######## 9. Fetching froop document")
                self.db.collection("users").document(froopHost).collection("myFroops").document(froopId).getDocument { (froopDocument, error) in
                                   if let error = error {
                                       PrintControl.shared.printFroopDataController("Error fetching Froop data: \(error.localizedDescription)")
                                   } else if let froopDocument = froopDocument, froopDocument.exists, let froopData = froopDocument.data() {
                                       let froop = Froop(dictionary: froopData)
                                       let endTimeUTC = froop?.froopEndTime
                                       if froop?.froopCreationTime ?? Date() > froop?.froopStartTime ?? Date() {
                                           PrintControl.shared.printFroopDataController("####### This is a Past Froop")
                                           return
                                       }
                                       let endTime = endTimeUTC
                                       
                                       if endTime ?? Date() < currentTime {
                            PrintControl.shared.printFroopDataController("######## 10. Deleting expired Froop (\(froopId)) from myInvitesList")
                            let sourceRef = inviteListCollectionRef.document(document.documentID) // Use document.documentID instead of froopId
                            let destinationRef = archivedListCollectionRef.document(document.documentID)
                            self.moveDocument(sourceRef: sourceRef, destinationRef: destinationRef)
                        } else {
                            PrintControl.shared.printFroopDataController("Froop (\(froopId)) in myInvitesList is still active")
                        }
                    } else {
                        PrintControl.shared.printFroopDataController("Froop document does not exist or has been deleted")
                    }
                }
            }
        }
    }
    
    func moveDocument(sourceRef: DocumentReference, destinationRef: DocumentReference) {
        PrintControl.shared.printFroopDataController("-function moveDocument firing")
        sourceRef.getDocument { (document, error) in
            if let error = error {
                // Log the error and prevent further operations.
                PrintControl.shared.printData("Error getting document: \(error)")
            } else if let document = document, document.exists, let data = document.data() {
                destinationRef.setData(data) { error in
                    if let error = error {
                        PrintControl.shared.printFroopDataController("Error writing document to destination collection: \(error.localizedDescription)")
                    } else {
                        sourceRef.delete() { error in
                            if let error = error {
                                PrintControl.shared.printFroopDataController("Error removing document from source collection: \(error.localizedDescription)")
                            } else {
                                PrintControl.shared.printFroopDataController("Document successfully moved from source to destination collection!")
                            }
                        }
                    }
                }
            } else {
                PrintControl.shared.printFroopDataController("Error fetching document: \(error?.localizedDescription ?? "Document does not exist")")
            }
        }
    }
}





