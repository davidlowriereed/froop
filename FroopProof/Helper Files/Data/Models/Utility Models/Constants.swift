//
//  Constants.swift
//  FroopProof
//
//  Created by David Reed on 1/21/23.
//

import Firebase
import SwiftUI
import UIKit
import FirebaseFirestore

let db = FirebaseServices.shared.db
//MARK: Older Referernces
let COLLECTION_USERS = db.collection("users")
let COLLECTION_RIDES = db.collection("rides")



struct RefPath {
    
    //MARK: Core References
    
    static func userColRef() -> CollectionReference {
        return db.collection("users")
    }
    
    static func userDocRef(uid: String) -> DocumentReference {
        return userColRef().document(uid)
    }
    
    
    //MARK: myFroops - where actual Froop Data is stored
    
    static func myFroopsColRef(uid: String) -> CollectionReference {
        return userDocRef(uid: uid).collection("myFroops")
    }
    
    static func froopAnnotationsColRef(uid: String, froopId: String) -> CollectionReference {
        return froopDocRef(uid: uid, froopId: froopId).collection("annotations")
    }
    
    static func froopDocRef(uid: String, froopId: String) -> DocumentReference {
        return myFroopsColRef(uid: uid).document(froopId)
    }
    
    static func invitedFriendsColRef(uid: String, froopId: String) -> CollectionReference {
        return froopDocRef(uid: uid, froopId: froopId).collection("invitedFriends")
    }
    
    static func confirmedListDocRef(uid: String, froopId: String) -> DocumentReference {
        return invitedFriendsColRef(uid: uid, froopId: froopId).document("confirmedList")
    }
    
    
    //MARK:  froopDecisions - where user's decisions are managed with regard to attending Froops
    
    static func froopDecisionsColRef(uid: String) -> CollectionReference {
        return userDocRef(uid: uid).collection("froopDecisions")
    }
    
    static func froopListsDocRef(uid: String) -> DocumentReference {
        return froopDecisionsColRef(uid: uid).document("froopLists")
    }
    
    static func myListsColRef(uid: String, lists: String) -> CollectionReference {
        return froopListsDocRef(uid: uid).collection(lists)
    }
    
    static func myArchivedListColRef(uid: String) -> CollectionReference {
        return froopListsDocRef(uid: uid).collection("myArchivedList")
    }
    
    static func myConfirmedListColRef(uid: String) -> CollectionReference {
        return froopListsDocRef(uid: uid).collection("myConfirmedList")
    }
    
    static func myDeclinedListColRef(uid: String) -> CollectionReference {
        return froopListsDocRef(uid: uid).collection("myDeclinedList")
    }
    
    static func myInvitesListColRef(uid: String) -> CollectionReference {
        return froopListsDocRef(uid: uid).collection("myInvitesList")
    }
    
    
    //MARK:  where user's friends are stored
    
    static func friendsColRef(uid: String) -> CollectionReference {
        return userDocRef(uid: uid).collection("friends")
    }
    
    static func friendListDocRef(uid: String) -> DocumentReference {
        return friendsColRef(uid: uid).document("friendList")
    }
    
    // Conversations
    static func conversationsColRef() -> CollectionReference {
        return db.collection("conversations")
    }
    
    static func conversationDocRef(conversationId: String) -> DocumentReference {
        return conversationsColRef().document(conversationId)
    }
    
    static func messagesColRef(conversationId: String) -> CollectionReference {
        return conversationDocRef(conversationId: conversationId).collection("messages")
    }

    static func messageDocRef(conversationId: String, messageId: String) -> DocumentReference {
        return messagesColRef(conversationId: conversationId).document(messageId)
    }
    
    // User Conversations
    static func myConversationsColRef(uid: String) -> CollectionReference {
        return userDocRef(uid: uid).collection("myConversations")
    }

    static func myConversationDocRef(uid: String, conversationId: String) -> DocumentReference {
        return myConversationsColRef(uid: uid).document(conversationId)
    }
    
    static func myConversationChatStoreDocRef(uid: String) -> DocumentReference {
        return myConversationsColRef(uid: uid).document("chatStore")
    }
    
    static func chatStoreDocRef(uid: String) -> DocumentReference {
        return myConversationsColRef(uid: uid).document("chatStore")
    }
    
}






