//
//  LocationManager.swift
//  FroopProof
//
//  Created by David Reed on 1/19/23.
//

import CoreLocation
import MapKit
import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseAuth
import UIKit
import SwiftUI


final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    @ObservedObject var myData = MyData.shared
    @ObservedObject var timeZoneManager = TimeZoneManager()
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    @Published var locationCount = 0
    @Published var locations: [(count: Int, latitude: Double, longitude: Double)] = []
    
    @Published var user2DLocation: CLLocationCoordinate2D?
    @Published var userLocationAddress: String?
    @Published var circleOverlays: [MKCircle] = []
    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published var resolution: Double = 100
    @Published var isUserInsideGeofence: Bool = false
    @Published var guestArrived: Bool = false
    @Published var guestLeft: Bool = false
    @Published var locationUpdateTimerOn: Bool = false
    @Published var currentAddress: String?
    @Published var userTimeZone: TimeZone = TimeZone.current
    @Published var addressString: String = "Loading address..."

    @Published var userLocation: CLLocation?
    @Published var region: MKCoordinateRegion = MKCoordinateRegion.defaultRegion()
    private let locationManager = CLLocationManager()

    
    var locationUpdateTimer: Timer?
    var froopDataArray: [FroopData] = []
    var currentLocation: CLLocation?
    var geofenceRegion: CLCircularRegion? {
        didSet {
            if let region = geofenceRegion {
                locationManager.startMonitoring(for: region)
            } else {
                if let oldRegion = oldValue {
                    locationManager.stopMonitoring(for: oldRegion)
                }
            }
        }
    }
    var froopData = FroopData(dictionary: [:]) {
        didSet {
            let center = froopData?.froopLocationCoordinate
            let radius = 100.0 // Adjust this value according to your requirements
            let identifier = "Froop Geofence"
            geofenceRegion = CLCircularRegion(center: center ?? CLLocationCoordinate2D(), radius: radius, identifier: identifier)
        }
    }
    var appStateManager: AppStateManager {
        return AppStateManager.shared
    }
    var printControl: PrintControl {
        return PrintControl.shared
    }
    var firebaseServices: FirebaseServices {
        return FirebaseServices.shared
    }
    var froopDataController: FroopDataController {
        return FroopDataController.shared
    }
    var navLocationServices: NavLocationServices {
        return NavLocationServices.shared
    }
    
    private var isUpdating = false

    
    // MARK: Initialization and Configuration
    
    override init() {
        super.init()
        configureLocationManager()
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.showsBackgroundLocationIndicator = true
        locationManager.pausesLocationUpdatesAutomatically = false
    }
    
    ///Admin Functions
    private func configureLocationManager() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        // Remove the following line to avoid requesting authorization on initialization
        // locationManager.requestWhenInUseAuthorization()
    }
    func requestAlwaysAuthorization() {
        locationManager.requestAlwaysAuthorization()
    }
    func requestWhenInUseAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    // MARK:  Location Updates Management
    
    func startUpdating() async {
        do {
            for try await update in CLLocationUpdate.liveUpdates(.automotiveNavigation) {
                guard let location = update.location else { continue }
                DispatchQueue.main.async {
                    self.userLocation = location
                }
            }
        } catch {
            print("📍 Error while receiving location updates: \(error.localizedDescription)")
        }
    }
    
    func stopUpdating() {
        PrintControl.shared.printNavLocationServices("-LocationManager: Function: stopUpdating is firing!")
        guard isUpdating else { return }
        locationManager.stopUpdatingLocation()
        isUpdating = false
        TimerServices.shared.shouldCallupdateUserLocationInFirestore = false
    }
    func requestSingleUpdate () {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    func startLiveLocationUpdates() async {
        do {
            // Choose the appropriate configuration based on your app's needs.
            for try await update in CLLocationUpdate.liveUpdates(.default) {
                guard let location = update.location else { continue }
                DispatchQueue.main.async {
                    // Update your location handling here
                    self.userLocation = location
                    // Post notifications or update the UI as necessary
                }
            }
        } catch {
            print("Error while receiving location updates: \(error)")
        }
    }
    private func publishLocationUpdate() {
        // Update published properties and notify observers
    }
    
    ///Delegates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard FirebaseServices.shared.isAuthenticated else {
            return
        }
        
        guard let location = locations.first else { return }
        
        DispatchQueue.main.async { [weak self] in
            self?.userLocation = location
            self?.region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 5000, longitudinalMeters: 5000)
        }
        
        locationCount += 1
        
        self.locations.append((count: locationCount, latitude: location.coordinate.latitude, longitude: location.coordinate.longitude))
        
        updateUserLocationInFirestore()

        // Fetch the time zone for the user's location
        var timeZone: TimeZone? {
            return TimeZone.current
        }
        
        getCurrentLocationAddress(location) { (address) in
            self.userLocationAddress = address
        }
        
        // Calculate travel time to Froops and reschedule the notifications
        for froopData in froopDataArray {
            calculateTravelTime(from: location.coordinate, to: froopData.froopLocationCoordinate) { travelTime in
                if let travelTime = travelTime {
                    self.rescheduleLocalNotification(for: froopData, travelTime: travelTime)
                } else {
                    PrintControl.shared.printErrorMessages("Could not calculate travel time.")
                }
            }
        }

        let uid = FirebaseServices.shared.uid
        // Update user's location in Firestore
        let db = FirebaseServices.shared.db
        
        let userDocRef = db.collection("users").document(uid)
        
        let geoPoint = FirebaseServices.shared.convertToGeoPoint(coordinate: location.coordinate)
        userDocRef.updateData([
            "coordinate": geoPoint
        ]) { error in
            if let error = error {
                PrintControl.shared.printErrorMessages("Error updating location: \(error)")
            } else {
                self.updateUserLocationInFirestore()
                PrintControl.shared.printNavLocationServices("Location successfully updated")
            }
        }
        
        // Check if user has arrived
        if let froopLocation = froopDataArray.first?.froopLocationCoordinate {
            let froopLocation = CLLocation(latitude: froopLocation.latitude, longitude: froopLocation.longitude)
            if location.distance(from: froopLocation) <= 25 {
                stopUpdating()
                userDocRef.updateData([
                    "guestArrived": true
                ]) { error in
                    if let error = error {
                        PrintControl.shared.printErrorMessages("Error updating guestArrived: \(error)")
                    } else {
                        PrintControl.shared.printNavLocationServices("guestArrived successfully updated")
                    }
                }
            } else if location.distance(from: froopLocation) > 25 {
                userDocRef.updateData([
                    "guestArrived": false,
                    "guestLeft": true
                ]) { error in
                    if let error = error {
                        PrintControl.shared.printErrorMessages("Error updating guestArrived and guestLeft: \(error)")
                    } else {
                        PrintControl.shared.printNavLocationServices("guestArrived and guestLeft successfully updated")
                    }
                }
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region.identifier == geofenceRegion?.identifier {
            PrintControl.shared.printNavLocationServices("-LocationManager: Function: locationManager is firing!")
            isUserInsideGeofence = true
            notifyBackendUserArrival(uid: FirebaseServices.shared.uid, froopId: self.froopData?.froopId ?? "") { result in
                switch result {
                    case .success(let isArrivalNotified):
                        PrintControl.shared.printNotifications("Arrival notification sent successfully: \(isArrivalNotified)")
                    case .failure(let error):
                        PrintControl.shared.printErrorMessages("Error sending arrival notification: \(error.localizedDescription)")
                }
            }
            showAlert = true
            alertMessage = "Entered region: \(region.identifier)"
        }
    }
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region.identifier == geofenceRegion?.identifier {
            PrintControl.shared.printNavLocationServices("-LocationManager: Function: locationManager is firing!")
            isUserInsideGeofence = false
            
            showAlert = true
            alertMessage = "Exited region: \(region.identifier)"
            
        }
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        PrintControl.shared.printNavLocationServices("-LocationManager: Function: didChangeAuthorization is firing!")
        print("📍 didChangeAuthorization called with status: \(status)")
        
        DispatchQueue.main.async {
            self.authorizationStatus = status
            print("📍 authorizationStatus updated on main thread to: \(status)")
        }
        
        switch status {
            case .denied, .restricted:
                print("📍 Authorization status: denied or restricted")
                stopUpdatingUserLocationInFirestore()
                print("📍 Stopped updating user location in Firestore")
                stopUpdating()
                print("📍 Stopped updating location")
                PrintControl.shared.printNavLocationServices("updating userLocation THREE")
            case .authorizedAlways, .authorizedWhenInUse:
                print("📍 Authorization status: authorized (always or when in use)")
                startUpdatingAsync()
                print("📍 Started async location updates")
            case .notDetermined:
                print("📍 Authorization status: not determined")
            @unknown default:
                print("📍 Authorization status: unknown")
        }
        
        print("📍 didChangeAuthorization method completed")
    }
    
    private func startUpdatingAsync() {
        print("📍 startUpdatingAsync called")
        Task {
            print("📍 Starting async task for location updates")
            await startUpdating()
            print("📍 Async location updates started")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        PrintControl.shared.printErrorMessages("Failed to get user's location: \(error)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("📍 locationManagerDidChangeAuthorization called")
        let status = manager.authorizationStatus
        print("📍 New authorization status: \(status)")
        
        DispatchQueue.main.async {
            self.authorizationStatus = status
            print("📍 authorizationStatus updated on main thread to: \(status)")
        }
        
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            print("📍 Location authorized")
            updateAppStateManagerAuthorization(true)
            startUpdatingAsync()
        case .denied, .restricted:
            print("📍 Location authorization denied or restricted")
            updateAppStateManagerAuthorization(false)
            stopUpdatingUserLocationInFirestore()
            stopUpdating()
        case .notDetermined:
            print("📍 Location authorization not determined")
        @unknown default:
            print("📍 Unknown location authorization status")
        }
    }
    
    private func updateAppStateManagerAuthorization(_ authorized: Bool) {
        DispatchQueue.main.async {
            self.appStateManager.locationAuthorized = authorized
        }
    }
    
    // MARK: Location Access and Processing
    
    func getLocation() -> CLLocationCoordinate2D? {
        return locationManager.location?.coordinate
    }
    func calculateTravelTime(from sourceCoordinate: CLLocationCoordinate2D, to destinationCoordinate: CLLocationCoordinate2D, completion: @escaping (TimeInterval?) -> Void) {
        PrintControl.shared.printNavLocationServices("-LocationManager: Function: calculateTravelTime is firing!")
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: sourceCoordinate))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destinationCoordinate))
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        directions.calculateETA { response, error in
            if let error = error {
                PrintControl.shared.printErrorMessages("Error calculating travel time: \(error.localizedDescription)")
                completion(nil)
                return
            }
            guard let etaResponse = response else {
                completion(nil)
                return
            }
            completion(etaResponse.expectedTravelTime)
        }
    }
    func updateUserLocationAddress() {
        // Assuming `myData.coordinate` is of type CLLocationCoordinate2D
        guard let coordinate = self.userLocation?.coordinate else {
            print("User location is not available")
            return
        }

        // Create CLLocation from CLLocationCoordinate2D
        let userLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(userLocation) { [weak self] (placemarks, error) in
            guard let self = self else { return }

            if let error = error {
                print("Reverse geocoding failed: \(error.localizedDescription)")
                return
            }

            if let placemark = placemarks?.first {
                let address = [placemark.subThoroughfare, placemark.thoroughfare, placemark.locality, placemark.administrativeArea, placemark.postalCode, placemark.country]
                    .compactMap { $0 }
                    .joined(separator: ", ")

                self.userLocationAddress = address
                print("User's location address: \(address)")
            }
        }
    }
    func fetchCurrentAddress() {
        updateUserLocationAddress()
    }
    
    // MARK: Geofencing and Region Monitoring
    
    func setGeofenceForFroop(coordinate: CLLocationCoordinate2D, radius: Double = 100.0) {
        let circleOverlay = MKCircle(center: coordinate, radius: radius)
        circleOverlays.append(circleOverlay)
    }
   
    
    // MARK: Firestore Integration
    
    func updateUserLocationInFirestore() {
        guard firebaseServices.isAuthenticated else {
               return
           }
        let uid = FirebaseServices.shared.uid
        let db = FirebaseServices.shared.db
        let docRef = db.collection("users").document(uid)
            // Get the current location
            if let location = self.getLocation() {
                PrintControl.shared.printNavLocationServices("Location: \(location)")
                // Update the user document with the current location
                docRef.updateData([
                    "geoPoint": GeoPoint(latitude: location.latitude, longitude: location.longitude),
                    "coordinate": GeoPoint(latitude: location.latitude, longitude: location.longitude)
                ]) { error in
                    if let error = error {
                        PrintControl.shared.printErrorMessages("Error updating user document with location: \(error)")
                    } else {
                        PrintControl.shared.printNavLocationServices("User location updated successfully at:  \(Date())")
                        PrintControl.shared.printNavLocationServices("User Latitude \(location.latitude), Longitude: \(location.longitude)")
                    }
                }
            } else {
                PrintControl.shared.printErrorMessages("Failed to get user location.")
            }
    }
    func stopUpdatingUserLocationInFirestore() {
        locationUpdateTimer?.invalidate()
        locationUpdateTimer = nil
        locationUpdateTimerOn = false
    }
    
    
    // MARK:  Utility Functions
    
    func findCoordinateName() {
        print("firing)")
        self.froopData?.froopLocationtitle = ""
        Task {
            let location = CLLocation(latitude: myData.coordinate.latitude, longitude: myData.coordinate.longitude)
            let geoDecoder = CLGeocoder()
            if let name = try? await geoDecoder.reverseGeocodeLocation(location).first?.name {
                self.froopData?.froopLocationtitle = name
                print("🛜🛜🛜🛜 \(name)")
            }
        }
    }
    
    func getCurrentLocationAddress(_ location: CLLocation, completion: @escaping (String?) -> Void) {
        PrintControl.shared.printNavLocationServices("-LocationManager: Function: getCurrentLocationAddress is firing!")
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                PrintControl.shared.printErrorMessages("Error getting location address: \(error.localizedDescription)")
                completion(nil)
                return
            }
            guard let placemarks = placemarks, let placemark = placemarks.first else {
                completion(nil)
                return
            }
            // Use the placemark to get the address
            var addressString = ""
            if let streetNumber = placemark.subThoroughfare {
                addressString += streetNumber + " "
            }
            if let streetName = placemark.thoroughfare {
                addressString += streetName + ", "
            }
            if let city = placemark.locality {
                addressString += city + ", "
            }
            if let state = placemark.administrativeArea {
                addressString += state + " "
            }
            if let postalCode = placemark.postalCode {
                addressString += postalCode + ", "
            }
            if let country = placemark.country {
                addressString += country
            }
            completion(addressString)
        }
    }
    
    func getAddress(from location: CLLocation) {
        PrintControl.shared.printNavLocationServices("-LocationManager: Function: getAddress is firing!")
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error {
                PrintControl.shared.printErrorMessages(error.localizedDescription)
            } else if let placemarks = placemarks {
                if let placemark = placemarks.first {
                    var addressString = ""
                    if let streetNumber = placemark.subThoroughfare {
                        addressString += streetNumber + " "
                    }
                    if let streetName = placemark.thoroughfare {
                        addressString += streetName + ", "
                    }
                    if let city = placemark.locality {
                        addressString += city + ", "
                    }
                    if let state = placemark.administrativeArea {
                        addressString += state + " "
                    }
                    if let postalCode = placemark.postalCode {
                        addressString += postalCode + ", "
                    }
                    if let country = placemark.country {
                        addressString += country
                    }
                    print(addressString)
                    // Update the state variable with the new address
                    DispatchQueue.main.async {
                        self.addressString = addressString
                    }
                }
            }
        }
    }
    
    
    

    // MARK: CLLocationManagerDelegate
    
    
    
    // MARK: Notifications and Backend Communication
    
    func notifyBackendUserArrival(uid: String, froopId: String, completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        PrintControl.shared.printNavLocationServices("-LocationManager: Function: notifyBackendUserArrival is firing!")
        // Replace this URL with the actual API endpoint for your backend
        let urlString = "https://yourbackend.com/api/user_arrival"
        
        guard let url = URL(string: urlString) else {
            completionHandler(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = [
            "uid": uid,
            "froopId": froopId
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            completionHandler(.failure(error))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completionHandler(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
                completionHandler(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid HTTP response"])))
                return
            }
            
            completionHandler(.success(true))
        }
        
        task.resume()
    }
    func rescheduleLocalNotification(for froopData: FroopData, travelTime: TimeInterval) {
        PrintControl.shared.printNavLocationServices("-LocationManager: Function: rescheduleLocalNotification is firing!")
        let notificationId = "\(froopData.froopId)_travel_time_notification"
        
        // Remove any existing notification with the same ID
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationId])
        
        // Schedule a new notification
        let content = UNMutableNotificationContent()
        content.title = "Time to leave for your Froop"
        content.body = "It's time to head out for your Froop: \(froopData.froopName)."
        content.sound = .default
        
        let triggerTime = froopData.froopStartTime.addingTimeInterval(-travelTime)
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: triggerTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(identifier: notificationId, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                PrintControl.shared.printErrorMessages("Error scheduling notification: \(error.localizedDescription)")
            } else {
                PrintControl.shared.printNavLocationServices("Notification scheduled for travel time.")
            }
        }
    }
}

