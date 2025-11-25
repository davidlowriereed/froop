//
//  Conversation.swift
//  FroopProof
//
//  Created by David Reed on 7/25/23.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct Conversation: Identifiable {
    var id: String
    var userIds: [String]
    var lastReadMessage: [String: String] // Dictionary with userId as key and messageId as value

    init?(document: DocumentSnapshot) {
        let data = document.data()
        guard let unwrappedData = data,
              let userIds = unwrappedData["userIds"] as? [String], !userIds.isEmpty else {
            return nil  // Return nil if userIds are not found or the array is empty
        }
        self.id = document.documentID
        self.userIds = userIds

        // Extract lastReadMessage if it exists in the document
        self.lastReadMessage = unwrappedData["lastReadMessage"] as? [String: String] ?? [:]
    }
    
    // New initializer for direct creation of a Conversation instance
    init(id: String = UUID().uuidString, userIds: [String] = [], lastReadMessage: [String: String] = [:]) {
        self.id = id
        self.userIds = userIds
        self.lastReadMessage = lastReadMessage
    }
}


struct ConversationAndMessages: Identifiable {
    var id: String { conversation.id }
    var conversation: Conversation
    var messages: [Message]
    var participants: [UserData]
}


extension ConversationAndMessages: Equatable {
    static func == (lhs: ConversationAndMessages, rhs: ConversationAndMessages) -> Bool {
        // Assuming Conversation, Message, and UserData are also Equatable.
        // If they are not, you would need to make them Equatable as well,
        // or provide custom logic here to compare their properties.
        return lhs.conversation == rhs.conversation &&
               lhs.messages == rhs.messages &&
               lhs.participants == rhs.participants
    }
}

extension Conversation: Equatable {
    static func == (lhs: Conversation, rhs: Conversation) -> Bool {
        // Compare relevant properties
        return lhs.id == rhs.id // Add more comparisons as necessary
    }
}
