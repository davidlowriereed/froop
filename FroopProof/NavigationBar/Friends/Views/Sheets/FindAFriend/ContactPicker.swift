//
//  ContactPicker.swift
//  FroopProof
//
//  Created by David Reed on 4/5/23.
//

import SwiftUI
import Contacts
import Combine
import Foundation
import ContactsUI

struct ContactPicker: UIViewControllerRepresentable {
    
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var navLocationServices = NavLocationServices.shared
    // @ObservedObject var froopDataListener = FroopDataListener.shared
    var onPhoneNumberSelected: ((String) -> Void)?

    
    typealias UIViewControllerType = EmbeddedContactPickerViewController
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var selectedContact: HashableCNContact?
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self, presentationMode: presentationMode, onPhoneNumberSelected: onPhoneNumberSelected)
    }

    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ContactPicker>) -> ContactPicker.UIViewControllerType {
        let viewController = ContactPicker.UIViewControllerType()
        viewController.delegate = context.coordinator
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: EmbeddedContactPickerViewController, context: Context) {
    }
}
    
final class Coordinator: NSObject, EmbeddedContactPickerViewControllerDelegate {
    let parent: ContactPicker
    var onPhoneNumberSelected: ((String) -> Void)?  // Closure to handle the phone number selection
    var presentationMode: Binding<PresentationMode>

    init(_ parent: ContactPicker, presentationMode: Binding<PresentationMode>, onPhoneNumberSelected: ((String) -> Void)?) {
        self.parent = parent
        self.presentationMode = presentationMode
        self.onPhoneNumberSelected = onPhoneNumberSelected  // Assign the passed closure to the property
    }

    func embeddedContactPickerViewController(_ viewController: EmbeddedContactPickerViewController, didSelect contact: CNContact) {
        if let phoneNumber = contact.phoneNumbers.first?.value.stringValue {
            parent.selectedContact = HashableCNContact(contact: contact)
            onPhoneNumberSelected?(phoneNumber)  // Call the closure with the selected phone number
        }
        presentationMode.wrappedValue.dismiss()
    }

    func embeddedContactPickerViewControllerDidCancel(_ viewController: EmbeddedContactPickerViewController) {
        presentationMode.wrappedValue.dismiss()
    }
    
    private func formatPhoneNumber(_ number: String) -> String {
        let digits = number.filter { "0123456789".contains($0) }
        return digits
    }
}


class EmbeddedContactPickerViewController: UIViewController, CNContactPickerDelegate {
    weak var delegate: EmbeddedContactPickerViewControllerDelegate?
    var selectedContact: HashableCNContact?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.open(selectedContact: selectedContact, animated: animated)
    }
    
    private func open(selectedContact: HashableCNContact?, animated: Bool) {
        let viewController = CNContactPickerViewController()
        viewController.delegate = self
        viewController.displayedPropertyKeys = [CNContactPhoneNumbersKey] // Ensure phone numbers are fetched
        self.present(viewController, animated: animated)
    }
    
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        self.dismiss(animated: false) {
            self.delegate?.embeddedContactPickerViewControllerDidCancel(self)
        }
    }

    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        self.dismiss(animated: false) {
            self.delegate?.embeddedContactPickerViewController(self, didSelect: contact)
        }
    }
}
