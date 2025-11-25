//
//  InvitationList.swift
//  FroopProof
//
//  Created by David Reed on 4/7/23.
//

import Combine
import SwiftUI
import Firebase
import FirebaseFirestore

class InvitationList: ObservableObject {
    @Published var myInvitesList: [String] = []
    @Published var myConfirmedList: [String] = []
    @Published var myDeclinedList: [String] = []
    
    private var listenerService = ListenerStateService.shared
    let uid = FirebaseServices.shared.uid
    var db = FirebaseServices.shared.db
    private var invitesListener: ListenerRegistration?
    private var confirmedListener: ListenerRegistration?
    private var declinedListener: ListenerRegistration?
    
    private var invitesListenerKey: String { return "invitesListListenerKey_\(uid)" }
    private var confirmedListenerKey: String { return "confirmedListListenerKey_\(uid)" }
    private var declinedListenerKey: String { return "declinedListListenerKey_\(uid)" }
    
    
    init(uid: String) {
        observeInvitations(for: uid)
    }
    
    deinit {
        invitesListener?.remove()
        confirmedListener?.remove()
        declinedListener?.remove()
    }
    
    private func observeInvitations(for uid: String) {
        let userRef = db.collection("users").document(uid).collection("froopDecisions").document("froopLists")
        
        // Observe myInvitesList
        if listenerService.shouldCreateListener(forKey: invitesListenerKey) {
            let listener = userRef.collection("myInvitesList").addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    PrintControl.shared.printErrorMessages("Error fetching documents: \(String(describing: error))")
                    return
                }
                self.myInvitesList = documents.filter { $0.documentID != "placeholder" }.map { $0.documentID }
            }
            listenerService.addListener(listener, forKey: invitesListenerKey)
        }
        
        // Observe myConfirmedList
        if listenerService.shouldCreateListener(forKey: confirmedListenerKey) {
            let listener = userRef.collection("myConfirmedList").addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    PrintControl.shared.printErrorMessages("Error fetching documents: \(String(describing: error))")
                    return
                }
                self.myConfirmedList = documents.filter { $0.documentID != "placeholder" }.map { $0.documentID }
            }
            listenerService.addListener(listener, forKey: confirmedListenerKey)
        }
        
        // Observe myDeclinedList
        if listenerService.shouldCreateListener(forKey: declinedListenerKey) {
            let listener = userRef.collection("myDeclinedList").addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    PrintControl.shared.printErrorMessages("Error fetching documents: \(String(describing: error))")
                    return
                }
                self.myDeclinedList = documents.filter { $0.documentID != "placeholder" }.map { $0.documentID }
            }
            listenerService.addListener(listener, forKey: declinedListenerKey)
        }
    }
}
