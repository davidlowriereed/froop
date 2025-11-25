//
//  AlertListenerManager.swift
//  FroopProof
//
//  Created by David Reed on 4/29/23.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import Firebase
import UserNotifications


class AlertListenerManager: ObservableObject {
    var db = FirebaseServices.shared.db
    @Published private var showAlert = false
    @Published private var alertMessage = ""
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                PrintControl.shared.printErrorMessages("Error requesting notification permission: \(error)")
            } else {
                PrintControl.shared.printAppStateSetupListener("Notification permission granted: \(granted)")
            }
        }
    }
    
    func listenForFroopInvitations() {
        PrintControl.shared.printAppStateSetupListener("listenForFroopInvitations firing")
        let uid = FirebaseServices.shared.uid
        let froopDecisionsRef = db.collection("users").document(uid).collection("froopDecisions")
        let invitesListRef = froopDecisionsRef.document("froopLists").collection("myInvitesList")

        invitesListRef.addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                PrintControl.shared.printErrorMessages("Error getting documents: \(error)")
            } else {
                for change in querySnapshot?.documentChanges ?? [] {
                    if change.type == .added {
                       // var document = change.document

                        // Create a notification
                        let content = UNMutableNotificationContent()
                        content.title = "New Notification"
                        content.body = "You have received an invitation to a new Froop!"
                        content.sound = .default

                        // Create a trigger for the notification
                        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

                        // Create a request for the notification
                        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

                        // Add the request to the notification center
                        UNUserNotificationCenter.current().add(request) { error in
                            if let error = error {
                                PrintControl.shared.printErrorMessages("Error sending notification: \(error)")
                            } else {
                                PrintControl.shared.printNotifications("Notification scheduled")
                            }
                        }
                    }
                }
            }
        }
    }
    
}
