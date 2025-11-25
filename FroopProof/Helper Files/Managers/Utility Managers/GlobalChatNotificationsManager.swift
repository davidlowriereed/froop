
import Foundation
import Firebase
import FirebaseFirestore
import UserNotifications
import UIKit
import SwiftUI
import FirebaseAuth

class GlobalChatNotificationsManager: ObservableObject {
    static let shared = GlobalChatNotificationsManager()
    @ObservedObject var notificationsManager = NotificationsManager.shared
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
    @Published var holderCon: ConversationAndMessages = ConversationAndMessages(conversation: Conversation(), messages: [], participants: [])
    @Published var holderConIndex: Int = 0
    @Published var chatIds: [String] = []
    @Published var isLoading = false
    @Published var otherUserId = ""
    @Published var chatToId = ""
    @Published var conversationId: String = ""
    @Published var selectedFriend: UserData = UserData()
   
    
    let db = FirebaseServices.shared.db
    let uid = FirebaseServices.shared.uid
    
    private var conversationListeners: [String: ListenerRegistration] = [:]
    
    var froopDataController: FroopDataController {
        return FroopDataController.shared
    }
    
    var otherUserfroopUserID: String {
        let conversation = holderCon.conversation
        if let otherUserId = getOtherUserId(from: conversation),
           let otherUserData = findUserData(with: otherUserId) {
            return otherUserData.froopUserID
        } else {
            return ""
        }
    }
    
    var otherUserProfileImageUrl: String {
        let conversation = holderCon.conversation
        if let otherUserId = getOtherUserId(from: conversation),
           let otherUserData = findUserData(with: otherUserId) {
            return otherUserData.profileImageUrl
        } else {
            return "" // default URL or placeholder
        }
    }
    
    var otherUserName: String {
        let conversation = holderCon.conversation
        if let otherUserId = getOtherUserId(from: conversation),
           let otherUserData = findUserData(with: otherUserId) {
            return otherUserData.firstName + " " + otherUserData.lastName
        } else {
            return "" // default URL or placeholder
        }
    }
    
    var froopManager: FroopManager {
        return FroopManager.shared
    }
    
    var currentConversation: ConversationAndMessages? {
        return notificationsManager.conversationsAndMessages.first { conversationAndMessages in
            conversationAndMessages.conversation.id.contains(conversationId)
        }
    }
    
    init() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        setupActiveChatsListener(uid: uid)
    }
    
    ///General Functions
    
    private func getOtherUserId(from conversation: Conversation) -> String? {
        let currentUserUID = FirebaseServices.shared.uid
        return conversation.userIds.first(where: { $0 != currentUserUID })
    }
    
    private func findUserData(with uid: String) -> UserData? {
        let confirmedFriends = MyData.shared.myFriends
        return confirmedFriends.first(where: { $0.froopUserID == uid })
    }
    
    func printGlobalConversationsAndMessages() {
        for conversation in conversationsAndMessages {
            print("Conversation ID: \(conversation.conversation.id), User IDs: \(conversation.conversation.userIds)")
            for message in conversation.messages {
                print("Message: \(message.text), Sender ID: \(message.senderId)")
            }
        }
    }
    
    ///IN-APP MESSAGING
    
   
    
    private func setupActiveChatsListener(uid: String) {
        let activeChatsRef = db.collection("users").document(uid).collection("myChats").document("activeChats")
        
        // Try to fetch the activeChats document
        activeChatsRef.getDocument { (document, error) in
            if let document = document, document.exists {
                // Document exists, extract chatIds
                self.chatIds = document.get("chatId") as? [String] ?? []
//                print("🙊 chat IDs: \(self.chatIds)")
                self.fetchMessagesAndConversations()
            } else {
                // Document does not exist, create it
                activeChatsRef.setData(["chatId": []]) { error in
                    if let error = error {
                        print("🚫Error creating activeChats document: \(error)")
                    } else {
                        self.chatIds = []
                        self.fetchMessagesAndConversations()
                    }
                }
            }
        }
        // Set up listener for activeChats
        let listener = activeChatsRef.addSnapshotListener { (document, error) in
            if let document = document, document.exists {
                self.chatIds = document.get("chatId") as? [String] ?? []
            } else {
                print("🚫Error fetching activeChats: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
        // Register the listener with ListenerStateService
        ListenerStateService.shared.registerListener(listener, forKey: "activeChatsListener")
        
    }
    
    func sendMessage(content: String, toUserId: String, froopId: String? = nil) {
        guard !content.isEmpty else { return }
        
        // Use findOrCreateConversation with a completion handler to get the conversation ID asynchronously
        findOrCreateConversation(with: toUserId, froopId: froopId) { conversationId in
            // Now that you have the conversationId, proceed to post the message
            self.postMessage(content: content, conversationId: conversationId, toUserId: toUserId, froopId: froopId)
        }
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
        self.notificationsManager.totalUnreadMessages = unreadMessagesCount
//        print("Updated Badge Count = \(self.totalUnreadMessages)")
    }
    
    func markMessagesAsRead(in conversationAndMessages: ConversationAndMessages) {
        guard let lastMessage = conversationAndMessages.messages.last else { return }

        // First, update the local array with the new lastReadMessage information
        if var currentConversation = notificationsManager.conversationsAndMessages.first(where: { $0.conversation.id == conversationAndMessages.conversation.id }) {
            currentConversation.conversation.lastReadMessage[self.uid] = lastMessage.id
            
            // Find the index of the current conversation in the array
            if let index = notificationsManager.conversationsAndMessages.firstIndex(where: { $0.conversation.id == currentConversation.conversation.id }) {
                notificationsManager.conversationsAndMessages[index] = currentConversation // Update the array with the modified conversation
            }
        }

        // Then, update Firestore
        let conversationRef = db.collection("chats").document(conversationAndMessages.conversation.id)
        conversationRef.updateData([
            "lastReadMessage.\(self.uid)": lastMessage.id
        ]) { error in
            if let error = error {
                print("Error updating last read message: \(error)")
            } else {
                print("Last read message updated successfully")
            }
        }
        updateUnreadMessageCount()
    }
    
    func updateUnreadMessageCount() {
        self.notificationsManager.totalUnreadMessages = 0 // Reset the count

        for conversation in conversationsAndMessages {
            let lastReadMessageId = conversation.conversation.lastReadMessage[self.uid] ?? ""
            let unreadMessages = conversation.messages.filter { $0.id > lastReadMessageId }
            self.notificationsManager.totalUnreadMessages += unreadMessages.count
        }
    }
    
    ///Global Messaging
    
 
    
    func setupConversation(with selectedFriendId: String) {
        guard currentConversation == nil else { return }
        
        isLoading = true
        
        findOrCreateConversation(with: selectedFriendId) { conversationId in
            self.isLoading = false
            
        }
    }
    
    
    
    func findOrCreateConversation(with toUserId: String, froopId: String? = nil, completion: @escaping (String) -> Void) {
        let currentUserId = FirebaseServices.shared.uid
        let chatsRef = db.collection("chats")

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
            
            // No existing conversation found, create a new one.
            let newConversationData: [String: Any] = [
                "userIds": [currentUserId, toUserId],
                "lastReadMessage": [currentUserId: "", toUserId: ""]
            ]
            
            // Add any additional initial data as needed.
            
            // Create the new conversation document.
            let newConversationRef = chatsRef.document()
            newConversationRef.setData(newConversationData) { error in
                if let error = error {
                    print("🚫Error creating new conversation: \(error)")
                    return
                }
                
                // Return the ID of the newly created conversation.
                completion(newConversationRef.documentID)
            }
        }
    }

    
    func indexOfConversation(withConversationId conversationId: String, in conversationsAndMessages: [ConversationAndMessages]) -> Int? {
        return conversationsAndMessages.firstIndex { $0.conversation.id == conversationId }
    }
    
    func fetchMessagesAndConversations() {
        for chatId in chatIds {
            setupConversationListener(conversationId: chatId)
            setupMessagesListener(conversationId: chatId)
        }
    }
    
    // Sets up a listener for changes in a specific conversation document
    func setupConversationListener(conversationId: String) {
        let conversationRef = db.collection("chats").document(conversationId)
        let conversationListener = conversationRef.addSnapshotListener { [weak self] (document, error) in
            guard let self = self else { return }
            if let error = error {
                print("🚫Error fetching conversation details: \(error.localizedDescription)")
                return
            }
            guard let document = document, document.exists, let conversation = Conversation(document: document) else {
                print("Document for conversation \(conversationId) does not exist or failed to initialize.")
                return
            }
            self.updateOrAddConversation(conversation)
        }
        ListenerStateService.shared.registerListener(conversationListener, forKey: "conversation_\(conversationId)")
    }

    // Updates or adds a conversation to the conversationsAndMessages array
    func updateOrAddConversation(_ conversation: Conversation) {
        if let index = self.conversationsAndMessages.firstIndex(where: { $0.conversation.id == conversation.id }) {
            self.conversationsAndMessages[index].conversation = conversation
        } else {
            let newConversationAndMessages = ConversationAndMessages(conversation: conversation, messages: [], participants: [])
            self.conversationsAndMessages.append(newConversationAndMessages)
        }
        self.checkForNewMessages()
    }

    // Sets up a listener for messages within a specific conversation
    func setupMessagesListener(conversationId: String) {
        let messagesRef = db.collection("chats").document(conversationId).collection("messages").order(by: "timestamp")
        let messagesListener = messagesRef.addSnapshotListener { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            if let error = error {
                print("🚫Error fetching messages for \(conversationId): \(error.localizedDescription)")
                return
            }
            guard let documents = querySnapshot?.documents else {
                print("No documents found in messages collection for \(conversationId).")
                return
            }
            let messages = documents.compactMap { Message(document: $0) }
            self.updateMessagesForConversation(conversationId, messages: messages)
        }
        ListenerStateService.shared.registerListener(messagesListener, forKey: "messages_\(conversationId)")
    }

    // Updates the messages for a specific conversation in the conversationsAndMessages array
    func updateMessagesForConversation(_ conversationId: String, messages: [Message]) {
        if let index = self.conversationsAndMessages.firstIndex(where: { $0.conversation.id == conversationId }) {
            self.conversationsAndMessages[index].messages = messages
            // Manually trigger an update if holderCon corresponds to this conversation
            if holderCon.conversation.id == conversationId {
                DispatchQueue.main.async {
                    self.holderCon = ConversationAndMessages(conversation: self.holderCon.conversation, messages: messages, participants: self.holderCon.participants)
                }
            }
        }
    }
    
    func manageSpecificConversation(with toUserId: String) {
        findOrCreateConversation(with: toUserId) { [weak self] conversationId in
            guard let self = self else { return }
            
            // Check if the conversation is already present in the conversationsAndMessages array
            if !self.conversationsAndMessages.contains(where: { $0.conversation.id == conversationId }) {
                // The conversation is new, set up listeners for the conversation and its messages
                self.setupConversationListener(conversationId: conversationId)
                self.setupMessagesListener(conversationId: conversationId)
            } else {
                // The conversation already exists, maybe refresh or update UI as needed
                // This can be a good place to ensure the UI is scrolled to the latest message or similar actions
            }
        }
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
        // Prepare message data
        print(" 🤘content: \(content)")
        print(" 🤘conversationId: \(conversationId)")
        print(" 🤘toUserId: \(toUserId)")
        print(" 🤘froopId: \(String(describing: froopId))")
        
        var messageData: [String: Any] = [
            "senderId": FirebaseServices.shared.uid,
            "receiverId": toUserId,
            "text": content,
            "timestamp": FieldValue.serverTimestamp(),
            "conversationId": conversationId
        ]
        
        if let froopId = froopId {
            messageData["froopId"] = froopId
        }
        
        // Check if conversationId exists in the current user's activeChats
        let currentUserActiveChatsRef = db.collection("users").document(FirebaseServices.shared.uid).collection("myChats").document("activeChats")
        currentUserActiveChatsRef.getDocument { documentSnapshot, error in
            if let document = documentSnapshot, document.exists, let chatIds = document.get("chatId") as? [String], chatIds.contains(conversationId) {
                // conversationId exists in the current user's activeChats, proceed to post the message
                self.postMessageToConversation(content: content, conversationId: conversationId, messageData: messageData)
            } else {
                // conversationId does not exist, update activeChats for both users and then post the message
                self.updateActiveChatsForUser(userId: FirebaseServices.shared.uid, withConversationId: conversationId)
                self.updateActiveChatsForUser(userId: toUserId, withConversationId: conversationId)
                self.postMessageToConversation(content: content, conversationId: conversationId, messageData: messageData)
            }
        }
    }

    private func postMessageToConversation(content: String, conversationId: String, messageData: [String: Any]) {
        // Add the new message to the conversation's messages collection
        print("Posting message: \(messageData)") // Debug print
        let messagesRef = db.collection("chats").document(conversationId).collection("messages")
        messagesRef.addDocument(data: messageData) { error in
            if let error = error {
                print("🚫Error posting message: \(error.localizedDescription)")
            } else {
                print("Message posted successfully")
            }
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
}


