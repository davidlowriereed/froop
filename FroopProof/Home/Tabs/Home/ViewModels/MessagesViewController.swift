//
//  MessagesViewController.swift
//  FroopProof
//
//  Created by David Reed on 3/12/23.
//

import Foundation
import SwiftUI
import MessageUI




class MessagesViewController: UIViewController, ObservableObject, MFMessageComposeViewControllerDelegate {
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var navLocationServices = NavLocationServices.shared
    // @ObservedObject var froopDataListener = FroopDataListener.shared
    
    var delegate: MessagesViewDelegate?
    var recipients: [String]?
    var body: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func displayMessageInterface() {
        let composeVC = MFMessageComposeViewController()
        composeVC.messageComposeDelegate = self
        
        // Configure the fields of the interface
        composeVC.recipients = self.recipients ?? []
        composeVC.body = body ?? ""
        
        // Present the view controller modally.
        if MFMessageComposeViewController.canSendText() {
            self.present(composeVC, animated: true, completion: nil)
        } else {
            self.delegate?.messageCompletion(result: MessageComposeResult.failed)
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true)
        self.delegate?.messageCompletion(result: result)
    }
}

struct MessageUIView: UIViewControllerRepresentable {
    
    // To be able to dismiss itself after successfully finishing with the MessageUI
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var recipients: [String]
    var body: String
    var completion: ((_ result: MessageComposeResult) -> Void)
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> MessagesViewController {
        let controller = MessagesViewController()
        controller.delegate = context.coordinator
        controller.recipients = recipients
        controller.body = body
        return controller
    }
    
    func updateUIViewController(_ uiViewController: MessagesViewController, context: Context) {
        uiViewController.recipients = recipients
        uiViewController.displayMessageInterface()
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, MessagesViewDelegate {
        var parent: MessageUIView
        
        init(_ controller: MessageUIView) {
            self.parent = controller
        }
        
        func messageCompletion(result: MessageComposeResult) {
            self.parent.presentationMode.wrappedValue.dismiss()
            self.parent.completion(result)
        }
    }
}
