//
//  PassiveMapView.swift
//  FroopProof
//
//  Created by David Reed on 1/19/23.
//

import SwiftUI
import MapKit
import CoreLocation
import Kingfisher
import SwiftUIBlurView



struct PassiveMapView: View {
    @Environment(\.colorScheme) var colorScheme
    
    /// GLOBAL PROPERTIES
    @ObservedObject var locationManager = LocationManager.shared
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var froopManager = FroopManager.shared
    @ObservedObject var mapManager = MapManager.shared
    @ObservedObject var froopHistory: FroopHistory
    @ObservedObject var dataController = DataController.shared
    @ObservedObject var annotationManager = AnnotationManager.shared
    @ObservedObject var timerServices = TimerServices.shared
    @ObservedObject var timeZoneManager = TimeZoneManager.shared
    @ObservedObject var navLocationServices = NavLocationServices.shared
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
    @State var flightFocused: Bool = false
    private var shouldShowAnnotations: Bool {
        mapManager.tapLatitudeDelta < 0.008
    }
    @State var isShowing: Bool = false
    @State private var showNavigationDropdown = false

    
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
    @State private var showAddPinAlert = false
    @State private var newPinTitle = ""
    @State var departureCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
    @State var planeLocationCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
    @State var arrivalCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
    
    init(froopHistory: FroopHistory, globalChat: Binding <Bool>) {
        UITabBar.appearance().isHidden = true
        self.froopHistory = FroopHistory(
            froop: Froop(dictionary: [:]) ?? Froop.emptyFroop(),
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
    @State private var now = Date()
    
    var timeUntilNextFroop: TimeInterval? {
        
        let thisFroop = froopManager.selectedFroopHistory.froop
        
        return thisFroop.froopStartTime.timeIntervalSince(now)
    }
    
    var countdownText: String {
        if let timeUntilNextFroop = timeUntilNextFroop {
            // Use the formatDuration2 function from the timeZoneManager
            return "\(timeZoneManager.formatDuration2(durationInMinutes: timeUntilNextFroop))"
        } else {
            
            return ""
            
        }
    }
    
    var body: some View {
        ZStack {
            MapReader { reader in
                ZStack {
                    VStack {
                        Map(position: $mapManager.cameraPosition, interactionModes: isMapDraggable ? .all : [], selection: $mapSelection) {
                            
                            if let route {
                                MapPolyline(route.polyline)
                                    .stroke(Color(red: 255/255, green: 49/255, blue: 97/255), lineWidth: 5)
                            }
                            
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
                            
                            ForEach(annotationManager.guestAnnotations, id: \.froopUserID) { participant in
                                Annotation(participant.firstName, coordinate: participant.coordinate) {
                                    PassiveGuestAnnotation(guest: participant, globalChat: $globalChat)
                                        .id(participant.froopUserID)
                                }
                            }
                            
                            
                            // MARK: Froop Annotation
                            Marker(froopManager.selectedFroopHistory.froop.froopLocationtitle, coordinate: froopManager.selectedFroopHistory.froop.froopLocationCoordinate )
                                .tint(Color(red: 249/255, green: 0/255, blue: 98/255))
                                .tag(froopManager.selectedFroopHistory.froop.froopId)
                        }
                        .frame(width: UIScreen.screenWidth, height: froopManager.selectedFroopHistory.froop.froopType == 5009 ? UIScreen.screenHeight * 1 : UIScreen.screenHeight)
                        .opacity(froopManager.selectedFroopHistory.froop.froopId == "" ? 0.5 : 1)
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
                            await MapManager.shared.loadPassiveRouteDestination()
                        }
                        .onAppear {
                            timerServices.shouldUpdateAnnotations = true
                            if let center = MapManager.shared.cameraPosition.region?.center {
                                MapManager.shared.centerLatitude = center.latitude
                                MapManager.shared.centerLongitude = center.longitude
                            }
                            MapManager.shared.startListeningForFroopPins()
                            
                            let froopLocation = froopManager.selectedFroopHistory.froop.froopLocationCoordinate
                            let myLocation = MyData.shared.coordinate // Directly accessing the property
                            
                            let midpoint = MapManager.shared.midpointBetween(coordinate1: froopLocation, coordinate2: myLocation)
                            let span = MapManager.shared.spanToInclude(coordinate1: froopLocation, coordinate2: myLocation)
                            let region = MKCoordinateRegion(center: midpoint, span: span)
                            withAnimation(.easeInOut(duration: 1.0)) {
                                MapManager.shared.cameraPosition = .region(region)
                            }
                            
                            Task {
                                await locationManager.startLiveLocationUpdates()
                            }
                            timerServices.startAnnotationTimer()
                            mapSelection = froopManager.selectedFroopHistory.froop.froopId
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
                        .onChange(of: appStateManager.appState) { oldValue, newValue in
                            if oldValue != newValue {
                                isShowing = false
                            }
                            
                        }
                        .overlay {
                            VStack {
                                Rectangle()
                                    .foregroundStyle(.black)
                                    .frame(height: 100)
                                    .ignoresSafeArea()
                                Spacer()
                            }
                            
                            VStack {
                                HStack {
                                    VStack {
                                        Image(systemName: "circle")
                                            .font(.system(size: 24))
                                            .foregroundStyle(.pink)
                                            .padding(.leading, 20)
                                        Spacer()
                                    }
                                    Spacer()
                                    Text(froopManager.selectedFroopHistory.froop.froopName)
                                    Spacer()
                                    NavigationAppsDropdown(isShowing: $showNavigationDropdown)
                                }
                                .padding(.top, 50)
                            }
                            /// FLIGHT RELATED OVERLAY
                            VStack {
                                HStack {
                                    Spacer()
                                    if froopManager.selectedFroopHistory.froop.froopType == 5009 {
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
                                                    Text("Flight: \(froopManager.selectedFroopHistory.flightData.number ?? "")")
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
                                            let froopLocation = froopManager.selectedFroopHistory.froop.froopLocationCoordinate
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
                                                let froopLoc = froopManager.selectedFroopHistory.froop.froopLocationCoordinate
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
                                        if froopManager.selectedFroopHistory.froop.froopType == 5009 {
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
                        .navigationTitle("\(froopManager.selectedFroopHistory.froop.froopName)")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbarBackground(.visible, for: .navigationBar)
                        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
                        
                        .alert("Add New Pin", isPresented: $showAddPinAlert) {
                            TextField("Pin Title", text: $newPinTitle)
                            Button("Add", action: addNewPin)
                            Button("Cancel", role: .cancel) { }
                        } message: {
                            Text("Enter a title for the new pin")
                        }
                        .onDisappear {
                            timerServices.shouldUpdateAnnotations = false
                        }
                        Spacer()
                    }
                    if froopManager.selectedFroopHistory.froop.froopType == 5009 {
                        VStack {
                            Spacer()
                            ZStack {
                                BlurView(style: .light)
                                    .frame(height: UIScreen.screenHeight * 0.35)
                                    .opacity(1)
                                    .border(Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.5), width: 0.5)
                                    .shadow(color: Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.3), radius: 20)
                                
                                VStack(alignment: .leading, spacing: 10) {
                                    Text(froopManager.selectedFroopHistory.froop.froopLocationtitle)
                                        .font(.system(size: 16))
                                        .foregroundColor(colorScheme == .dark ? .white : Color(red: 50/255, green: 46/255, blue: 62/255))
                                        .fontWeight(.semibold)
                                    HStack {
                                        Image(systemName: "location")
                                            .font(.system(size: 14))
                                            .foregroundColor(colorScheme == .dark ? .white : Color(red: 50/255, green: 46/255, blue: 62/255))
                                            .fontWeight(.regular)
                                        Text(froopManager.selectedFroopHistory.froop.froopLocationsubtitle)
                                            .font(.system(size: 14))
                                            .foregroundColor(colorScheme == .dark ? .white : Color(red: 50/255, green: 46/255, blue: 62/255))
                                            .fontWeight(.regular)
                                        
                                        Spacer()
                                        
                                        Text("In: \(countdownText)")
                                            .font(.system(size: 14))
                                            .foregroundColor(colorScheme == .dark ? .white : Color(red: 50/255, green: 46/255, blue: 62/255))
                                            .fontWeight(.light)
                                    }
                                    
                                    Divider()
                                    
                                    FlightLocationView()
                                    
                                    Spacer()
                                }
                                .frame(height: UIScreen.screenHeight * 0.35)
                                .padding(.leading, 35)
                                .padding(.trailing, 35)
                                
                                .padding(.top, 25)
                                
                                
                            }
                            .frame(height: UIScreen.screenHeight * 0.35)
                        }
                        .transition(.move(edge: .bottom))
                    }
                    
                    
                }
            }
            .onAppear {
                annotationManager.updateAnnotations(with: froopManager.selectedFroopHistory.confirmedFriends)
            }
        }
    }
    func onAddPinButtonTapped() {
        annotationManager.trackingUser = false
        createNewDropPin()
        showAddPinAlert = true
    }
    
    func addNewPin() {
        let newPin = FroopDropPin(coordinate: MapManager.shared.froopDropPin.coordinate, title: newPinTitle, subtitle: "", pinImage: "mappin.circle.fill")
        MapManager.shared.froopPins.append(newPin)
        MapManager.shared.newPinCreation = false
        newPinTitle = ""
    }
    
    //    func onAddPinButtonTapped() {
    //        annotationManager.trackingUser = false
    //        let newCenter = froopManager.selectedFroopHistory.froop.froopLocationCoordinate
    //        let offset = mapRegion.span.latitudeDelta / 20
    //        let adjustedCenter = CLLocationCoordinate2D(latitude: newCenter.latitude - offset, longitude: newCenter.longitude)
    //        let adjustedRegion = MKCoordinateRegion(center: adjustedCenter, latitudinalMeters: 250, longitudinalMeters: 250)
    //        withAnimation(.easeInOut(duration: 1.0)) {
    //            MapManager.shared.cameraPosition = .region(adjustedRegion)
    //        }
    //        createNewDropPin()
    //        mapManager.showPinDetailsView = false
    //        MapManager.shared.newPinCreation = true
    //        MapManager.shared.showSavePinView = true
    //        MapManager.shared.tabUp = false
    //        appStateManager.appStateToggle = true
    //        print("appStateToggle 4")
    //
    //
    //    }
    
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
        let currentLocation = froopManager.selectedFroopHistory.froop.froopLocationCoordinate
        // Calculate the new latitude 100 meters to the north
        let metersNorth = 100.0
        let degreeDistance = metersNorth / 111000 // degrees per meter
        
        let newLatitude = currentLocation.latitude + degreeDistance
        let newCoordinate = CLLocationCoordinate2D(latitude: newLatitude, longitude: currentLocation.longitude)
        
        MapManager.shared.froopDropPin = FroopDropPin(coordinate: newCoordinate, title: "", subtitle: "", pinImage: "mappin.circle.fill")
        
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
    
}




struct CustomAnnotation: Codable {
    let id: String
    let title: String
    let latitude: Double
    let longitude: Double
    let description: String
    let owner: String
    let ownerUid: String
    
    // Add any other properties you need
}


//struct NavigationAppsButton: View {
//    @State private var showNavigationDropdown = false
//    
//    var body: some View {
//        ZStack(alignment: .topTrailing) {
//            
//            
//                            Button(action: {
//                                showNavigationDropdown.toggle()
//                            }) {
//                                Image(systemName: "arrow.up.left.and.down.right.and.arrow.up.right.and.down.left")
//                                    .foregroundColor(.white)
//                                    .frame(width: 35, height: 35)
//                            }
//            
//                            if showNavigationDropdown {
//                                NavigationAppsDropdown(isShowing: $showNavigationDropdown)
//                            }
//        }
//    }
//}
