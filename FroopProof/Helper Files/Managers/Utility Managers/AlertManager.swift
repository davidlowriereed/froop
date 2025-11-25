//
//  AlertManager.swift
//  FroopProof
//
//  Created by David Reed on 6/10/23.
//

import SwiftUI

class AlertManager: ObservableObject {
    static let shared = AlertManager()

    private init() {}

    func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            if let topController = windowScene.windows.first?.rootViewController {
                var presentedController = topController
                while let presented = presentedController.presentedViewController {
                    presentedController = presented
                }
                presentedController.present(alert, animated: true, completion: nil)
            }
        }
    }
}
