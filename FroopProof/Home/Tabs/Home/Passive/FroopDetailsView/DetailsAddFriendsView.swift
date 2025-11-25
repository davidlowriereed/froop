//
//  DetailsAddFriendsView.swift
//  FroopProof
//
//  Created by David Reed on 6/21/23.
//

import SwiftUI

struct DetailsAddFriendsView: View {
    
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var printControl = PrintControl.shared
//     @ObservedObject var froopDataListener = FroopDataListener.shared
    @ObservedObject var myData = MyData.shared
    @ObservedObject var froopManager = FroopManager.shared
    @ObservedObject var friendViewController = FriendViewController.shared
    @ObservedObject var timeZoneManager: TimeZoneManager = TimeZoneManager()
    @ObservedObject var froopData = FroopData.shared
    @ObservedObject var friendData: UserData = UserData()
    @State var selectedFroopUUID: String = ""
    @Binding var froopAdded: Bool
    
    var body: some View {
        
        VStack {
            HStack {
                
                if froopManager.selectedFroopHistory.froopStatus == .none {
                    
                    EmptyView()
                    
                } else {
                    
                    if (FirebaseServices.shared.uid) == froopManager.selectedFroopHistory.froop.froopHost {
                        ZStack (alignment: .center) {
                            VStack {
                                Spacer()
                                Rectangle()
                                    .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                    .opacity(1)
                                    .ignoresSafeArea()
                                
                            }
                            .frame(maxHeight: 100)
                            
                            
                            Button {
                                PrintControl.shared.printFroopDetails("Adding Friends")
                                froopManager.addFriendsOpen = true
                                PrintControl.shared.printFroopDetails("editing froop details")
                                froopManager.updateFroopHistoryToggle.toggle()
                                //froopManager.froopDetailOpen = false
                            } label:{
                                HStack () {
                                    Spacer()
                                    Text("INVITE")
                                        .font(.system(size: 18, weight: .thin))
                                        .foregroundColor(.white)
//                                        .frame(width: 125, height: 50)
                                        .padding(.bottom, 15)
                                
                                    Image(systemName: "plus")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(.white)
//                                        .frame(width: 75, height: 75)
                                        .padding(.bottom, 15)
                                    
                                    Text("PEOPLE")
                                        .font(.system(size: 18, weight: .thin))
                                        .foregroundColor(.white)
//                                        .frame(width: 175, height: 50)
                                        .padding(.bottom, 15)
                                    Spacer()
                                }
                            }
                        }
                        
                    } else {
                        VStack {
                            Spacer()
                            Rectangle()
                                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                .opacity(1)
                                .ignoresSafeArea()
                            
                        }
                        .frame(maxHeight: 100)
                    }
                }
            }
            .ignoresSafeArea()
        }
    }
}
