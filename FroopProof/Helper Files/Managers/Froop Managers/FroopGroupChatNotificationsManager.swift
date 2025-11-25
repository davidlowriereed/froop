//
//  FroopGroupChatNotificationsManager.swift
//  FroopProof
//
//  Created by David Reed on 11/15/23.
//

import Foundation
import Firebase
import FirebaseFirestore
import UserNotifications
import UIKit
import SwiftUI


class FroopGroupChatNotificationsManager: ObservableObject {
    static let shared = FroopGroupChatNotificationsManager()
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var notificationsManager = NotificationsManager.shared
    @Published var froopGroupConversationAndMessages: ConversationAndMessages = ConversationAndMessages(conversation: Conversation(), messages: [], participants: [])
//    @Published var conversations: [Conversation] = []
    @Published var chatEntered: Bool = false
    @Published var hostId: String = ""
    @Published var messageText: String = ""
    @Published var currentFroopId: String = ""
    @Published var currentHostId: String = ""
    @Published var chatViewOpen: Bool = false

    let db = FirebaseServices.shared.db
    let uid = FirebaseServices.shared.uid
    
    @Published var froopGroupConversations: [ConversationAndMessages] = []
//    @Published var sGCI: Int = 0 // selectedGroupChatIndex

    ///UPDATED FUNCTIONS
    
    private func printFroopConversationAndMessagesDetails(_ conversationAndMessages: ConversationAndMessages) {
        _ = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopId ?? ""
        _ = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.host.froopUserID ?? ""
    }
    
    
    
    func sendGroupMessage(content: String) {
        guard !content.isEmpty else { return }

        let froopId = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopId ?? ""
        let hostId = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.host.froopUserID ?? ""
        let groupChatRef = db.collection("users").document(hostId)
                             .collection("myFroops").document(froopId)
                             .collection("chats").document("froopGroupChat")
                             .collection("messages")

        groupChatRef.addDocument(data: [
            "senderId": uid,
            "text": content,
            "timestamp": FieldValue.serverTimestamp()
        ]) { error in
            if let error = error {
                print("🚫Error sending group message: \(error)")
                return
            }
            FroopManager.shared.refreshGroupChatMessages(for: self.appStateManager.currentFilteredFroopHistory[safe: self.appStateManager.aFHI]?.froop.froopId ?? "", for: self.appStateManager.currentFilteredFroopHistory[safe: self.appStateManager.aFHI]?.froop.froopHost ?? "")
            print("Group message posted successfully")
        }
    }
    
    func getLastMessage() -> Message {
        let currentUserUID = FirebaseServices.shared.uid
        let otherMessages = froopGroupConversationAndMessages.messages.filter { $0.senderId != currentUserUID }
        
        // Check if there are any messages and sort them to get the latest one
        if let lastMessage = otherMessages.sorted(by: { $0.timestamp > $1.timestamp }).first {
            return lastMessage
        } else {
            // Return a default message if there are no messages
            return Message(dictionary: [:], id: "")
        }
    }

    func findUserData(with uid: String) -> UserData? {
         let confirmedFriends = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.confirmedFriends ?? []
         return confirmedFriends.first(where: { $0.froopUserID == uid })
     }
}


