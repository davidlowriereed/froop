//
//  PinArray.swift
//  FroopProof
//
//  Created by David Reed on 7/18/23.
//

import Foundation
import UIKit
import MapKit

class PinArray: ObservableObject {
    static let shared = PinArray()
    
    @Published var froopDropPins: [FroopDropPin] = []
    
    func getFroopAnnotations(forFroop froopId: String, forUser userId: String) {
        let annotationsRef = RefPath.froopAnnotationsColRef(uid: userId, froopId: froopId)
        annotationsRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                PrintControl.shared.printMap("Error getting froop annotations: \(error)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                PrintControl.shared.printMap("No documents found")
                return
            }
            
            self.froopDropPins = documents.compactMap { document -> FroopDropPin? in
                let data = document.data()
                guard
                    let latitude = data["latitude"] as? Double,
                    let longitude = data["longitude"] as? Double,
                    let title = data["title"] as? String,
                    let subtitle = data["subtitle"] as? String,
                    let messageBody = data["messageBody"] as? String,
                    let colorHexString = data["color"] as? String,
                    let color = UIColor(named: colorHexString),
                    let creatorUID = data["creatorUID"] as? String,
                    let pinImage = data["pinImage"] as? String
                else {
                    return nil
                }
                
                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                return FroopDropPin(coordinate: coordinate, title: title, subtitle: subtitle, messageBody: messageBody, color: color, creatorUID: creatorUID, pinImage: pinImage)
            }
        }
    }
}

