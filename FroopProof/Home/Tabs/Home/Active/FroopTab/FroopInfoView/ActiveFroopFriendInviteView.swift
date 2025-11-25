//
//  DetailsAddFriendsView.swift
//  FroopProof
//
//  Created by David Reed on 6/21/23.
//

import SwiftUI

struct ActiveFroopFriendInviteView: View {
    
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var printControl = PrintControl.shared
    // @ObservedObject var froopDataListener = FroopDataListener.shared
    @ObservedObject var myData = MyData.shared
    @ObservedObject var froopManager = FroopManager.shared
    @ObservedObject var friendViewController = FriendViewController.shared
    @ObservedObject var timeZoneManager: TimeZoneManager = TimeZoneManager()
    @ObservedObject var froopData = FroopData.shared
    @ObservedObject var friendData: UserData = UserData()
    @State var detailGuests: [UserData] = []
    @State var instanceFroop: FroopHistory
    var timestamp: Date = Date()
    
    //@Binding var froopAdded: Bool
    @Binding var invitedFriends: [UserData]
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    if (FirebaseServices.shared.uid) == appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopHost {
                        ZStack (alignment: .center) {
                           
                            RoundedRectangle(cornerRadius: 25)
                                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                .opacity(0.25)
                                .frame(width: UIScreen.screenWidth * 0.6, height: 50)
                            
                            
                            Button {
                                PrintControl.shared.printFroopDetails("Adding Friends")
                                froopManager.addFriendsOpen = true
                                PrintControl.shared.printFroopDetails("editing froop details")
                                //froopManager.froopDetailOpen = false
                            } label:{
                                HStack (alignment: .center) {
                                    Spacer()
                                    Image(systemName: "plus")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                        .frame(width: 30, height: 50)
                                    if invitedFriends.isEmpty {
                                        Text("INVITE FRIENDS \(appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.confirmedFriends.count ?? 0 )")
                                            .font(.system(size: 18, weight: .thin))
                                            .foregroundColor(.white)
                                            .multilineTextAlignment(.center)
                                            .frame(width: 125, height: 40)
                                    } else {
                                        Text("INVITE FRIENDS")
                                            .font(.system(size: 18, weight: .thin))
                                            .foregroundColor(.white)
                                            .multilineTextAlignment(.center)
                                            .frame(width: 175, height: 40)
                                    }
                                    Spacer()
                                }
                            }
                            .frame(width: UIScreen.screenWidth * 0.6, height: 40)
                            
                        }
                        
                    } else {
                        EmptyView()
                    }
                }
            }
        }
        .blurredSheet(.init(.ultraThinMaterial), show: $froopManager.addFriendsOpen) {
        } content: {
            ZStack {
                VStack {
                    Spacer()
                    
                    AddFriendsActiveFroopView(friendDetailOpen: $froopManager.friendDetailOpen, addFriendsOpen: $froopManager.addFriendsOpen, timestamp: timestamp, detailGuests: $detailGuests)
                }
                
                
                VStack {
                    Rectangle()
                        .foregroundColor(.white)
                        .opacity(0.01)
                        .onTapGesture {
                            self.froopManager.addFriendsOpen = false
                            print("CLEAR TAP Froop Details View")
                            
                        }
                        .frame(maxWidth: .infinity, maxHeight: 100)
                        .ignoresSafeArea()
                    //.border(.pink)
                    Spacer()
                }
                VStack {
                    Text("tap to close")
                        .font(.system(size: 18))
                        .fontWeight(.light)
                        .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.75))
                        .padding(.top, 25)
                        .opacity(0.5)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 24))
                        .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.75))
                    Spacer()
                }
                .frame(alignment: .top)
            }
            .presentationDetents([.large])
        }
    }
}

