//
//  HomeViewModel.swift
//  FroopProof
//
//  Created by David Reed on 1/20/23.
//

import Foundation
import CoreLocation
import Firebase
import SwiftUI
import FirebaseAuth

class HomeViewModel: ObservableObject {
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var navLocationServices = NavLocationServices.shared
    @Published var mapState = MapViewState.noInput
    @Published var user: User?
    
        var userLocation: CLLocationCoordinate2D?
    var selectedLocation: FroopData = FroopData()
    
    private let radius: Double = 50 * 1000
    private var listenersDictionary = [String: ListenerRegistration]()
}
