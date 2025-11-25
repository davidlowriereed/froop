//
//  GlobalMapView.swift
//  Design_Layouts
//
//  Created by David Reed on 9/19/23.
//

//import SwiftUI
//import MapKit
//import CoreLocation
//import CoreLocationUI
//import UIKit
//
//
//@available(iOS 17.0, *)
//struct GlobalMapView: View {
//    @State var cameraPosition: MapCameraPosition = .region(.myRegion)
//    @State var mapSelection: MKMapItem?
//    @Namespace var locationSpace
//    @State var viewingRegion: MKCoordinateRegion?
//    
//    /// Search Properties
//    @State var searchText: String = ""
//    @State var showSearch: Bool = false
//    @State var searchResults: [MKMapItem] = []
//    
//    /// Map Selection Detail Properties
//    @State var showDetails: Bool = false
//    @State var lookAroundScene: MKLookAroundScene?
//    
//    /// Route Properties
//    @State var routeDisplaying: Bool = false
//    @State var route: MKRoute?
//    @State var routeDestination: MKMapItem?
//    
//    var body: some View {
//        NavigationStack {
//            Map(position: $cameraPosition, selection: $mapSelection, scope: locationSpace) {
//                /// Map Annotations
//                Annotation("Apple Park", coordinate: .myLocation) {
//                    ZStack {
//                        Image(systemName: "applelogo")
//                            .font(.title)
//                        Image(systemName: "circle")
//                            .font(.system(size: 50))
//                            .offset(x: 1)
//                    }
//                }
//                // .annotationTitles(.hidden)
//                
//                /// Simply Display Annotations as Marker, as we seen before
//                ForEach(searchResults, id: \.self) { mapItem in
//                    /// Hiding All other Markers, Expect Destionation one
//                    if routeDisplaying {
//                        if mapItem == routeDestination {
//                            let placemark = mapItem.placemark
//                            Marker(placemark.name ?? "Place", coordinate: placemark.coordinate)
//                                .tint(Color(red: 255/255, green: 49/255, blue: 97/255))
//                        }
//                    } else {
//                        let placemark = mapItem.placemark
//                        Marker(placemark.name ?? "Place", coordinate: placemark.coordinate)
//                            .tint(Color(red: 255/255, green: 49/255, blue: 97/255))
//                    }
//                }
//                
//                /// Display Route using Polyline
//                if let route {
//                    MapPolyline(route.polyline)
//                    /// Applying Bigger Stroke
//                        .stroke(Color(red: 255/255, green: 49/255, blue: 97/255), lineWidth: 7)
//                }
//                
//                /// To Show User Current Location
//                /// This will work only when the User Gave Location Access
//                UserAnnotation()
//            }
//            .onMapCameraChange({ ctx in
//                viewingRegion = ctx.region
//            })
//            .overlay(alignment: .bottomTrailing) {
//                VStack(spacing: 15) {
//                    MapCompass(scope: locationSpace)
//                    MapPitchToggle(scope: locationSpace)
//                    /// As this will work only when the User Gave Location Access
//                    MapUserLocationButton(scope: locationSpace)
//                    /// This will Goes to the Defined User Region
//                    Button {
//                        withAnimation(.smooth) {
//                            cameraPosition = .region(.myRegion)
//                        }
//                    } label: {
//                        Image(systemName: "mappin")
//                            .font(.title3)
//                    }
//                    .buttonStyle(.borderedProminent)
//                }
//                .buttonBorderShape(.circle)
//                .padding()
//            }
//            .mapScope(locationSpace)
//            .navigationTitle("Map")
//            .navigationBarTitleDisplayMode(.inline)
//            /// Search Bar
//            .searchable(text: $searchText, isPresented: $showSearch)
//            /// Showing Trasnlucent ToolBar
//            .toolbarBackground(.visible, for: .navigationBar)
//            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
//            /// When Route Displaying Hiding Top And Bottom Bar
//            .toolbar(routeDisplaying ? .hidden : .visible, for: .navigationBar)
//            .sheet(isPresented: $showDetails, onDismiss: {
//                withAnimation(.snappy) {
//                    /// Zooming Region
//                    if let boundingRect = route?.polyline.boundingMapRect, routeDisplaying {
//                        cameraPosition = .rect(boundingRect.reducedRect(0.45))
//                    }
//                }
//            }, content: {
//                MapDetails()
//                    .presentationDetents([.height(300)])
//                    .presentationBackgroundInteraction(.enabled(upThrough: .height(300)))
//                    .presentationCornerRadius(25)
//                    .interactiveDismissDisabled(true)
//            })
//            .safeAreaInset(edge: .bottom) {
//                if routeDisplaying {
//                    Button("End Route") {
//                        /// Closing The Route and Setting the Selection
//                        withAnimation(.snappy) {
//                            routeDisplaying = false
//                            showDetails = true
//                            mapSelection = routeDestination
//                            routeDestination = nil
//                            route = nil
//                            if let coordinate = mapSelection?.placemark.coordinate {
//                                cameraPosition = .region(.init(center: coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000))
//                            }
//                        }
//                    }
//                    .foregroundStyle(.white)
//                    .frame(maxWidth: .infinity)
//                    .contentShape(Rectangle())
//                    .padding(.vertical, 12)
//                    .background(.red.gradient, in: .rect(cornerRadius: 15))
//                    .padding()
//                    .background(.ultraThinMaterial)
//                }
//            }
//        }
//        .onSubmit(of: .search) {
//            Task {
//                guard !searchText.isEmpty else { return }
//                
//                await searchPlaces()
//            }
//        }
//        .onChange(of: showSearch, initial: false) {
//            if !showSearch {
//                /// Clearing Search Results
//                searchResults.removeAll(keepingCapacity: false)
//                showDetails = false
//                /// Zooming out to User Region when Search Cancelled
//                withAnimation(.smooth) {
//                    cameraPosition = .region(viewingRegion ?? .myRegion)
//                }
//            }
//        }
//        .onChange(of: mapSelection) { oldValue, newValue in
//            /// Displaying Details about the Selected Place
//            showDetails = newValue != nil
//            /// Fetching Look Around Preview, when ever selection Changes
//            fetchLookAroundPreview()
//        }
//    }
//    
//    /// Map Details View
//    @ViewBuilder
//    func MapDetails() -> some View {
//        VStack(spacing: 15) {
//            ZStack {
//                /// New Look Around API
//                if lookAroundScene == nil {
//                    /// New Empty View API
//                    ContentUnavailableView("No Preview Available", systemImage: "eye.slash")
//                } else {
//                    LookAroundPreview(scene: $lookAroundScene)
//                }
//            }
//            .frame(height: 200)
//            .clipShape(.rect(cornerRadius: 15))
//            /// Close Button
//            .overlay(alignment: .topTrailing) {
//                Button(action: {
//                    /// Closing View
//                    showDetails = false
//                    withAnimation(.snappy) {
//                        mapSelection = nil
//                    }
//                }, label: {
//                    Image(systemName: "xmark.circle.fill")
//                        .font(.title)
//                        .foregroundStyle(Color(red: 50/255, green: 46/255, blue: 62/255))
//                        .background(.white, in: .circle)
//                })
//                .padding(10)
//            }
//            
//            /// Direction's Button
//            Button("Get Directions", action: fetchRoute)
//                .foregroundStyle(.white)
//                .frame(maxWidth: .infinity)
//                .padding(.vertical, 12)
//                .contentShape(Rectangle())
//                .background(Color(red: 255/255, green: 49/255, blue: 97/255).gradient, in: .rect(cornerRadius: 15))
//        }
//        .padding(15)
//    }
//    
//    /// Search Places
//    func searchPlaces() async {
//        let request = MKLocalSearch.Request()
//        request.naturalLanguageQuery = searchText
//        request.region = viewingRegion ?? .myRegion
//        
//        let results = try? await MKLocalSearch(request: request).start()
//        searchResults = results?.mapItems ?? []
//    }
//    
//    /// Fetching Location Preview
//    func fetchLookAroundPreview() {
//        if let mapSelection {
//            /// Clearing Old One
//            lookAroundScene = nil
//            Task.detached(priority: .background) {
//                let request = MKLookAroundSceneRequest(mapItem: mapSelection)
//                lookAroundScene = try? await request.scene
//            }
//        }
//    }
//    
//    /// Fetching Route
//    func fetchRoute() {
//        if let mapSelection {
//            let request = MKDirections.Request()
//            request.source = .init(placemark: .init(coordinate: .myLocation))
//            request.destination = mapSelection
//            
//            Task {
//                let result = try? await MKDirections(request: request).calculate()
//                route = result?.routes.first
//                /// Saving Route Destination
//                routeDestination = mapSelection
//                
//                withAnimation(.snappy) {
//                    routeDisplaying = true
//                    showDetails = false
//                }
//            }
//        }
//    }
//}



