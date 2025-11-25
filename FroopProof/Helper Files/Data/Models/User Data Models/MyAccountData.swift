//
//  MyAccountData.swift
//  FroopProof
//
//  Created by David Reed on 5/1/24.
//

import Foundation
import Firebase
import FirebaseFirestore
import Combine
import FirebaseAuth

final class MyAccountData: ObservableObject {
    static let shared = MyAccountData()

    private var db = Firestore.firestore()
    private var accountListener: ListenerRegistration?
    @Published var accountId: String = ""
    @Published var primaryUid: String = ""
    @Published var authUids: [String] = []
    @Published var phoneNumber: String = ""
    @Published var fcmToken: String = ""
    @Published var OTPVerified: Bool = false
    @Published var premiumAccount: Bool = false
    @Published var professionalAccount: Bool = false
    @Published var creationDate: Date = Date()
    @Published var badgeCount: Int = 0

    init() {
        fetchAccountData()
    }

    deinit {
        accountListener?.remove()
    }

    
    func fetchAccountData() {
           guard let uid = Auth.auth().currentUser?.uid else {
               print("Error: No user is currently signed in.")
               return
           }

           // Fetch the account using the current auth UID
           let accountsRef = db.collection("accounts")
           accountsRef.whereField("authUids", arrayContains: uid)
               .getDocuments { [weak self] (snapshot, error) in
                   guard let self = self, let snapshot = snapshot, !snapshot.documents.isEmpty else {
                       print("Error fetching account data: \(error?.localizedDescription ?? "Unknown error")")
                       return
                   }
                   
                   // Assuming the first document is the right one
                   let document = snapshot.documents.first!
                   self.accountId = document.documentID
                   self.updateProperties(with: document.data())
                   self.setupAccountListener()
               }
       }

       func setupAccountListener() {
           guard !accountId.isEmpty else { return }
           let docRef = db.collection("accounts").document(accountId)
           
           accountListener = docRef.addSnapshotListener { [weak self] (document, error) in
               guard let self = self, let document = document, document.exists else {
                   print("Error fetching account: \(error?.localizedDescription ?? "Document does not exist")")
                   return
               }
               
               if let data = document.data() {
                   self.updateProperties(with: data)
               }
           }
       }

       func updateProperties(with data: [String: Any]) {
           self.phoneNumber = data["phoneNumber"] as? String ?? ""
           self.fcmToken = data["fcmToken"] as? String ?? ""
           self.badgeCount = data["badgeCount"] as? Int ?? 0
           self.OTPVerified = data["OTPVerified"] as? Bool ?? false
           self.premiumAccount = data["premiumAccount"] as? Bool ?? false
           self.professionalAccount = data["professionalAccount"] as? Bool ?? false
           self.creationDate = (data["creationDate"] as? Timestamp)?.dateValue() ?? Date()
           self.authUids = data["authUids"] as? [String] ?? []
           self.primaryUid = data["primaryUid"] as? String ?? ""
       }

       func updateUserSubscriptionStatusInFirestore(hasPremiumAccess: Bool) {
           guard !accountId.isEmpty else {
               print("Error: Account ID is not set.")
               return
           }
           
           let accountDoc = db.collection("accounts").document(accountId)
           accountDoc.updateData([
               "premiumAccount": hasPremiumAccess
           ]) { error in
               if let error = error {
                   print("Error updating user subscription status: \(error.localizedDescription)")
               } else {
                   print("User subscription status updated successfully 3.")
               }
           }
       }
}
