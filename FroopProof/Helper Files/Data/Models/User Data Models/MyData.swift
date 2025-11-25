//
//  MyData.swift
//  FroopProof
//
//  Created by David Reed on 1/18/23.
//

import Foundation
import CoreLocation
import Firebase
import Combine
import SwiftUI
import UIKit
import FirebaseFirestore
import MapKit
import RevenueCat
import FirebaseAuth

final class MyData: ObservableObject {
    static let shared = MyData()
    @Published var inviteUrlUid: String = ""
    
    private var listener: ListenerRegistration?
    private var cancellables: Set<AnyCancellable> = []
    var uid = Auth.auth().currentUser?.uid ?? ""
    var db = Firestore.firestore()
    @Published var data = [String: Any]()
    let id: UUID = UUID()
    @Published var froopUserID: String = ""
    @Published var timeZone: String = TimeZone.current.identifier
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var phoneNumber: String = ""
    @Published var addressNumber: String = ""
    @Published var addressStreet: String = ""
    @Published var unitName: String = ""
    @Published var addressCity: String = ""
    @Published var addressState: String = ""
    @Published var addressZip: String = ""
    @Published var addressCountry: String = ""
    @Published var profileImageUrl: String = ""
    @Published var fcmToken: String = ""
    @Published var OTPVerified: Bool = false
    @Published var premiumAccount: Bool = false
    @Published var professionalAccount: Bool = false
    @Published var professionalTemplates: [String] = []
    @Published var myFriends: [UserData] = []
    @Published var creationDate: Date = Date()
    @Published var userDescription: String = ""
    @Published var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
    var geoPoint: GeoPoint {
        get {
            return GeoPoint(latitude: coordinate.latitude, longitude: coordinate.longitude)
        }
        set {
            let newCoordinate = CLLocationCoordinate2D(latitude: newValue.latitude, longitude: newValue.longitude)
            if newCoordinate.latitude != coordinate.latitude || newCoordinate.longitude != coordinate.longitude {
                self.coordinate = newCoordinate
            }
        }
    }
    
    @Published var badgeCount = 0
    @Published var myLocDerivedTitle: String? = nil
    @Published var myLocDerivedSubtitle: String? = nil
    @Published var searchTexts: [String] = []
    /// ONBOARDING
    

    
    var dictionary: [String: Any] {
        let geoPoint = convertToGeoPoint(coordinate: coordinate)
        return [
            "froopUserID": froopUserID,
            "firstName": firstName,
            "lastName": lastName,
            "phoneNumber": phoneNumber,
            "addressNumber": addressNumber,
            "addressStreet": addressStreet,
            "unitName": unitName,
            "addressCity": addressCity,
            "addressState": addressState,
            "addressZip": addressZip,
            "addressCountry": addressCountry,
            "timeZone": timeZone,
            "profileImageUrl": profileImageUrl,
            "fcmToken": fcmToken,
            "badgeCount" : badgeCount,
            "coordinate": geoPoint,
            "OTPVerified" : OTPVerified,
            "premiumAccount": premiumAccount,
            "professionalAccount": professionalAccount,
            "professionalTemplates": professionalTemplates,
            "myFriends": myFriends,
            "creationDate": creationDate,
            "userDescription": userDescription,
            "searchTexts": searchTexts
        ]
    }
    
    init?(dictionary: [String: Any]) {
        updateProperties(with: dictionary)
        // Check if the required properties have been set
        guard !self.froopUserID.isEmpty else {
            return nil
        }
    }
    
    var cancellable: ListenerRegistration?
    
    init() {
        
        PrintControl.shared.printMyData("MyData UID: \(id)")
        guard !FirebaseServices.shared.uid.isEmpty else {
            PrintControl.shared.printErrorMessages("Error: no user is currently signed in.")
            return
        }
        let uid = Auth.auth().currentUser?.uid ?? ""
        // handle the case when no user is signed in or UID is empty
        
        let docRef = db.collection("users").document(uid)
        
        self.listener = docRef.addSnapshotListener { (document, error) in
            if let document = document, let data = document.data() {
                self.updateProperties(with: data)
                self.fcmToken = data["fcmToken"] as? String ?? ""
                if let geoPoint = data["coordinate"] as? GeoPoint {
                    self.coordinate = FirebaseServices.shared.convertToCoordinate(geoPoint: geoPoint)
                }
                self.fetchFriendList(forUID: uid)
            }
        }
        
        if let listener = self.listener {
            ListenerStateService.shared.registerListener(listener, forKey: "myDataListener")
        }
        listenForFriendChanges(forUID: uid)
        ListenerStateService.shared.listenersActiveSubject
            .sink { isActive in
                if !isActive {
                    self.listener?.remove()
                    self.listener = nil
                }
            }
            .store(in: &cancellables)
        Task {
            let (title, subtitle) = await fetchAddressTitleAndSubtitle()
            await MainActor.run {
                // This block is guaranteed to run on the main thread.
                myLocDerivedTitle = title
                myLocDerivedSubtitle = subtitle
            }
        }
    }
    
    deinit {
        listener?.remove()
    }
    
    func removeListener() {
        listener?.remove()
        listener = nil
    }
    
    func setupListener() {
        guard let uid = Auth.auth().currentUser?.uid, !uid.isEmpty else { return }

        let docRef = db.collection("users").document(uid)

        self.listener = docRef.addSnapshotListener { (document, error) in
            guard let document = document, document.exists, let data = document.data() else {
                return
            }
            self.updateProperties(with: data)
        }
    }
    
    func updateProperties(with data: [String: Any]) {
        PrintControl.shared.printUserData("-myData: Function: updateProperties is firing!")
        self.data = data
        self.froopUserID = data["froopUserID"] as? String ?? ""
        self.timeZone = data["timeZone"] as? String ?? TimeZone.current.identifier
        self.firstName = data["firstName"] as? String ?? ""
        self.lastName = data["lastName"] as? String ?? ""
        self.phoneNumber = data["phoneNumber"] as? String ?? ""
        self.addressNumber = data["addressNumber"] as? String ?? ""
        self.addressStreet = data["addressStreet"] as? String ?? ""
        self.unitName = data["unitName"] as? String ?? ""
        self.addressCity = data["addressCity"] as? String ?? ""
        self.addressState = data["addressState"] as? String ?? ""
        self.addressZip = data["addressZip"] as? String ?? ""
        self.addressCountry = data["addressCountry"] as? String ?? ""
        self.profileImageUrl = data["profileImageUrl"] as? String ?? ""
        self.fcmToken = data["fcmToken"] as? String ?? ""
        self.badgeCount = data["badgeCount"] as? Int ?? 0
        if let geoPoint = data["coordinate"] as? GeoPoint {
            self.coordinate = CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
        }
        self.premiumAccount = data["premiumAccount"] as? Bool ?? false
        self.professionalAccount = data["professionalAccount"] as? Bool ?? false
        self.professionalTemplates = data["professionalTemplates"] as? [String] ?? []
        self.OTPVerified = data["OTPVerified"] as? Bool ?? false
        self.creationDate = data["creationDate"] as? Date ?? Date()
        self.userDescription = data["userDescription"] as? String ?? ""
        self.searchTexts = data["searchTexts"] as? [String] ?? []
        PrintControl.shared.printMyData("--------retrieving User Data")
        
    }
    
    func convertToGeoPoint(coordinate: CLLocationCoordinate2D) -> GeoPoint {
        return GeoPoint(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
    
    func fetchFriendList(forUID uid: String) {
        // Fetch the current user's list of friend UIDs
        db.collection("users").document(uid).collection("friends").document("friendList").getDocument { [weak self] (document, error) in
            guard let self = self else { return }
            if let document = document, document.exists {
                if let friendUIDs = document.data()?["friendUIDs"] as? [String], !friendUIDs.isEmpty {
                    self.fetchUserDatas(forUIDs: friendUIDs)
                } else {
                    DispatchQueue.main.async {
                        self.myFriends = []
                    }
                }
            } else {
                // Handle the case where the document does not exist or an error occurred
                DispatchQueue.main.async {
                    self.myFriends = []
                }
            }
        }
    }
    
    func processApprovedFriendRequests(forUID uid: String) {
        // Fetch the current user's list of friends to update local storage if needed
        db.collection("users").document(uid).collection("friends").document("friendList").getDocument { [weak self] (document, error) in
            guard let _ = self, let document = document, document.exists, let friendUIDs = document.data()?["friendUIDs"] as? [String] else { return }
            
            // Retrieve the locally stored invited friends array
            var invitedFriends: [String] = UserDefaults.standard.array(forKey: "invitedFriends") as? [String] ?? []
            
            // Filter out UIDs that are now friends
            invitedFriends = invitedFriends.filter { !friendUIDs.contains($0) }
            
            // Update the local storage with the filtered array
            UserDefaults.standard.set(invitedFriends, forKey: "invitedFriends")
        }
    }
    
    private func fetchUserDatas(forUIDs uids: [String]) {
        // Filter out the 'placeholder' UID
        let validUIDs = uids.filter { $0 != "placeholder" }
        
        // Create a publisher for each UID that fetches the UserData
        let publishers = validUIDs.map { uid in
            Future<UserData, Error> { [weak self] promise in
                FroopManager.shared.fetchUserData(for: uid) { result in
                    switch result {
                        case .success(let userData):
                            // Before appending, ensure uniqueness based on `froopUserID`
                            DispatchQueue.main.async {
                                if let self = self, !self.myFriends.contains(where: { $0.froopUserID == userData.froopUserID }) {
                                    self.myFriends.append(userData)
                                }
                            }
                            promise(.success(userData))
                        case .failure(let error):
                            promise(.failure(error))
                    }
                }
            }
        }
        
        // Combine all the publishers into one and subscribe to the collected results
        Publishers.MergeMany(publishers)
            .collect()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        // Handle the error here if you want to
                        PrintControl.shared.printMyData("Error fetching user data: \(error.localizedDescription)")
                    }
                },
                receiveValue: { [weak self] userDatas in
                    // This section is now redundant as the uniqueness check is done immediately after data fetching
                }
            )
            .store(in: &self.cancellables) // Ensure `self.cancellables` is correctly referenced as a property of your class
    }

    
    func listenForFriendChanges(forUID uid: String) {
        let listenerKey = "friendsListener_\(uid)"  // Unique key for the listener
        let friendsRef = db.collection("users").document(uid).collection("friends")
        
        // Only create a listener if one doesn't exist for the given user's friends
        if ListenerStateService.shared.shouldCreateListener(forKey: listenerKey) {
            let listener = friendsRef.addSnapshotListener { [weak self] (querySnapshot, error) in
                guard let self = self else { return }
                var newFriendUIDs = [String]()
                
                for document in querySnapshot?.documents ?? [] {
                    if let friendUID = document.data()["friendUID"] as? String { // Make sure to use the correct key for the UID
                        newFriendUIDs.append(friendUID)
                    }
                }
                
                if !newFriendUIDs.isEmpty {
                    self.fetchUserDatas(forUIDs: newFriendUIDs)
                } else {
                    DispatchQueue.main.async {
                        self.myFriends = []
                    }
                }
            }
            // Register the listener with ListenerStateService
            ListenerStateService.shared.registerListener(listener, forKey: listenerKey)
        }
    }
    
    func updateSubscriptionStatus() {
        Purchases.shared.getCustomerInfo { [weak self] (purchaserInfo, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("🚫Error fetching purchaser info: \(error.localizedDescription)")
                return
            }
            
            let hasPremiumAccess = purchaserInfo?.entitlements["Premium"]?.isActive == true
            self.updateUserSubscriptionStatusInFirestore(hasPremiumAccess: hasPremiumAccess)
        }
    }
    
    func updateUserSubscriptionStatusInFirestore(hasPremiumAccess: Bool) {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("🚫Error: User is not logged in.")
            return
        }
        
        let usersRef = Firestore.firestore().collection("users")
        let userDoc = usersRef.document(uid)
        
        userDoc.updateData([
            "premiumAccount": hasPremiumAccess
        ]) { error in
            if let error = error {
                print("🚫Error updating user subscription status: \(error.localizedDescription)")
            } else {
                print("User subscription status updated successfully 2.")
                AppStateManager.shared.showCoverScreen = false
            }
        }
    }
}

