//
//  KeyboardEvents.swift
//  FroopProof
//
//  Created by David Reed on 1/22/23.
//

import Foundation
import UIKit
import SwiftUI
import Combine


struct KeyTextField: View {
    let placeholder: String
    @Binding var text: String
    @Binding var isEditing: Bool
    @State private var cancellableSet = Set<AnyCancellable>()

    public init(placeholder: String, text: Binding<String>, isEditing: Binding<Bool>) {
        self.placeholder = placeholder
        self._text = text
        self._isEditing = isEditing
    }

    var body: some View {
        VStack {
            TextField(placeholder, text: $text, axis: .vertical)
                .lineLimit(3)
                .onAppear {
                    // set up a publisher to listen for keyboard events
                    NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
                        .merge(with: NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification))
                        .sink { notification in
                            // when the keyboard is shown or hidden, change the isEditing state variable
                            self.isEditing = notification.name == UIResponder.keyboardWillShowNotification
                        }
                        .store(in: &cancellableSet)
                }
        }
    }
}


import Combine
import UIKit


/// Publisher to read keyboard changes.


