//
//  LocationResultsCell.swift
//  FroopProof
//
//  Created by David Reed on 1/19/23.
//

import SwiftUI
import MapKit
import CoreLocation

struct LocationSearchResultCell: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var navLocationServices = NavLocationServices.shared
    // @ObservedObject var froopDataListener = FroopDataListener.shared
 
    
    let title: String
    let subtitle: String
    @State private var location: FroopData?
    
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

