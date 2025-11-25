//
//  Messages.swift
//  FroopProof
//
//  Created by David Reed on 7/25/23.
//

import SwiftUI
import Combine
import Firebase
import FirebaseFirestore
import Foundation

struct Message: Decodable, Identifiable, Hashable {
    var id: String
    var text: String
    var senderId: String
    var timestamp: Date
    var receiverId: String
    var froopId: String
    var host: String
    var conversationId: String

    // Initializer from a Firestore Document
    init?(document: DocumentSnapshot) {
        guard let data = document.data() else {
//            print("Document data is nil for document ID: \(document.documentID)")
            return nil
        }
//        print("Document data for \(document.documentID): \(data)")

        guard let text = data["text"] as? String else {
//            print("Text field is missing or not a string in document ID: \(document.documentID)")
            return nil
        }
//        print("Text: \(text)")

        guard let senderId = data["senderId"] as? String else {
//            print("SenderId field is missing or not a string in document ID: \(document.documentID)")
            return nil
        }
//        print("SenderId: \(senderId)")

        guard let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() else {
//            print("Timestamp field is missing or not a Timestamp in document ID: \(document.documentID)")
            return nil
        }
//        print("Timestamp: \(timestamp)")

        let receiverId = data["receiverId"] as? String
        let froopId = data["froopId"] as? String
        let host = data["host"] as? String
        let conversationId = data["conversationId"] as? String

        self.id = document.documentID
        self.text = text
        self.senderId = senderId
        self.timestamp = timestamp
        self.receiverId = receiverId ?? ""
        self.froopId = froopId ?? ""
        self.host = host ?? ""
        self.conversationId = conversationId ?? ""
        NotificationsManager.shared.checkForNewMessages()

    }
    
    init(dictionary: [String: Any], id: String) {
        self.id = id
        self.text = dictionary["text"] as? String ?? "Default Text"
        self.senderId = dictionary["senderId"] as? String ?? "Default Sender"
        self.timestamp = (dictionary["timestamp"] as? Timestamp)?.dateValue() ?? Date()
        self.receiverId = dictionary["receiverId"] as? String ?? "Default Receiver"
        self.froopId = dictionary["froopId"] as? String ?? "Default FroopId"
        self.host = dictionary["host"] as? String ?? "Default Host"
        self.conversationId = dictionary["conversationId"] as? String ?? "Default ConversationId"
    }
    
}

