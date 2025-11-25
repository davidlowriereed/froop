//
//  PhoneNumberTextField.swift
//  FroopProof
//
//  Created by David Reed on 4/3/23.
//

import SwiftUI
import UIKit

struct PhoneNumberTextField: UIViewRepresentable {
    @Binding var text: String
    var onEditingChanged: (Bool) -> Void = { _ in }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator
        textField.keyboardType = .phonePad
        textField.textColor = .white
        textField.font = UIFont.systemFont(ofSize: 24, weight: .thin)
        textField.clearButtonMode = .whileEditing
        textField.attributedPlaceholder = NSAttributedString(string: "(123) 456-7890)", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.5)])
        textField.addTarget(context.coordinator, action: #selector(Coordinator.textFieldDidChange), for: .editingChanged)
        //textField.borderStyle = .roundedRect
        //textField.layer.borderWidth = 0.25
        //textField.layer.borderColor = UIColor.white.cgColor
        //textField.layer.cornerRadius = 5
        textField.textAlignment = .center
        
        return textField
    }
    
    func updateUIView(_ textField: UITextField, context: Context) {
        textField.text = text
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: PhoneNumberTextField
        
        init(_ parent: PhoneNumberTextField) {
            self.parent = parent
        }
        
        @objc func textFieldDidChange(_ textField: UITextField) {
            guard let text = textField.text else { return }
            parent.text = formatPhoneNumber(text)
        }
        
        func textFieldDidBeginEditing(_ textField: UITextField) {
            parent.onEditingChanged(true)
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            parent.onEditingChanged(false)
        }
        
        private func formatPhoneNumber(_ phoneNumber: String) -> String {
            let allowedCharacterSet = CharacterSet(charactersIn: "0123456789")
            let filtered = phoneNumber.filter { character in
                String(character).rangeOfCharacter(from: allowedCharacterSet) != nil
            }
            
            var formatted = ""
            
            for (index, character) in filtered.enumerated() {
                switch index {
                case 0:
                    formatted += "("
                case 3:
                    formatted += ") "
                case 6:
                    formatted += "-"
                default:
                    break
                }
                formatted += String(character)
            }
            
            return formatted
        }
    }
}
