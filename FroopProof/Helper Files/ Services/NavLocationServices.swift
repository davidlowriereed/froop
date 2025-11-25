//
//  NavLocationServices.swift
//  FroopProof
//
//  Created by David Reed on 5/26/23.
//

import Foundation
import UIKit
import SwiftUI

class NavLocationServices: NSObject, ObservableObject {
    static let shared = NavLocationServices()
    
    @Published var trackActiveUserLocation: Bool = false
    @Published var trackUserLocation: Bool = true
    @Published var selectedTab: Tab = .froop
    @Published var selectedFroopTab: FroopTab = .map
    
    
    private override init() {}
    
    
    var appStateManager: AppStateManager {
        return AppStateManager.shared
    }
    var printControl: PrintControl {
        return PrintControl.shared
    }
//    var froopDataListener: FroopDataListener {
//        return FroopDataListener.shared
//    }
    var froopDataController: FroopDataController {
        return FroopDataController.shared
    }
    var navLocationServices: NavLocationServices {
        return NavLocationServices.shared
    }
    var locationManager: LocationManager {
        return LocationManager.shared
    }
}
