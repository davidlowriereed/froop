//
//  MessageView.swift
//  FroopProof
//
//  Created by David Reed on 4/5/23.
//

import SwiftUI
import MessageUI
import FirebaseFirestore

struct MessageView: UIViewControllerRepresentable {
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var navLocationServices = NavLocationServices.shared
    // @ObservedObject var froopDataListener = FroopDataListener.shared
    
    @Binding var isPresented: Bool
    var phoneNumber: String
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> MFMessageComposeViewController {
        let messageComposeViewController = MFMessageComposeViewController()
        messageComposeViewController.messageComposeDelegate = context.coordinator
        messageComposeViewController.recipients = [phoneNumber]
        messageComposeViewController.body = "Hey, I'm now using an app called Froop to organize getting together with friends.  You can download it here: https://apps.apple.com/us/app/froop-do-anything-together/id6446192748"
        return messageComposeViewController
    }
    
    func updateUIViewController(_ uiViewController: MFMessageComposeViewController, context: Context) {
    }
    
    class Coordinator: NSObject, MFMessageComposeViewControllerDelegate {
        var parent: MessageView
        
        init(_ parent: MessageView) {
            self.parent = parent
        }
        
        func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
            parent.isPresented = false
            
            // Create a new document in the "smsInvitations" collection
            let db = FirebaseServices.shared.db
            let smsInvitationsRef = db.collection("smsInvitations")
            let cleanedPhoneNumber = removePhoneNumberFormatting(parent.phoneNumber)
            let invitationRef = smsInvitationsRef.document(cleanedPhoneNumber)
            
            // Set the data for the new document
            let data: [String: Any] = [
                "senderUid": FirebaseServices.shared.uid,
                "phoneNumber": cleanedPhoneNumber,
                "timestamp": Timestamp(date: Date())  // The current time
            ]
            
            invitationRef.setData(data) { error in
                if let error = error {
                    print("🚫Error creating invitation document: \(error)")
                } else {
                    print("Invitation document created")
                }
            }
        }
        
        func removePhoneNumberFormatting(_ phoneNumber: String) -> String {
            let cleanedPhoneNumber = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            return cleanedPhoneNumber
        }
    }
}
