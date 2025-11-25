//
//  DetailsMapView.swift
//  Design_Layouts
//
//  Created by David Reed on 6/20/23.
//

import SwiftUI
import SwiftUIBlurView
import Kingfisher
import Firebase
import FirebaseAuth
import FirebaseFirestore
import Foundation
import MapKit
import EventKit
import FirebaseCrashlytics

struct DetailsMapView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var navLocationServices = NavLocationServices.shared
//     @ObservedObject var froopDataListener = FroopDataListener.shared
    @ObservedObject var myData = MyData.shared
    @ObservedObject var froopManager = FroopManager.shared
    @ObservedObject var friendViewController = FriendViewController.shared
    @ObservedObject var timeZoneManager: TimeZoneManager = TimeZoneManager()
    @ObservedObject var froopData = FroopData.shared
    @ObservedObject var friendData: UserData = UserData()
    
    @Binding var selectedFroopHistory: FroopHistory
    
    var body: some View {
        ZStack {
            Rectangle()
                .frame(height: 75)
                .foregroundColor(.white)

            HStack (alignment: .center) {
                Image(systemName: "mappin.and.ellipse")
                    .font(.system(size: 24))
                    .foregroundColor(colorScheme == .dark ? Color(red: 249/255, green: 0/255, blue: 98/255 ) : Color(red: 249/255, green: 0/255, blue: 98/255 ))
                    .padding(.trailing, 15)
                
                VStack (alignment: .leading){
                    Text(froopManager.selectedFroopHistory.froop.froopLocationtitle)
                        .foregroundColor(colorScheme == .dark ? Color(red: 50/255, green: 46/255, blue: 62/255) : Color(red: 50/255, green: 46/255, blue: 62/255))
                        .opacity(0.7)
                        .font(.system(size: 16))
                        .fontWeight(.semibold)
                    Text(froopManager.selectedFroopHistory.froop.froopLocationsubtitle)
                        .foregroundColor(colorScheme == .dark ? Color(red: 50/255, green: 46/255, blue: 62/255) : Color(red: 50/255, green: 46/255, blue: 62/255))
                        .opacity(0.7)
                        .font(.system(size: 12))
                        .lineLimit(2)
                    
                }
                
                Spacer()
                
                Button () {
                    froopManager.froopMapOpen = true
                } label: {
                    ZStack {
                        
                        Image("mapImage")
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: 75, maxHeight: 75)
                        Rectangle()
                            .frame(width: 75, height: 75)
                            .foregroundColor(.white)
                            .opacity(0.5)
                        
                        VStack  {
                            Text("Open")
                                .foregroundColor(colorScheme == .dark ? Color(red: 50/255, green: 46/255, blue: 62/255) : Color(red: 50/255, green: 46/255, blue: 62/255))
                                .font(.system(size: 16))
                            Text("Map")
                                .foregroundColor(colorScheme == .dark ? Color(red: 50/255, green: 46/255, blue: 62/255) : Color(red: 50/255, green: 46/255, blue: 62/255))
                                .font(.system(size: 16))
                        }
                        .font(.system(size: 12))
                    }
                }
                
            }
            .ignoresSafeArea()
            .padding(.leading, 25)
        }
        Divider()
    }
}


