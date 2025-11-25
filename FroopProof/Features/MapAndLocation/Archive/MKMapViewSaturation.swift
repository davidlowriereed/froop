//
//  MKMapViewSaturation.swift
//  FroopProof
//
//  Created by David Reed on 8/3/23.
//

import SwiftUI
import MapKit
import CoreLocation

class DesaturatedMapView: UIView {
    
    let mapView = MKMapView()
    let overlayView = UIView()

    var saturation: CGFloat = 0.0 {
        didSet {
            overlayView.backgroundColor = UIColor.white.withAlphaComponent(1.0 - saturation)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(mapView)
        mapView.frame = bounds
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        addSubview(overlayView)
        overlayView.frame = bounds
        overlayView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
