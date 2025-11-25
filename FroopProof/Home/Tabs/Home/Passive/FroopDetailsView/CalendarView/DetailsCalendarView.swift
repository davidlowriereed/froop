//
//  DetailsCalendarView.swift
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

struct DetailsCalendarView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var froopManager = FroopManager.shared
    @ObservedObject var timeZoneManager: TimeZoneManager = TimeZoneManager()
    @Binding var selectedFroopHistory: FroopHistory
    
    @State private var formattedDateString: String = ""
    
    var body: some View {
        ZStack {
            Rectangle()
                .frame(height: 75)
                .foregroundColor(colorScheme == .dark ? Color(red: 220/255 , green: 220/255, blue: 225/255) : Color(red: 220/255 , green: 220/255, blue: 225/255))
                .onAppear{
                    formattedDateString = timeZoneManager.formatDateDetail(passedDate: froopManager.selectedFroopHistory.froop.froopStartTime)
                }
            HStack (alignment: .center) {
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 24))
                    .foregroundColor(colorScheme == .dark ? Color(red: 249/255, green: 0/255, blue: 98/255 ) : Color(red: 249/255, green: 0/255, blue: 98/255 ))
                    .padding(.trailing, 15)
                
                Text(formattedDateString)
                    .foregroundColor(colorScheme == .dark ? Color(red: 50/255, green: 46/255, blue: 62/255) : Color(red: 50/255, green: 46/255, blue: 62/255))
                    .opacity(0.7)
                    .font(.system(size: 16))
                    .fontWeight(.semibold)
                
                Spacer()
                
                ZStack {
                    Rectangle()
                        .frame(width: 75, height: 75)
                        .foregroundColor(colorScheme == .dark ? .clear : .clear)
                    VStack  {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(colorScheme == .dark ? .green : .green)
                            .font(.system(size: 24))
                            .padding(.bottom,1)
                        Text("Confirmed")
                            .fontWeight(.light)
                            .foregroundColor(colorScheme == .dark ? Color(red: 50/255, green: 46/255, blue: 62/255) : Color(red: 50/255, green: 46/255, blue: 62/255))
                            .opacity(0.7)
                    }
                    .font(.system(size: 12))
                }
                
            }
            .ignoresSafeArea()
            .padding(.leading, 25)
        }
        Divider()
    }
}

