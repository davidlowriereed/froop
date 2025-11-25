//
//  UserSubscriptionManager.swift
//  FroopProof
//
//  Created by David Reed on 1/24/24.
//

import FirebaseFirestore
import FirebaseAuth

class UserSubscriptionManager: ObservableObject {
    static let shared = UserSubscriptionManager()
    private let db = Firestore.firestore()
    private var subscriptionListener: ListenerRegistration?
    @Published var isPremium: Bool = false

    func checkSubscriptionStatus(completion: @escaping (Bool) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }

        let userDocRef = db.collection("users").document(userId)
        subscriptionListener = userDocRef.addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("🚫Error fetching user document: \(error?.localizedDescription ?? "")")
                completion(false)
                return
            }

            let isPremiumAccount = document.get("premiumAccount") as? Bool ?? false
            self.isPremium = isPremiumAccount // Update the isPremium property
            completion(isPremiumAccount)
        }
    }

    func stopListeningToSubscriptionStatus() {
        subscriptionListener?.remove()
    }
}
