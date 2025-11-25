//
//  DetailsTasksAndInformationView.swift
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

struct DetailsTasksAndInformationView: View {
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
//    @ObservedObject var friendData: UserData = UserData()
    
    @State var addons: [TaskInfoAddon] = []
    
    
    @State var froopDetails: String = ""
    @State var froopSafety:  String = ""
    @State var froopFlightInfo: String = ""
    @Binding var taskOn: Bool
    @Binding var selectedFroopHistory: FroopHistory

    
    var body: some View {
        ZStack {
            Rectangle()
                .frame(height: 125)
                .foregroundColor(colorScheme == .dark ? Color(red: 250/255 , green: 250/255, blue: 255/255) : Color(red: 250/255 , green: 250/255, blue: 255/255))
            
            VStack {
                
                HStack {
                    Text("Tasks and Information")
                        .font(.system(size: 14))
                        .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                        .opacity(0.7)
                        .fontWeight(.semibold)
                        .padding(.top, 10)
                        .padding(.leading, 25)
                        .padding(.bottom, 15)
                    Spacer()
                }
                
                
                
                HStack {
                    
                    SignUpView(taskOn: $taskOn)
                    
//                    FroopMessageView()
//
//                    FlightInfoView()
//
//                    DetailsView()
//
//                    SafetyView()
                    
                    
                }
                Spacer()
            }
            .frame(maxHeight: 125)
        
          
        }
        Divider()
            .padding(.leading, 15)
            .padding(.trailing, 15)
    }
    
    func openURL(_ urlString: String) {
        guard let url = URL(string: urlString) else {
//            print("Invalid URL")
            return
        }

        UIApplication.shared.open(url)
    }
    
}

struct TaskInfoAddon {
    let id: Int
    let name: String
    let systemImageName: String
    let action: () -> Void
}


