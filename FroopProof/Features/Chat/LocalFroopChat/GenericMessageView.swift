//
//  MessageView.swift
//  FroopProof
//
//  Created by David Reed on 4/5/23.
//

import SwiftUI
import MessageUI

struct GenericMessageView: UIViewControllerRepresentable {
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var navLocationServices = NavLocationServices.shared
    // @ObservedObject var froopDataListener = FroopDataListener.shared
    
    @Binding var isPresented: Bool
    var phoneNumber: String
    
    func makeCoordinator() -> GCoordinator {
        GCoordinator(self)
    }
    
    func makeUIViewController(context: Context) -> MFMessageComposeViewController {
        let messageComposeViewController = MFMessageComposeViewController()
        messageComposeViewController.messageComposeDelegate = context.coordinator
        messageComposeViewController.recipients = [phoneNumber]
        messageComposeViewController.body = ""
        return messageComposeViewController
    }
    
    func updateUIViewController(_ uiViewController: MFMessageComposeViewController, context: Context) {
    }
    
    class GCoordinator: NSObject, MFMessageComposeViewControllerDelegate {
        var parent: GenericMessageView
        
        init(_ parent: GenericMessageView) {
            self.parent = parent
        }
        
        func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
            parent.isPresented = false
        }
        
        func removePhoneNumberFormatting(_ phoneNumber: String) -> String {
            let cleanedPhoneNumber = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            return cleanedPhoneNumber
        }
    }
}
