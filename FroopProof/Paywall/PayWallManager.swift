//
//  PayWallManager.swift
//  FroopProof
//
//  Created by David Reed on 1/26/24.
//

import SwiftUI
import RevenueCat
import RevenueCatUI
import FirebaseAuth
import Firebase
import FirebaseFirestore

class PayWallManager: ObservableObject {
    static let shared = PayWallManager()
    @Published var showIAPView: Bool = false
    @Published var showDefaultView: Bool = false
    @Published var model: PaywallModel?
    let db = FirebaseServices.shared.db
    
    
    func fetchPaywallData() async throws {
        print("Fetching Paywall Data! 🚨")
        guard let jsonDict = try await Purchases.shared.offerings().current?.metadata else {
            DispatchQueue.main.async {
                self.showDefaultView = true
            }
            return
        }
        /// Converting into JSON data
        let jsonData = try JSONSerialization.data(withJSONObject: jsonDict, options: .prettyPrinted)
        let model = try JSONDecoder().decode(PaywallModel.self, from: jsonData)
        DispatchQueue.main.async {
            self.model = model
            self.showDefaultView = model.showDefaultView
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
                print("User subscription status updated successfully 1.")
            }
        }
    }
    
}
