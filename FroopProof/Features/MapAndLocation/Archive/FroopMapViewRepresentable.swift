//
//  FroopMapViewRepresentable.swift
//  FroopProof
//
//  Created by David Reed on 1/19/23.
//

import SwiftUI
import MapKit
import CoreLocation

struct FroopMapViewRepresentable: UIViewRepresentable {
    @EnvironmentObject var locationSearchViewModel: LocationSearchViewModel
    @EnvironmentObject var homeViewModel: HomeViewModel
    
    @ObservedObject var locationManager = LocationManager.shared
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var navLocationServices = NavLocationServices.shared
    @ObservedObject var froopData = FroopData.shared
    
    let mapView = MKMapView()
    
    @Binding var mapState: MapViewState
    
  

    func calculateDistance(to location: FroopData) -> Double {
        PrintControl.shared.printNavLocationServices("-FroopMapViewRepresentable: Function: calculateDistance is firing!")
        guard let userLocation = LocationManager.shared.userLocation else { return 0 }
        let froopData = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        PrintControl.shared.printNavLocationServices(froopData.description)
        PrintControl.shared.printNavLocationServices("8888888888888888888888")
        return userLocation.distance(from: froopData)
    }

    func makeUIView(context: Context) -> some UIView {
        PrintControl.shared.printNavLocationServices("-FroopMapViewRepresentable: Function: makeUIView is firing!")
        mapView.delegate = context.coordinator
        mapView.isRotateEnabled = false
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .none
        
        if let userLocation = LocationManager.shared.userLocation {
            let region = MKCoordinateRegion(center: userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
            mapView.setRegion(region, animated: false)
        }
        
        PrintControl.shared.printNavLocationServices("updating userLocation ELEVEN")
        return mapView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        PrintControl.shared.printNavLocationServices("-FroopMapViewRepresentable: Function: updateUIView is firing!")
        switch mapState {
        case .noInput:
            PrintControl.shared.printNavLocationServices("NO INPUT")
            context.coordinator.clearMapViewAndRecenterOnUserLocation()
            break
        case .searchingForLocation:
            PrintControl.shared.printNavLocationServices("SEARCHING FOR LOCATION")
            break
        case .locationSelected:
                PrintControl.shared.printMap("LOCATION SELECTED")
            if CLLocationCoordinate2DIsValid(froopData.froopLocationCoordinate) {
                PrintControl.shared.printNavLocationServices("DEBUG: Adding stuff to map..")
                context.coordinator.addAndSelectAnnotation(withCoordinate: froopData.froopLocationCoordinate)
                context.coordinator.configurePolyline(withDestinationCoordinate: froopData.froopLocationCoordinate)
                PrintControl.shared.printMap("Froop Coordinates \(String(describing: froopData.froopLocationCoordinate))")
                PrintControl.shared.printMap("User Coordinates \(self.mapView.userLocation)")
            }
            break
        case .polylineAdded:
            PrintControl.shared.printMap("POLY LINE ADDED")
            break
        case .tripRequested:
            PrintControl.shared.printMap("TRIP REQUESTED")
            break
        case .tripAccepted:
            PrintControl.shared.printMap("TRIP ACCEPTED")
            break
        case .driverArrived:
            PrintControl.shared.printMap("DRIVER ARRIVED")
            break
        case .tripInProgress:
            PrintControl.shared.printMap("TRIP IN PROGRESS")
            break
        case .arrivedAtDestination:
            PrintControl.shared.printMap("ARRIVED AT DESTINATION")
            break
        case .tripCompleted:
            PrintControl.shared.printMap("TRIP COMPLETED")
            break
        case .tripCancelled:
            PrintControl.shared.printMap("TRIP CANCELLED")
            break
        }
    }
    
    func makeCoordinator() -> MapCoordinator {
        PrintControl.shared.printNavLocationServices("-FroopMapViewRepresentable: Function: makeCoordinator is firing!")
        return MapCoordinator(parent: self, mapUpdateState: MapUpdateState(), froopData: froopData)
    }
}


