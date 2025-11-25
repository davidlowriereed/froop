//
//  LoadingManager.swift
//  FroopProof
//
//  Created by David Reed on 11/19/23.
//

import Foundation
import SwiftUI

class LoadingManager: ObservableObject {
    static var shared = LoadingManager()
    
    @Published var froopHistoryLoaded: Bool = false
    
}
