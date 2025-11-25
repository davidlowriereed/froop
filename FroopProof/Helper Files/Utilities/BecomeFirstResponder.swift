//
//  BecomeFirstResponder.swift
//  FroopProof
//
//  Created by David Reed on 4/13/23.
//

import SwiftUI

struct BecomeFirstResponder: ViewModifier {
    @Binding var becomeFirstResponder: Bool

    func body(content: Content) -> some View {
        content
            .background(FirstResponderBackground(becomeFirstResponder: $becomeFirstResponder))
    }
}

struct FirstResponderBackground: UIViewRepresentable {
    @Binding var becomeFirstResponder: Bool

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        if becomeFirstResponder {
            uiView.window?.makeFirstResponder(uiView)
            becomeFirstResponder = false
        }
    }
}

