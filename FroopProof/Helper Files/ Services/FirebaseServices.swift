//
//  FirebaseServices.swift
//  FroopProof
//
//  Created by David Reed on 5/16/23.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseCore
import FirebaseStorage
import FirebaseDatabase
import FirebaseSessions
import FirebaseCrashlytics
import UserNotifications
import MapKit
import SwiftUI

class FirebaseServices: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    
    static let shared = FirebaseServices()
    
    @Published var userTasks: Int = 0
//    @Published var userLocation: CLLocationCoordinate2D?
    
    var db: Firestore
    var uid: String
    var storage: Storage
    var database: Database
    
    
    var tasks: [StorageUploadTask] = []
    
    private var authStateDidChangeListenerHandle: AuthStateDidChangeListenerHandle?
    
    var isAuthenticated: Bool {
        return !uid.isEmpty
    }
    
    private override init() {
        self.db = Firestore.firestore()
        self.uid = Auth.auth().currentUser?.uid ?? ""
        self.storage = Storage.storage()
        self.database = Database.database()
        
        super.init()

        authStateDidChangeListenerHandle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                self.uid = user.uid
            } else {
                self.uid = ""
                self.cancelAllTasks()
            }
        }
    }
    
    var appStateManager: AppStateManager {
        return AppStateManager.shared
    }
    
    var myData: MyData {
        return MyData.shared
    }
    
    var timerServices: TimerServices {
        return TimerServices.shared
    }
    
    var printControl: PrintControl {
        return PrintControl.shared
    }
 
    var froopDataController: FroopDataController {
        return FroopDataController.shared
    }
    
//    var navLocationServices: NavLocationServices {
//        return NavLocationServices.shared
//    }
    
//    var locationManager: LocationManager {
//        return LocationManager.shared
//    }
    
    func removeAuthStateDidChangeListener() {
        if let handle = authStateDidChangeListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
            authStateDidChangeListenerHandle = nil
        }
    }
    
    func getDownloadUrl(uid: String, completion: @escaping (URL?) -> Void) {
        let profilePicRef = storage.reference().child("ProfilePic/\(uid)")

        profilePicRef.downloadURL { url, error in
            if let error = error {
                PrintControl.shared.printFirebaseOperations("Error getting download URL: \(error)")
                completion(nil)
            } else {
                completion(url)
            }
        }
    }
    
    func checkSMSInvitations () {
        guard !myData.phoneNumber.isEmpty else {
            PrintControl.shared.printFirebaseOperations("Phone number is empty")
            return
        }
        
        let smsInvitationsRef = db.collection("smsInvitations")
        let invitationRef = smsInvitationsRef.document(myData.phoneNumber)
        PrintControl.shared.printFirebaseOperations("myData.phoneNumber: \(myData.phoneNumber)")
        invitationRef.getDocument { document, error in
            if let error = error {
                PrintControl.shared.printFirebaseOperations("Error getting document: \(error)")
            } else if let document = document, document.exists {
                // An invitation exists for this phone number
                PrintControl.shared.printFirebaseOperations("An invitation exists for this phone number")
                
                // Extract senderUid from the document
                if let senderUid = document.get("senderUid") as? String {
                    PrintControl.shared.printFirebaseOperations("Sender UID: \(senderUid)")
                    // Call acceptFriendRequest function with senderUid
                    FriendRequestManager.shared.acceptSMSInvitation(senderUid: senderUid, uid: self.uid){ (success) in
                        PrintControl.shared.printFirebaseOperations("Triggering Friend Request Manager Accept Friend Request Function")
                        if success {
                            PrintControl.shared.printFirebaseOperations("Friend request accepted successfully.")
                            invitationRef.delete { error in
                                if let error = error {
                                    PrintControl.shared.printFirebaseOperations("Error removing document: \(error)")
                                } else {
                                    PrintControl.shared.printFirebaseOperations("Document successfully removed!")
                                }
                            }
                        } else {
                            PrintControl.shared.printFirebaseOperations("Failed to accept friend request.")
                        }
                    }
                } else {
                    PrintControl.shared.printFirebaseOperations("Could not find senderUid in the document")
                }
            } else {
                // No invitation exists for this phone number
                PrintControl.shared.printFirebaseOperations("No invitation exists for this phone number")
            }
        }
    }
    
    func checkDoc(userID: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(userID)

        docRef.getDocument { (document, error) in
            if let error = error {
                completion(false)
                PrintControl.shared.printFirebaseOperations("Error getting document: \(error)")
            } else if let document = document, document.exists {
                completion(true)
                PrintControl.shared.printFirebaseOperations("Found document")
            } else {
                completion(false)
            }
        }
    }
    
    static func requestBadgePermission(completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.badge]) { (granted, error) in
            // You may want to handle errors in here too
            completion(granted)
        }
    }
    
    func saveUserFcmToken() {
        // Get the FCM token from user defaults
        guard let fcmToken = UserDefaults.standard.value(forKey: "fcmToken") else{
            return
        }
        let uid = FirebaseServices.shared.uid
        let userDocRef = Firestore.firestore().collection("users").document(uid)
        userDocRef.updateData(["fcmToken": fcmToken]) { error in
            if let error = error {
                print("🚫Error updating user document with fcmToken: \(error)")
            } else {
                print(">> UPDATED FCM TOKEN: ", "USER: ", uid, "FCM TOKEN: ", fcmToken)
            }
        }
    }
    
    func cancelAllTasks() {
        for task in tasks {
            task.cancel()
        }
        tasks.removeAll()
    }
    
    static func setBadgeCount(_ count: Int) {
        UNUserNotificationCenter.current().setBadgeCount(count) { error in
            if let error = error {
                PrintControl.shared.printFirebaseOperations("Error setting badge count: \(error)")
            }
        }
    }
    
    // Convert CLLocationCoordinate2D to GeoPoint
    func convertToGeoPoint(coordinate: CLLocationCoordinate2D) -> GeoPoint {
        return GeoPoint(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
    
    // Convert GeoPoint to CLLocationCoordinate2D
    func convertToCoordinate(geoPoint: GeoPoint) -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
    }
    
    func listenToFroopData(uid: String, froopId: String, update: @escaping ([String: Any]) -> Void) -> ListenerRegistration? {
        guard !uid.isEmpty, !froopId.isEmpty else {
            PrintControl.shared.printFirebaseOperations(uid)
            PrintControl.shared.printFirebaseOperations(froopId)
            PrintControl.shared.printErrorMessages("Invalid uid or froopId")
            return nil
        }
        
        let shouldCreate = ListenerStateService.shared.shouldCreateListener(forKey: "listenToFroopData")
        guard shouldCreate else {
            PrintControl.shared.printErrorMessages("Listener creation restricted by ListenerStateService")
            return nil
        }

        let docRef = db.collection("users").document(uid).collection("myFroops").document(froopId)
        
        let listenerKey = "users-\(uid)-froopDecisions-froopLists-listenToFroopData"

        if let existingListener = ListenerStateService.shared.getListener(forKey: listenerKey) {
             existingListener.remove()
         }
        
        let listener = docRef.addSnapshotListener { (document, error) in
            if let document = document {
                update(document.data() ?? [:])
            } else if let error = error {
                PrintControl.shared.printErrorMessages("Error listening for document updates: \(error)")
            }
        }
        
        ListenerStateService.shared.addListener(listener, forKey: listenerKey)

        return listener
    }
    
    func listenToFroop(uid: String, froopId: String, update: @escaping ([String: Any]) -> Void) -> ListenerRegistration? {
        guard !uid.isEmpty, !froopId.isEmpty else {
            PrintControl.shared.printFirebaseOperations(uid)
            PrintControl.shared.printFirebaseOperations(froopId)
            PrintControl.shared.printErrorMessages("Invalid uid or froopId")
            return nil
        }
        
        let shouldCreate = ListenerStateService.shared.shouldCreateListener(forKey: "listenToFroopData")
        guard shouldCreate else {
            PrintControl.shared.printErrorMessages("Listener creation restricted by ListenerStateService")
            return nil
        }

        let docRef = db.collection("users").document(uid).collection("myFroops").document(froopId)
        let randomGen = UUID()
        let listenerKey = "users-\(uid)-froopDecisions-froopLists-listenToFroopData-\(randomGen)"

        if let existingListener = ListenerStateService.shared.getListener(forKey: listenerKey) {
             existingListener.remove()
         }
        
        let listener = docRef.addSnapshotListener { (document, error) in
            if let document = document {
                update(document.data() ?? [:])
            } else if let error = error {
                PrintControl.shared.printErrorMessages("Error listening for document updates: \(error)")
            }
        }
        
        ListenerStateService.shared.addListener(listener, forKey: listenerKey)

        return listener
    }

}
