//
//  DetailsGuestMessageView.swift
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
import AVKit

struct DetailsGuestMessageView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var navLocationServices = NavLocationServices.shared
    // @ObservedObject var froopDataListener = FroopDataListener.shared
    @ObservedObject var myData = MyData.shared
    @ObservedObject var froopManager = FroopManager.shared
    @ObservedObject var friendViewController = FriendViewController.shared
    @ObservedObject var timeZoneManager: TimeZoneManager = TimeZoneManager()
    @ObservedObject var froopData = FroopData.shared
    @Binding var selectedFroopHistory: FroopHistory
//    @ObservedObject var friendData: UserData = UserData()
    
    @State private var showAlert = false
    
    
    @Binding var messageEdit: Bool
    
    var body: some View {
        VStack (spacing: 0){
            
            ZStack {
                Rectangle()
                    .frame(height: 50)
                    .foregroundColor(colorScheme == .dark ? Color(red: 250/255 , green: 250/255, blue: 255/255) : Color(red: 250/255 , green: 250/255, blue: 255/255))
                VStack {
                    Spacer()
                    
                    HStack {
                        Text("Host's Message")
                            .font(.system(size: 14))
                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                            .opacity(0.7)
                            .fontWeight(.semibold)
                            .padding(.top, 10)
                            .padding(.leading, 15)
                            .padding(.bottom, 5)
                        Spacer()
                    }
                    .padding(.trailing, 25)
                    .padding(.leading, 15)
                }
                .frame(maxHeight: 50)
            }
            Divider()
            ZStack {
                Rectangle()
                    .foregroundColor(Color.white).opacity(0.15)
                    .frame(width: UIScreen.screenWidth, height: UIScreen.screenHeight / 5.5)

                if froopManager.selectedFroopHistory.froop.froopIntroVideo == "" {
                    Text(selectedFroopHistory.froop.froopMessage)
                        .font(.system(size: 16))
                        .fontWeight(.light)
                        .frame(width: UIScreen.screenWidth - 50, height: UIScreen.screenHeight / 6)
                        .padding(.top, 5)
                        .padding(.bottom, 5)
                        .padding(.horizontal, 25)
                } else {
                    ZStack {
                        
                        KFImage(URL(string: froopManager.selectedFroopHistory.froop.froopIntroVideoThumbnail))
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: UIScreen.screenWidth * 1, height: UIScreen.screenHeight / 2.75)
                            .clipped()
                            .ignoresSafeArea()
                        
                        Image(systemName: "play.circle")
                            .foregroundColor(.white)
                            .font(.system(size: 45))
                    }
                    .frame(width: UIScreen.screenWidth, height: UIScreen.screenHeight / 3)
                    .padding()
                    .onTapGesture {
                        if froopManager.selectedFroopHistory.froop.froopIntroVideo != "" {
                            froopManager.showVideoPlayer = true
                        }
                    }
                }
            }
        }
        Divider()
    }
}


