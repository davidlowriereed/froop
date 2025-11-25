//
//  FroopHistoryService.swift
//  FroopProof
//
//  Created by David Reed on 10/19/23.
//

import FirebaseFirestore
import SwiftUI
import Combine

class FroopHistoryService: ObservableObject {
    static let shared = FroopHistoryService(froop: Froop(dictionary: [:]) ?? Froop.emptyFroop())
    private var froop: Froop
    var db = FirebaseServices.shared.db
    var uid = FirebaseServices.shared.uid
    @Published var myInvitesListListener: ListenerRegistration?
    @Published var myConfirmedListListener: ListenerRegistration?
    @Published var myDeclinedListListener: ListenerRegistration?
    @Published var myArchivedListListener: ListenerRegistration?
//    @Published var froopHistories: [FroopHistory] = []
    private var listeners: [String: ListenerRegistration] = [:]
    private var cancellables: Set<AnyCancellable> = []
    @Published var reportSignalSent: Bool = false
    
    var froopManager: FroopManager {
        return FroopManager.shared
    }
    
    init(froop: Froop) {
        self.froop = froop
        myInvitesListListener = FroopDataListener.shared.listenToFroopList(type: .invites, uid: uid) { froops in
            self.froopManager.createFroopHistoryArray { froopHistory in
                PrintControl.shared.printFroopHistoryServices("froopHistory created \(froopHistory.count)")
            }
        }
        myConfirmedListListener = FroopDataListener.shared.listenToFroopList(type: .confirmed, uid: uid) { froops in
            self.froopManager.createFroopHistoryArray { froopHistory in
                PrintControl.shared.printFroopHistoryServices("froopHistory created \(froopHistory.count)")
            }
        }
        myDeclinedListListener = FroopDataListener.shared.listenToFroopList(type: .declined, uid: uid) { froops in
            self.froopManager.createFroopHistoryArray { froopHistory in
                PrintControl.shared.printFroopHistoryServices("froopHistory created \(froopHistory.count)")
            }
        }
        myArchivedListListener = FroopDataListener.shared.listenToFroopList(type: .archived, uid: uid) { froops in
            self.froopManager.createFroopHistoryArray { froopHistory in
                PrintControl.shared.printFroopHistoryServices("froopHistory created \(froopHistory.count)")
            }
        }
        // Observe changes in listener activation state and respond accordingly
        ListenerStateService.shared.listenersActiveSubject
            .sink { [weak self] isActive in
                if isActive {
                    self?.setupListeners(for: froop)
                } else {
                    self?.deactivateAllListeners()
                }
            }
            .store(in: &cancellables)
        
        // Listen to Froop updates
        ListenerStateService.shared.froopUpdateSubject
            .sink { [self] updatedFroop in
                self.updateFroopHistories(for: updatedFroop)
                self.reportSignalSent = true
            }
            .store(in: &cancellables)
    }
    
    func setupListeners(for froop: Froop) {
        // Listener for the Froop document
        let froopRef = self.db.collection("users").document(froop.froopHost).collection("myFroops").document(froop.froopId)
        self.setupListener(forDocument: froopRef, withKey: "froop_\(froop.froopId)") {
//            print("a change happened to the Froop")
            self.updateFroopHistory(for: froop)
        }
        
        // Listener for the Group Chat of the Froop
        self.listenToGroupChatChanges(froopId: froop.froopId, hostId: froop.froopHost)
        
        // Listener for the Host of the Froop
        let hostRef = self.db.collection("users").document(froop.froopHost)
        self.setupListener(forDocument: hostRef, withKey: "host_\(froop.froopHost)") {
            self.updateFroopHistory(for: froop)
        }
        
        let froopInvitedListsRef = self.db.collection("users").document(froop.froopHost).collection("myFroops").document(froop.froopId).collection("invitedFriends").document("inviteList")
        self.setupListener(forDocument: froopInvitedListsRef, withKey: "froopInviteLists_\(froop.froopId)") {
//            print("a change happened to InviteList")
            self.updateFroopHistory(for: froop)
        }
        
        let froopConfirmedListsRef = self.db.collection("users").document(froop.froopHost).collection("myFroops").document(froop.froopId).collection("invitedFriends").document("confirmedList")
        self.setupListener(forDocument: froopConfirmedListsRef, withKey: "froopConfirmedLists_\(froop.froopId)") {
//            print("a change happened to ConfirmedListe")
            self.updateFroopHistory(for: froop)
        }
        
        let froopDeclinedListsRef = self.db.collection("users").document(froop.froopHost).collection("myFroops").document(froop.froopId).collection("invitedFriends").document("confirmedList")
        self.setupListener(forDocument: froopDeclinedListsRef, withKey: "froopDeclinedLists_\(froop.froopId)") {
//            print("a change happened to DeclinedList")
            self.updateFroopHistory(for: froop)
        }

        // Listeners for Collections
        let froopDecisionLists = ["myArchivedList", "myConfirmedList", "myInvitedList", "myDeclinedList"]
        for path in froopDecisionLists {
            let ref = self.db.collection("users").document(froop.froopHost).collection("froopDecisions").document("froopLists").collection(path)
            self.setupListener(forCollection: ref, withKey: path) {
                self.updateFroopHistory(for: froop)
            }
        }
    }
    
    func listenToGroupChatChanges(froopId: String, hostId: String) {
        let listenerKey = "groupChat_\(froopId)"
        
        if ListenerStateService.shared.shouldCreateListener(forKey: listenerKey) {
            let groupChatRef = db.collection("users").document(hostId)
                                   .collection("myFroops").document(froopId)
                                   .collection("chats").document("froopGroupChat")
                                   .collection("messages").order(by: "timestamp")

            let listener = groupChatRef.addSnapshotListener { [weak self] querySnapshot, error in
                if let error = error {
                    PrintControl.shared.printFroopHistoryServices("Error listening to group chats: \(error.localizedDescription)")
                    return
                }
                guard let self = self, let documents = querySnapshot?.documents else {
                    return
                }

                // Print an alert to the console indicating new messages have been received
                print("New messages detected in group chat for Froop ID: \(froopId)")

                // Map each document to a Message object
                let newMessages = documents.compactMap { Message(document: $0) }

                // Update the corresponding FroopHistory object with new messages
                withAnimation(.easeInOut(duration: 0.5)) {
                    if let index = self.froopManager.froopHistory.firstIndex(where: { $0.froop.froopId == froopId }) {
                        // Append new messages to existing messages in froopGroupConversationAndMessages
                        self.froopManager.froopHistory[index].froopGroupConversationAndMessages.messages.append(contentsOf: newMessages)
                    }
                }
            }
            
            ListenerStateService.shared.registerListener(listener, forKey: listenerKey)
        }
    }

    private func setupListener(forDocument document: DocumentReference, withKey key: String, onChange: @escaping () -> Void) {
        if ListenerStateService.shared.shouldCreateListener(forKey: key) {
            let listener = document.addSnapshotListener { (snapshot, error) in
                if let err = error {
                    PrintControl.shared.printFroopHistoryServices("Error listening to document: \(document.path). Error: \(err.localizedDescription)")
                } else if snapshot != nil {
                    PrintControl.shared.printFroopHistoryServices("Data change detected at document: \(document.path)")
                    onChange()
                }
            }
            listeners[key] = listener
            ListenerStateService.shared.registerListener(listener, forKey: key)
        }
    }

    private func setupListener(forCollection collection: CollectionReference, withKey key: String, onChange: @escaping () -> Void) {
        if ListenerStateService.shared.shouldCreateListener(forKey: key) {
            let listener = collection.addSnapshotListener { (snapshot, error) in
                if let err = error {
                    PrintControl.shared.printFroopHistoryServices("Error listening to collection: \(collection.path). Error: \(err.localizedDescription)")
                } else if snapshot != nil {
                    PrintControl.shared.printFroopHistoryServices("Data change detected at collection: \(collection.path)")
                    onChange()
                }
            }
            listeners[key] = listener
            ListenerStateService.shared.registerListener(listener, forKey: key)
        }
    }

    private func updateFroopHistory(for froop: Froop) {
        // Find the FroopHistory instance that needs updating
        withAnimation(.easeInOut(duration: 0.5)) {
            if let index = froopManager.froopHistory.firstIndex(where: { $0.froop.froopId == froop.froopId }) {
                // Fetch the updated data for the FroopHistory
                froopManager.createSingleFroopHistory(for: froop) { updatedFroopHistory in
                    // Update the FroopHistory instance
                    self.froopManager.froopHistory[index] = updatedFroopHistory ?? FroopManager.defaultFroopHistory()
                    // Notify any observers that the data has changed
                    self.froopManager.froopHistoryUpdateSubject.send()
                }
            }
        }
    }

    private func fetchDataFrom(_ collection: String) -> [Dictionary<String, Any>] {
        // Fetch data from Firestore. Placeholder, needs to be implemented.
        return []
    }

    private func updateFroopHistories(for froop: Froop) {
        PrintControl.shared.printFroopHistoryServices("🔄 Attempting to update FroopHistories for Froop with ID: \(froop.froopId)")
        FroopManager.shared.createSingleFroopHistory(for: froop) { [weak self] froopHistory in
            guard let newFroopHistory = froopHistory else {
                // Handle error or failure to get FroopHistory
                PrintControl.shared.printFroopHistoryServices("Failed to create FroopHistory for Froop with ID: \(froop.froopId)")
                return
            }
            
            // Check if this FroopHistory is already in the list
            withAnimation(.easeInOut(duration: 0.5)) {
                if let index = self?.froopManager.froopHistory.firstIndex(where: { $0.froop.froopId == froop.froopId }) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        self?.froopManager.froopHistory[index] = newFroopHistory
                    }
                } else {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        self?.froopManager.froopHistory.append(newFroopHistory)
                    }
                }
            }
        }
        evaluateFroopHistoryConditions()
    }
    
    func evaluateFroopHistoryConditions() {
        PrintControl.shared.printFroopHistoryServices("🤩 evaluate Froop History Condition is firing" )
        let currentDate = Date()
        
        for froopHistory in froopManager.froopHistory {
            PrintControl.shared.printFroopHistoryServices("Current Date \(Date())")
            PrintControl.shared.printFroopHistoryServices("froopHistory.froop.froopStartTime \(froopHistory.froop.froopStartTime)")
            PrintControl.shared.printFroopHistoryServices("froophistory.froop.froopEndTime \(froopHistory.froop.froopEndTime)")
            if currentDate >= froopHistory.froop.froopStartTime && currentDate <= froopHistory.froop.froopEndTime {
              
                // If any of the FroopHistory objects match your criteria, notify listeners
                froopManager.froopHistoryUpdateSubject.send()
                break
            }
        }
    }

    func deactivateAllListeners() {
        for (key, _) in listeners {
            PrintControl.shared.printFroopHistoryServices("🔕 Deactivating listener with key: \(key)")
            ListenerStateService.shared.removeListener(forKey: key)
        }
    }
}



