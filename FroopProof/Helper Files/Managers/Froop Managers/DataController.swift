//
//  DataController.swift
//  FroopProof
//
//  Created by David Reed on 3/4/23.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

class DataController: ObservableObject {
    static let shared = DataController()
    @Published var offsetY: CGFloat = 0
    var db = FirebaseServices.shared.db
    let uid = Auth.auth().currentUser?.uid ?? ""
    @Published var allSelected: Int = 0
    @Published var selectedUser: UserData = UserData()
    @Published var screenSize = determineScreenSizeCategory()
    @Published var toggleDynamicIsland = UIDevice().checkIfHasDynamicIsland()
    // MARK: - User Functions
    @Published var tempDirectory = NSTemporaryDirectory()
    @Published var profileToggle = false
    @Published var chatFriendTabToggle = false
    @Published var myFriends: [UserData] = []
    @Published var numberOfFriendRequests: Int = 0


    func checkLists(uid: String, completion: @escaping ([String], [String], [String], [String]) -> Void) {
        guard !uid.isEmpty else {
            PrintControl.shared.printErrorMessages("Error: UID is empty")
               return
           }
        
        let group = DispatchGroup()
        
        var myArchivedList: [String] = []
        var myConfirmedList: [String] = []
        var myDeclinedList: [String] = []
        var myInvitesList: [String] = []
        
        group.enter()
        RefPath.myArchivedListColRef(uid: uid).getDocuments { (snapshot, error) in
            PrintControl.shared.printFroopDataController("Current User UID: \(self.uid)")
            if let documents = snapshot?.documents {
                myArchivedList = documents.compactMap { $0.documentID != "placeholder" ? $0.documentID : nil }
            }
            group.leave()
        }
        
        group.enter()
        RefPath.myConfirmedListColRef(uid: uid).getDocuments { (snapshot, error) in
            if let documents = snapshot?.documents {
                myConfirmedList = documents.compactMap { $0.documentID != "placeholder" ? $0.documentID : nil }
            }
            group.leave()
        }
        
        group.enter()
        RefPath.myDeclinedListColRef(uid: uid).getDocuments { (snapshot, error) in
            if let documents = snapshot?.documents {
                myDeclinedList = documents.compactMap { $0.documentID != "placeholder" ? $0.documentID : nil }
            }
            group.leave()
        }
        
        group.enter()
        RefPath.myInvitesListColRef(uid: uid).getDocuments { (snapshot, error) in
            if let documents = snapshot?.documents {
                myInvitesList = documents.compactMap { $0.documentID != "placeholder" ? $0.documentID : nil }
            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            completion(myArchivedList, myConfirmedList, myDeclinedList, myInvitesList)
        }
    }
    
    func getUserDataByPhoneNumber(phoneNumber: String, completion: @escaping (Result<UserData, Error>) -> Void) {
        // Check if the phone number is empty
        if phoneNumber.isEmpty {
            let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Phone number is empty"])
            completion(.failure(error))
            return
        }
        
        
        let usersCollectionRef = db.collection("users")
        let query = usersCollectionRef.whereField("phoneNumber", isEqualTo: phoneNumber)
        
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                guard let document = querySnapshot?.documents.first else {
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "User document does not exist"])
                    completion(.failure(error))
                    return
                }
                
                if let userData = UserData(dictionary: document.data()) {
                    completion(.success(userData))
                } else {
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unable to create UserData object from document data"])
                    completion(.failure(error))
                }
            }
        }
    }
    
    //    MARK: Usage:
    //    let uid = "1234"
    // replace with actual UID
    //    getUserData(uid: uid) { result in
    //        switch result {
    //        case .success(let userData):
    //            // handle success
    //        case .failure(let error):
    //            // handle error
    //        }
    //    }
    
    func updateUser(_ completion: @escaping (Result<Bool, Error>) -> Void) {
        let uid = FirebaseServices.shared.uid
        if uid.isEmpty {
            let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Current user UID is empty"])
            completion(.failure(error))
            return
        }
        
        let userRef = db.collection("users").document(uid)
        userRef.updateData(MyData.shared.dictionary) { error in
            if let error = error {
                PrintControl.shared.printErrorMessages("Error updating user data: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                PrintControl.shared.printErrorMessages("User data updated successfully.")
                completion(.success(true))
            }
        }
    }
    
    
    func getUserDataFriends(uid: String, completion: @escaping (Result<[UserData], Error>) -> Void) {
        let docRef = db.collection("users").document(uid).collection("friends").document("friendList")
        
        docRef.getDocument { document, error in
            if let error = error {
                completion(.failure(error))
            } else if let document = document, document.exists {
                if let friendList = document.data()?["friendList"] as? [String] {
                    let dispatchGroup = DispatchGroup()
                    var userDataFriends = [UserData]()
                    var missingFriendDocs = 0
                    for friendUID in friendList {
                        dispatchGroup.enter()
                        let friendDocRef = self.db.collection("users").document(friendUID)
                        friendDocRef.getDocument { friendDocument, friendError in
                            if let friendError = friendError {
                                completion(.failure(friendError))
                            } else if let friendDocument = friendDocument, friendDocument.exists {
                                let userData = UserData(dictionary: friendDocument.data() ?? [:])
                                userDataFriends.append(userData ?? UserData())
                                dispatchGroup.leave()
                            } else {
                                missingFriendDocs += 1
                                dispatchGroup.leave()
                            }
                        }
                    }
                    dispatchGroup.notify(queue: DispatchQueue.main) {
                        if missingFriendDocs == 0 {
                            completion(.success(userDataFriends))
                        } else {
                            let friendError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Some friend documents do not exist"])
                            completion(.failure(friendError))
                        }
                    }
                } else {
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Friend list not found"])
                    completion(.failure(error))
                }
            } else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "User document does not exist"])
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Froop Functions
    
    func getUserFroops(uid: String, completion: @escaping (Result<[FroopData], Error>) -> Void) {
        let froopsCollectionRef = db.collection("users").document(uid).collection("myFroops")
        
        froopsCollectionRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
            } else if let querySnapshot = querySnapshot {
                var froopsArray = [FroopData]()
                for document in querySnapshot.documents {
                    do {
                        let data = try JSONSerialization.data(withJSONObject: document.data(), options: [])
                        let froop = try JSONDecoder().decode(FroopData.self, from: data)
                        froopsArray.append(froop)
                    } catch let decodingError {
                        PrintControl.shared.printErrorMessages("Error decoding FroopData: \(decodingError)")
                        completion(.failure(decodingError))
                        return
                    }
                }
                completion(.success(froopsArray))
            } else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No documents found in the collection"])
                completion(.failure(error))
            }
        }
    }
    
    
    //MARK:  Usage
    //    getUserFroops(uid: "exampleUID") { result in
    //        switch result {
    //        case .success(let froopsArray):
    //            print("Retrieved froops: \(froopsArray)")
    //        case .failure(let error):
    //            print("🚫Error retrieving froops: \(error.localizedDescription)")
    //        }
    //    }
    
    
    func getFroopData(for froopID: String, completion: @escaping (Froop?) -> Void) {
        // Implementation for fetching froop data from Firestore
    }
    
    func updateFroop(_ froop: Froop, completion: @escaping (Bool) -> Void) {
        // Implementation for updating froop data in Firestore
    }
    
    func deleteFroop(_ froop: Froop, completion: @escaping (Bool) -> Void) {
        // Implementation for deleting froop data in Firestore
    }
    
    
    
    // MARK: - Comparison Functions
    
    func getCommonFriends(from friendGroups: [[UserData]], completion: @escaping ([UserData]) -> Void) {
        guard friendGroups.count >= 2 else {
            completion([])
            return
        }
        
        var commonFriends = friendGroups.first ?? []
        
        for friends in friendGroups[1...] {
            commonFriends = commonFriends.filter { friend in
                friends.contains { $0.froopUserID == friend.froopUserID }
            }
        }
        
        completion(commonFriends)
    }
    
    func getUserDataFriendsCompared(uid: String, completion: @escaping (Result<[UserData], Error>) -> Void) {
        
        let friendListDocRef = db.collection("users").document(uid).collection("friends").document("friendList")
        
        friendListDocRef.getDocument { (document, error) in
            if let error = error {
               
                PrintControl.shared.printData("Error getting document: \(error)")
                return
               
            } else if let document = document, document.exists {
                
                let friendUIDs = document.data()?["friendUIDs"] as? [String] ?? []
                
                // fetch UserData objects for each UID in friendUIDs
                let group = DispatchGroup()
                var friendsArray = [UserData]()
                for friendUID in friendUIDs {
                    group.enter()
                    let friendDocRef = self.db.collection("users").document(friendUID)
                    friendDocRef.getDocument { (document, error) in
                        if let error = error {
                            group.leave()
                            completion(.failure(error))
                            return
                        }
                        
                        if let document = document, document.exists,
                           let friendData = UserData(dictionary: document.data() ?? [:]) {
                            friendsArray.append(friendData)
                        }
                        group.leave()
                    }
                }
                
                group.notify(queue: .main) {
                    // all friends have been fetched
                    completion(.success(friendsArray))
                }
            } else if let error = error {
                completion(.failure(error))
            } else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No document found in the collection"])
                completion(.failure(error))
            }
        }
    }
    
    
    
    
    
    // MARK: USAGE
    //    getUserDataFriends(uid: "uid1") { result1 in
    //        switch result1 {
    //        case .success(let friends1):
    //            getUserDataFriends(uid: "uid2") { result2 in
    //                switch result2 {
    //                case .success(let friends2):
    //                    let commonFriends = getCommonFriends(from: [friends1, friends2]) { common in
    //                        // common contains an array of UserData objects that are common between both sets of friends
    //                    }
    //                case .failure(let error):
    //                    print("🚫Error getting friends for uid2: \(error.localizedDescription)")
    //                }
    //            }
    //        case .failure(let error):
    //            print("🚫Error getting friends for uid1: \(error.localizedDescription)")
    //        }
    //    }
    
    
    //MARK:  CLEAN UP FUNCTIONS
    
    func updateUserData() {
        
        let usersCollection = db.collection("users")
        
        usersCollection.getDocuments { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                PrintControl.shared.printErrorMessages("Error fetching documents: \(String(describing: error))")
                return
            }
            
            for document in snapshot.documents {
                var data = document.data()
                let uid = document.documentID
                
                // Add missing fields to document
               // let myData = MyData(dictionary: data)
                let mirror = Mirror(reflecting: MyData.shared)
                for child in mirror.children {
                    guard let fieldName = child.label else { continue }
                    
                    if data[fieldName] == nil {
                        let defaultValue = mirror.descendant(fieldName)
                        data[fieldName] = defaultValue
                    }
                }
                
                // Remove extraneous fields from document
                for field in data.keys {
                    if !mirror.children.contains(where: { $0.label == field }) {
                        data.removeValue(forKey: field)
                    }
                }
                
                // Update document in Firestore
                usersCollection.document(uid).setData(data) { error in
                    if let error = error {
                        PrintControl.shared.printErrorMessages("Error updating user document \(uid): \(error.localizedDescription)")
                    } else {
                        PrintControl.shared.printFroopDataController("User document \(uid) successfully updated")
                    }
                }
            }
        }
    }
    func reportLocation(file: String = #file, line: Int = #line, function: String = #function) {
        PrintControl.shared.printData("Function called from: \(file), line: \(line), function: \(function)")
        PrintControl.shared.printData("Call stack:")
        for symbol in Thread.callStackSymbols {
            PrintControl.shared.printData(symbol)
        }
    }
}

extension DataController {
    func isFriend(_ froopUserID: String) -> Bool {
        return myFriends.contains(where: { $0.froopUserID == froopUserID })
    }
}
