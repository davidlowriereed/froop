//
//  KeyListener.swift
//  FroopProof
//
//  Created by David Reed on 1/22/23.
//

import Foundation
import UIKit


class MyViewModel: ObservableObject {
    @Published var isEditing = false
    private var keyboardObservers = [NSObjectProtocol]()
    
    init() {
        setupKeyboardObservers()
    }
    
    deinit {
        removeKeyboardObservers()
    }
    
    private func setupKeyboardObservers() {
        let willShowObserver = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { [weak self] (notification) in
            self?.isEditing = true
        }
        let willHideObserver = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { [weak self] (notification) in
            self?.isEditing = false
        }
        keyboardObservers.append(contentsOf: [willShowObserver, willHideObserver])
    }
    
    private func removeKeyboardObservers() {
        keyboardObservers.forEach { NotificationCenter.default.removeObserver($0) }
    }
}


//MARK: How to use -

//struct MyView: View {
//    @EnvironmentObject var viewModel: MyViewModel
//    var body: some View {
//        TextField("Enter text", text: /* your binding */)
//            .onEditingChanged { isEditing in
//                self.viewModel.isEditing = isEditing
//            }
//        // other views that depend on isEditing
//    }
//}
