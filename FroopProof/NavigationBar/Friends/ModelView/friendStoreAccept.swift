//
//  friendStoreAccept.swift
//  FroopProof
//
//  Created by David Reed on 2/18/23.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
 
import UIKit

class FriendStoreAccept: ObservableObject {
    
    
//    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var navLocationServices = NavLocationServices.shared
    // @ObservedObject var froopDataListener = FroopDataListener.shared
    
    var db = FirebaseServices.shared.db
    @Published var friends: [UserData] = []

    init(inviteArray: [String]) {
        
        for friendUID in inviteArray {
            let friendRef = db.collection("users").document(friendUID)
            friendRef.getDocument { (friendDocument, error) in
                if let friendDocument = friendDocument {
                    let data = friendDocument.data()
                    print("Friend Data: \(data as Any)")
                    do {
                        let friendData = UserData(dictionary: data ?? [:])
                        self.friends.append(friendData ?? UserData())
                        print("Friend Data Object: \(String(describing: friendData))")
                    } 
                }
            }
        }
    }
}
