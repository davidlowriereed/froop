//
//  ActiveFlightMapView.swift
//  FroopProof
//
//  Created by David Reed on 10/30/23.
//

import SwiftUI
import MapKit
import Kingfisher
import CoreLocation


struct ActiveFlightMapView: View {
    /// GLOBAL PROPERTIES
    @ObservedObject var locationManager = LocationManager.shared
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var froopManager = FroopManager.shared
    @ObservedObject var mapManager = MapManager.shared
    @ObservedObject var froopHistory: FroopHistory
    @ObservedObject var dataController = DataController.shared
    @ObservedObject var annotationManager = AnnotationManager.shared
    @ObservedObject var timerServices = TimerServices.shared
    @ObservedObject var flightManager = FroopFlightDataManager.shared
    
    /// TRACKING PROPERTIESS
    @State private var mapRegion: MKCoordinateRegion = MKCoordinateRegion.myRegion
    @State var tapLatitude: Double = 0.0
    @State var tapLongitude: Double = 0.0
    @State var mapPositionX: Double = 0.0
    @State var mapPositionY: Double = 0.0
    @State private var selectedMarkerId: String?
    @State var distance: Double = 0.0
    @State private var userLocation: CLLocationCoordinate2D?
    @State var offset: CGFloat = 0
    @State var lastStoredOffset: CGFloat = 0
    @GestureState var gesturOffSet: CGFloat = 0
    @State private var equatableCenter: EquatableCoordinate = EquatableCoordinate(coordinate: MKCoordinateRegion.myRegion.center)
    
    /// STATE PROPERTIES
    @State var friendDetailOpen: Bool = false
    @State private var isMapDraggable = true
    @State private var mapSelection: String?
    private var shouldShowAnnotations: Bool {
        mapManager.tapLatitudeDelta < 0.008
    }
    
    
    /// Route Properties
    @State private var routeDisplaying: Bool = false
    @State private var route: MKRoute?
    @State private var routeDestination: MKMapItem?
    @State var makeNewPin: Bool = false

    /// LEGACY
    @State private var cameraPosition: MapCameraPosition = .region(.myRegion)
    @State var tapLatitudeDelta: Double = 0.0
    @State var tapLongitudeDelta: Double = 0.0
    @State private var centerLatitude: Double = 0.0
    @State private var centerLongitude: Double = 0.0
    @State var showMenu: Bool = false
    @State var newPin: FroopDropPin = FroopDropPin()
    
    /// OTHER PROPERTIES
    @Namespace private var locationSpace
    @Binding var globalChat: Bool
//    @Binding var selectedUser: UserData?
    @State private var rerun = UUID()
    
    var flightPathCoordinates: [CLLocationCoordinate2D] {
        let start = CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437) // Los Angeles
        let end = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060) // New York
                                                                                 // Simulating a direct line path for simplicity
        return [start, end]
    }
    
    @State var flightDeparting: ScheduledFlightAPI.FlightDetail = ScheduledFlightAPI.FlightDetail.empty()
    @State var flightArriving: ScheduledFlightAPI.FlightDetail = ScheduledFlightAPI.FlightDetail.empty()
    
    @State var departureCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
    @State var planeLocationCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
    @State var arrivalCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
    var now = Date()
    
    private var shouldDisplayFlightInfo: Bool {
        appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopType == 5009
    }
    
    init(froopHistory: FroopHistory, globalChat: Binding <Bool>) {
        UITabBar.appearance().isHidden = true
        self.froopHistory = FroopHistory(
            froop: Froop(dictionary: [:]) ?? Froop(dictionary: [:]) ?? Froop.emptyFroop(),
            host: UserData(),
            invitedFriends: [],
            confirmedFriends: [],
            declinedFriends: [],
            pendingFriends: [],
            images: [],
            videos: [],
            froopGroupConversationAndMessages: ConversationAndMessages(conversation: Conversation(), messages: [], participants: []), froopMediaData: FroopMediaData(
                froopImages: [],
                froopDisplayImages: [],
                froopThumbnailImages: [],
                froopIntroVideo: "",
                froopIntroVideoThumbnail: "",
                froopVideos: [],
                froopVideoThumbnails: []
            ),
            flightData: ScheduledFlightAPI.FlightDetail.empty()
        )
        _globalChat = globalChat
    }
    
    var body: some View {
        
        if appStateManager.aFHI >= 0 && appStateManager.aFHI < appStateManager.currentFilteredFroopHistory.count {
            
            MapReader { reader in
                Map(position: $mapManager.cameraPosition, interactionModes: isMapDraggable ? .all : [], selection: $mapSelection) {
                    
                    Marker(flightDeparting.departure?.airport.iata ?? "", systemImage: "airplane.circle", coordinate: CLLocationCoordinate2D(latitude: flightDeparting.departure?.airport.location.lat ?? 0.0, longitude: flightDeparting.departure?.airport.location.lon ?? 0.0))
                        .tint(.orange)
                    Marker(
                        flightArriving.arrival?.airport.iata ?? "",
                        systemImage: "airplane.circle",
                        coordinate: CLLocationCoordinate2D(latitude: flightArriving.arrival?.airport.location.lat ?? 0.0, longitude: flightArriving.arrival?.airport.location.lon ?? 0.0)
                    )
                        .tint(.green)
                    
                    Marker(appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.flightData.number ?? "",
                           systemImage: "airplane.circle",
                           coordinate: CLLocationCoordinate2D(latitude: planeLocationCoordinate.latitude, longitude: planeLocationCoordinate.longitude)
                    )
                        .tint(.blue)

                    if mapManager.departureToPlane != [] {
                        MapPolyline(coordinates: mapManager.departureToPlane)
                            .stroke(Color(red: 255/255, green: 49/255, blue: 97/255), lineWidth: 5)
                        
                        MapPolyline(coordinates: mapManager.planeToArrival)
                            .stroke(Color(red: 255/255, green: 49/255, blue: 97/255), lineWidth: 5)
                        
                    }
                }
                .frame(width: UIScreen.screenWidth, height: UIScreen.screenHeight)
                .mapStyle(.standard(elevation: .automatic))
                .onAppear {
//                    flightManager.fetchAirlineioData(flightNumber: "33", airlineCode: "DL", date: "20231024") { result in
//                        switch result {
//                            case .success(let data):
//                                flightManager.flightioData = data
//                                print("🦁🐯 \(data)")
//                            case .failure(_):
//                                print("🦁 data didn't load")
//                        }
//                    }
                    flightManager.fetchActiveFlightData(flightIata: appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.flightData.number) { result in
                        DispatchQueue.main.async { // Ensuring we're on the main thread
                            switch result {
                                case .success(let flights):
                                    print("Flights: \(flights)")
                                    if let firstFlight = flights.first {
                                        flightManager.activeFlight = firstFlight

                                        flightDeparting = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.flightData ?? ScheduledFlightAPI.FlightDetail.empty()
                                        flightArriving = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.flightData ?? ScheduledFlightAPI.FlightDetail.empty()

                                        departureCoordinate = CLLocationCoordinate2D(latitude: flightDeparting.departure?.airport.location.lat ?? 0.0, longitude: flightDeparting.departure?.airport.location.lon ?? 0.0)
                                        planeLocationCoordinate = CLLocationCoordinate2D(latitude: flightManager.activeFlight.geography?.latitude ?? 0.0, longitude: flightManager.activeFlight.geography?.longitude ?? 0.0)
                                        arrivalCoordinate = CLLocationCoordinate2D(latitude: flightArriving.arrival?.airport.location.lat ?? 0.0, longitude: flightArriving.arrival?.airport.location.lon ?? 0.0)
                                        
                                        mapManager.departureToPlane = mapManager.greatCircleCoordinates(from: departureCoordinate, to: planeLocationCoordinate, steps: 100)
                                        mapManager.planeToArrival = mapManager.greatCircleCoordinates(from: planeLocationCoordinate, to: arrivalCoordinate, steps: 100)
                                        
                                        flightManager.startFetchingFlightData(flightIata: flightManager.activeFlight.flight?.iataNumber ?? "")
                                    }

                                case .failure(let error):
                                    print("Error: \(error.localizedDescription)")
                            }
                        }
                    }
                    flightDeparting = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.flightData ?? ScheduledFlightAPI.FlightDetail.empty()
                    flightArriving = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.flightData ?? ScheduledFlightAPI.FlightDetail.empty()
                    flightManager.thisFlightStart = flightStartTime() ?? Date()
                    flightManager.thisFlightEnd = flightEndTime() ?? Date()
                    
                    departureCoordinate = CLLocationCoordinate2D(latitude: flightDeparting.departure?.airport.location.lat ?? 0.0, longitude: flightDeparting.departure?.airport.location.lon ?? 0.0)
                    planeLocationCoordinate = CLLocationCoordinate2D(latitude: flightManager.activeFlight.geography?.latitude ?? 0.0, longitude: flightManager.activeFlight.geography?.longitude ?? 0.0)
                    arrivalCoordinate = CLLocationCoordinate2D(latitude: flightArriving.arrival?.airport.location.lat ?? 0.0, longitude: flightArriving.arrival?.airport.location.lon ?? 0.0)
                    
                    if now < flightManager.thisFlightStart {
                        mapManager.departureToPlane = mapManager.greatCircleCoordinates(from: departureCoordinate, to: arrivalCoordinate, steps: 200)
                    } else {
                        mapManager.departureToPlane = mapManager.greatCircleCoordinates(from: departureCoordinate, to: planeLocationCoordinate, steps: 100)
                        mapManager.planeToArrival = mapManager.greatCircleCoordinates(from: planeLocationCoordinate, to: arrivalCoordinate, steps: 100)
                    }
                    
                   
                    
                    mapManager.departureToPlane = mapManager.greatCircleCoordinates(from: departureCoordinate, to: planeLocationCoordinate, steps: 100)
                    mapManager.planeToArrival = mapManager.greatCircleCoordinates(from: planeLocationCoordinate, to: arrivalCoordinate, steps: 100)
                    
                    timerServices.shouldUpdateAnnotations = true
                    if let center = MapManager.shared.cameraPosition.region?.center {
                        MapManager.shared.centerLatitude = center.latitude
                        MapManager.shared.centerLongitude = center.longitude
                    }
                    MapManager.shared.startListeningForFroopPins()
                    
                    let froopLocation = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopLocationCoordinate ?? CLLocationCoordinate2D()
                    let myLocation = MyData.shared.coordinate // Directly accessing the property
                    
                    if appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopType ?? 0 == 5009 {
                        let midpoint = MapManager.shared.midpointBetween(coordinate1: departureCoordinate, coordinate2: arrivalCoordinate)
                        let span = MapManager.shared.spanToInclude(coordinate1: planeLocationCoordinate, coordinate2: arrivalCoordinate)
                        let region = MKCoordinateRegion(center: midpoint, span: span)
                        withAnimation(.easeInOut(duration: 1.0)) {
                            MapManager.shared.cameraPosition = .region(region)
                        }
                    } else {
                        let midpoint = MapManager.shared.midpointBetween(coordinate1: froopLocation, coordinate2: myLocation)
                        let span = MapManager.shared.spanToInclude(coordinate1: froopLocation, coordinate2: myLocation)
                        let region = MKCoordinateRegion(center: midpoint, span: span)
                        withAnimation(.easeInOut(duration: 1.0)) {
                            MapManager.shared.cameraPosition = .region(region)
                        }
                    }
                   
                    
                    Task {
                        await locationManager.startLiveLocationUpdates()
                    }
                    timerServices.startAnnotationTimer()
                    mapSelection = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopId
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        // Ensure user location is available before fetching the route
                        if locationManager.userLocation != nil {
                            fetchRoute()
                        } else {
                            PrintControl.shared.printMap("💥User location is nil, cannot fetch route")
                        }
                    }
                    if appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopType == 5009 {
                        setInitialRegion()
                    }
                    PrintControl.shared.printMap("🔥 Map On Appear Firing")
                }
                .navigationTitle("\(appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopName ?? "")")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
                .onChange(of: planeLocationCoordinate) { oldValue, newValue in
                    if appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopType ?? 0 == 5009 {
                        let midpoint = MapManager.shared.midpointBetween(coordinate1: planeLocationCoordinate, coordinate2: arrivalCoordinate)
                        let span = MapManager.shared.spanToInclude(coordinate1: planeLocationCoordinate, coordinate2: arrivalCoordinate)
                        let region = MKCoordinateRegion(center: midpoint, span: span)
                        withAnimation(.easeInOut(duration: 1.0)) {
                            MapManager.shared.cameraPosition = .region(region)
                        }
                    } else {
                        let froopLocation = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopLocationCoordinate ?? CLLocationCoordinate2D()
                        let myLocation = MyData.shared.coordinate // Directly accessing the property
                        let midpoint = MapManager.shared.midpointBetween(coordinate1: froopLocation, coordinate2: myLocation)
                        let span = MapManager.shared.spanToInclude(coordinate1: froopLocation, coordinate2: myLocation)
                        let region = MKCoordinateRegion(center: midpoint, span: span)
                        withAnimation(.easeInOut(duration: 1.0)) {
                            MapManager.shared.cameraPosition = .region(region)
                        }
                    }
                }
                .onDisappear {
                    timerServices.shouldUpdateAnnotations = false
                    flightManager.stopFetchingFlightData()
                }
            }
        }
    }
    
    func flightStartTime() -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mmZ"
        
        guard let departureDate = formatter.date(from: self.appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.flightData.departure?.scheduledTime.utc ?? "") else {
            print("Error parsing dates")
            return nil
        }
        return departureDate
    }
    
    func flightEndTime() -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mmZ"
        
        guard let arrivalDate = formatter.date(from: self.appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.flightData.arrival?.scheduledTime.utc ?? "") else {
            print("Error parsing dates")
            return nil
        }
        return arrivalDate
    }
    
    private func setInitialRegion() {
           // Example coordinates for departure and arrival
           let departureCoordinate = CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437) // Los Angeles
           let arrivalCoordinate = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060) // New York

           // Calculate the midpoint
           let midpointLatitude = (departureCoordinate.latitude + arrivalCoordinate.latitude) / 2
           let midpointLongitude = (departureCoordinate.longitude + arrivalCoordinate.longitude) / 2
           let midpoint = CLLocationCoordinate2D(latitude: midpointLatitude, longitude: midpointLongitude)

           // Calculate the span
           let latitudeDelta = abs(departureCoordinate.latitude - arrivalCoordinate.latitude) * 1.5 // 50% padding
           let longitudeDelta = abs(departureCoordinate.longitude - arrivalCoordinate.longitude) * 1.5 // 50% padding

           // Set the region
           mapManager.mapRegion = MKCoordinateRegion(
               center: midpoint,
               span: MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
           )
       }
    
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
            mapManager.showPinDetailsView = false
            MapManager.shared.newPinCreation = true
            MapManager.shared.showSavePinView = true
            MapManager.shared.tabUp = false
            appStateManager.appStateToggle = true
            print("appStateToggle 6")

        }
    }
    
    func onWazeButtonTapped() {
        MapManager.shared.openWaze()
    }
    
    func focusOnPin(_ pin: FroopDropPin) {
        let newRegion = MKCoordinateRegion(center: pin.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        withAnimation(.easeInOut(duration: 0.5)) {
            mapManager.cameraPosition = .region(newRegion)
        }
    }
    
    func cycleThroughPins() {
        annotationManager.cycleToNextPin()
        guard !MapManager.shared.froopPins.isEmpty else { return }
        
        // Assuming cycleToNextPin() updates currentPinIndex appropriately
        let pin = MapManager.shared.froopPins[annotationManager.currentPinIndex]
        focusOnPin(pin)
    }
    
    func cycleThroughGuestsAndHost() {
        annotationManager.cycleToNextGuest()
        guard !annotationManager.guestAnnotations.isEmpty else { return }
        
        // Assuming cycleToNextGuest() updates currentGuestIndex appropriately
        let nextGuest = annotationManager.guestAnnotations[annotationManager.currentGuestIndex]
        annotationManager.zoomToLocation(nextGuest.coordinate)
    }
    
    func createNewDropPin() {
        if let currentLocation = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopLocationCoordinate {
            // Calculate the new latitude 100 meters to the north
            let metersNorth = 100.0
            let degreeDistance = metersNorth / 111000 // degrees per meter
            
            let newLatitude = currentLocation.latitude + degreeDistance
            let newCoordinate = CLLocationCoordinate2D(latitude: newLatitude, longitude: currentLocation.longitude)
            
            MapManager.shared.froopDropPin = FroopDropPin(coordinate: newCoordinate, title: "", subtitle: "", pinImage: "mappin.circle.fill")
        }
        makeNewPin = true
    }
    
    func updatePinLocation(to newCoordinate: CLLocationCoordinate2D) {
        MapManager.shared.froopDropPin.coordinate = newCoordinate
    }
    
    func fetchRoute() {
        let departure = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.flightData.departure?.airport ?? ScheduledFlightAPI.AirportDetails.empty()
        let arrival = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.flightData.arrival?.airport ?? ScheduledFlightAPI.AirportDetails.empty()

        let departureCoordinate = CLLocationCoordinate2D(latitude: departure.location.lat , longitude: departure.location.lon )
        let arrivalCoordinate = CLLocationCoordinate2D(latitude: arrival.location.lat , longitude: arrival.location.lon )
        
        // Assuming you have a source location, if not, you'll need to fetch it
        let sourceCoordinate = departureCoordinate
        let sourceMapItem = MKMapItem(placemark: MKPlacemark(coordinate: sourceCoordinate))
        
        let destinationCoordinate = arrivalCoordinate
        
        let request = MKDirections.Request()
        request.source = sourceMapItem
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destinationCoordinate))
        
        Task {
            do {
                let response = try await MKDirections(request: request).calculate()
                route = response.routes.first
                routeDestination = mapManager.routeDestination
                
                withAnimation(.snappy) {
                    routeDisplaying = true
                }
            } catch {
                PrintControl.shared.printMap("💥Failed to calculate route: \(error)")
            }
        }
    }
    
    func midpointBetween(coordinate1: CLLocationCoordinate2D, coordinate2: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        let latitude = (coordinate1.latitude + coordinate2.latitude) / 2
        let longitude = (coordinate1.longitude + coordinate2.longitude) / 2
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    func spanToInclude(coordinate1: CLLocationCoordinate2D, coordinate2: CLLocationCoordinate2D) -> MKCoordinateSpan {
        let maxLatitude = max(abs(coordinate1.latitude - coordinate2.latitude), abs(coordinate1.longitude - coordinate2.longitude))
        let span = maxLatitude * 1.5 // Adjust the multiplication factor to add padding
        return MKCoordinateSpan(latitudeDelta: span, longitudeDelta: span)
    }
    
    func latitudeDeltaFromDrag(point: CGPoint, mapCenter: CLLocationCoordinate2D, mapSpan: MKCoordinateSpan, screenSize: CGSize) -> Double {
        let tapLatitudeDelta = mapSpan.latitudeDelta / screenSize.height
        let centerScreenPoint = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
        let screenOffsetY = point.y - centerScreenPoint.y
        let latitudeOffset = screenOffsetY * tapLatitudeDelta
        return latitudeOffset
    }
    
}





///OLDER CLASSES



