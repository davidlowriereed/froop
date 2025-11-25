//
//  AnnotationController.swift
//  FroopProof
//
//  Created by David Reed on 5/25/23.
//

import Foundation
import MapKit


class AnnotationController: ObservableObject {
    @Published var apexAnnotationPins: [ApexAnnotationPin] = []

    func setupAnnotations(froopLocation: CLLocationCoordinate2D, froopName: String, froopHostUrl: String, userLocation: CLLocationCoordinate2D) {
        // Create the Froop annotation
        let froopPin = ApexAnnotationPin(coordinate: froopLocation, pinType: .froopPin)
        apexAnnotationPins.append(froopPin)

        // Create the user annotation
        let userPin = ApexAnnotationPin(coordinate: userLocation, pinType: .guestPin)
        apexAnnotationPins.append(userPin)
    }
}
