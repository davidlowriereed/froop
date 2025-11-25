//
//  notificationsManager.swift
//  FroopProof
//
//  Created by David Reed on 3/12/23.
//

import Foundation
import Firebase
import FirebaseFirestore
import UserNotifications
import UIKit
import SwiftUI
import FirebaseAuth

class NotificationsManager: ObservableObject {
    static let shared = NotificationsManager()
    @ObservedObject var firebaseServices = FirebaseServices.shared
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var froopDataListener = FroopDataListener.shared
    @Published var chatCount: Int = 0
    @Published var conversationsAndMessages: [ConversationAndMessages] = []
    @Published var conversationExists: Bool = false
    @Published var bringScrollDown: Bool = true
    @Published var chatEntered: Bool = false
    @Published var tempChatToId: String = ""
    @Published var currentChatContext: ChatContext = .global
    @Published var openGlobalChat: Bool = false

//    var appStateManager: AppStateManager {
//        return AppStateManager.shared
//    }
    
    //MARK: badges app wide
    //MARK: Froop badges
    @Published var homeInvites: Int = 0  //@User You have recieved an invitation to a Froop
    @Published var homeConfirmed: Int = 0  //@Host Friend has confirmed your invitation
    @Published var homeDeclined: Int = 0  //@Host Friend has declined your invitation
    @Published var activeFroopPreGame: Int = 0  //@User Froop Notice Message it will start in 30 minutes
    @Published var activeFroopEnding: Int = 0  //@User Froop Notice Message it will end in 30 mintues
    @Published var activeFroopHostMessage: Int = 0 //@AllConfirmed Host sends message to everyone attending
    @Published var activeFroopMessages: Int = 0 //@User Everyone that sent you a message in the Froop
    @Published var activeFroopChanges: Int = 0  //@AllConfirmed Host changes a detail about the Froop
    @Published var activeFroopPinDrop: Int = 0  //@User Someone Dropped a Pin on the Map
    @Published var froopImageAdded: Int = 0  //@User Someone uploaded a picture to the froop
    @Published var froopVideoAdded: Int = 0 //@User Someone uploaded a video to the froop
    @Published var froopPublished: Int = 0  //@AllConfirmed Host publishes froop for sharing in feed
    
    //MARK: Friend Badges
    @Published var newFriendRequest: Int = 0 //@User you have a new friend request waiting
    @Published var newFriendAccept: Int = 0  //@Sending User A friend you invited has accepted
    @Published var newFriendJoined: Int = 0  //@Sending User A friend you invited by SMS has joined
    @Published var newFriendDeclined: Int = 0  //@Sending User A friend you invited has declined
    @Published var newAcquaintanceJoined: Int = 0  //@User Someone you know has joined Froop
    
    //MARK: Communication Badges
    @Published var friendMessage: Int = 0  //@User a friend has messaged you in Froop
    @Published var friendMessages: Int = 0  //@User aggregate of all messages sent to you in Froop
    @Published var froopHostMessage: Int = 0  //@User Host from inactive froop has sent a message to all invited / confirmed users
    @Published var systemMessage: Int = 0  //@User Froop System Message
    @Published var chatIds: [String] = []
    @Published var totalUnreadMessages: Int = 0

    
    @Published var badgeCounts: [Tab: Int] = [
        .froop: 0,
    ]

    let db = FirebaseServices.shared.db
    let uid = FirebaseServices.shared.uid
    
    private var conversationListeners: [String: ListenerRegistration] = [:]
    
    var froopDataController: FroopDataController {
        return FroopDataController.shared
    }
    
    var froopManager: FroopManager {
        return FroopManager.shared
    }
    
    
    init() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        setupActiveChatsListener(uid: uid)
    }
    
    
    
    ///IN-APP MESSAGING

    
    
    private func setupActiveChatsListener(uid: String) {
        print("🅰️")
        let activeChatsRef = db.collection("users").document(uid).collection("myChats").document("activeChats")

        // Try to fetch the activeChats document
        activeChatsRef.getDocument { (document, error) in
            if let document = document, document.exists {
                // Document exists, extract chatIds
                self.chatIds = document.get("chatId") as? [String] ?? []
                PrintControl.shared.printNotifications("Document exists - Chat IDs: \(self.chatIds)") // Print the current chat IDs
                self.fetchMessagesAndConversations()
            } else {
                print("Document does not exist, creating...") // Indicate document creation
                // Document does not exist, create it
                activeChatsRef.setData(["chatId": []]) { error in
                    if let error = error {
                        print("Error creating activeChats document: \(error)")
                    } else {
                        self.chatIds = []
                        print("ActiveChats document created with empty chatId array") // Confirm document creation
                        self.fetchMessagesAndConversations()
                    }
                }
            }
        }

        // Set up listener for activeChats
        let listener = activeChatsRef.addSnapshotListener { (document, error) in
            if let document = document, document.exists {
                let newChatIds = document.get("chatId") as? [String] ?? []
                print("Listener detected changes - Updated Chat IDs: \(newChatIds)") // Print updated chat IDs
                if self.chatIds != newChatIds {
                    self.chatIds = newChatIds
                    self.fetchMessagesAndConversations()
                    self.checkForNewMessages()
                }
            } else {
                print("Error fetching activeChats: \(error?.localizedDescription ?? "Unknown error")")
            }
        }

        // Register the listener with ListenerStateService
        ListenerStateService.shared.registerListener(listener, forKey: "activeChatsListener")
    }
    
    func fetchParticipantData(forUserIds userIds: [String], completion: @escaping ([UserData]?, Error?) -> Void) {
        var participants = [UserData]()
        let dispatchGroup = DispatchGroup()

        for userId in userIds {
            dispatchGroup.enter()
            AppStateManager.shared.getUserData(uid: userId) { result in
                switch result {
                    case .success(let userData):
                        participants.append(userData)
                    case .failure(let error):
                        print("🚫Error fetching user data for userId \(userId): \(error)")
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            if participants.isEmpty {
                completion(nil, NSError(domain: "NoParticipantsFound", code: 0, userInfo: nil))
            } else {
                completion(participants, nil)
            }
        }
    }
    
    func sendMessage(content: String, toUserId: String, froopId: String? = nil) {
        guard !content.isEmpty else { return }
        postMessage(content: content, conversationId: GlobalChatNotificationsManager.shared.conversationId, toUserId: toUserId, froopId: froopId)
    }
    
    func checkForNewMessages() {
        for conversationAndMessages in conversationsAndMessages {
            guard let lastReadMessageId = conversationAndMessages.conversation.lastReadMessage[self.uid] else { continue }
            
            if let lastMessage = conversationAndMessages.messages.last, lastMessage.id != lastReadMessageId {
                // There are new messages in this conversation
                self.updateBadgeCountForNewMessage(in: conversationAndMessages)
            }
        }
    }

    func updateBadgeCountForNewMessage(in conversationAndMessages: ConversationAndMessages) {
        let conversation = conversationAndMessages.conversation
        let messages = conversationAndMessages.messages

        var unreadMessagesCount = 0

        if let lastReadMessageId = conversation.lastReadMessage[self.uid],
           let lastReadMessageIndex = messages.firstIndex(where: { $0.id == lastReadMessageId }) {
            
            // Count only messages after the last read message and not sent by the current user
            unreadMessagesCount = messages[(lastReadMessageIndex + 1)...].filter { $0.senderId != self.uid }.count
        } else {
            // If there's no last read message, consider only messages sent by others as unread
            unreadMessagesCount = messages.filter { $0.senderId != self.uid }.count
        }

        // Assign the counted value to totalUnreadMessages
        self.totalUnreadMessages = unreadMessagesCount
//        print("Updated Badge Count = \(self.totalUnreadMessages)")
    }
    
    func markMessagesAsRead(in conversationAndMessages: ConversationAndMessages) {
        guard let lastMessage = conversationAndMessages.messages.last else { return }

        let conversationRef = db.collection("chats").document(conversationAndMessages.conversation.id)
        conversationRef.updateData([
            "lastReadMessage.\(self.uid)": lastMessage.id
        ]) { error in
            if let error = error {
                print("🚫Error updating last read message: \(error)")
            } else {
                print("Last read message updated successfully")
            }
        }
    }
    
    func updateUnreadMessageCount() {
        self.totalUnreadMessages = 0 // Reset the count

        for conversation in conversationsAndMessages {
            let lastReadMessageId = conversation.conversation.lastReadMessage[self.uid] ?? ""
            let unreadMessages = conversation.messages.filter { $0.id > lastReadMessageId }
            self.totalUnreadMessages += unreadMessages.count
        }
    }
    
    ///Global Messaging

    func findOrCreateConversation(with toUserId: String, froopId: String? = nil) -> String {
    // Step 1: Check for existing conversation
    if let existingConversationId = checkForExistingConversation(with: toUserId) {
        return existingConversationId
    }
    
    // Step 2: Create a new conversation
    return createNewConversation(with: toUserId)
}
    
    func fetchMessagesAndConversations() {
        for chatId in chatIds {
            let conversationRef = db.collection("chats").document(chatId)
            
            // Set up listener for conversation details
            let conversationListener = conversationRef.addSnapshotListener { [weak self] (documentSnapshot, error) in
                guard let self = self, let snapshot = documentSnapshot, error == nil else {
                    print("🚫Error fetching conversation details: \(String(describing: error))")
                    return
                }
                
                if let conversation = Conversation(document: snapshot) {
                    // Fetch participant data for the conversation
                    self.fetchParticipantData(forUserIds: conversation.userIds) { participants, error in
                        guard let participants = participants, error == nil else {
                            print("🚫Error fetching participants: \(String(describing: error))")
                            return
                        }
                        
                        // Setup listener for messages within this conversation
                        let messagesRef = conversationRef.collection("messages").order(by: "timestamp")
                        let messagesListener = messagesRef.addSnapshotListener { (querySnapshot, error) in
                            guard let documents = querySnapshot?.documents, error == nil else {
                                print("🚫Error fetching messages: \(String(describing: error))")
                                return
                            }
                            let messages = documents.compactMap { Message(document: $0) }
                            
                            // Update or add the conversation with messages and participants
                            let conversationAndMessages = ConversationAndMessages(conversation: conversation, messages: messages, participants: participants)
                            self.updateOrAddConversationAndMessages(conversationAndMessages)
                        }
                        ListenerStateService.shared.registerListener(messagesListener, forKey: "messages_\(chatId)")
                    }
                }
            }
            ListenerStateService.shared.registerListener(conversationListener, forKey: "conversation_\(chatId)")
        }
    }
    
    func updateOrAddConversationAndMessages(_ newConversationAndMessages: ConversationAndMessages) {
        if let index = conversationsAndMessages.firstIndex(where: { $0.conversation.id == newConversationAndMessages.conversation.id }) {
            conversationsAndMessages[index] = newConversationAndMessages
        } else {
            conversationsAndMessages.append(newConversationAndMessages)
        }
        // Optionally trigger any UI updates or notifications as needed
    }

    private func printConversationAndMessagesDetails(_ conversationAndMessages: ConversationAndMessages) {
        print("Conversation ID: \(conversationAndMessages.conversation.id)")
        print("User IDs in Conversation: \(conversationAndMessages.conversation.userIds.joined(separator: ", "))")
        for message in conversationAndMessages.messages {
            print("Message ID: \(message.id), Sender ID: \(message.senderId), Receiver ID: \(message.receiverId), Content: \(message.text)")
        }
        checkForNewMessages()
    }
    
    private func checkForExistingConversation(with toUserId: String) -> String? {
        for conversationAndMessages in conversationsAndMessages {
            if conversationAndMessages.conversation.userIds.contains(toUserId) {
                return conversationAndMessages.conversation.id
            }
        }
        return nil
    }
    
    private func createNewConversation(with toUserId: String) -> String {
        let newConversationRef = db.collection("chats").document()
        let initialLastReadMessage = [self.uid: "", toUserId: ""]
        newConversationRef.setData([
            "userIds": [self.uid, toUserId],
            "lastReadMessage": initialLastReadMessage
        ])
        
        // Update activeChats for both users
        updateActiveChatsForUser(userId: self.uid, withConversationId: newConversationRef.documentID)
        updateActiveChatsForUser(userId: toUserId, withConversationId: newConversationRef.documentID)
        
        return newConversationRef.documentID
    }
    
    private func updateActiveChatsForUser(userId: String, withConversationId conversationId: String) {
        let activeChatsRef = db.collection("users").document(userId).collection("myChats").document("activeChats")
        activeChatsRef.setData(["chatId": FieldValue.arrayUnion([conversationId])], merge: true)
    }
    
    func postMessage(content: String, conversationId: String, toUserId: String, froopId: String?) {
        let conversationRef = db.collection("chats").document(conversationId)
        // Prepare message data including froopId if available
        var messageData: [String: Any] = [
            "senderId": uid,
            "receiverId": toUserId,
            "text": content,
            "timestamp": FieldValue.serverTimestamp(),
            "conversationId": conversationId,
            "froopId": froopId as Any
            
        ]
        if let froopId = froopId {
            messageData["froopId"] = froopId
        }

        // Add the new message to the conversation
        conversationRef.collection("messages").addDocument(data: messageData) { error in
            if let error = error {
                print("🚫Error sending message: \(error)")
                return
            }
            // Handle successful message sending if needed
        }
    }
    
    ///BADGES
    
    func resetBadgeCountForUser(uid: String) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(uid)
        
        userRef.updateData([
            "badgeCount": 0
        ]) { err in
            if let err = err {
                PrintControl.shared.printNotifications("Error updating document: \(err)")
            } else {
                PrintControl.shared.printNotifications("Document successfully updated")
            }
        }
    }
    
    static func sendPushNotification(to token: String, title: String, body: String, data: [String: Any]) {
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!
        let paramString: [String: Any] = ["to": token,
                                          "notification": ["title": title, "body": body],
                                          "data": data]
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=TYMUNU9WWS", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            do {
                if let jsonData = data {
                    if let json = try JSONSerialization.jsonObject(with: jsonData, options: [.allowFragments]) as? [String: Any] {
                        print(json)
                    }
                }
            } catch let error {
                PrintControl.shared.printNotifications("Error serializing JSON: \(error)")
            }
        }
        task.resume()
    }
    
    func printAllConversationAndMessagesDetails() {
        for conversationAndMessages in conversationsAndMessages {
            // Print conversation details
            print("Conversation ID: \(conversationAndMessages.conversation.id)")
            print("User IDs in Conversation: \(conversationAndMessages.conversation.userIds.joined(separator: ", "))")
           
            // Print last read message IDs per user
            print("Last Read Messages:")
            for (userId, messageId) in conversationAndMessages.conversation.lastReadMessage {
                print("User ID: \(userId), Last Read Message ID: \(messageId)")
            }

            // Print messages
            print("Messages:")
            for message in conversationAndMessages.messages {
                print("Message ID: \(message.id), Sender ID: \(message.senderId), Timestamp: \(message.timestamp), Text: \(message.text)")
            }
            
            // Print participants details
            print("Participants:")
            for participant in conversationAndMessages.participants {
                print("Participant ID: \(participant.froopUserID), Name: \(participant.firstName) \(participant.lastName)")
            }

            print("-----------------------------------")
        }
    }
}

struct ChatStoreData {
    var chats: [String] // assuming 'chats' is an array of conversation IDs
}
