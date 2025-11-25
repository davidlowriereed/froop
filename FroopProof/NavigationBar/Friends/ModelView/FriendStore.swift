//
//  FriendStore.swift
//  FroopProof
//
//  Created by David Reed on 2/12/23.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
 
import UIKit

class FriendStore: ObservableObject {
    static let shared = FriendStore()
    //    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var navLocationServices = NavLocationServices.shared
    // @ObservedObject var froopDataListener = FroopDataListener.shared
    
    var db = FirebaseServices.shared.db
    @Published var friends: [UserData] = []
    
    init() {
        let friendListRef = db.collection("users").document(FirebaseServices.shared.uid).collection("friends").document("friendList")
        
        friendListRef.addSnapshotListener { [weak self] querySnapshot, error in
            guard let self = self else { return } // Prevent strong reference cycles
            guard let snapshot = querySnapshot, snapshot.exists, let data = snapshot.data() else {
                print("🚫Error fetching friends 5 or no friends data available: \(error?.localizedDescription ?? "unknown error")")
                return
            }
            
            let friendUIDs = data["friendUIDs"] as? [String] ?? []
            
            // Check if the friendUIDs array is empty
            if friendUIDs.isEmpty {
                DispatchQueue.main.async {
                    self.friends = [] // Make sure to update on main thread
                }
                return
            }
            
            // Initialize an empty array to hold the UserData objects
            var newFriends: [UserData] = []
            
            // Create a dispatch group to track when all async calls are complete
            let dispatchGroup = DispatchGroup()
            
            // Perform document fetching on a background queue
            DispatchQueue.global(qos: .userInitiated).async {
                for uid in friendUIDs {
                    dispatchGroup.enter() // Enter the dispatch group for each async call
                    
                    // Check if the uid is valid and non-empty
                    guard !uid.isEmpty else {
                        print("Invalid or empty user ID: \(uid)")
                        dispatchGroup.leave() // Leave the dispatch group if the uid is invalid
                        continue
                    }
                    
                    let userRef = self.db.collection("users").document(uid)
                    
                    userRef.getDocument { (document, error) in
                        defer { dispatchGroup.leave() } // Leave the dispatch group in the defer block to ensure it's called
                        
                        if let document = document, document.exists {
                            if let data = document.data(), let friendData = UserData(dictionary: data) {
                                // Append friendData to newFriends array
                                newFriends.append(friendData)
                            } else {
                                print("Unable to initialize UserData from Firestore document data")
                            }
                        } else if let error = error {
                            print("🚫Error fetching friend document: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    }
}

