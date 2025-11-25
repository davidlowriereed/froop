//
//FroopDataListener.swift
//FroopProof
//
//Created by David Reed on 5/29/23.


import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseCore
import FirebaseStorage
import FirebaseDatabase
import FirebaseSessions
import FirebaseCrashlytics
import FirebaseSharedSwift
import UserNotifications
import MapKit
import CoreLocation
import SwiftUI


class FroopDataListener: NSObject, ObservableObject {
    
    static let shared = FroopDataListener()
    
    @Published var myInvitesList: [Froop] = []
    @Published var myConfirmedList: [Froop] = []
    @Published var myDeclinedList: [Froop] = []
    @Published var myArchivedList: [Froop] = []
//    @Published var friends: [UserData] = []
    let uid = FirebaseServices.shared.uid
    let db = FirebaseServices.shared.db
    @Published var froops: [String: Froop] = [:]
//    @Published private var froopDatas: [String: FroopData] = [:]
    var listeners: [String: ListenerRegistration] = [:]
//    
    override init() {
        super.init()
    }
//    
    deinit {
        stopListeners()
    }

    private func stopListeners() {
        for listener in listeners.values {
            listener.remove()
        }
        listeners.removeAll()
    }
    
    
    var printControl: PrintControl {
        return PrintControl.shared
    }
    
    var froopDataController: FroopDataController {
        return FroopDataController.shared
    }
    var navLocationServices: NavLocationServices {
        return NavLocationServices.shared
    }
    var locationManager: LocationManager {
        return LocationManager.shared
    }
    
    func updateInvitesList(invitesList: [Froop]) {
        self.myInvitesList = invitesList
    }
    
    func updateConfirmedList(confirmedList: [Froop]) {
        self.myConfirmedList = confirmedList
    }
    
    func updateDeclinedList(declinedList: [Froop]) {
        self.myDeclinedList = declinedList
    }
    
    private func updateFroop(with data: [String: Any]) {
        guard let froopId = data["froopId"] as? String else {
            return
        }
        
        let updatedFroop = Froop(dictionary: data)
        froops[froopId] = updatedFroop
        // Update the lists
        DataController.shared.checkLists(uid: FirebaseServices.shared.uid) { (archivedList, confirmedList, declinedList, invitesList) in
            let invitesFroopList = invitesList.compactMap { self.froops[$0] }
            let confirmedFroopList = confirmedList.compactMap { self.froops[$0] }
            let declinedFroopList = declinedList.compactMap { self.froops[$0] }
            
            self.updateInvitesList(invitesList: invitesFroopList)
            self.updateConfirmedList(confirmedList: confirmedFroopList)
            self.updateDeclinedList(declinedList: declinedFroopList)
            dump(FroopDataListener.shared.myConfirmedList)
        }
    }
    
    
//    private func addListener(for froopId: String) {
//        if listeners[froopId] != nil {
//            // Already listening for this froopId
//            return
//        }
//        
//        
//        
//        let listener = FirebaseServices.shared.listenToFroopData(uid: FirebaseServices.shared.uid, froopId: froopId) { [weak self] data in
//            self?.updateFroop(with: data)
//        }
//        listeners[froopId] = listener
//    }
    
    func listenToFroopList(type: FroopListType, uid: String, completion: @escaping ([Froop]) -> Void) -> ListenerRegistration? {
        let docRef = db.collection("users").document(uid).collection("froopDecisions").document("froopLists").collection(type.collectionName)
        
        let listenerKey = "users-\(uid)-froopDecisions-froopLists-\(type.collectionName)"
        
        if let existingListener = ListenerStateService.shared.getListener(forKey: listenerKey) {
            existingListener.remove()
        }
        PrintControl.shared.printData("Listen To Froop List:\(uid)")
        
        let listener = docRef.addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                PrintControl.shared.printErrorMessages("Error listening for document updates: \(error)")
            } else {
                var froopList: [Froop] = []
                let group = DispatchGroup()
                
                for document in querySnapshot!.documents {
                    let data = document.data()
                    
                    if data["placeholder"] as? String == "placeholder" {
                        continue
                    }
                    PrintControl.shared.printData("PROGRESS1")
                    
                    
                    guard let froopHost = data["froopHost"] as? String, let froopId = data["froopId"] as? String else {
                        PrintControl.shared.printErrorMessages("Invalid froopHost or froopId in data: \(data)")
                        continue
                    }
                    PrintControl.shared.printData("PROGRESS2")
                    
                    if froopHost.isEmpty || froopId.isEmpty {
                        // Handle the error: possibly continue the loop or break with an error message
                        PrintControl.shared.printErrorMessages("froopHost or froopId is empty. Cannot create a document reference with an empty path.")
                        continue
                    }
                    
                    let froopDocRef = self.db.collection("users").document(froopHost).collection("myFroops").document(froopId)
                    PrintControl.shared.printData("PROGRESS 2.5: \(froopDocRef.path)")
                    group.enter()
                    froopDocRef.getDocument { (froopDocument, error) in
                        if let error = error {
                            PrintControl.shared.printErrorMessages("Error fetching Froop document: \(error)")
                        } else if let froopDocument = froopDocument, froopDocument.exists {
                            let froop = Froop(dictionary: froopDocument.data() ?? [:])
                            froopList.append(froop ?? Froop(dictionary: [:]) ?? Froop.emptyFroop())
                        } else {
                            PrintControl.shared.printErrorMessages("Froop document does not exist")
                        }
                        PrintControl.shared.printData("PROGRESS3")
                        group.leave()
                    }
                }
                PrintControl.shared.printData("PROGRESS4")
                group.notify(queue: .main) {
                    switch type {
                    case .invites:
                        FroopDataController.shared.myInvitesList = froopList
                        FroopDataListener.shared.myInvitesList = froopList
                    case .confirmed:
                        FroopDataController.shared.myConfirmedList = froopList
                        FroopDataListener.shared.myConfirmedList = froopList
                    case .declined:
                        FroopDataController.shared.myDeclinedList = froopList
                        FroopDataListener.shared.myDeclinedList = froopList
                    case .archived:
                        FroopDataController.shared.myArchivedList = froopList
                        FroopDataListener.shared.myArchivedList = froopList
                    }
                    PrintControl.shared.printData("\(type.collectionName) Updated")
                    FroopManager.shared.createFroopHistoryArray() { froopHistory in
                        DispatchQueue.main.async {
                            FroopManager.shared.froopHistory = froopHistory
                            PrintControl.shared.printData("FroopHistory collection updated. Total count: \(FroopManager.shared.froopHistory.count)")
                        }
                    }
                    FroopDataController.shared.processPastEvents()
                    completion(froopList) // This will return the froopList to the caller via the closure
                }
            }
        }
        ListenerStateService.shared.addListener(listener, forKey: listenerKey)
        return listener
    }
    
}


