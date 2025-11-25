//
//  FroopLocationSearchView.swift
//  FroopProof
//
//  Created by David Reed on 5/29/24.
//

import SwiftUI
import MapKit
import Kingfisher
import SwiftUIBlurView

struct FroopLocationSearchView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var froopData = FroopData.shared
    @ObservedObject var locationManager = LocationManager.shared
    @ObservedObject var mapManager = MapManager.shared
    @ObservedObject var vm = LocationSearchViewModel.shared
    @ObservedObject var myData = MyData.shared
    @ObservedObject var navLocationServices = NavLocationServices.shared
    @ObservedObject var changeView = ChangeView.shared

//    @State var searchText: String = ""
    @State private var showSearch: Bool = false
    @FocusState private var isSearchBarFocused: Bool
    @State private var locationAuthorized = false
    @State var showRec = false
    @State private var delayCompleted = false
    @State private var mapState = MapViewState.searchingForLocation
    @State private var showLocationSearchView = false
    @State private var listPresented = true
    @State var searchSubmit: Bool = false
    @State var focusOn: Bool = false
    @State var isDragging: Bool = false
    @State var openPreview: Bool = false
    
    var body: some View {
        Map(position: $vm.cameraPosition, selection: $vm.mapSelection) {
            Annotation(MyData.shared.firstName, coordinate: .myLocation) {
                ZStack {
                    Circle()
                        .frame(width: 52, height: 52)
                        .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255))
                        .shadow(color: Color(red: 50/255, green: 46/255, blue: 62/255), radius: 5)
                    KFImage(URL(string: myData.profileImageUrl))
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                }
            }
            .annotationTitles(.hidden)
            if vm.results != [] {
                ForEach(vm.processedSearchResults, id: \.0) { (mapItem, isLookAroundAvailable) in
                    if vm.routeDisplaying {
                        if mapItem == vm.routeDestination {
                            let placemark = mapItem.placemark
                            Marker(placemark.name ?? "Place", coordinate: placemark.coordinate)
                                .tint(.blue)
                        }
                    } else {
                        let placemark = mapItem.placemark
                        let tintColor: Color = isLookAroundAvailable ? .green : .blue
                        Marker(placemark.name ?? "Place", coordinate: placemark.coordinate)
                            .tint(tintColor)
                    }
                }
            }
            
            if let route = vm.route {
                MapPolyline(route.polyline)
                    .stroke(.blue, lineWidth: 7)
            }
            
            UserAnnotation()
        }
        .mapStyle(.standard(elevation: .realistic))
        .onMapCameraChange { ctx in
            vm.viewingRegion = ctx.region
            vm.searchCompleter.region = ctx.region
        }
        .overlay {
            ZStack {
                VStack(spacing: 0) {
                    ZStack {
                        Rectangle()
                            .foregroundColor(.clear)
                            .background(.thinMaterial)
                            .frame(height: searchSubmit ? 75 : focusOn ? 175 : 250)
                            .shadow(color: Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.2), radius: 7, x: 7, y: 7)
                            .shadow(color: Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.2), radius: 7, x: -7, y: -7)
                        VStack {
//                            Spacer()
                            Text(searchSubmit ? "" : focusOn ? ("Find Location") : "Have a location in mind?")
                                .font(.system(size: focusOn ? 28 : 36))
                                .multilineTextAlignment(.center)
                                .foregroundColor(colorScheme == .dark ? .white : Color(red: 50/255, green: 46/255, blue: 62/255))
                                .fontWeight(.thin)
                                .padding(.bottom, 15)
                                .padding(.leading, 15)
                                .padding(.trailing, 15)
                                .padding(.top, 10)
                            SearchBarView(vm: vm, searchText: $vm.searchText, searchSubmit: $searchSubmit, focusOn: $focusOn, listPresented: $listPresented)
                                .padding(.top, focusOn ? 0 : 25)
                                .frame(width: UIScreen.main.bounds.width * 0.85)
                                .offset(y: vm.showDetails ? -35 : 0)

                            if focusOn && !openPreview {
                                HStack(spacing: 5) {
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundColor(Color(.white).opacity(0))
                                        .frame(width: 125, height: 30)
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundColor(Color(.white).opacity(0))
                                        .frame(width: 125, height: 30)
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundColor(Color(.white).opacity(0))
                                        .frame(width: 125, height: 30)
                                }
                                .frame(height: 40)
                                .padding(.bottom, 15)
                            }
                            Spacer()
                        }
                        .padding(.top, 25)
//                        .frame(height: 150)
                    }
                    .frame(height: searchSubmit ? 75 : focusOn ? 175 : 250)
                    .padding(.top, searchSubmit ? 0 : focusOn ? 0 : vm.results.count > 0 ? 0 : 0)
                    if mapState == .searchingForLocation {
                        SearchResultsView(vm: vm, listPresented: $listPresented, searchSubmit: $searchSubmit, openPreview: $openPreview)
                            .opacity(listPresented ? 1 : 0)
                    } else if mapState == .noInput {
                        Text("")
                            .padding(.top, 60)
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    mapState = .searchingForLocation
                                }
                            }
                    }
                    VStack {
                        Rectangle()
                            .foregroundColor(.clear)
                            .background(.thinMaterial)
                            .frame(height: 5)
                    }
                    .ignoresSafeArea()
                }
                
                if openPreview {
                    VStack {
                        Spacer()
                        ZStack {
                            BlurView(style: .light)
                                .frame(height: UIScreen.screenHeight * 0.4)
                                .edgesIgnoringSafeArea(.bottom)
                                .border(Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.5), width: 0.5)
                                .shadow(color: Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.3), radius: 20)
                            
                            
                            FroopLocationConfirmationView(froopData: froopData, changeView: changeView)
                        }
                        .frame(height: UIScreen.screenHeight * 0.4)
                        .transition(.move(edge: .bottom))
                    }
                    .ignoresSafeArea()
                }
            }
        }
        .onChange(of: vm.routeDestination) {
            print("MetaData: \(vm.routeDestination?.pointOfInterestCategory?.rawValue ?? "No Categories Available")")
        }
        .onChange(of: vm.mapSelection) { oldValue, newValue in
            vm.showDetails = newValue != nil
            vm.fetchLookAroundPreview()
            print("firing")
        }
        .onChange(of: locationManager.userLocation) { oldValue, newValue in
            if oldValue != newValue {
                withAnimation(.easeInOut(duration: 2.0)) {
                    if !locationAuthorized {
                        focusOnMe()
                    }
                    locationAuthorized = true
                }
            }
        }
        .onChange(of: vm.searchText) {
            if !vm.searchText.isEmpty {
                vm.search(text: vm.searchText, region: locationManager.region)
            } else {
                vm.places = []
            }
        }
        .onChange(of: vm.searchText) {
            if vm.searchText == "" {
                vm.results = []
                vm.places = []
            }
        }
    }
    
    func focusOnMe() {
        let location = LocationManager.shared.userLocation
        withAnimation(.easeInOut(duration: 0.5)) {
            vm.cameraPosition = .camera(MapCamera(centerCoordinate: location?.coordinate ?? CLLocationCoordinate2D(), distance: 50000, heading: 0, pitch: 25))
        }
    }
}

extension MKMapItem {
    func fetchLookAroundScene(completion: @escaping (MKLookAroundScene?) -> Void) {
        let request = MKLookAroundSceneRequest(mapItem: self)
        request.getSceneWithCompletionHandler { scene, error in
            completion(scene)
        }
    }
}

struct SearchBarView: View {
    @ObservedObject var vm: LocationSearchViewModel
    @Binding var searchText: String
    @State var text: String = ""
    @Binding var searchSubmit: Bool
    @State private var counter: Int = 0
    @Binding var focusOn: Bool
    @Binding var listPresented: Bool

    var body: some View {
        VStack (spacing: 10) {
            LocationSearchBar(text: $text, searchSubmit: $searchSubmit, focusOn: $focusOn)
                .onChange(of: text) {
                    if text.count > 0 {
                        searchText = text
                        vm.showDetails = false
                    } else {
                        searchText = ""
                    }
                }
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        searchText = ""
                        searchSubmit = false
                        counter = 0
                        listPresented = true
                        vm.showDetails = false
                    }
                }
            Spacer()
        }
        .frame(width: UIScreen.main.bounds.width * 0.85)
    }
}


struct SearchResultCard: View {
    var title: String
    var subtitle: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding()
        .background(.thinMaterial)
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding(.horizontal)
    }
}

struct SearchResultsView: View {
    @ObservedObject var vm: LocationSearchViewModel
    @ObservedObject var froopData = FroopData.shared
    @Binding var listPresented: Bool
    @Binding var searchSubmit: Bool
    @Binding var openPreview: Bool
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                ForEach(vm.results.filter { result in
                    !vm.locationFilter.contains(where: {result.subtitle.contains($0)}) &&
                    !result.subtitle.isEmpty
                }, id: \.self) { result in
                    SearchResultCard(title: result.title, subtitle: result.subtitle)
                        .padding(.top, 10)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                vm.selectLocation(result, froopData: froopData) { coordinate in
                                    if coordinate != nil {
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                            vm.mapSelection = vm.processedSearchResults.first { $0.0.placemark.coordinate == coordinate }?.0
                                            vm.fetchRoute()
                                            vm.fetchLookAroundPreview()
                                            
                                        }
                                    }
                                }
                            }
                            Task {
                                await vm.retrieveMapItem(for: result) {
                                    await vm.processSearchResults()
                                }
                            }
                            openPreview = true
                            searchSubmit = true
                            listPresented = false
                            vm.showDetails = true
                        }
                }
            }
            .padding(.top, 15)
        }
        .opacity(vm.queryFragment == "" ? 0 : 1)
    }
}


struct LocationSearchBar: View {
    @ObservedObject var vm = LocationSearchViewModel.shared
    @Binding var text: String
    @Binding var searchSubmit: Bool
    @Binding var focusOn: Bool
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        HStack {
            TextField("Search...", text: $vm.queryFragment)
                .padding(7)
                .padding(.leading, 25)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        Spacer()
                    }
                        .padding(.horizontal, 10)
                )
                .focused($isTextFieldFocused)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(red: 50/255, green: 46/255, blue: 62/255), lineWidth: 0.5)
                )
        }
        .padding(.horizontal, 10)
        .onChange(of: searchSubmit) {
            withAnimation(.easeInOut(duration: 0.5)) {
                isTextFieldFocused = !searchSubmit
            }
        }
        .onChange(of: isTextFieldFocused) {
            withAnimation(.easeInOut(duration: 0.5)) {
                focusOn = isTextFieldFocused
            }
        }
    }
}
