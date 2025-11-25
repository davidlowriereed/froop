//
//  FroopMapBackgroundView.swift
//  FroopProof
//
//  Created by David Reed on 3/3/23.
//

import SwiftUI
import MapKit
import SwiftUIBlurView

struct FroopMapBackgroundView: View {
    
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var navLocationServices = NavLocationServices.shared
    // @ObservedObject var froopDataListener = FroopDataListener.shared
    @ObservedObject var froopData = FroopData.shared
    @State private var showLocationSearchView = false
    @State private var mapState = MapViewState.locationSelected
    @EnvironmentObject var locationViewModel: LocationSearchViewModel
    @Binding var homeViewModel: HomeViewModel
    @ObservedObject var myData = MyData.shared
    @State var showRec = false
    
    
    var body: some View {
        
        ZStack(alignment: .bottom) {
            ZStack(alignment: .top) {
                Text("")
                //ActiveFroopMapViewRepresentable(froopData: froopData, mapState: $mapState)
                    .opacity(1)
            
            }
            .background(Color.clear)
            .environmentObject(locationViewModel)
            .environmentObject(MyData.shared)
            .environmentObject(froopData)
            .environmentObject(homeViewModel)
            .edgesIgnoringSafeArea(.bottom)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            
        }
        
    }
    
}
