//
//  FeedbackDataModel.swift
//  FroopProof
//
//  Created by David Reed on 5/18/23.
//

import SwiftUI
import MapKit
import Foundation
import CoreLocation

struct FeedbackDataModel: Identifiable {
    
    
    
    @ObservedObject var printControl = PrintControl.shared
   
    // @ObservedObject var froopDataListener = FroopDataListener.shared
   
 
    
    let id: String
    let froopId: String
    let froopHost: String
    let type: String
    let userLatitude: Double
    let userLongitude: Double
    let createdAt: Date
    let topic: String
    let bodyText: String
    let fromUser: String

    var dictionary: [String: Any] {
        return [
            "id": id,
            "froopId": froopId,
            "froopHost": froopHost,
            "type": type,
            "userLatitude": userLatitude,
            "userLongitude": userLongitude,
            "createdAt": createdAt,
            "topic": topic,
            "bodyText": bodyText,
            "fromUser": fromUser
        ]
    }
}
