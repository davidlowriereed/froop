//
//  GuestLocation.swift
//  FroopProof
//
//  Created by David Reed on 4/26/23.
//

import SwiftUI
import MapKit

struct GuestLocation {
    
    
    
    @ObservedObject var printControl = PrintControl.shared
   
    // @ObservedObject var froopDataListener = FroopDataListener.shared
   
 
    
    var location: CLLocationCoordinate2D
    var profileImageUrl: String
    var name: String
    var froopUserID: String
    var phoneNumber: String
    var currentDistance: CLLocationDistance?
    var etaToFroop: TimeInterval?
}
