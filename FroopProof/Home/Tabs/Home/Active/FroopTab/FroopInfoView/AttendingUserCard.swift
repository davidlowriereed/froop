//
//  AttendingUserCard.swift
//  FroopProof
//
//  Created by David Reed on 5/12/23.
//

import SwiftUI
import Kingfisher
import MapKit



struct AttendingUserCard: View {
    
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var navLocationServices = NavLocationServices.shared
    @ObservedObject var friendRequestManager = FriendRequestManager.shared
    // @ObservedObject var froopDataListener = FroopDataListener.shared
    @ObservedObject var annotationManager = AnnotationManager.shared
    
    @State var guestFirstName: String = ""
    @State var guestLastName: String = ""
    @State var guestURL: String = ""
    @State var guestLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    @State var froopLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    @State var distance: Double = 0.0
    @State var friendDetailOpen: Bool = false
    @Binding var friend: UserData
    @Binding var globalChat: Bool


    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5)
                .frame(height: 75)
                .foregroundColor(.white)
                .opacity(0.8)
                .onAppear {
                    LocationManager.shared.calculateTravelTime(from: friend.coordinate,
                                                               to: appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopLocationCoordinate ?? CLLocationCoordinate2D()) { travelTime in
                        if let travelTime = travelTime {
                            // convert travel time to minutes
                            let travelTimeMinutes = Double(travelTime / 60)
                            distance = travelTimeMinutes
                        }
                    }
                }
                .onChange(of: friend.coordinate.latitude) { oldValue, newValue in
                    LocationManager.shared.calculateTravelTime(from: friend.coordinate,
                                                               to: appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopLocationCoordinate ?? CLLocationCoordinate2D()) { travelTime in
                        if let travelTime = travelTime {
                            // convert travel time to minutes
                            let travelTimeMinutes = Double(travelTime / 60)
                            distance = travelTimeMinutes
                        }
                    }
                }
            
            HStack {
                ZStack {
                    Circle()
                        .frame(width: 65, height: 65)
                    KFImage(URL(string: friend.profileImageUrl))
                        .resizable()
                        .scaledToFill()
                        .frame(width: 65, height: 65)
                        .clipShape(Circle())
                    
                       
                }
                .padding(.top, 3)
                .padding(.bottom, 3)
                .padding(.leading, 10)
                .padding(.trailing, 15)
                
                VStack (alignment: .leading) {
                    Text("\(friend.firstName) \(friend.lastName)")
                        .font(.system(size: 18))
                        .fontWeight(.medium)
                        .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                        .multilineTextAlignment(.leading)
                    Text("ETA in \(String(format: "%.0f", distance)) minutes")
                        .font(.system(size: 14))
                        .fontWeight(.regular)
                        .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                        .multilineTextAlignment(.leading)
                        
                }
                .offset(x: -10)
                Spacer()
                ZStack {
                    Rectangle()
                        .frame(width: 50, height: 50)
                        .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                        .opacity(0.5)
                        
                    Button(action: {
                        NavLocationServices.shared.selectedFroopTab = .map
                        annotationManager.zoomToGuestLocation(friend.coordinate)
                    }) {
                        Image(systemName: "car.rear.road.lane.dashed")
                            .foregroundColor(.white)
                            .font(.system(size: 24))
                            .fontWeight(.semibold)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                    }
                }
                .padding(.trailing, 10)
                .background(Color.clear)
            }
            .background(Color.clear)
        }
        .background(Color.clear)
        .onTapGesture {
            if friend.froopUserID != FirebaseServices.shared.uid {
                friendDetailOpen = true
            }
        }
        
        .fullScreenCover(isPresented: $friendDetailOpen) {
            //                friendListViewOpen = false
        } content: {
            ZStack {
                VStack {
                    Spacer()
                    UserDetailView4(friend: $friend, friendDetailOpen: $friendDetailOpen, globalChat: $globalChat)
//                        .ignoresSafeArea()
                }
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "xmark")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .blendMode(.difference)
                            .padding(.trailing, 40)
                            .padding(.top, UIScreen.screenHeight * 0.005)
                            .onTapGesture {
                                self.friendDetailOpen = false
                                print("CLEAR TAP MainFriendView 5")
                            }
                    }
                    .frame(alignment: .trailing)
                    Spacer()
                }
            }
            .onAppear {
                friendRequestManager.selectedFriend = friend
            }
        }
     
    }
}

