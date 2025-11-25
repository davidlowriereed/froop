//
//  TouchCaptureView.swift
//  FroopProof
//
//  Created by David Reed on 4/13/23.
//

import Foundation
import SwiftUI

struct TouchCaptureView: UIViewRepresentable {
    let onTouch: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> TouchCaptureControl {
        let control = TouchCaptureControl()
        control.onTouch = onTouch
        return control
    }

    func updateUIView(_ uiView: TouchCaptureControl, context: Context) {
    }

    class Coordinator: NSObject {
        var parent: TouchCaptureView

        init(_ parent: TouchCaptureView) {
            self.parent = parent
        }
    }
}
