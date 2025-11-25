//
//  AccountSetupManager.swift
//  FroopProof
//
//  Created by David Reed on 1/28/24.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import SwiftUI

class AccountSetupManager: ObservableObject { 
    static let shared = AccountSetupManager(profileSetup: ProfileData())
    @ObservedObject var myData = MyData.shared
    @ObservedObject var myAccountData = MyAccountData.shared
    @Published var profileSetup: ProfileData = ProfileData()
    private var update: Bool = true
    var db = FirebaseServices.shared.db
    var uid = Auth.auth().currentUser?.uid ?? ""
    @Published var key: UUID = UUID()


    init(myData: MyData = MyData.shared, profileSetup: ProfileData, db: Firestore = FirebaseServices.shared.db, uid: String = Auth.auth().currentUser?.uid ?? "") {
        self.myData = myData
        self.profileSetup = profileSetup
        self.db = db
        self.uid = uid
        updateProfileSetup()
//        saveUserFcmToken()
    }
    
    func forceRefresh() {
        self.key = UUID()
    }
    
    func checkOrCreateAccountDocument(for user: User) async {
        print("🔶 checkOrCreateAccountDocument Firing")
        let uid = user.uid
        let accountsRef = Firestore.firestore().collection("accounts")
        
        // Attempt to find an existing account document
        let querySnapshot = try? await accountsRef.whereField("authUids", arrayContains: uid).getDocuments()
        if let documents = querySnapshot?.documents, !documents.isEmpty {
            // Account document exists
            print("Account document exists for UID: \(uid)")
        } else {
            // No account document exists, create a new one
            createNewAccountDocument(for: user)
        }
    }
    
    func createNewAccountDocument(for user: User) {
        print("🔶 createNewAccountDocument Firing")

        let uid = user.uid
        let accountsRef = Firestore.firestore().collection("accounts")
        let currentDate = Date()
        let newAccountData: [String: Any] = [
            "accountId": uid, // Use the auth UID as the initial accountId
            "authUids": [uid], // Initialize with the current UID
            "primaryUid": uid, // Set the primary UID to the current UID
            "phoneNumber": "", // Initialize as empty
            "OTPVerified": false, // Default to false
            "premiumAccount": false, // Default to false
            "professionalAccount": false, // Default to false
            "creationDate": Timestamp(date: currentDate), // Current date as creation date
            "badgeCount": 0 // Initialize with zero
        ]
        
        accountsRef.document(uid).setData(newAccountData) { error in
            if let error = error {
                print("Error creating account document: \(error.localizedDescription)")
            } else {
                print("Account document created successfully for UID: \(uid)")
            }
        }
    }
    
    func updateProfileSetup() {
        if update {
            profileSetup.froopUserID = MyData.shared.froopUserID
            profileSetup.firstName = MyData.shared.firstName
            profileSetup.lastName = MyData.shared.lastName
            profileSetup.profileImageUrl = MyData.shared.profileImageUrl
            profileSetup.phoneNumber = MyData.shared.phoneNumber
            profileSetup.OTPVerified = MyData.shared.OTPVerified
            profileSetup.timeZone = MyData.shared.timeZone
            profileSetup.addressZip = MyData.shared.addressZip
            profileSetup.addressCity = MyData.shared.addressCity
            profileSetup.addressState = MyData.shared.addressState
            profileSetup.addressNumber = MyData.shared.addressNumber
            profileSetup.addressStreet = MyData.shared.addressStreet
            profileSetup.addressCountry = MyData.shared.addressCountry
            profileSetup.myFriends = MyData.shared.myFriends
            profileSetup.creationDate = MyData.shared.creationDate
            profileSetup.userDescription = MyData.shared.userDescription
            profileSetup.myLocDerivedTitle = MyData.shared.myLocDerivedTitle
            profileSetup.myLocDerivedSubtitle = MyData.shared.myLocDerivedSubtitle
            profileSetup.coordinate = MyData.shared.coordinate
            profileSetup.myFriends = MyData.shared.myFriends
            profileSetup.badgeCount = MyData.shared.badgeCount
            update = false
        }
    }
    
    func createUserAndCollections(uid: String, completion: @escaping (Error?) -> Void) {
        let userDocRef = db.collection("users").document(uid)
        
        createOrUpdateUserDocument(uid: uid) { error in
            guard error == nil else {
                completion(error)
                return
            }
            
            self.createUserSubcollections(for: userDocRef) { error in
                guard error == nil else {
                    completion(error)
                    return
                }
                
                self.createFroopDecisionsDocumentAndSubcollections(uid: uid) { error in
                    completion(error)
                }
            }
        }
    }
    
    func createOrUpdateUserDocument(uid: String, completion: @escaping (Error?) -> Void) {
        let userDocRef = db.collection("users").document(uid)
        let fcmToken = getUserFcmToken() ?? ""

        Task {
            do {
                let documentSnapshot = try await userDocRef.getDocument()
                if documentSnapshot.exists {
                    let data = ["froopUserID": uid, "fcmToken": fcmToken]
                    try await userDocRef.updateData(data)
                } else {
                    var data = MyData.shared.dictionary
                    data["froopUserID"] = uid
                    data["fcmToken"] = fcmToken
                    try await userDocRef.setData(data)
                }
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    func createUserSubcollections(for userDocRef: DocumentReference, completion: @escaping (Error?) -> Void) {
        let collectionsInsideUser = ["myFroops", "froopDecisions"]
        let froopUID = "froop"
        let froopFriendRef = db.collection("users").document(froopUID).collection("friends").document("friendList")
       
        Task {
            do {
                for collection in collectionsInsideUser {
                    let newDocRef = userDocRef.collection(collection).document("placeholder")
                    // Check if "placeholder" document exists before setting data
                    let docSnapshot = try await newDocRef.getDocument()
                    if !docSnapshot.exists {
                        try await newDocRef.setData(["placeholder": "placeholder"])
                    }
                }
                
                // Creating the friendList document within the friends collection if it doesn't exist
                // Attempt to retrieve the friendList document first to check if it exists
                let friendListDocRef = userDocRef.collection("friends").document("friendList")
                let friendListSnapshot = try await friendListDocRef.getDocument()

                // Check if the document already exists
                if !friendListSnapshot.exists {
                    // Document does not exist, safe to set data without overwriting existing data
                    try await friendListDocRef.setData(["friendUIDs": ["froop"]])
                } else {
          
                }
                
                // Update Froop's friendList to include current user's UID without overwriting
                try await froopFriendRef.updateData(["friendUIDs": FieldValue.arrayUnion([uid])])
                
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }

    func createFroopDecisionsDocumentAndSubcollections(uid: String, completion: @escaping (Error?) -> Void) {
        let froopDecisionsDocRef = db.collection("froopDecisions").document(uid).collection("froopLists").document("placeholder")
        let collectionsInsideFroopLists = ["myArchivedList", "myConfirmedList", "myDeclinedList", "myInvitesList"]

        Task {
            do {
                // Check if "placeholder" document in "froopLists" exists before setting data
                let decisionsSnapshot = try await froopDecisionsDocRef.getDocument()
                if !decisionsSnapshot.exists {
                    try await froopDecisionsDocRef.setData(["placeholder": "placeholder"])
                }

                for collection in collectionsInsideFroopLists {
                    let newCollectionRef = froopDecisionsDocRef.collection(collection).document("placeholder")
                    // Check if "placeholder" document in each collection exists before setting data
                    let collectionSnapshot = try await newCollectionRef.getDocument()
                    if !collectionSnapshot.exists {
                        try await newCollectionRef.setData(["placeholder": "placeholder"])
                    }
                }
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }

//    func saveUserFcmToken() {
//        // Check if the user is authenticated
//        guard let uid = Auth.auth().currentUser?.uid, !uid.isEmpty else {
//           print("User is not authenticated. fcmToken not saved to user document.")
//            let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "User is not authenticated. fcmToken not saved to user document."])
//            Crashlytics.crashlytics().record(error: error) // Log error to Crashlytics
//            return
//        }
//        
//        // Get the FCM token form user defaults
//        guard let fcmToken = UserDefaults.standard.value(forKey: "FCMTokenNotification") else {
//            return
//        }
//        
//        let db = Firestore.firestore()
//        let docRef = db.collection("users").document(uid)
//        let accountDocRef = db.collection("account").document(myAccountData.accountId)
//        
//        // Update the user document with the fcmToken
//        docRef.updateData(["fcmToken": fcmToken]) { error in
//            if let error = error {
//                print("Error updating user document with fcmToken: \(error)")
//                Crashlytics.crashlytics().record(error: error) // Log error to Crashlytics
//            } else {
//                print("fcmToken saved to user document successfully")
//            }
//        }
//        accountDocRef.updateData(["fcmToken": fcmToken]) { error in
//            if let error = error {
//                print("Error updating account document with fcmToken: \(error)")
//                Crashlytics.crashlytics().record(error: error) // Log error to Crashlytics
//            } else {
//                print("fcmToken saved to account document successfully")
//            }
//        }
//    }
    
    func getUserFcmToken() -> String? {
        print("getUserFcmToken function firing!")
        // Check if the user is authenticated
        guard let uid = Auth.auth().currentUser?.uid, !uid.isEmpty else {
            print("User is not authenticated. Unable to retrieve fcmToken.")
            let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "User is not authenticated. Unable to retrieve fcmToken."])
            Crashlytics.crashlytics().record(error: error) // Log error to Crashlytics
            return nil
        }
        
        // Get the FCM token from user defaults
        let fcmToken = UserDefaults.standard.value(forKey: "FCMTokenNotification") as? String
        return fcmToken
    }
}
