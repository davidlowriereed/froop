//
//  TouchCaptureControl.swift
//  FroopProof
//
//  Created by David Reed on 4/13/23.
//

import Foundation
import UIKit

import UIKit

class TouchCaptureControl: UIControl {
    var onTouch: (() -> Void)?

    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        onTouch?()
        return false // Return false so the control does not capture the touch and allows other UI elements to respond
    }
}
