//
//  froopMapView.swift
//  FroopProof
//
//  Created by David Reed on 4/26/23.
//

//import MapKit
//import FirebaseFirestore
//import SwiftUI
//import CoreLocation
//import Kingfisher
//
//struct FroopMapView: View {
//
//
//
//    @ObservedObject var appStateManager = AppStateManager.shared
//    @ObservedObject var printControl = PrintControl.shared
//    @ObservedObject var navLocationServices = NavLocationServices.shared
//    // @ObservedObject var froopDataListener = FroopDataListener.shared
//
//
//
//    @State private var internalRegion: MKCoordinateRegion
//    @ObservedObject var myData = MyData.shared
//    var db = FirebaseServices.shared.db
//    @Binding var froopLocation: CLLocationCoordinate2D
//    @Binding var froopHostUrl: String
//    @Binding var froopName: String
//    var userCoordinate = FirebaseServices.shared.userLocation
//    @State var distance: Double = 0.0
//    @State var expectedTravelTime: Double = 0.0
//    @State private var apexAnnotationPins: [ApexAnnotationPin] = []
//    @StateObject var annotationController: AnnotationController
//
//    init(froopLocation: Binding<CLLocationCoordinate2D>, froopHostUrl: Binding<String>, froopName: Binding<String>, region: MKCoordinateRegion) {
//           _froopLocation = froopLocation
//           _froopHostUrl = froopHostUrl
//           _froopName = froopName
//           _internalRegion = State(initialValue: region)
//           _annotationController = StateObject(wrappedValue: AnnotationController())
//       }
//
//    var body: some View {
//
//        FroopMapBackgroundView(froopData: FroopData(), homeViewModel: $homeViewModel, userData: userData)
        
//        let regionBinding = Binding(
//                    get: { self.internalRegion },
//                    set: { newValue in
                        // Ignore the new value when the user interacts with the map
                        // Update the internal region only when you need to programmatically move the map
//                    }
//                )
//        Map(coordinateRegion: regionBinding, annotationItems: annotationController.apexAnnotationPins) { item in
//            Annotation(coordinate: item.coordinate) {
//                switch item.pinType {
//                case .froopPin:
//                    FroopAnnotationView(froopPin: item)
//                case .userLocation:
//                    Image(systemName: "location.fill").foregroundColor(.red)
//                case .guestPin:
//                    GuestAnnotationView(guestPin: item)
//                }
//            }
//        }
//        .onAppear {
//            annotationController.setupAnnotations(froopLocation: froopLocation, froopName: froopName, froopHostUrl: froopHostUrl, userLocation: userCoordinate ?? CLLocationCoordinate2D())
//
//
//
//        }
//
//    }
//
//    private func calculateDistanceAndTime() {
//        let request = MKDirections.Request()
//        request.source = MKMapItem(placemark: MKPlacemark(coordinate: userCoordinate ?? CLLocationCoordinate2D()))
//        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: froopLocation))
//        request.transportType = .automobile
//
//        let directions = MKDirections(request: request)
//        directions.calculate { response, error in
//            guard let response = response, let route = response.routes.first else { return }
//            distance = route.distance / 1000  // distance in kilometers
//            expectedTravelTime = route.expectedTravelTime / 60 // time in minutes
//            print("Distance: \(distance) km")
//            print("Time: \(expectedTravelTime) minutes")
//        }
//    }
//
//    private func calculateDistanceInDegrees() -> Double {
        // Convert the distance from meters to degrees
        // Note: This is a rough estimate. The actual conversion factor varies depending on the location on Earth
//        let earthRadiusInMeters = 6371000.0
//        return distance / earthRadiusInMeters * (180.0 / .pi)
//    }
//    
//}

