//
//  MapUpdateState.swift
//  FroopProof
//
//  Created by David Reed on 1/22/23.
//
import Foundation
import UIKit
import SwiftUI
import CoreLocation

class MapUpdateState: ObservableObject {
    
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var navLocationServices = NavLocationServices.shared
    // @ObservedObject var froopDataListener = FroopDataListener.shared
    
    @Published var isFunctionEnabled = true
}
