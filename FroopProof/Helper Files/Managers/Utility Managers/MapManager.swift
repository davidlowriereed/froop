//
//  MapManager.swift
//  FroopProof
//
//  Created by David Reed on 11/6/23.
//

import SwiftUI
import MapKit
import FirebaseFirestore
import Combine
import Contacts
import Foundation


class MapManager: ObservableObject {
    
    /// Global Properties
    static let shared = MapManager()
    @ObservedObject var locationManager = LocationManager.shared
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var froopManager = FroopManager.shared
    @ObservedObject var flightManager = FroopFlightDataManager.shared
    lazy var annotationManager: AnnotationManager = {
        AnnotationManager.shared
    }()
    
    @Published var mapSelection: MKMapItem?

    /// Interface Properties
    @Published var tabUp: Bool = true
    @Published var showMenu: Bool = false

    
    /// Map Specific Properties
    @Published var route: MKRoute?
    @Published var routeDestination: MKMapItem?
    @Published var cameraPosition: MapCameraPosition = .region(.myNowRegion)
    @Published var mapRegion: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @Published var centerLatitude: Double = 0.0
    @Published var centerLongitude: Double = 0.0
    @Published var refreshMap = false
    @Published var routeDisplaying: Bool = false
    @Published var equatableCenter: EquatableCoordinate = EquatableCoordinate(coordinate: MKCoordinateRegion.myRegion.center) 

    /// Pin and Annotation Properties
    @Published var makeNewPin: Bool = false
    @Published var newPinCreation: Bool = false
    @Published var newPassivePinCreation: Bool = false
    @Published var froopPins: [FroopDropPin] = []
    @Published var newPin: FroopDropPin = FroopDropPin()
    @Published var froopDropPin: FroopDropPin = FroopDropPin()
    @Published var onSelected: Bool = false
    @Published var showSavePinView: Bool = false
    @Published var showSavePassivePinView: Bool = false

    @Published var showPinDetailsView: Bool = false
    @Published var showPassivePinDetailsView: Bool = false
    @Published var pinEnlarge: Bool = false
    @Published var createdPinDetail: FroopDropPin = FroopDropPin()
    @Published var flightPathCoordinates: [CLLocationCoordinate2D] = []

    /// Diagnostic Properties
    @Published var tapLatitude: Double = 0.0
    @Published var tapLongitude: Double = 0.0
    @Published var tapLatitudeDelta: Double = 0.0
    @Published var tapLongitudeDelta: Double = 0.0
    @Published var mapPositionX: Double = 0.0
    @Published var mapPositionY: Double = 0.0
    @Published var departureToPlane: [CLLocationCoordinate2D] = []
    @Published var planeToArrival: [CLLocationCoordinate2D] = []
    
    /// Other Properties
    let colorLookup: [Color: UIColor] = [
        .pink: UIColor.systemPink,
        .black: UIColor(red: 50/255, green: 46/255, blue: 62/255, alpha: 1.0),
        .blue: UIColor.blue,
        .green: UIColor.green,
        .yellow: UIColor.yellow,
        .red: UIColor.red,
        .orange: UIColor.orange,
        .purple: UIColor.purple
    ]
    
    let wazeDeepLink = "https://waze.com/ul" // Update this with the specific location if needed

    func onAddPinButtonTapped() {
        annotationManager.trackingUser = false
        if let newCenter = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopLocationCoordinate {
            let offset = mapRegion.span.latitudeDelta / 20
            let adjustedCenter = CLLocationCoordinate2D(latitude: newCenter.latitude - offset, longitude: newCenter.longitude)
            let adjustedRegion = MKCoordinateRegion(center: adjustedCenter, latitudinalMeters: 250, longitudinalMeters: 250)
            withAnimation(.easeInOut(duration: 1.0)) {
                MapManager.shared.cameraPosition = .region(adjustedRegion)
            }
            createNewDropPin()
            showPinDetailsView = false
            newPinCreation = true
            showSavePinView = true
            tabUp = false
            appStateManager.appStateToggle = true
            print("appStateToggle 3")

        }
    }
    
    func linearPathCoordinates(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D, steps: Int = 100) -> [CLLocationCoordinate2D] {
        var coordinates = [CLLocationCoordinate2D]()

        let deltaLat = end.latitude - start.latitude
        let deltaLon = end.longitude - start.longitude

        for i in 0...steps {
            let t = Double(i) / Double(steps)
            let lat = start.latitude + t * deltaLat
            let lon = start.longitude + t * deltaLon
            coordinates.append(CLLocationCoordinate2D(latitude: lat, longitude: lon))
        }

        return coordinates
    }
    
    func greatCircleCoordinates(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D, steps: Int = 100) -> [CLLocationCoordinate2D] {
        var coordinates = [CLLocationCoordinate2D]()
        let lat1 = start.latitude.degreesToRadians
        let lon1 = start.longitude.degreesToRadians
        let lat2 = end.latitude.degreesToRadians
        let lon2 = end.longitude.degreesToRadians

        let d = acos(sin(lat1) * sin(lat2) + cos(lat1) * cos(lat2) * cos(lon2 - lon1))
        
        for i in 0...steps {
            let f = Double(i) / Double(steps)
            let A = sin((1 - f) * d) / sin(d)
            let B = sin(f * d) / sin(d)
            let x = A * cos(lat1) * cos(lon1) + B * cos(lat2) * cos(lon2)
            let y = A * cos(lat1) * sin(lon1) + B * cos(lat2) * sin(lon2)
            let z = A * sin(lat1) + B * sin(lat2)
            let lat = atan2(z, sqrt(x * x + y * y))
            let lon = atan2(y, x)
            coordinates.append(CLLocationCoordinate2D(latitude: lat.radiansToDegrees, longitude: lon.radiansToDegrees))
        }
        return coordinates
    }

    
    func createNewPassiveDropPin() {
        let currentLocation = froopManager.selectedFroopHistory.froop.froopLocationCoordinate
        // Calculate the new latitude 100 meters to the north
        let metersNorth = 100.0
        let degreeDistance = metersNorth / 111000 // degrees per meter

        let newLatitude = currentLocation.latitude + degreeDistance
        let newCoordinate = CLLocationCoordinate2D(latitude: newLatitude, longitude: currentLocation.longitude)

        MapManager.shared.froopDropPin = FroopDropPin(coordinate: newCoordinate, title: "Tap On Map", subtitle: "To Place", pinImage: "mappin.circle.fill")
        makeNewPin = true
    }
    
    func createNewDropPin() {
        if let currentLocation = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopLocationCoordinate {
            // Calculate the new latitude 100 meters to the north
            let metersNorth = 100.0
            let degreeDistance = metersNorth / 111000 // degrees per meter
            
            let newLatitude = currentLocation.latitude + degreeDistance
            let newCoordinate = CLLocationCoordinate2D(latitude: newLatitude, longitude: currentLocation.longitude)
            
            MapManager.shared.froopDropPin = FroopDropPin(coordinate: newCoordinate, title: "Tap On Map", subtitle: "To Place", pinImage: "mappin.circle.fill")
        }
        makeNewPin = true
    }
    
    func generateFlightPathCoordinates() -> [CLLocationCoordinate2D] {
        
        let departure = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.flightData.departure?.airport
        let arrival = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.flightData.arrival?.airport

        let departureCoordinate = CLLocationCoordinate2D(latitude: departure?.location.lat ?? 0.0, longitude: departure?.location.lon ?? 0.0)
        let arrivalCoordinate = CLLocationCoordinate2D(latitude: arrival?.location.lat ?? 0.0, longitude: arrival?.location.lon ?? 0.0)
        
        let coordinates: [CLLocationCoordinate2D] = [departureCoordinate, arrivalCoordinate]
                                                     
        return coordinates
    }
    
    func loadFlightRoute() async {
        let departure = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.flightData.departure?.airport
        let arrival = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.flightData.arrival?.airport

        let departureCoordinate = CLLocationCoordinate2D(latitude: departure?.location.lat ?? 0.0, longitude: departure?.location.lon ?? 0.0)
        let arrivalCoordinate = CLLocationCoordinate2D(latitude: arrival?.location.lat ?? 0.0, longitude: arrival?.location.lon ?? 0.0)
        
        let departurePlacemark = MKPlacemark(coordinate: departureCoordinate)
        let arrivalPlacemark = MKPlacemark(coordinate: arrivalCoordinate)
        
        self.route = await createRoute(departurePlacemark: departurePlacemark, arrivalPlacemark: arrivalPlacemark)
    }
    
    private func createRoute(departurePlacemark: MKPlacemark, arrivalPlacemark: MKPlacemark) async -> MKRoute? {
        let departureItem = MKMapItem(placemark: departurePlacemark)
        let arrivalItem = MKMapItem(placemark: arrivalPlacemark)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = departureItem
        directionRequest.destination = arrivalItem
        directionRequest.transportType = .any // You can choose .automobile or .any for flights metaphorically
        
        let directions = MKDirections(request: directionRequest)
        do {
            let response = try await directions.calculate()
            guard let route = response.routes.first else {
                print("No routes found between the specified locations")
                return nil
            }
            return route
        } catch {
            print("Error calculating the route: \(error)")
            return nil
        }
    }
    
    
    func fetchRoute() {
        PrintControl.shared.printMap("🔥🚀💥fetchRoute Firling")
        // Assuming you have a source location, if not, you'll need to fetch it
        if let sourceCoordinate = locationManager.userLocation?.coordinate {
            let sourceMapItem = MKMapItem(placemark: MKPlacemark(coordinate: sourceCoordinate))
            PrintControl.shared.printMap("🔥Source location: \(sourceCoordinate.latitude), \(sourceCoordinate.longitude)")
            
            if let destinationCoordinate = MapManager.shared.routeDestination?.placemark.coordinate {
                PrintControl.shared.printMap("🔥Destination location: \(destinationCoordinate.latitude), \(destinationCoordinate.longitude)")
                
                let request = MKDirections.Request()
                request.source = sourceMapItem
                request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destinationCoordinate))
                
                Task {
                    do {
                        let response = try await MKDirections(request: request).calculate()
                        route = response.routes.first
                        routeDestination = MapManager.shared.routeDestination
                        
                        withAnimation(.snappy) {
                            routeDisplaying = true
                        }
                    } catch {
                        PrintControl.shared.printMap("💥Failed to calculate route: \(error)")
                    }
                }
            } else {
                PrintControl.shared.printMap("💥Destination location not set")
            }
        } else {
            PrintControl.shared.printMap("💥Source location not available")
        }
    }
    
    func openPassiveWaze() {
        // Retrieve the name and address
        
        let latitude: Double = froopManager.selectedFroopHistory.froop.froopLocationCoordinate.latitude 
        let longitude: Double = froopManager.selectedFroopHistory.froop.froopLocationCoordinate.longitude 
        
        // Check if Waze is installed
        if UIApplication.shared.canOpenURL(URL(string: "waze://")!) {
            // Waze is installed. Launch Waze and start navigation
            let urlStr = String(format: "waze://?ll=%f,%f&navigate=yes", latitude, longitude)
            UIApplication.shared.open(URL(string: urlStr)!)
        } else {
            // Waze is not installed. Launch AppStore to install Waze app
            UIApplication.shared.open(URL(string: "http://itunes.apple.com/us/app/id323229106")!)
        }
    }
    
    func openWaze() {
        // Retrieve the name and address
        
        let latitude: Double = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopLocationCoordinate.latitude ?? 0.0
        let longitude: Double = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopLocationCoordinate.longitude ?? 0.0
        
        // Check if Waze is installed
        if UIApplication.shared.canOpenURL(URL(string: "waze://")!) {
            // Waze is installed. Launch Waze and start navigation
            let urlStr = String(format: "waze://?ll=%f,%f&navigate=yes", latitude, longitude)
            UIApplication.shared.open(URL(string: urlStr)!)
        } else {
            // Waze is not installed. Launch AppStore to install Waze app
            UIApplication.shared.open(URL(string: "http://itunes.apple.com/us/app/id323229106")!)
        }
    }
    
    func mapItem(for address: String) async throws -> MKMapItem {
        let geocoder = CLGeocoder()
        return try await withCheckedThrowingContinuation { continuation in
            geocoder.geocodeAddressString(address) { placemarks, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let placemark = placemarks?.first, let location = placemark.location else {
                    continuation.resume(throwing: NSError(domain: "", code: -1, userInfo: nil)) // Consider creating a specific error
                    return
                }
                
                var addressDictionary: [String: Any] = [:]
                if let name = placemark.name { addressDictionary[CNPostalAddressStreetKey] = name }
                if let city = placemark.locality { addressDictionary[CNPostalAddressCityKey] = city }
                if let state = placemark.administrativeArea { addressDictionary[CNPostalAddressStateKey] = state }
                if let zip = placemark.postalCode { addressDictionary[CNPostalAddressPostalCodeKey] = zip }
                if let country = placemark.country { addressDictionary[CNPostalAddressCountryKey] = country }
                if let isoCountryCode = placemark.isoCountryCode { addressDictionary[CNPostalAddressISOCountryCodeKey] = isoCountryCode }
                
                let mkPlacemark = MKPlacemark(coordinate: location.coordinate, addressDictionary: addressDictionary)
                let mapItem = MKMapItem(placemark: mkPlacemark)
                mapItem.name = placemark.name // Optionally set the name based on the placemark details
                
                continuation.resume(returning: mapItem)
            }
        }
    }
    
    func loadPassiveRouteDestination() async {
        let coordinate = froopManager.selectedFroopHistory.froop.froopLocationCoordinate 
        do {
            let placemark = MKPlacemark(coordinate: coordinate)
            DispatchQueue.main.async {
                self.routeDestination = MKMapItem(placemark: placemark)
            }
        }
    }
    
    func loadRouteDestination() async {
        let coordinate = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopLocationCoordinate ?? CLLocationCoordinate2D()
        do {
            let placemark = MKPlacemark(coordinate: coordinate)
            DispatchQueue.main.async {
                self.routeDestination = MKMapItem(placemark: placemark)
            }
        }
    }

    func updatePassiveFroopDropPin() {
        // Ensure the user ID and Froop ID are available
        let userId = froopManager.selectedFroopHistory.host.froopUserID
        let froopId = froopManager.selectedFroopHistory.froop.froopId

        // Reference to the specific froopPin document in Firestore
        let froopPinRef = db.collection("users").document(userId)
            .collection("myFroops").document(froopId)
            .collection("froopPins").document(froopDropPin.id.uuidString)
        
        // Update only the messageBody field
        froopPinRef.updateData(["messageBody": froopDropPin.messageBody]) { error in
            if let error = error {
                // Handle any errors here
                print("🚫Error updating FroopDropPin messageBody: \(error.localizedDescription)")
            } else {
                // Update successful
                print("FroopDropPin messageBody updated successfully")
            }
        }
    }
    
    func updateFroopDropPin() {
        // Ensure the user ID and Froop ID are available
        let userId = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.host.froopUserID ?? ""
        let froopId = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopId ?? ""

        // Reference to the specific froopPin document in Firestore
        let froopPinRef = db.collection("users").document(userId)
            .collection("myFroops").document(froopId)
            .collection("froopPins").document(froopDropPin.id.uuidString)
        
        // Update only the messageBody field
        froopPinRef.updateData(["messageBody": froopDropPin.messageBody]) { error in
            if let error = error {
                // Handle any errors here
                print("🚫Error updating FroopDropPin messageBody: \(error.localizedDescription)")
            } else {
                // Update successful
                print("FroopDropPin messageBody updated successfully")
            }
        }
    }
    
    func savePassiveFroopDropPin() {
        newPinCreation = false
        // Ensure the user ID and Froop ID are available
        let userId = froopManager.selectedFroopHistory.host.froopUserID
        let froopId = froopManager.selectedFroopHistory.froop.froopId
        froopDropPin.coordinate = froopDropPin.coordinate
        // Reference to the froopPins collection in Firestore
        let froopPinsRef = db.collection("users").document(userId)
            .collection("myFroops").document(froopId)
            .collection("froopPins")
        
        // Convert FroopDropPin to a dictionary
        let pinData = froopDropPin.dictionary
        
        // Save the pin data to Firestore
        froopPinsRef.document(froopDropPin.id.uuidString).setData(pinData) { error in
            if let error = error {
                // Handle any errors here
                print("🚫Error saving FroopDropPin: \(error.localizedDescription)")
            } else {
                // Data saved successfully
                print("FroopDropPin saved successfully")
            }
        }
    }
    
    func saveFroopDropPin() {
        newPinCreation = false
        // Ensure the user ID and Froop ID are available
        let userId = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.host.froopUserID ?? ""
        let froopId = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopId ?? ""
        froopDropPin.coordinate = froopDropPin.coordinate
        // Reference to the froopPins collection in Firestore
        let froopPinsRef = db.collection("users").document(userId)
            .collection("myFroops").document(froopId)
            .collection("froopPins")
        
        // Convert FroopDropPin to a dictionary
        let pinData = froopDropPin.dictionary
        
        // Save the pin data to Firestore
        froopPinsRef.document(froopDropPin.id.uuidString).setData(pinData) { error in
            if let error = error {
                // Handle any errors here
                print("🚫Error saving FroopDropPin: \(error.localizedDescription)")
            } else {
                // Data saved successfully
                print("FroopDropPin saved successfully")
            }
        }
    }
    
    func deletePassiveFroopDropPin(pinId: String) {
        let userId = froopManager.selectedFroopHistory.host.froopUserID
        let froopId = froopManager.selectedFroopHistory.froop.froopId
        showPinDetailsView = false
        let froopPinsRef = db.collection("users").document(userId)
            .collection("myFroops").document(froopId)
            .collection("froopPins")

        froopPinsRef.document(pinId).delete() { error in
            if let error = error {
                print("🚫Error removing document: \(error)")
            } else {
                print("Document successfully removed!")
            }
        }
    }
    
    func deleteFroopDropPin(pinId: String) {
        let userId = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.host.froopUserID ?? ""
        let froopId = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopId ?? ""
        showPinDetailsView = false
        let froopPinsRef = db.collection("users").document(userId)
            .collection("myFroops").document(froopId)
            .collection("froopPins")

        froopPinsRef.document(pinId).delete() { error in
            if let error = error {
                print("🚫Error removing document: \(error)")
            } else {
                print("Document successfully removed!")
            }
        }
    }
    
    func startListeningForPassiveFroopPins() {
        // Check if the index is within bounds and the array is not empty

        let userId = froopManager.selectedFroopHistory.host.froopUserID
        let froopId = froopManager.selectedFroopHistory.froop.froopId

        let froopPinsRef = db.collection("users").document(userId)
                             .collection("myFroops").document(froopId)
                             .collection("froopPins")

        froopPinsRef.addSnapshotListener { snapshot, error in
            guard let documents = snapshot?.documents else {
//                print("No documents in 'froopPins' or error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            self.froopPins = documents.map { queryDocumentSnapshot -> FroopDropPin in
                let data = queryDocumentSnapshot.data()
//                print("Document data: \(data)") // Print the data for each document

                let title = data["title"] as? String ?? ""
                let subtitle = data["subtitle"] as? String ?? ""
                let colorHex = data["color"] as? String ?? "#000000FF"
                let color = UIColor(hex: colorHex) ?? UIColor(red: 50/255, green: 46/255, blue: 62/255, alpha: 1.0)
                let pinImage = data["pinImage"] as? String ?? "mappin"
                let creatorUID = data["creatorUID"] as? String ?? ""
                let latitude = data["latitude"] as? Double ?? 0
                let longitude = data["longitude"] as? Double ?? 0
                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

                let documentID = UUID(uuidString: queryDocumentSnapshot.documentID) ?? UUID()
                return FroopDropPin(
                    id: documentID,
                    coordinate: coordinate,
                    title: title,
                    subtitle: subtitle,
                    color: color,
                    creatorUID: creatorUID,
                    pinImage: pinImage
                )
            }
        }
    }

    func startListeningForFroopPins() {
        // Check if the index is within bounds and the array is not empty
        guard appStateManager.aFHI >= 0,
              appStateManager.aFHI < appStateManager.currentFilteredFroopHistory.count else {
//            print("Current Froop History is empty or index is out of bounds")
            return
        }

        let userId = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.host.froopUserID ?? ""
        let froopId = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopId ?? ""

        let froopPinsRef = db.collection("users").document(userId)
                             .collection("myFroops").document(froopId)
                             .collection("froopPins")

        froopPinsRef.addSnapshotListener { snapshot, error in
            guard let documents = snapshot?.documents else {
//                print("No documents in 'froopPins' or error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            self.froopPins = documents.map { queryDocumentSnapshot -> FroopDropPin in
                let data = queryDocumentSnapshot.data()
//                print("Document data: \(data)") // Print the data for each document

                let title = data["title"] as? String ?? ""
                let subtitle = data["subtitle"] as? String ?? ""
                let colorHex = data["color"] as? String ?? "#000000FF"
                let color = UIColor(hex: colorHex) ?? UIColor(red: 50/255, green: 46/255, blue: 62/255, alpha: 1.0)
                let pinImage = data["pinImage"] as? String ?? "mappin"
                let creatorUID = data["creatorUID"] as? String ?? ""
                let latitude = data["latitude"] as? Double ?? 0
                let longitude = data["longitude"] as? Double ?? 0
                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

                let documentID = UUID(uuidString: queryDocumentSnapshot.documentID) ?? UUID()
                return FroopDropPin(
                    id: documentID,
                    coordinate: coordinate,
                    title: title,
                    subtitle: subtitle,
                    color: color,
                    creatorUID: creatorUID, 
                    pinImage: pinImage
                )
            }
        }
    }
    
    
    /// Utility Methods
    func createArch(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D) -> [CLLocationCoordinate2D] {
        let midLatitude = (start.latitude + end.latitude) / 2
        let midLongitude = (start.longitude + end.longitude) / 2
        let altitude = abs(end.latitude - start.latitude) / 10  // Adjust arch height here

        var coordinates = [CLLocationCoordinate2D]()
        let steps = 100  // More steps for smoother curve
        for i in 0...steps {
            let t = Double(i) / Double(steps)
            let lat = (1 - t) * start.latitude + t * end.latitude
            let lon = (1 - t) * start.longitude + t * end.longitude
            let adjustedAltitude = altitude * sin(t * .pi)  // Sinusoidal arch
            coordinates.append(CLLocationCoordinate2D(latitude: lat + adjustedAltitude, longitude: lon))
        }
        return coordinates
    }
    
    func convertToUIColor(_ color: Color) -> UIColor {
        return UIColor(color)
    }
    
    func midpointBetween(coordinate1: CLLocationCoordinate2D, coordinate2: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        let latitude = (coordinate1.latitude + coordinate2.latitude) / 2
        let longitude = (coordinate1.longitude + coordinate2.longitude) / 2
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    func spanToInclude(coordinate1: CLLocationCoordinate2D, coordinate2: CLLocationCoordinate2D) -> MKCoordinateSpan {
        let maxLatitude = max(abs(coordinate1.latitude - coordinate2.latitude), abs(coordinate1.longitude - coordinate2.longitude))
        let span = maxLatitude * 2 // Adjust the multiplication factor to add padding
        return MKCoordinateSpan(latitudeDelta: span, longitudeDelta: span)
    }
    
    func convertPointToCoordinate(point: CGPoint, mapCenter: CLLocationCoordinate2D, mapSpan: MKCoordinateSpan, screenSize: CGSize) -> CLLocationCoordinate2D {
        // Determine scale
        let tapLatitudeDelta = mapSpan.latitudeDelta / screenSize.height
        let tapLongitudeDelta = mapSpan.longitudeDelta / screenSize.width
        
        // Calculate offset from center in screen points
        let centerScreenPoint = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
        let screenOffsetX = point.x - centerScreenPoint.x
        let screenOffsetY = point.y - centerScreenPoint.y
        
        // Convert screen offset to geographical offset
        let latitudeOffset = screenOffsetY * tapLatitudeDelta
        let longitudeOffset = screenOffsetX * tapLongitudeDelta
        
        // Apply offset to map center
        let newLatitude = mapCenter.latitude - latitudeOffset // Subtract because screen Y increases downwards
        let newLongitude = mapCenter.longitude + longitudeOffset
        
        return CLLocationCoordinate2D(latitude: newLatitude, longitude: newLongitude)
    }
    
    func updatePinLocation(to newCoordinate: CLLocationCoordinate2D) {
        froopDropPin.coordinate = newCoordinate
    }
}

extension UIColor {
    convenience init(_ color: Color) {
        let components = color.cgColor?.components ?? [0, 0, 0, 0]
        self.init(red: components[0], green: components[1], blue: components[2], alpha: components[3])
    }
}

extension UIColor {
    convenience init?(hex: String) {
        let r, g, b, a: CGFloat
        let scanner = Scanner(string: hex)
        var hexNumber: UInt64 = 0

        if scanner.scanHexInt64(&hexNumber) {
            r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
            g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
            b = CGFloat(hexNumber & 0x0000ff) / 255
            a = 1.0 // Assuming your hex color is not transparent and does not include alpha value

            self.init(red: r, green: g, blue: b, alpha: a)
        } else {
            return nil
        }
    }
}

struct EquatableRegion: Equatable {
    let region: MKCoordinateRegion
    
    static func == (lhs: EquatableRegion, rhs: EquatableRegion) -> Bool {
        return lhs.region.center.latitude == rhs.region.center.latitude &&
        lhs.region.center.longitude == rhs.region.center.longitude &&
        lhs.region.span.latitudeDelta == rhs.region.span.latitudeDelta &&
        lhs.region.span.longitudeDelta == rhs.region.span.longitudeDelta
    }
}


extension MapManager {
    func zoomToLocation(_ coordinate: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        self.cameraPosition = .region(region)
    }
}


class ArcPolyline: MKPolyline {
    var coordinates: [CLLocationCoordinate2D]
    
    init(coordinates: [CLLocationCoordinate2D]) {
        self.coordinates = coordinates
        super.init()
    }
}

struct FlightMapView: View {
    @ObservedObject var flightManager = FroopFlightDataManager.shared
    @ObservedObject var froopManager = FroopManager.shared
    @ObservedObject var mapManager = MapManager.shared
    @ObservedObject var timeZoneManager = TimeZoneManager.shared



    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 100, longitudeDelta: 100)
    )
    
    var body: some View {
        ZStack {
            MapReader { reader in
                Map()
//                    coordinateRegion: $region, annotationItems: [froopManager.selectedFroopHistory.froop]) { froop in
//                    MapAnnotation(coordinate: CLLocationCoordinate2D(
//                        latitude: froop.flightData?.departure.airport.location.lat ?? 0,
//                        longitude: froop.flightData?.departure.airport.location.lon ?? 0)) {
//                            Text("Departure")
//                        }
//                    MapAnnotation(coordinate: CLLocationCoordinate2D(
//                        latitude: froop.flightData?.arrival.airport.location.lat ?? 0,
//                        longitude: froop.flightData?.arrival.airport.location.lon ?? 0)) {
//                            Text("Arrival")
//                        }
//                }
//                .overlay(
//                    Path { path in
//                        if let departure = froopManager.selectedFroopHistory.froop.flightData?.departure,
//                           let arrival = froopManager.selectedFroopHistory.froop.flightData?.arrival {
//                            let coordinates = mapManager.createArch(from: CLLocationCoordinate2D(
//                                latitude: departure.airport.location.lat,
//                                longitude: departure.airport.location.lon),
//                                                                    to: CLLocationCoordinate2D(
//                                                                        latitude: arrival.airport.location.lat,
//                                                                        longitude: arrival.airport.location.lon))
//                            
//                            path.addLines(coordinates)
//                        }
//                    }
//                        .stroke(Color.blue, lineWidth: 2)
//                )
            }
        }
        .onAppear {
            if let departure = froopManager.selectedFroopHistory.froop.flightData?.departure,
               let arrival = froopManager.selectedFroopHistory.froop.flightData?.arrival {
                timeZoneManager.updateTimeZonesForFlight(
                    departureLat: departure.airport.location.lat,
                    departureLon: departure.airport.location.lon,
                    arrivalLat: arrival.airport.location.lat,
                    arrivalLon: arrival.airport.location.lon,
                    apiKey: Secrets.googleTimeZoneAPI
                ) { departingTimeZone, arrivingTimeZone, error in
                    if let error = error {
                        print("Error updating time zones: \(error)")
                        return
                    }
                    DispatchQueue.main.async {
                        froopManager.selectedFroopHistory.froop.flightData?.departure?.airport.localTimeZoneIdentifier = departingTimeZone?.timeZoneId
                        froopManager.selectedFroopHistory.froop.flightData?.arrival?.airport.localTimeZoneIdentifier = arrivingTimeZone?.timeZoneId
                    }
                }
            }
        }
    }
}



struct FlightPathView: View {
    @ObservedObject var flightManager = FroopFlightDataManager.shared
    @ObservedObject var froopManager = FroopManager.shared
    @ObservedObject var mapManager = MapManager.shared
    @ObservedObject var timeZoneManager = TimeZoneManager.shared
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 
                                        ((FroopManager.shared.selectedFroopHistory.froop.flightData?.departure?.airport.location.lat ?? 0.0) + (FroopManager.shared.selectedFroopHistory.froop.flightData?.arrival?.airport.location.lat ?? 0.0)) / 2,
                                       longitude:
                                        ((FroopManager.shared.selectedFroopHistory.froop.flightData?.departure?.airport.location.lon ?? 0.0) + (FroopManager.shared.selectedFroopHistory.froop.flightData?.arrival?.airport.location.lon ?? 0.0)) / 2),
        
        span: MKCoordinateSpan(
            latitudeDelta: abs(FroopManager.shared.selectedFroopHistory.froop.flightData?.departure?.airport.location.lat ?? 0.0 - (FroopManager.shared.selectedFroopHistory.froop.flightData?.arrival?.airport.location.lat ?? 0.0) ) * 1.5,
            longitudeDelta: abs(FroopManager.shared.selectedFroopHistory.froop.flightData?.departure?.airport.location.lon ?? 0.0 - (FroopManager.shared.selectedFroopHistory.froop.flightData?.arrival?.airport.location.lon ?? 0.0) ) * 1.5)
    )
    
    var body: some View {
        Map() /*{ location in*/
//            MapAnnotation(coordinate: location.coordinate) {
//                VStack {
//                    Text(location.name)
//                        .foregroundColor(.white)
//                        .padding(5)
//                        .background(Color.blue)
//                        .cornerRadius(10)
//                    Image(systemName: "airplane")
//                        .foregroundColor(.red)
//                }
//            }
//        }
//        .overlay(
//            Path { path in
//                let points = [departure.coordinate, arrival.coordinate]
//                path.addLines(points.map { MKMapPoint($0).coordinate })
//            }
//            .strokedPath(StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
//            .foregroundColor(.blue)
//        )
    }
}


struct AirportAnnotationView: View {
    var name: String
    
    var body: some View {
        VStack {
            Image(systemName: "airplane.circle")
                .foregroundColor(.blue)
                .padding(5)
                .background(Color.white)
                .clipShape(Circle())
            Text(name)
                .font(.caption)
                .foregroundColor(.black)
        }
    }
}


extension Double {
    var degreesToRadians: Double {
        return self * .pi / 180
    }
    var radiansToDegrees: Double {
        return self * 180 / .pi
    }
}
