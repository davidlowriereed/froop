//
//  DetailsHeaderView.swift
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

struct DetailsHeaderView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var myData = MyData.shared
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var froopManager = FroopManager.shared
    @Binding var templateMade: Bool
    @State private var swingIn: Bool = false
    
    var timeUntilStart: String {
        let calendar = Calendar.current
        let now = Date()
        
        if froopManager.selectedFroopHistory.froop.froopStartTime > now {
            let components = calendar.dateComponents([.day, .hour, .minute], from: now, to: froopManager.selectedFroopHistory.froop.froopStartTime)
            
            let days = components.day ?? 0
            let hours = components.hour ?? 0
            let minutes = components.minute ?? 0
            
            var timeUntilStart = "Starts in "
            
            if days > 9 {
                timeUntilStart += "\(days)d : "
            } else if days > 0 && days < 10 {
                timeUntilStart += "0\(days)d : "
            } else {
                timeUntilStart += "00d : "
            }
            
            
            if hours > 9 {
                timeUntilStart += "\(hours)h : "
            } else if hours > 0 && hours < 10 {
                timeUntilStart += "0\(hours)h : "
            } else {
                timeUntilStart += "00h : "
            }
            
            
            if minutes > 9 {
                timeUntilStart += "\(minutes)m"
            } else if minutes > 0 && minutes < 10 {
                timeUntilStart += "0\(minutes)m"
            } else {
                timeUntilStart += "00m"
            }
            
            
            return timeUntilStart.trimmingCharacters(in: .whitespaces)
        } else if froopManager.selectedFroopHistory.froop.froopEndTime < now {
            return "Froop has already started"
        } else {
            return "This Froop occured in the past"
        }
    }
    
    var body: some View {
        ZStack {
            ZStack {
                Rectangle()
                    .frame(height: 225)
                    .foregroundColor(colorScheme == .dark ? Color(red: 50/255, green: 46/255, blue: 62/255) : Color(red: 50/255, green: 46/255, blue: 62/255))
                if FirebaseServices.shared.uid == froopManager.selectedFroopHistory.host.froopUserID {
                    if froopManager.selectedFroopHistory.froop.froopType != 5001 {
                        if myData.premiumAccount || myData.professionalAccount {
                            ZStack {
                                VStack {
                                    HStack {
                                        
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 0)
                                                .fill(froopManager.selectedFroopHistory.froop.template || templateMade ? Color(red: 0/255, green: 150/255, blue: 160/255) : Color(red: 249/255, green: 0/255, blue: 98/255))
                                                .frame(width: 70, height: 40)
                                                .shadow(color: Color(.black).opacity(0.5), radius: 4, x: 4, y: 4)
                                            VStack {
                                                Text(froopManager.selectedFroopHistory.froop.template || templateMade ? "Made From" : "Create")
                                                    .font(.system(size: 12))
                                                    .fontWeight(.regular)
                                                    .foregroundColor(.white)
                                                Text(froopManager.selectedFroopHistory.froop.template || templateMade ? "Template" : "Template")
                                                    .font(.system(size: 12))
                                                    .fontWeight(.regular)
                                                    .foregroundColor(.white)
                                            }
                                        }
                                        Spacer()
                                    }
                                    Spacer()
                                }
                                .padding(.top, 50)
                                .onTapGesture {
                                    //print("tapped")
                                    templateMade = true
                                    if !froopManager.selectedFroopHistory.froop.template || !templateMade {
                                        froopManager.saveFroopAsTemplate(froopId: "froopId") { error in
                                            if let error = error {
                                                print("🚫Error copying froop to templates: \(error.localizedDescription)")
                                                print(froopManager.selectedFroopHistory.froop.froopId)
                                            } else {
                                                print("Froop successfully copied to templates with confirmed friends.")
                                            }
                                        }
                                    }
                                }
                            }
                            .frame(maxHeight: 200)
                            .offset(x: swingIn ? 0 : 100)
                            .onAppear {
                                withAnimation(.interactiveSpring(response: 0.55, dampingFraction: 0.65, blendDuration: 0.65)) {
                                    swingIn = true
                                }
                            }
                        }
                    } else {
                        EmptyView()
                            .frame(height: 200)
                    }
                }
            }
            ZStack {
                VStack {
                    Spacer()
                    HStack {
                        ZStack {
                            Circle()
                                .frame(width: 75)
                                .foregroundColor(colorScheme == .dark ? .white : .white)
                            KFImage(URL(string: froopManager.selectedFroopHistory.host.profileImageUrl))
                                .placeholder {
                                    ProgressView()
                                }
                                .resizable()
                                .scaledToFill()
                                .frame(width: 75, height: 75, alignment: .center)
                                .clipShape(Circle())
                        }
                        
                        VStack (alignment: .leading){
                            Text(froopManager.selectedFroopHistory.froop.froopName )
                                .foregroundColor(colorScheme == .dark ? .white: .white)
                                .font(.system(size: 24))
                            Text("Host: \(froopManager.selectedFroopHistory.host.firstName ) \(froopManager.selectedFroopHistory.host.lastName)")
                                .foregroundColor(colorScheme == .dark ? .white: .white)
                                .font(.system(size: 14))
                                .offset(y: 8)
                            Text(timeUntilStart)
                                .font(.system(size: 14))
                                .fontWeight(.regular)
                                .foregroundColor(.white).opacity(0.4)
                                .frame(alignment: .leading)
                                .offset(y: 8)
                            
                        }
                        .offset(y: -5)
                        .padding(.leading, 15)
                        
                        Spacer()
                    }
                    
                }
                .frame(maxHeight: 200)
                .padding(.bottom, 10)
                .padding(.trailing, 25)
                .padding(.leading, 25)
                
            }
        }
    }
}


