//
//  ActiveMapView.swift
//  FroopProof
//
//  Created by David Reed on 10/30/23.
//

import SwiftUI
import MapKit
import Kingfisher
import CoreLocation


struct ActiveMapView: View {
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
    @ObservedObject var flightTimeManager = FlightTimeManager.shared
    
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
    @State var flightFocused: Bool = false
    @State var leaveTimer: String = ""
    
    /// Route Properties
    @State private var routeDisplaying: Bool = false
    @State private var route: MKRoute?
    @State private var routeDestination: MKMapItem?
    @State var makeNewPin: Bool = false
    @State var flightDeparting: ScheduledFlightAPI.FlightDetail = ScheduledFlightAPI.FlightDetail.empty()
    @State var flightArriving: ScheduledFlightAPI.FlightDetail = ScheduledFlightAPI.FlightDetail.empty()
    
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

                    if MapManager.shared.newPinCreation {
                        Annotation("by: \(MyData.shared.firstName) \(MyData.shared.lastName)", coordinate: MapManager.shared.froopDropPin.coordinate) {
                            NewFroopPin(froopDropPin: MapManager.shared.froopDropPin)
                        }
                    }
                    
                    if shouldShowAnnotations {
                        ForEach(MapManager.shared.froopPins, id: \.id) { pin in
                            Annotation("", coordinate: pin.coordinate) {
                                CreatedFroopPin(froopDropPin: pin)
                            }
                            .tag(pin.id)
                        }
                    }
                    
                    if appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopType == 5009 {
                        
                        Marker(flightDeparting.departure?.airport.iata ?? "", systemImage: "airplane.circle", coordinate: CLLocationCoordinate2D(latitude: flightDeparting.departure?.airport.location.lat ?? 0.0, longitude: flightDeparting.departure?.airport.location.lon ?? 0.0))
                            .tint(.orange)
                        
                        Marker(
                            flightArriving.arrival?.airport.iata ?? "",
                            systemImage: "airplane.circle",
                            coordinate: CLLocationCoordinate2D(latitude: flightArriving.arrival?.airport.location.lat ?? 0.0, longitude: flightArriving.arrival?.airport.location.lon ?? 0.0)
                        )
                        .tint(.green)
                        
                        Annotation(appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.flightData.number ?? "", coordinate: CLLocationCoordinate2D(latitude: planeLocationCoordinate.latitude,longitude: planeLocationCoordinate.longitude)) {
                            
                            PlaneAnnotationView(departureCoordinate: CLLocationCoordinate2D(latitude: planeLocationCoordinate.latitude,longitude: planeLocationCoordinate.longitude), arrivalCoordinate: CLLocationCoordinate2D(latitude: flightArriving.arrival?.airport.location.lat ?? 0.0, longitude: flightArriving.arrival?.airport.location.lon ?? 0.0))
                                .onTapGesture {
                                    annotationManager.trackingUser = false
                                    // Safely unwrap the current center of the camera position
                                    withAnimation(.easeInOut(duration: 1.0)) {
                                        // Calculate the offset to move the center upwards
                                        let planeLoc = CLLocationCoordinate2D(latitude: planeLocationCoordinate.latitude,longitude: planeLocationCoordinate.longitude)
                                        // Adjust the center point upwards
                                        let adjustedCenter = CLLocationCoordinate2D(
                                            latitude: planeLoc.latitude,
                                            longitude: planeLoc.longitude
                                        )
                                        
                                        // Create a new region with the adjusted center
                                        
                                        let adjustedRegion = MKCoordinateRegion(
                                            center: adjustedCenter,
                                            latitudinalMeters: 100000,
                                            longitudinalMeters: 100000
                                        )
                                        
                                        MapManager.shared.cameraPosition = .region(adjustedRegion)
                                    }
                                }
                        }
                        
                        if mapManager.departureToPlane != [] {
                            MapPolyline(coordinates: mapManager.departureToPlane)
                                .stroke(Color(red: 255/255, green: 49/255, blue: 97/255), lineWidth: 3)
                            
                            MapPolyline(coordinates: mapManager.planeToArrival)
                                .stroke(.blue, lineWidth: 3)
                            
                        }
                    }
                    
                    ForEach(annotationManager.guestAnnotations, id: \.froopUserID) { participant in
                        Annotation(participant.firstName, coordinate: participant.coordinate) {
                            ActiveGuestAnnotation(guest: participant, globalChat: $globalChat)
                                .id(participant.froopUserID)
                        }
                    }
                    
                    // MARK: Froop Annotation
                    Marker(appStateManager.currentFilteredFroopHistory[appStateManager.aFHI].froop.froopLocationtitle, coordinate: appStateManager.currentFilteredFroopHistory[appStateManager.aFHI].froop.froopLocationCoordinate )
                        .tint(Color(red: 249/255, green: 0/255, blue: 98/255))
                        .tag(appStateManager.currentFilteredFroopHistory[appStateManager.aFHI].froop.froopId)
                    
                    if let route {
                        MapPolyline(route.polyline)
                            .stroke(Color(red: 255/255, green: 49/255, blue: 97/255), lineWidth: 5)
                    }
                    
                }
                .frame(width: UIScreen.screenWidth, height: UIScreen.screenHeight)
                .opacity(appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopId == nil ? 0.5 : 1)
                .onChange(of: mapSelection) { oldValue, newValue in
                    if let selectedId = newValue, selectedId != selectedMarkerId {
                        selectedMarkerId = selectedId
                        if let selectedPin = MapManager.shared.froopPins.first(where: { $0.id.uuidString == selectedId }) {
                            annotationManager.zoomToLocation(selectedPin.coordinate)
                        }
                    }
                }
                .mapStyle(.standard(elevation: .automatic))
                .onMapCameraChange { mapCameraUpdateContext in
                    mapManager.tapLatitude = mapCameraUpdateContext.camera.centerCoordinate.latitude
                    mapManager.tapLongitude = mapCameraUpdateContext.camera.centerCoordinate.longitude
                    mapManager.tapLatitudeDelta = mapCameraUpdateContext.region.span.latitudeDelta
                    mapManager.tapLongitudeDelta = mapCameraUpdateContext.region.span.longitudeDelta
                    print("\(mapCameraUpdateContext.camera.centerCoordinate)")
                    print("\(mapCameraUpdateContext.region)")
                }
                .onTapGesture(perform: { screenCoord in
                    annotationManager.trackingUser = false
                    if MapManager.shared.newPinCreation {
                        let pinLocation = reader.convert(screenCoord, from: .local)
                        tapLatitude = pinLocation?.latitude ?? 0.0
                        tapLongitude = pinLocation?.longitude ?? 0.0
                        MapManager.shared.froopDropPin.coordinate = pinLocation ?? CLLocationCoordinate2D()
                        print(pinLocation as Any)
                    }
                })
                .onChange(of: equatableCenter) {
                    MapManager.shared.centerLatitude = equatableCenter.coordinate.latitude
                    MapManager.shared.centerLongitude = equatableCenter.coordinate.longitude
                }
                .task {
                    if appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopType != 5009 {
                        await MapManager.shared.loadRouteDestination()
                    }
                }
                .onAppear {
                    flightTimeManager.flightData = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.flightData ?? ScheduledFlightAPI.FlightDetail.empty()
                    if let currentLocation = LocationManager.shared.currentLocation?.coordinate {
                        flightTimeManager.setUserDepartureTime(from: currentLocation, to: departureCoordinate)
                    }
                    timerServices.shouldUpdateAnnotations = true
                    if let center = MapManager.shared.cameraPosition.region?.center {
                        MapManager.shared.centerLatitude = center.latitude
                        MapManager.shared.centerLongitude = center.longitude
                    }
                    let froopLocation = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopLocationCoordinate ?? CLLocationCoordinate2D()
                    let myLocation = MyData.shared.coordinate // Directly accessing the property
                    
                    if appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopType ?? 0 == 5009 {
                        flightFocused = true
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
                        flightManager.thisFlightStart = self.flightStartTime() ?? Date()
                        flightManager.thisFlightEnd = self.flightEndTime() ?? Date()
                        
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
                    
                    MapManager.shared.startListeningForFroopPins()
                    
                    Task {
                        await locationManager.startLiveLocationUpdates()
                    }
                    
                    timerServices.startAnnotationTimer()
                    
                    mapSelection = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopId ?? ""
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        // Ensure user location is available before fetching the route
                        if locationManager.userLocation != nil {
                            fetchRoute()
                        } else {
                            PrintControl.shared.printMap("💥User location is nil, cannot fetch route")
                        }
                    }
                    PrintControl.shared.printMap("🔥 Map On Appear Firing")
                }
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
                .overlay {
                    
                    VStack {
                        HStack {
                            Spacer()
                            if appStateManager.currentFilteredFroopHistory[appStateManager.aFHI].froop.froopType == 5009 {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 15)
                                    
                                        .foregroundColor(.white)
                                        .background(
                                            RoundedRectangle(cornerRadius: 15)
                                                .fill(.ultraThinMaterial)
                                        )
                                        .opacity(0.5)
                                    
                                    HStack {
                                        VStack (alignment: .leading, spacing: 5) {
                                            Text("Flight: \(appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.flightData.number ?? "")")
                                                .font(.system(size: 14))
                                                .fontWeight(.semibold)
                                                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                            
                                            Text("Leave in: \(flightTimeManager.formattedTimeUntilLeaving) Min")
                                                .font(.system(size: 14))
                                                .fontWeight(.semibold)
                                                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                            
                                            Spacer()
                                        }
                                        Spacer()
                                    }
                                    .padding(.top, 10)
                                    .padding(.leading, 10)

                                    
                                }
                                .frame(width: UIScreen.screenWidth * 0.4, height: UIScreen.screenWidth * 0.3)
                                .padding(.top, 125)
                                .padding(.trailing, 20)
                            }
                        }
                        
                        Spacer()
                        
                        HStack {
                            VStack {
                                
                                ZStack {
                                    Image(systemName: "circle.fill")
                                        .font(.system(size: 34))
                                        .foregroundColor(.white)
                                        .background(.ultraThinMaterial)
                                        .clipShape(.rect(cornerRadius: 10))
                                    
                                    Image(systemName: "location.circle.fill")
                                        .font(.system(size: 34))
                                        .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255))
                                    
                                }
                                .padding(.bottom, 5)
                                .onTapGesture {
                                    flightFocused = false
                                    // Safely unwrap the current center of the camera position
                                    if let currentCenter = mapManager.cameraPosition.region?.center {
                                        mapManager.centerLatitude = currentCenter.latitude
                                        mapManager.centerLongitude = currentCenter.longitude
                                    }
                                    
                                    // Safely unwrap the froop location and use a default coordinate if nil
                                    let froopLocation = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopLocationCoordinate ?? CLLocationCoordinate2D()
                                    let myLocation = MyData.shared.coordinate // Assuming this is always valid
                                    
                                    // Calculate midpoint and span
                                    let midpoint = mapManager.midpointBetween(coordinate1: froopLocation, coordinate2: myLocation)
                                    let span = mapManager.spanToInclude(coordinate1: froopLocation, coordinate2: myLocation)
                                    
                                    // Create a new region and update the camera position
                                    let region = MKCoordinateRegion(center: midpoint, span: span)
                                    withAnimation(.easeInOut(duration: 1.0)) {
                                        mapManager.cameraPosition = .region(region)
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                                        // Ensure user location is available before fetching the route
                                        if locationManager.userLocation != nil {
                                            fetchRoute()
                                        } else {
                                            PrintControl.shared.printMap("💥User location is nil, cannot fetch route")
                                        }
                                    }
                                }
                                //
                                ZStack {
                                    Image(systemName: "circle.fill")
                                        .font(.system(size: 34))
                                        .foregroundColor(.white)
                                        .background(.ultraThinMaterial)
                                        .clipShape(.rect(cornerRadius: 10))
                                    
                                    Image(systemName: "f.circle.fill")
                                        .font(.system(size: 34))
                                        .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255))
                                    
                                }
                                .padding(.bottom, 5)
                                .onTapGesture {
                                    flightFocused = false
                                    
                                    annotationManager.trackingUser = false
                                    // Safely unwrap the current center of the camera position
                                    withAnimation(.easeInOut(duration: 1.0)) {
                                        // Calculate the offset to move the center upwards
                                        let froopLoc = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopLocationCoordinate ?? CLLocationCoordinate2D()
                                        // Adjust the center point upwards
                                        let adjustedCenter = CLLocationCoordinate2D(
                                            latitude: froopLoc.latitude,
                                            longitude: froopLoc.longitude
                                        )
                                        
                                        // Create a new region with the adjusted center
                                        
                                        let adjustedRegion = MKCoordinateRegion(
                                            center: adjustedCenter,
                                            latitudinalMeters: 250,
                                            longitudinalMeters: 250
                                        )
                                        DispatchQueue.main.asyncAfter(deadline: .now()) {
                                            // Ensure user location is available before fetching the route
                                            if locationManager.userLocation != nil {
                                                fetchRoute()
                                            } else {
                                                PrintControl.shared.printMap("💥User location is nil, cannot fetch route")
                                            }
                                        }
                                        
                                        MapManager.shared.cameraPosition = .region(adjustedRegion)
                                    }
                                }
                                
                                ZStack {
                                    Image(systemName: "circle.fill")
                                        .font(.system(size: 34))
                                        .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255))
                                        .background(Material.ultraThinMaterial)
                                        .clipShape(.rect(cornerRadius: 10))
                                    
                                    Image(systemName: "person.and.arrow.left.and.arrow.right")
                                        .font(.system(size: 20))
                                        .foregroundColor(.white)
                                    
                                }
                                .padding(.bottom, 5)
                                .onTapGesture {
                                    flightFocused = false
                                    
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        cycleThroughGuestsAndHost()
                                        annotationManager.trackingUser = true
                                    }
                                }
                                if appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopType == 5009 {
                                    ZStack {
                                        Image(systemName: "circle.fill")
                                            .font(.system(size: 34))
                                            .foregroundColor(.white)
                                            .background(.ultraThinMaterial)
                                            .clipShape(.rect(cornerRadius: 10))
                                        
                                        Image(systemName: "airplane.circle.fill")
                                            .font(.system(size: 34))
                                            .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255))
                                            .clipShape(.rect(cornerRadius: 10))
                                        
                                    }
                                    .padding(.bottom, 5)
                                    .onTapGesture {
                                        flightFocused = true
                                        withAnimation(.easeInOut(duration: 0.5)) {
                                            let midpoint = MapManager.shared.midpointBetween(coordinate1: planeLocationCoordinate, coordinate2: arrivalCoordinate)
                                            let span = MapManager.shared.spanToInclude(coordinate1: planeLocationCoordinate, coordinate2: arrivalCoordinate)
                                            let region = MKCoordinateRegion(center: midpoint, span: span)
                                            withAnimation(.easeInOut(duration: 1.0)) {
                                                MapManager.shared.cameraPosition = .region(region)
                                            }
                                            
                                        }
                                    }
                                }
                                
                                if mapManager.froopPins.count > 0 {
                                    ZStack {
                                        Image(systemName: "circle.fill")
                                            .font(.system(size: 34))
                                            .foregroundColor(.white)
                                            .background(.ultraThinMaterial)
                                            .clipShape(.rect(cornerRadius: 5))
                                        
                                        Image(systemName: "mappin.circle.fill")
                                            .font(.system(size: 34))
                                            .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255))
                                        
                                        Image(systemName: "arrow.left.and.line.vertical.and.arrow.right")
                                            .font(.system(size: 20))
                                            .foregroundColor(.white)
                                    }
                                    .onTapGesture {
                                        flightFocused = false
                                        
                                        annotationManager.trackingUser = false
                                        cycleThroughPins()
                                    }
                                }
                                
                            }
                            
                            Spacer()
                            
                        }
                    }
                    .padding(.bottom, 150)
                    .padding(.leading, 20)
                }
                .navigationTitle("\(appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopName ?? "")")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
                .onDisappear {
                    timerServices.shouldUpdateAnnotations = false
                }
            }
            .onAppear {
                annotationManager.updateAnnotations(with: appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.confirmedFriends ?? [])
            }
        }
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
            print("appStateToggle 5")

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
    
}

///OLDER CLASSES

class MovableAnnotationView: MKAnnotationView {
    var newCenter: CGPoint?
}

class GuestAnnotation: NSObject, MKAnnotation, MovableAnnotation {
    var guest: UserData
    @objc dynamic var coordinate: CLLocationCoordinate2D
    var title: String?
    
    init(guest: UserData) {
        self.guest = guest
        self.coordinate = guest.coordinate
        self.title = "\(guest.firstName) \(guest.lastName)"
        super.init()
    }
}

class PhoneNumberButton: UIButton {
    var phoneNumber: String?
}

class AnnotationModel: ObservableObject {
    @Published var annotation: FroopDropPin?
}

struct EquatableCoordinate: Equatable {
    let coordinate: CLLocationCoordinate2D
    
    static func == (lhs: EquatableCoordinate, rhs: EquatableCoordinate) -> Bool {
        return lhs.coordinate.latitude == rhs.coordinate.latitude &&
        lhs.coordinate.longitude == rhs.coordinate.longitude
    }
}



