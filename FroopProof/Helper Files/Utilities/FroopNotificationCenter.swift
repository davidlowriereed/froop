//
//  FroopNotificationCenter.swift
//  FroopProof
//
//  Created by David Reed on 4/16/23.
//

import SwiftUI
import Foundation



class FroopNotificationCenter {
    weak var delegate: FroopNotificationDelegate?

    func notifyParticipantsChanged(_ froopHistory: FroopHistory) {
        delegate?.froopParticipantsChanged(froopHistory)
    }

    func notifyStatusChanged(_ froopHistory: FroopHistory) {
        delegate?.froopStatusChanged(froopHistory)
    }
}
