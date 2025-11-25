//
//  ConfirmedFroopsList.swift
//  FroopProof
//
//  Created by David Reed on 4/17/23.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import SwiftUI
import UIKit

class ConfirmedFroopsList: ObservableObject {
    @Published var activeFroops: [Froop] = []
    init() {}
    
    init(activeFroops: [Froop]) {
        self.activeFroops = activeFroops
    }
}
