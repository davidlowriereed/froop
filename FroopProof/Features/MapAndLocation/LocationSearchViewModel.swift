//
//  LocationSearchViewModel.swift
//  FroopProof
//
//  Created by David Reed on 1/19/23.
//

import SwiftUI
import Firebase
import MapKit
import UIKit
import FirebaseFirestore
import CoreLocation

@MainActor
class LocationSearchViewModel: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    static let shared = LocationSearchViewModel()
    @ObservedObject var locationManager = LocationManager.shared
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var locationServices = NavLocationServices.shared
    
    // MARK: - Properties
    @Published var results = [MKLocalSearchCompletion]()
    @Published var selectedFroopLocation = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    @Published var pickupTime: String?
    @Published var dropOffTime: String?
    @Published var places = [PlaceViewModel]()
    @Published var locationFilter: [String] = ["Search Nearby"]
    @Published private(set) var processedSearchResults: [(MKMapItem, Bool)] = []
    @Published var cameraPosition: MapCameraPosition = .region(.myNowRegion)
    @Published var route: MKRoute?
    @Published var routeDestination: MKMapItem?
    @Published var routeDisplaying: Bool = false
    @Published var viewingRegion: MKCoordinateRegion?
    @Published var mapSelection: MKMapItem?
    @Published var showDetails: Bool = false
    @Published var lookAroundScene: MKLookAroundScene?
    @Published var searchText: String = ""
    @Published var text: String = ""


    let searchCompleter = MKLocalSearchCompleter()
    var queryFragment: String = "" {
        didSet {
            guard !queryFragment.isEmpty else {
                results = []
                return
            }
            searchCompleter.queryFragment = queryFragment
        }
    }
    
    // MARK: Lifecycle
    override init() {
        super.init()
        searchCompleter.delegate = self
        if let initialRegion = viewingRegion {
            searchCompleter.region = initialRegion
        }
    }
    
    func calculateRegion(for places: [PlaceViewModel]) -> MKCoordinateRegion? {
        guard !places.isEmpty else { return nil }
        
        var minLat = places.first!.mapItem.placemark.coordinate.latitude
        var maxLat = places.first!.mapItem.placemark.coordinate.latitude
        var minLon = places.first!.mapItem.placemark.coordinate.longitude
        var maxLon = places.first!.mapItem.placemark.coordinate.longitude
        
        for place in places {
            let coord = place.mapItem.placemark.coordinate
            if coord.latitude < minLat {
                minLat = coord.latitude
            }
            if coord.latitude > maxLat {
                maxLat = coord.latitude
            }
            if coord.longitude < minLon {
                minLon = coord.longitude
            }
            if coord.longitude > maxLon {
                maxLon = coord.longitude
            }
        }
        
        let centerLat = (minLat + maxLat) / 2
        let centerLon = (minLon + maxLon) / 2
        let spanLat = (maxLat - minLat) * 1.25 // Add a buffer to the span
        let spanLon = (maxLon - minLon) * 1.25 // Add a buffer to the span
        
        let span = MKCoordinateSpan(latitudeDelta: spanLat, longitudeDelta: spanLon)
        let center = CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon)
        
        return MKCoordinateRegion(center: center, span: span)
    }
    
    func updateCameraPosition() {
        if let region = calculateRegion(for: places) {
            cameraPosition = .region(region)
        }
    }
    
    func retrieveMapItems(completion: @escaping () async -> Void) {
        let dispatchGroup = DispatchGroup()
        var mapItems = [MKMapItem]()
        places = []
        for result in results {
            dispatchGroup.enter()
            locationSearch(forLocalSearchCompletion: result) { response, error in
                if let mapItem = response?.mapItems.first {
                    mapItems.append(mapItem)
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.places = mapItems.map(PlaceViewModel.init)
            Task {
                await completion()
            }
        }
    }
    
    func retrieveMapItem(for result: MKLocalSearchCompletion, completion: @escaping () async -> Void) {
        places = []
        locationSearch(forLocalSearchCompletion: result) { response, error in
            if let mapItem = response?.mapItems.first {
                self.places = [PlaceViewModel(mapItem: mapItem)]
                self.processedSearchResults = [(mapItem, false)] // or true if LookAround is available
            }
            Task {
                await completion()
            }
        }
    }
    
    func processSearchResults() async {
        var processedResults: [(MKMapItem, Bool)] = []
        print("one!")
        for place in places {
            if (try? await MKLookAroundSceneRequest(mapItem: place.mapItem).scene) != nil {
                processedResults.append((place.mapItem, true))
            } else {
                processedResults.append((place.mapItem, false))
            }
        }
        
        DispatchQueue.main.async {
            self.processedSearchResults = processedResults
        }
    }
    
    // MARK: - Helpers
    func search(text: String, region: MKCoordinateRegion) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = text
        searchRequest.region = region
        
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            guard let response = response else {
                print("Error: \(error?.localizedDescription ?? "Unknown Error")")
                return
            }
            
            self.places = response.mapItems.map(PlaceViewModel.init)
        }
    }
    
    func selectLocation(_ localSearch: MKLocalSearchCompletion, froopData: FroopData, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        locationSearch(forLocalSearchCompletion: localSearch) { response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let item = response?.mapItems.first else {
                completion(nil)
                return
            }

            froopData.froopLocationtitle = localSearch.title
            froopData.froopLocationsubtitle = localSearch.subtitle
            froopData.froopLocationCoordinate = item.placemark.coordinate

            guard let userLocation = self.locationManager.userLocation?.coordinate else {
                completion(item.placemark.coordinate)
                return
            }

            self.getDestinationRoute(from: userLocation, to: item.placemark.coordinate) { route in
                self.route = route

                // Calculate the bounding region for the route
                let routeRect = route.polyline.boundingMapRect
                let region = MKCoordinateRegion(routeRect)

                // Calculate center coordinate and distance dynamically
                let centerCoordinate = CLLocationCoordinate2D(
                    latitude: (userLocation.latitude + item.placemark.coordinate.latitude) / 2,
                    longitude: (userLocation.longitude + item.placemark.coordinate.longitude) / 2
                )

                // Dynamic distance calculation based on the span of the region
                let latitudinalSpan = region.span.latitudeDelta * 111000 // approximately converting degrees to meters
                let longitudinalSpan = region.span.longitudeDelta * 111000 // approximately converting degrees to meters
                let maxSpan = max(latitudinalSpan, longitudinalSpan)
                let dynamicDistance = maxSpan * 5 // adding a larger buffer to the distance

                print("Latitudinal Span: \(latitudinalSpan)")
                print("Longitudinal Span: \(longitudinalSpan)")
                print("Max Span: \(maxSpan)")
                print("Dynamic Distance: \(dynamicDistance)")

                // Adjust center coordinate for top 2/3 view
                let adjustedCenterCoordinate = CLLocationCoordinate2D(
                    latitude: centerCoordinate.latitude + (latitudinalSpan * -0.4) / 111000, // shifting 30% of the span upwards
                    longitude: centerCoordinate.longitude
                )

                self.cameraPosition = .camera(MapCamera(centerCoordinate: adjustedCenterCoordinate, distance: dynamicDistance, heading: 0, pitch: 45)) // Adjust pitch for elevation view
                completion(item.placemark.coordinate)
            }
        }
    }

    func fetchLookAroundPreview() {
        if let mapSelection {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            
            lookAroundScene = nil
            Task.detached(priority: .background) {
                let request = MKLookAroundSceneRequest(mapItem: mapSelection )
                if let scene = try? await request.scene {
                    DispatchQueue.main.async {
                        self.lookAroundScene = scene
                    }
                }
            }
        }
    }

    func locationSearch(forLocalSearchCompletion localSearch: MKLocalSearchCompletion, completion: @escaping MKLocalSearch.CompletionHandler) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = localSearch.title.appending(localSearch.subtitle)
        
        searchRequest.region = viewingRegion ?? MKCoordinateRegion()
        
        let search = MKLocalSearch(request: searchRequest)
        search.start(completionHandler: completion)
    }
    
    func getDestinationRoute(from userLocation: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D, completion: @escaping(MKRoute) -> Void) {
        let userPlacemark = MKPlacemark(coordinate: userLocation)
        let destPlacemark = MKPlacemark(coordinate: destination)
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: userPlacemark)
        request.destination = MKMapItem(placemark: destPlacemark)
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            if error != nil {
                return
            }
            
            guard let route = response?.routes.first else { return }
            self.configurePickupAndDropoffTimes(with: route.expectedTravelTime)
            completion(route)
        }
    }
    
    func fetchRoute() {
        if let mapSelection {
            let request = MKDirections.Request()
            request.source = .init(placemark: .init(coordinate: .myLocation))
            request.destination = mapSelection
            
            Task {
                if let result = try? await MKDirections(request: request).calculate() {
                    route = result.routes.first
                    routeDestination = mapSelection
                    let expectedTravelTime = route?.expectedTravelTime
                    print("Expected travel time: \(expectedTravelTime ?? 0) seconds")
                    
                    withAnimation(.snappy) {
                        routeDisplaying = true
                    }
                }
            }
        }
    }
    
    func configurePickupAndDropoffTimes(with expectedTravelTime: Double) {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        
        pickupTime = formatter.string(from: Date())
        dropOffTime = formatter.string(from: Date() + expectedTravelTime)
    }
    
    // MARK: - MKLocalSearchCompleterDelegate
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.results = completer.results
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Search completer failed with error: \(error.localizedDescription)")
    }
}


struct PlaceViewModel: Identifiable, Hashable {
    let id = UUID()
    let mapItem: MKMapItem
    
    init(mapItem: MKMapItem) {
        self.mapItem = mapItem
    }
    
    var title: String {
        mapItem.name ?? "Unknown Place"
    }
    
    var subtitle: String {
        let placemark = mapItem.placemark
        var addressParts: [String] = []
        
        if let thoroughfare = placemark.thoroughfare {
            addressParts.append(thoroughfare)
        }
        if let subThoroughfare = placemark.subThoroughfare {
            addressParts.append(subThoroughfare)
        }
        if let locality = placemark.locality {
            addressParts.append(locality)
        }
        if let administrativeArea = placemark.administrativeArea {
            addressParts.append(administrativeArea)
        }
        if let postalCode = placemark.postalCode {
            addressParts.append(postalCode)
        }
        
        return addressParts.joined(separator: ", ")
    }
    
    static func == (lhs: PlaceViewModel, rhs: PlaceViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

enum MapCameraPositionSearch {
    case camera(MapCamera)
    case region(MKCoordinateRegion)
}

struct MapCameraSearch {
    var centerCoordinate: CLLocationCoordinate2D
    var distance: CLLocationDistance
    var heading: CLLocationDirection
    var pitch: CGFloat
}
