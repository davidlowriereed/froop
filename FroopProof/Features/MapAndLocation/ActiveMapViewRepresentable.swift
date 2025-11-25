//
//  FroopMapViewRepresentable.swift
//  FroopProof
//
//  Created by David Reed on 1/19/23.
//


import SwiftUI
import MapKit
import CoreLocation
import Combine
import Kingfisher
import FirebaseFirestore
 




struct ActiveMapViewRepresentable: UIViewRepresentable {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel = ActiveMapViewModel.shared
    @ObservedObject var appStateManager = AppStateManager.shared
    
    func makeUIView(context: Context) -> MKMapView {
        
        let longPress = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.addAnnotationOnLongPress(gesture:)))
        longPress.minimumPressDuration = 0.3
        
        viewModel.mapView.addGestureRecognizer(longPress)
        viewModel.mapView.delegate = context.coordinator
        viewModel.mapView.isRotateEnabled = false
        viewModel.mapView.showsUserLocation = false
        viewModel.mapView.userTrackingMode = .none
        
        let froopLocation = viewModel.froopLocation
        let region = MKCoordinateRegion(center: froopLocation, span: MKCoordinateSpan(latitudeDelta: viewModel.regLat, longitudeDelta: viewModel.regLon))
        viewModel.mapView.setRegion(region, animated: false)
        
        return viewModel.mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: UIViewRepresentableContext<ActiveMapViewRepresentable>) {
        if !viewModel.isMapViewInitialized {
            let froopLocation = viewModel.froopLocation
            let region = MKCoordinateRegion(center: froopLocation, span: MKCoordinateSpan(latitudeDelta: viewModel.regLat, longitudeDelta: viewModel.regLon))
            uiView.setRegion(region, animated: false)
        }
        
        // Remove any annotations from the map view that aren't in the viewModel.annotations array
        for annotation in uiView.annotations {
            if !viewModel.annotations.contains(where: { $0.coordinate.latitude == annotation.coordinate.latitude && $0.coordinate.longitude == annotation.coordinate.longitude }) {
                uiView.removeAnnotation(annotation)
            }
        }
        
        // Add any annotations from the viewModel.annotations array that aren't in the map view
        for annotation in viewModel.annotations {
            if !uiView.annotations.contains(where: { $0.coordinate.latitude == annotation.coordinate.latitude && $0.coordinate.longitude == annotation.coordinate.longitude }) {
                uiView.addAnnotation(annotation)
            }
        }
        
        if let polyline = viewModel.polyline {
            uiView.removeOverlays(uiView.overlays)
            uiView.addOverlay(polyline)
        }
        
        // Handle map state changes
        switch viewModel.mapState {
            case .noInput:
                PrintControl.shared.printMap("noInput")
            case .searchingForLocation: break
                // Handle searching for location state
            case .locationSelected:
                viewModel.configurePolyline(forGuests: appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.confirmedFriends ?? [])
                
                // Handle location selected state
            default:
                break
        }
    }
    
    func makeCoordinator() -> ActiveMapViewModel.ActiveMapCoordinator {
        let defaultImageUrl = "https://firebasestorage.googleapis.com/v0/b/froop-proof.appspot.com/o/ProfilePic%2FJDgZUEkawWa2UbQib5PI63AM4bA2.jpg?alt=media&token=1387264e-efbc-447a-9a4c-ea6c6f036be9"
        let annotationImageUrl = defaultImageUrl
        return ActiveMapViewModel.ActiveMapCoordinator(viewModel: viewModel, annotationImageUrl: annotationImageUrl, mapView: MKMapView())
    }
    
    
}


class ActiveMapViewModel: ObservableObject {
    
    static let shared = ActiveMapViewModel(froopLocation: CLLocationCoordinate2D())
    
    @EnvironmentObject var locationSearchViewModel: LocationSearchViewModel
    @EnvironmentObject var homeViewModel: HomeViewModel
    
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var navLocationServices = NavLocationServices.shared
    // @ObservedObject var froopDataListener = FroopDataListener.shared
    @ObservedObject var locationManager = LocationManager.shared
    @ObservedObject var froopManager = FroopManager.shared
    @ObservedObject var myData = MyData.shared
    @ObservedObject var pinArray = PinArray.shared
    let db = FirebaseServices.shared.db
    
    var visualEffectView: UIVisualEffectView?
    
    let annotationModel = AnnotationModel()
    
    @Published var froopAnnotations = [NewFroopPin]()
    
    @Published var isMapViewInitialized = false
    @Published var centerCoordinate: CLLocationCoordinate2D?
    @Published var froopLocation: CLLocationCoordinate2D
    @Published var mapState: MapViewState = .locationSelected
    @Published var annotations: [MKAnnotation] = []
    @Published var polyline: MKPolyline?
    @Published var currentRegion: MKCoordinateRegion?
    @Published var regLon: Double = 0.01
    @Published var regLat: Double = 0.01
    @Published var annotationImage: String = ""
    @Published var overlay: MKOverlay?
    @Published var selectedAnnotation: NewFroopPin?
    //    @State private var showChatView = false
    
    private var cancellables = Set<AnyCancellable>()
    
    let mapView: MKMapView
    
    var guestAnnotations: [String: MovableAnnotation] = [:]
    
    init(froopLocation: CLLocationCoordinate2D) {
        self.mapView = MKMapView() // Initialize mapView
        self.froopLocation = AppStateManager.shared.currentFilteredFroopHistory[AppStateManager.shared.aFHI].froop.froopLocationCoordinate 
        isMapViewInitialized = true

        // Call updateMapView after setting froopLocation
        self.updateMapView()
        
        let froopLocationAnnotation = MKPointAnnotation()
        froopLocationAnnotation.coordinate = self.froopLocation
        froopLocationAnnotation.title = "Froop Location"
        self.mapView.addAnnotation(froopLocationAnnotation)
        
        appStateManager.onUpdateMapView = { [weak self] in
            self?.updateMapView()
        }

        // Observe changes in PinArray's froopDropPins and update the map annotations accordingly
        PinArray.shared.$froopDropPins
            .sink { [weak self] froopDropPins in
                guard let self = self else { return }

                // Remove all current annotations
                let existingAnnotations = self.mapView.annotations.filter { $0 is FroopMapAnnotation }
                self.mapView.removeAnnotations(existingAnnotations)

                // Convert FroopDropPins to FroopMapAnnotations and add them to the map
                let newAnnotations = froopDropPins.map { FroopMapAnnotation(details: $0) }
                self.mapView.addAnnotations(newAnnotations)
                self.annotations.append(contentsOf: newAnnotations)
            }
            .store(in: &cancellables)

        // Listen for changes to the activeInvitedFriends array
        appStateManager.currentFilteredFroopHistory[AppStateManager.shared.aFHI].$confirmedFriends
            .sink { [weak self] (guests: [UserData]) in
                guard self != nil else { return }

                // Process guest annotations as before
                // ...
            }
            .store(in: &cancellables)

        loadAnnotations()
    }
    
    func loadAnnotations() {
        guard appStateManager.appState != .passive,
              appStateManager.aFHI >= 0,
              appStateManager.aFHI < appStateManager.currentFilteredFroopHistory.count else {
            PrintControl.shared.printMap("Application is in passive mode, or index out of bounds, skipping loadAnnotations")
            return
        }
        
        PrintControl.shared.printMap("loadAnnotations Function Firing!")
        
        let froopHistory = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]
        
        guard ((froopHistory?.host.froopUserID.isEmpty) == nil), ((froopHistory?.froop.froopId.isEmpty) == nil) else {
            PrintControl.shared.printMap("Error: Blank froopHost or froopId")
            return
        }
        
        let annotationsCollection = db.collection("users").document(froopHistory?.host.froopUserID ?? "").collection("myFroops").document(froopHistory?.host.froopUserID ?? "").collection("annotations")
        PrintControl.shared.printMap("annotationsCollection: \(String(describing: annotationsCollection))")
        
        annotationsCollection.getDocuments() { [weak self] (querySnapshot, err) in
            guard let self = self else { return }
            
            if let err = err {
                PrintControl.shared.printMap("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    PrintControl.shared.printMap("\(document.documentID) => \(document.data())")
                    
                    let data = document.data()
                    
                    if let coordinateData = data["coordinate"] as? GeoPoint {
                        let coordinate = FirebaseServices.shared.convertToCoordinate(geoPoint: coordinateData)
                        
                        let title = data["title"] as? String
                        let subtitle = data["subtitle"] as? String
                        let messageBody = data["messageBody"] as? String
                        let colorString = data["color"] as? String
                        let creatorUID = data["creatorUID"] as? String
                        let pinImage = data["pinImage"] as? String
                        let color = UIColor(named: colorString ?? "") ?? UIColor.white
                        
                        let froopDropPin = FroopDropPin(coordinate: coordinate, title: title, subtitle: subtitle, messageBody: messageBody, color: color, creatorUID: creatorUID, pinImage: pinImage)
                        let froopMapAnnotation = FroopMapAnnotation(details: froopDropPin)

                        if !self.annotations.contains(where: { ($0 as? FroopMapAnnotation)?.id == froopMapAnnotation.id }) {
                            self.annotations.append(froopMapAnnotation)
                            self.mapView.addAnnotation(froopMapAnnotation)
                            self.adjustMapViewToFitAnnotations()
                        }
                    }
                }
            }
        }
    }
    
    func adjustMapViewToFitAnnotations() {
        PrintControl.shared.printMap("ADJUSTING MAP TO FIT ANNOTATIONS")
        guard let boundingRect = boundingMapRectForAnnotations() else { return }
        
        let fittingRect = mapView.mapRectThatFits(boundingRect, edgePadding: UIEdgeInsets(top: 150, left: 32, bottom: 150, right: 32))
        mapView.setVisibleMapRect(fittingRect, animated: true)
    }
    
    func boundingMapRectForAnnotations() -> MKMapRect? {
        var rect: MKMapRect?
        
        for annotation in mapView.annotations {
            let annotationPoint = MKMapPoint(annotation.coordinate)
            let pointRect = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: 0.1, height: 0.1) // Slight size to the point
            
            if let currentRect = rect {
                rect = currentRect.union(pointRect)
            } else {
                rect = pointRect
            }
        }
        
        return rect
    }
    
    func moveAnnotation(_ annotation: GuestAnnotation, to coordinate: CLLocationCoordinate2D, duration: TimeInterval) {
        UIView.animate(withDuration: duration) {
            annotation.coordinate = coordinate
        }
    }
    
    func updateGuestLocation(_ guest: UserData, withCoordinate newCoordinate: CLLocationCoordinate2D) {
        // Check if the annotation for this guest exists in the dictionary
        if let annotation = self.guestAnnotations[guest.froopUserID] {
            // If it does, update its coordinate to the new one
            annotation.coordinate = newCoordinate
        }
    }
    
    func updateBlurEffect(for view: MKMapView, selected: Bool) {
        //        if selected {
        //            let blurEffect = UIBlurEffect(style: .light)
        //            self.visualEffectView = UIVisualEffectView(effect: blurEffect)
        //            self.visualEffectView?.frame = view.bounds
        //            self.visualEffectView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        //            view.addSubview(self.visualEffectView!)
        //        } else {
        self.visualEffectView?.removeFromSuperview()
        self.visualEffectView = nil
    }
    
    func centerMapOnLocation(coordinate: CLLocationCoordinate2D, latMultiple: Double, lonMultiple: Double) {
        PrintControl.shared.printMap("center map function called")
        PrintControl.shared.printMap("Coordinate Received: \(coordinate)")
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegion(center: coordinate,
                                                  latitudinalMeters: regionRadius * latMultiple,
                                                  longitudinalMeters: regionRadius * lonMultiple)
        mapView.setRegion(coordinateRegion, animated: true)
        DispatchQueue.main.async {
            self.currentRegion = coordinateRegion
            
        }
    }
    
    func updateMapView() {
        mapView.removeAnnotations(mapView.annotations)
        
        if appStateManager.aFHI >= 0 && appStateManager.aFHI < appStateManager.currentFilteredFroopHistory.count {
            let froopHistory = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]
            
            let froopAnnotation = MKPointAnnotation()
            froopAnnotation.coordinate = froopHistory?.froop.froopLocationCoordinate ?? CLLocationCoordinate2D()
            froopAnnotation.title = froopHistory?.froop.froopName
            mapView.addAnnotation(froopAnnotation)
            mapView.selectAnnotation(froopAnnotation, animated: true)
            annotations.append(froopAnnotation)
            
            for guest in froopHistory?.confirmedFriends ?? [] {
                let annotation = MKPointAnnotation()
                annotation.coordinate = guest.coordinate
                annotation.title = "\(guest.firstName) \(guest.lastName)"
                mapView.addAnnotation(annotation)
            }
        }
    }
    
    
    
    func updatePolyline(for froop: Froop) {
        if appStateManager.aFHI >= 0 && appStateManager.aFHI < appStateManager.currentFilteredFroopHistory.count {
            let froopHistory = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]
            
            let froopLocation = froopHistory?.froop.froopLocationCoordinate ?? CLLocationCoordinate2D()
            var polylines: [MKPolyline] = []
            
            for guest in froopHistory?.confirmedFriends ?? [] {
                let polyline = makePolyline(from: froopLocation, to: guest.coordinate)
                polylines.append(polyline)
            }
            
            DispatchQueue.main.async {
                self.polyline = MKPolyline()
                // Update customOverlayRenderer with the new polyline
            }
        }
    }
    
    
    func configurePolyline(forGuests guests: [UserData]) {
        PrintControl.shared.printMap("-FroopMapViewRepresentable: Function: configurePolyline is firing!")
        PrintControl.shared.printMap("DAVID - CONFIGURE POLY LINE STARTED")
        
        mapView.removeOverlays(mapView.overlays)
        
        if let froopLocation = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopLocationCoordinate {
            for guest in guests {
                let guestLocation = guest.coordinate
                
                let coordinates = [froopLocation, guestLocation]
                let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
                
                mapView.addOverlay(polyline)
            }
        } else {
            // Handle the case where froopLocation is nil
            PrintControl.shared.printMap("froopLocation is nil")
        }
        
        //self.mapState = .polylineAdded
    }
    
    private func makePolyline(from froopLocation: CLLocationCoordinate2D, to guestLocation: CLLocationCoordinate2D) -> MKPolyline {
        let coordinates = [froopLocation, guestLocation]
        return MKPolyline(coordinates: coordinates, count: coordinates.count)
    }
    
    func calculateDistance(to location: FroopData) -> Double {
        PrintControl.shared.printNavLocationServices("-ActiveMapViewRepresentable: Function: calculateDistance is firing!")
        guard let userLocation = locationManager.userLocation else { return 0 }
        let froopData = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        return userLocation.distance(from: froopData)
    }
    
    class ActiveMapCoordinator: NSObject, MKMapViewDelegate {
        @ObservedObject var viewModel = ActiveMapViewModel.shared
        @ObservedObject var appStateManager = AppStateManager.shared
        @ObservedObject var notificationsManager = NotificationsManager.shared
        let uid = FirebaseServices.shared.uid
        var selectedAnnotationView: MKAnnotationView?
        
        var parentView: UIView?
        var duplicatedImageView: UIImageView?
        var backgroundView: UIView?
        var backgroundView2: UIView?
        var duplicatedAnnotation: MKAnnotationView?
        var callAnnotation: MKAnnotationView?
        var textAnnotation: MKAnnotationView?
        
        var visualEffectView: UIVisualEffectView?
        
        var userLocationCoordinate: CLLocationCoordinate2D?
        
        private var isDarkStyleCancellable: AnyCancellable?
        
        
        init(viewModel: ActiveMapViewModel, annotationImageUrl: String, mapView: MKMapView) {
            self.viewModel = viewModel
            super.init()
            
            // Subscribe to changes in isDarkStyle
            isDarkStyleCancellable = AppStateManager.shared.$isDarkStyle.sink { [weak self] newValue in
                guard let self = self else { return }
                if !newValue {
                    UIView.animate(withDuration: 0.5, animations: {
                        self.visualEffectView?.alpha = 0.0
                        self.parentView?.alpha = 0.0
                        self.backgroundView?.alpha = 0.0
                        self.backgroundView2?.alpha = 0.0
                    }, completion: { _ in
                        self.visualEffectView?.removeFromSuperview()
                        self.parentView?.removeFromSuperview()
                        self.backgroundView?.removeFromSuperview()
                        self.backgroundView2?.removeFromSuperview()
                    })
                }
            }
            
            // Add a tap gesture recognizer to the map view
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleMapTap(_:)))
            viewModel.mapView.addGestureRecognizer(tapGestureRecognizer)
        }
        
        @objc func addAnnotationOnLongPress(gesture: UILongPressGestureRecognizer) {
            if gesture.state == .began {
                PrintControl.shared.printMap("Gesture state is .began")
                
                let point = gesture.location(in: viewModel.mapView)
                let coordinate = viewModel.mapView.convert(point, toCoordinateFrom: viewModel.mapView)
                PrintControl.shared.printMap("Coordinate: \(coordinate.latitude), \(coordinate.longitude)")
                
                // Fetch or define the creatorUID and profileImageUrl values
                let creatorUID = FirebaseServices.shared.uid
                let pinImage = "mappin"
                
                let annotation = FroopDropPin(coordinate: coordinate, title: "", subtitle: "", messageBody: "", color: UIColor.purple, creatorUID: creatorUID, pinImage: pinImage)
                
                viewModel.mapView.addAnnotation(annotation as! MKAnnotation)
                appStateManager.isAnnotationMade = true
                appStateManager.isFroopTabUp = false
                viewModel.annotationModel.annotation = annotation
                
                viewModel.annotations.append(annotation as! MKAnnotation) // Add the new annotation to viewModel.annotations
            }
        }
        
        
        @objc func handleMapTap(_ gesture: UITapGestureRecognizer) {
            // Get the point that was tapped
            let point = gesture.location(in: viewModel.mapView)
            
            // Convert that point to a coordinate
            let coordinate = viewModel.mapView.convert(point, toCoordinateFrom: viewModel.mapView)
            
            // Define the map rect to search within
            let mapPoint = MKMapPoint(coordinate)
            let searchRect = MKMapRect(x: mapPoint.x, y: mapPoint.y, width: 1, height: 1)
            
            // Filter the map's annotations to find those within the search rect
            let tappedAnnotations = viewModel.mapView.annotations.filter { annotation in
                searchRect.contains(MKMapPoint(annotation.coordinate))
            }
            
            // If no annotations were tapped
            if tappedAnnotations.isEmpty {
                // Deselect all currently selected annotations
                for annotation in viewModel.mapView.selectedAnnotations {
                    viewModel.mapView.deselectAnnotation(annotation, animated: true)
                }
            }
        }
        
        func configurePolyline(forGuests guests: [UserData])  {
            PrintControl.shared.printMap("-FroopMapViewRepresentable: Function: configurePolyline is firing!")
            PrintControl.shared.printMap("DAVID - CONFIGURE POLY LINE STARTED")
            
            viewModel.mapView.removeOverlays(viewModel.mapView.overlays)
            
            if let froopLocation = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopLocationCoordinate {
                for guest in guests {
                    let guestLocation = guest.coordinate
                    
                    let coordinates = [froopLocation, guestLocation]
                    let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
                    
                    viewModel.mapView.addOverlay(polyline)
                }
            } else {
                // Handle the case where froopLocation is nil
                PrintControl.shared.printMap("froopLocation is nil")
            }
            
            //self.mapState = .polylineAdded
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if let froopDropPin = annotation as? FroopDropPin {
                let identifier = "FroopDropPin"
                
                // Reuse or create an MKPinAnnotationView
                var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
                if annotationView == nil {
                    annotationView = MKMarkerAnnotationView(annotation: froopDropPin as? MKAnnotation, reuseIdentifier: identifier)
                    annotationView?.canShowCallout = true
                } else {
                    annotationView?.annotation = froopDropPin as? any MKAnnotation
                }
                
                // Set the pin color
                annotationView?.markerTintColor = froopDropPin.color
                
                return annotationView
            }
            
            if let annotation = annotation as? GuestAnnotation {
                let identifier = "GuestAnnotation"
                var view: MKAnnotationView
                if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
                    dequeuedView.annotation = annotation
                    view = dequeuedView
                } else {
                    view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                    view.canShowCallout = false
                }
                
                // Download the image from the URL and set it as the annotation view's image
                if let url = URL(string: annotation.guest.profileImageUrl) {
                    let processor = DownsamplingImageProcessor(size: CGSize(width: 50, height: 50))
                    |> RoundCornerImageProcessor(cornerRadius: 20)
                    KingfisherManager.shared.retrieveImage(with: url, options: [
                        .processor(processor),
                        .scaleFactor(UIScreen.main.scale),
                        .transition(.fade(1)),
                        .cacheOriginalImage
                    ]) { result in
                        switch result {
                            case .success(let value):
                                view.image = value.image
                            case .failure(let error):
                                PrintControl.shared.printErrorMessages("Error: \(error)") // Handle the error
                        }
                    }
                }
                
                return view
                
            }
            return nil
        }
        
        
        
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            
        }
        
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            if let annotation = view.annotation as? MovableAnnotation {
                if control == view.rightCalloutAccessoryView {
                    // Handle the detail disclosure button being tapped
                    let alert = UIAlertController(title: "Edit Annotation", message: nil, preferredStyle: .alert)
                    alert.addTextField { textField in
                        textField.text = annotation.title
                    }
                    alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                        if let newTitle = alert.textFields?.first?.text {
                            annotation.title = newTitle
                        }
                    })
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                    
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                        windowScene.windows.first?.rootViewController?.present(alert, animated: true)
                    }
                } else if control == view.leftCalloutAccessoryView {
                    // Handle the delete button being tapped
                    mapView.removeAnnotation(annotation as! MKAnnotation)
                }
            }
        }
        
        func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
            
            if NavLocationServices.shared.trackActiveUserLocation == false {
                return
            }
            let newCoordinate = userLocation.coordinate
            guard let previousCoordinate = self.userLocationCoordinate else {
                // This is the first location update, so we don't have a previous location to compare with
                self.userLocationCoordinate = newCoordinate
                return
            }
            
            let distance = sqrt(pow(newCoordinate.latitude - previousCoordinate.latitude, 2) + pow(newCoordinate.longitude - previousCoordinate.longitude, 2))
            if distance < 0.00001 { // Adjust this threshold as needed
                                    // The location hasn't changed significantly, so we ignore this update
                return
            }
            
            // The location has changed significantly, so we process this update
            self.userLocationCoordinate = newCoordinate
            
            PrintControl.shared.printNavLocationServices("Previous Location: \(String(describing: previousCoordinate.latitude)), \(String(describing: previousCoordinate.longitude))")
            PrintControl.shared.printMap("New Location: \(newCoordinate.latitude), \(newCoordinate.longitude)")
            
            let region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude),
                span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            )
            
            PrintControl.shared.printNavLocationServices("updating userLocation TOMMY")
            PrintControl.shared.printNavLocationServices((String(describing: appStateManager.appState)))
            self.viewModel.currentRegion = region
            
            viewModel.mapView.setRegion(region, animated: false)
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            PrintControl.shared.printNavLocationServices("-ActiveMapViewRepresentable: Function: mapView2 is firing!")
            let polyline = MKPolylineRenderer(overlay: overlay)
            polyline.strokeColor = (UIColor(red: 249/255, green: 0/255, blue: 98/255, alpha: 0.75))
            polyline.lineWidth = 1
            return polyline
        }
        
        @objc func handleAnnotationTap(_ sender: UITapGestureRecognizer) {
            guard let view = sender.view else { return }
            
            // Animate the removal of the parent view and blur effect
            UIView.animate(withDuration: 0.5, animations: {
                view.alpha = 0.0 // Fade out the parent view
                self.visualEffectView?.alpha = 0.0 // Fade out the blur effect
            }, completion: { _ in
                // Remove the parent view and blur effect from the superview
                view.removeFromSuperview()
                self.visualEffectView?.removeFromSuperview()
                self.visualEffectView = nil
            })
        }
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            selectedAnnotationView = view
            
            if view.annotation is FroopDropPin {
                appStateManager.isAnnotationMade = true
                appStateManager.isFroopTabUp = false
                appStateManager.isDarkStyle = false
                ActiveMapViewModel.shared.annotationModel.annotation = view.annotation as? FroopDropPin
            }
            
            
        }
        
        @objc func callButtonTapped(_ sender: PhoneNumberButton) {
            guard let number = URL(string: "tel://" + (sender.phoneNumber ?? "")) else { return }
            UIApplication.shared.open(number)
        }
        
        @objc func textButtonTapped(_ sender: PhoneNumberButton) {
            // Implement the function to initiate a text conversation
            NotificationCenter.default.post(name: .init("TextButtonTapped"), object: nil, userInfo: ["phoneNumber": sender.phoneNumber ?? ""])
            appStateManager.guestPhoneNumber = sender.phoneNumber ?? "DefaultPhoneNumber"
            appStateManager.isMessageViewPresented = true
            PrintControl.shared.printMap("Text button was tapped") // Temporary placeholder
        }
        
        
        func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
            
            if view == selectedAnnotationView {
                selectedAnnotationView = nil
            }
            PrintControl.shared.printMap("didDeselect called")
            if view.annotation is FroopDropPin {
                appStateManager.isAnnotationMade = false
                appStateManager.isFroopTabUp = true
            }
            
            if view.annotation is GuestAnnotation, let visualEffectView = self.visualEffectView, let duplicatedAnnotation = self.duplicatedAnnotation {
                PrintControl.shared.printMap("GuestAnnotation selected, visualEffectView and duplicatedAnnotation are not nil")
                for subview in mapView.subviews {
                    if subview is UIButton {
                        subview.removeFromSuperview()
                    }
                }
                // Animate the blur effect and the duplicated annotation
                UIView.animate(withDuration: 0.5, animations: {
                    visualEffectView.alpha = 0.0 // Fade out
                    duplicatedAnnotation.transform = CGAffineTransform(scaleX: 1.0, y: 1.0) // Resize
                }, completion: { _ in
                    // Remove the blur effect
                    visualEffectView.removeFromSuperview()
                    self.visualEffectView = nil
                    
                    // Remove the duplicated annotation
                    duplicatedAnnotation.removeFromSuperview()
                    self.duplicatedAnnotation = nil
                    
                    // Update isDarkStyle on the main thread
                    DispatchQueue.main.async {
                        AppStateManager.shared.isDarkStyle = false
                    }
                })
            }
        }
        
        // MARK: - Helpers
        
        func addAndSelectAnnotation(withCoordinate coordinate: CLLocationCoordinate2D) {
            PrintControl.shared.printNavLocationServices("-ActiveMapViewRepresentable: Function: addAndSelectAnnotation is firing!")
            viewModel.mapView.removeAnnotations(viewModel.mapView.annotations)
            viewModel.annotations.removeAll()   // Remove all annotations from viewModel.annotations
            
            let anno = MKPointAnnotation()
            anno.coordinate = viewModel.froopLocation
            viewModel.mapView.addAnnotation(anno)
            viewModel.annotations.append(anno)   // Add the annotation to viewModel.annotations
            viewModel.mapView.selectAnnotation(anno, animated: true)
        }
    }
}


class FroopMapAnnotation: NSObject, MKAnnotation {
    let id: UUID
    dynamic var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var details: FroopDropPin

    init(details: FroopDropPin) {
        self.id = details.id
        self.coordinate = details.coordinate 
        self.title = details.title
        self.subtitle = details.subtitle
        self.details = details
    }
}
