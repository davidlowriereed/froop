//
//  FroopNotificationsManager.swift
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


class FroopChatNotificationsManager: ObservableObject {
    static let shared = FroopChatNotificationsManager()
    @ObservedObject var firebaseServices = FirebaseServices.shared
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var froopDataListener = FroopDataListener.shared
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var notificationsManager = NotificationsManager.shared
    
    @Published var froopConversationsAndMessages: [ConversationAndMessages] = []
    @Published var chatCount: Int = 0
    @Published var conversations: [Conversation] = []
    @Published var conversationExists: Bool = false
    @Published var chatEntered: Bool = false
    @Published var currentChatContext: ChatContext = .activeFroop(hostId: "")
    @Published var hostId: String = ""
    @Published var chatViewOpen: Bool = false
    @Published var holderConId: String = ""
    @Published var holderCon: ConversationAndMessages = ConversationAndMessages(conversation: Conversation(), messages: [], participants: [])
    @Published var totalUnreadFroopMessages: [(String, Int)] = []
    @Published var messageCount: Int = 0
    
    var activeListeners: [String: ListenerRegistration] = [:]
    var chatListener: ListenerRegistration?
    var chatListeners: [String: ListenerRegistration] = [:]
    
    let db = FirebaseServices.shared.db
    let uid = FirebaseServices.shared.uid
    
    
    func loadConversationsForCurrentUser() {
        let hostId = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.host.froopUserID ?? ""
        let froopId = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopId ?? ""

        // Immediately set up listener for the chats collection if it doesn't exist
        if self.activeListeners[froopId] == nil {
            self.setupConversationsListener(froopId: froopId)
        }

        // Path to the conversations
        let chatsRef = db.collection("users").document(hostId).collection("myFroops").document(froopId).collection("chats")

        // Fetch all conversations for the current froop
        chatsRef.getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            if let error = error {
                print("🚫Error getting conversations: \(error.localizedDescription)")
                return
            }

            guard let documents = querySnapshot?.documents else {
                print("No conversations found.")
                return
            }

            for document in documents {
                let conversationId = document.documentID
                // Check if the current user is part of the conversation (either as sender or receiver)
                if let receiverId = document.data()["receiverId"] as? String, let senderId = document.data()["senderId"] as? String, [receiverId, senderId].contains(self.uid) {
                    // Fetch messages for this conversation
                    self.fetchMessagesForConversation(document: document)
                }
            }
        }
    }

    func setupConversationsListener(froopId: String) {
        // Check if we already have an active listener for this froop's conversations
        if self.activeListeners[froopId] == nil {
            let hostId = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.host.froopUserID ?? ""
            let chatsRef = db.collection("users").document(hostId).collection("myFroops").document(froopId).collection("chats")
            
            let listener = chatsRef.addSnapshotListener { [weak self] (querySnapshot, error) in
                guard let self = self else { return }
                if let error = error {
                    print("🚫Error listening for conversation updates: \(error.localizedDescription)")
                    return
                }

                guard let snapshot = querySnapshot else {
                    print("Failed to fetch conversations.")
                    return
                }

                snapshot.documentChanges.forEach { change in
                    if change.type == .added || change.type == .modified {
                        self.handleConversationChange(change: change, froopId: froopId)
                    }
                }
            }
            
            // Store the listener using froopId as the key
            self.activeListeners[froopId] = listener
        }
    }
    
    private func fetchMessagesForConversation(document: QueryDocumentSnapshot) {
        let conversationId = document.documentID
        // Check if we already have an active listener for this conversation's messages
        if self.activeListeners[conversationId] == nil {
            let messagesRef = document.reference.collection("messages").order(by: "timestamp")
            
            let listener = messagesRef.addSnapshotListener { [weak self] (querySnapshot, error) in
                guard let self = self else { return }
                if let error = error {
                    print("🚫Error fetching messages for conversation \(conversationId): \(error.localizedDescription)")
                    return
                }

                guard let documents = querySnapshot?.documents else {
                    print("No messages found for conversation \(conversationId).")
                    return
                }

                let messages = documents.compactMap { Message(document: $0) }
                self.updateConversationAndMessages(conversationId: conversationId, messages: messages)
            }
            
            // Store the listener using conversationId as the key
            self.activeListeners[conversationId] = listener
        }
    }
    
    private func updateConversationAndMessages(conversationId: String, messages: [Message]) {
        if let index = self.froopConversationsAndMessages.firstIndex(where: { $0.id == conversationId }) {
            self.froopConversationsAndMessages[index].messages = messages
        } else {
            let newConversation = Conversation(id: conversationId, userIds: [], lastReadMessage: [:]) // Adjust based on how you initialize a new Conversation
            let newConversationAndMessages = ConversationAndMessages(conversation: newConversation, messages: messages, participants: [])
            self.froopConversationsAndMessages.append(newConversationAndMessages)
        }
    }
    
    private func handleConversationChange(change: DocumentChange, froopId: String) {
        let document = change.document
        if let receiverId = document.data()["receiverId"] as? String, let senderId = document.data()["senderId"] as? String, [receiverId, senderId].contains(self.uid) {
            // Check and update the conversation in the array or add a new one
            if let index = self.froopConversationsAndMessages.firstIndex(where: { $0.id == document.documentID }) {
                // Update existing conversation details if necessary
            } else {
                // Create a new conversation object and add it to the array
                let newConversation = Conversation(document: document) // Assuming Conversation can be initialized from a DocumentSnapshot
                if newConversation != nil {
                    self.froopConversationsAndMessages.append(ConversationAndMessages(conversation: newConversation!, messages: [], participants: []))
                }
            }
            // Now fetch messages for this conversation
            self.fetchMessagesForConversation(document: document)
        }
    }
    
    func removeListener(forId id: String) {
        activeListeners[id]?.remove()
        activeListeners.removeValue(forKey: id)
    }
    
    func setupActiveFroopChatsListener(froopId: String, currentUserUID: String, selectedFriendUID: String, conversationId: String, completion: @escaping ([Message]) -> Void) {
        holderConId = conversationId
        print("🌶️ HostID: \(appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.host.froopUserID ?? "")")
        print("🌶️🌶️ FroopId: \(froopId)")

        // Lookup the conversation in froopConversationsAndMessages
        if let conversationAndMessages = froopConversationsAndMessages.first(where: { $0.conversation.userIds.contains(currentUserUID) && $0.conversation.userIds.contains(selectedFriendUID) }) {
            let conversationId = conversationAndMessages.id
            print("🌶️🌶️🌶️ ConversationId: \(conversationId)")

            let hostId = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.host.froopUserID ?? ""

            let messagesRef = self.db.collection("users").document(hostId)
                                    .collection("myFroops").document(froopId)
                                    .collection("chats").document(conversationId)
                                    .collection("messages")
                                    .order(by: "timestamp")

            self.chatListener = messagesRef.addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("🚫Error listening for chat updates: \(error?.localizedDescription ?? "No error")")
                    return
                }
                let newMessages = documents.compactMap { Message(document: $0) }
                completion(newMessages) // Pass the messages to the callback
            }
        } else {
            print("No matching conversation found for the users")
            // Handle the case where no matching conversation is found
        }
    }

    
    ///
    ///  BEFORE FUNCTIONS
    ///
    
    func sendFroopMessage(content: String, toUserId: String) {
//        print("sendFroopMessage firing")
        guard !content.isEmpty else { return }
        let hostId = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.host.froopUserID ?? ""
        print("Host Name: \(appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.host.firstName ?? "")")
        let conversationId = holderConId
        print("Conversation ID: \(holderCon.conversation.id)")
        postFroopMessage(content: content, conversationId: conversationId, toUserId: toUserId, hostId: hostId )
    }
    
    private func checkForExistingFroopConversation(with toUserId: String) -> String? {
//        print("🤌🏼checkForExistingFroopConversation firing for user ID:  \(toUserId)")

        let currentUserId = FirebaseServices.shared.uid// Assuming this is the current user's ID

        for froopConversationAndMessages in froopConversationsAndMessages {
            let participants = froopConversationAndMessages.conversation.userIds
            printFroopConversationsAndMessages()

            // Check if the conversation involves both the current user and the target user
            if participants.contains(currentUserId) && participants.contains(toUserId) {
//                print("🤌🏼🤌🏼Existing conversation found: \(froopConversationAndMessages.conversation.id)")
                return froopConversationAndMessages.conversation.id
            }
        }
//        print("🫷🏼🫷🏼🫷🏼No existing conversation found for users: \(currentUserId) and \(toUserId)")
        return nil
    }
    
    private func createNewFroopConversation(with toUserId: String, hostId: String) -> String {
        print("🙇🏼‍♀️ createNewFroopConversation Function Firing")
        let froopId = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopId ?? ""
        let newConversationRef = db.collection("users").document(hostId).collection("myFroops").document(froopId).collection("chats").document()

        newConversationRef.setData(["userIds": [uid, toUserId]]) { error in
            if let error = error {
                print("🚫Error creating new conversation: \(error.localizedDescription)")
            } else {
                // After creating the conversation, add a document for this chat in activeChats for each user
                print("🍒 triggering updateActiveFroopChatsForUser function for: \(self.uid) for conversation ID \(newConversationRef.documentID) on Froop:  \(froopId)")
                self.updateActiveFroopChatsForUser(userId: self.uid, conversationId: newConversationRef.documentID, froopId: froopId)
                print("🍒 triggering updateActiveFroopChatsForUser function for: \(toUserId) for conversation ID \(newConversationRef.documentID) on Froop:  \(froopId)")
                self.updateActiveFroopChatsForUser(userId: toUserId, conversationId: newConversationRef.documentID, froopId: froopId)
            }
        }

        return newConversationRef.documentID
    }

    private func updateActiveFroopChatsForUser(userId: String, conversationId: String, froopId: String) {
        // Reference to the document with the given conversationId
        let activeChatRef = db.collection("users").document(userId).collection("myFroopChats").document(conversationId)

        // Attempt to retrieve the document
        activeChatRef.getDocument { (document, error) in
            if let document = document, document.exists {
                // Document already exists, print an error
                print("🚫Error: Document with conversationId \(conversationId) already exists for user \(userId).")
            } else {
                // Document does not exist, create or update the document
                activeChatRef.setData(["froopId": froopId, "conversationId": conversationId]) { error in
                    if let error = error {
                        print("🚫Error updating active chat for user \(userId): \(error.localizedDescription)")
                    } else {
                        print("Active chat for user \(userId) with conversationId \(conversationId) updated successfully.")
                    }
                }
            }
        }
    }
    
    func updateOrAddFroopConversation(_ conversation: Conversation) {
        if let index = self.froopConversationsAndMessages.firstIndex(where: { $0.conversation.id == conversation.id }) {
            self.froopConversationsAndMessages[index].conversation = conversation
        } else {
            let newConversationAndMessages = ConversationAndMessages(conversation: conversation, messages: [], participants: [])
            self.froopConversationsAndMessages.append(newConversationAndMessages)
        }
        self.checkForNewMessages()
    }
    
    func updateMessagesForFroopConversation(_ conversationId: String, messages: [Message]) {
        if let index = self.froopConversationsAndMessages.firstIndex(where: { $0.conversation.id == conversationId }) {
            self.froopConversationsAndMessages[index].messages = messages
        }
        self.checkForNewMessages()
    }
        
    func findOrCreateFroopConversation(with toUserId: String, froopId: String? = nil, completion: @escaping (String) -> Void) {
        let currentUserId = FirebaseServices.shared.uid
        let froopId = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopId ?? ""
        let hostId = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopHost ?? ""
        let chatsRef = db.collection("users").document(hostId).collection("myFroops").document(froopId).collection("chats")

        // Query for conversations that include both the current user's ID and the target user's ID in the 'userIds' array.
        let query = chatsRef.whereField("userIds", arrayContains: currentUserId)
        
        query.getDocuments { (snapshot, error) in
            if let error = error {
                print("🚫Error getting documents: \(error)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No documents found")
                return
            }
            
            // Iterate through the fetched documents to find a conversation with the specific user.
            for document in documents {
                let userIds = document.data()["userIds"] as? [String] ?? []
                if userIds.contains(toUserId) {
                    // A conversation with the specific user already exists.
                    completion(document.documentID)
                    return
                }
            }
            
            // No existing conversation found, create a new one. Include receiverId and senderId.
            let newConversationData: [String: Any] = [
                "userIds": [currentUserId, toUserId],
                "receiverId": toUserId,
                "senderId": currentUserId,
                "lastReadMessage": [currentUserId: "", toUserId: ""]
            ]
            
            // Create the new conversation document with the conversationId as its ID.
            let newConversationId = UUID().uuidString // Generate a unique ID for the conversation.
            let newConversationRef = chatsRef.document(newConversationId)
            newConversationRef.setData(newConversationData) { error in
                if let error = error {
                    print("🚫Error creating new conversation: \(error)")
                    return
                }
                
                // Return the ID of the newly created conversation.
                completion(newConversationId)
            }
        }
    }

    func checkForNewMessages() {
        for froopConversationsAndMessages in froopConversationsAndMessages {
            guard let lastReadMessageId = froopConversationsAndMessages.conversation.lastReadMessage[self.uid] else { continue }
            
            if let lastMessage = froopConversationsAndMessages.messages.last, lastMessage.id != lastReadMessageId {
                // There are new messages in this conversation
                self.notificationsManager.updateBadgeCountForNewMessage(in: froopConversationsAndMessages)
            }
        }
    }
    
    private func printFroopConversationAndMessagesDetails(_ conversationAndMessages: ConversationAndMessages) {
//        print("printFroopConversationAndMessagesDetails firing")
        
//        print("Conversation ID: \(conversationAndMessages.conversation.id)")
//        print("User IDs in Conversation: \(conversationAndMessages.conversation.userIds.joined(separator: ", "))")
        _ = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopId ?? ""
        _ = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.host.froopUserID ?? ""
        
//        for message in conversationAndMessages.messages {
//            print("Message ID: \(message.id), Sender ID: \(message.senderId), Receiver ID: \(message.receiverId), Content: \(message.text)")
//        }
    }
    
    func postFroopMessage(content: String, conversationId: String, toUserId: String, hostId: String) {
        print("postFroopMessage firing")
        let froopId = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopId ?? ""
        let senderId = FirebaseServices.shared.uid // Assuming this is the current user's ID
        
        // Reference to the conversation document
        let conversationRef = db.collection("users").document(hostId).collection("myFroops").document(froopId).collection("chats").document(conversationId)
        
        // First, check if the conversation document exists
        conversationRef.getDocument { (documentSnapshot, error) in
            if let document = documentSnapshot, document.exists {
                // Document exists, proceed to post the new message
                self.postMessage(toConversation: conversationRef, content: content, senderId: senderId, receiverId: toUserId, froopId: froopId, conversationId: conversationId)
            } else {
                // Document does not exist, create it with the necessary properties
                conversationRef.setData([
                    "userIds": [senderId, toUserId],
                    "senderId": senderId,
                    "receiverId": toUserId,
                    "froopId": froopId,
                    "conversationId": conversationId
                ]) { error in
                    if let error = error {
                        print("🚫Error creating new conversation document: \(error)")
                        return
                    }
                    // After creating the document, proceed to post the new message
                    self.postMessage(toConversation: conversationRef, content: content, senderId: senderId, receiverId: toUserId, froopId: froopId, conversationId: conversationId)
                }
            }
        }
    }

    func postMessage(toConversation conversationRef: DocumentReference, content: String, senderId: String, receiverId: String, froopId: String, conversationId: String) {
        conversationRef.collection("messages").addDocument(data: [
            "senderId": senderId,
            "receiverId": receiverId,
            "text": content,
            "timestamp": FieldValue.serverTimestamp(),
            "froopId": froopId,
            "conversationId": conversationId
        ]) { error in
            if let error = error {
                print("🚫Error sending message: \(error)")
                return
            }
            print("Message posted successfully")
            // Optionally, handle post-message success actions here
        }
    }
    
    func printFroopConversationsAndMessages() {
        for conversation in froopConversationsAndMessages {
            print("Conversation ID: \(conversation.conversation.id), User IDs: \(conversation.conversation.userIds)")
            for message in conversation.messages {
                print("Message: \(message.text), Sender ID: \(message.senderId)")
            }
        }
    }
}
