//
//  FroopActiveMapView.swift
//  FroopProof
//
//  Created by David Reed on 5/5/23.
//


//import Combine
//import SwiftUI
//import MapKit
//import FirebaseFirestore
//import Kingfisher
//import CoreLocation
//
//struct FroopDetailsMapView: View {
//    
//    @ObservedObject var printControl = PrintControl.shared
//    @ObservedObject var appStateManager = AppStateManager.shared
//    @State private var mapState = MapViewState.locationSelected
//    @EnvironmentObject var locationViewModel: LocationSearchViewModel
//    
//    
//    var body: some View {
//        
//        ZStack {
//            ZStack {
//                ActiveMapViewRepresentable()
//                    .onAppear {
//                        LocationManager.shared.startUpdating()
//                    }
//            }
//        }
//    }
//}
