//
//  UserDetailView2.swift
//  FroopProof
//
//  Created by David Reed on 8/21/23.
//

import SwiftUI
import UserNotifications

struct UserDetailView2: View {
    @ObservedObject var dataController = DataController.shared
    @ObservedObject var chatManager = FroopChatNotificationsManager.shared
    @Binding var selectedFriend: UserData
    @State var showInviteView = false
    @State var profileView: Bool = true
    @State var friendDetailOpen: Bool = false
    @State var currentFriends: [UserData] = []
    @Binding var globalChat: Bool

    var body: some View {
        ZStack {
            GeometryReader {
                let size = $0.size
                let safeArea = $0.safeAreaInsets
                
                UserPublicView(size: size, safeArea: safeArea, profileView: $profileView, friendDetailOpen: $friendDetailOpen, globalChat: $globalChat)
                    .ignoresSafeArea(.all, edges: .top)
                    .onAppear {
                        dataController.getUserDataFriends(uid: selectedFriend.froopUserID) { result in
                            switch result {
                            case .success(let friends):
                                self.currentFriends = friends
                            case .failure(let error):
                                print("🚫Error fetching friends 2: \(error.localizedDescription)")
                                // Handle the error appropriately
                            }
                        }
                    }
            }
            
            if dataController.allSelected > 0 {
                VStack {
                    Spacer()
                    ZStack {
                        Rectangle()
                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                            .opacity(0.7)
                            .frame(height: 100)
                        Text("Invite to a Froop")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .fontWeight(.thin)
                            .padding(.horizontal)
                            .padding(.bottom, 40)
                    }
                    .transition(.opacity)
                    
                }
                .ignoresSafeArea()
            } else {
                EmptyView()
            }
        }
        .onAppear {
            globalChat = true
//            print("🙊")

        }
    }
}

struct UserDetailView3: View {
    @ObservedObject var dataController = DataController.shared

    @State var showInviteView = false
    @State var profileView: Bool = true
    @Binding var selectedMapFriend: UserData
    @Binding var friendDetailOpen: Bool
    @State var currentFriends: [UserData] = []
    @Binding var globalChat: Bool

    var body: some View {
        ZStack {

            GeometryReader {
                let size = $0.size
                let safeArea = $0.safeAreaInsets
                
                UserPublicView(size: size, safeArea: safeArea, profileView: $profileView, friendDetailOpen: $friendDetailOpen, globalChat: $globalChat)
                    .ignoresSafeArea(.all, edges: .top)
            }
            
            if dataController.allSelected > 0 {
                VStack {
                    Spacer()
                    ZStack {
                        Rectangle()
                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                            .opacity(0.7)
                            .frame(height: 100)
                        Text("Invite to a Froop")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .fontWeight(.thin)
                            .padding(.horizontal)
                            .padding(.bottom, 40)
                    }
                    .transition(.opacity)
                    
                }
                .ignoresSafeArea()
            } else {
                EmptyView()
            }
        }
        .onAppear {
            globalChat = false
//            print("🙉")
        }
    }
}

struct UserDetailView4: View {
    @ObservedObject var dataController = DataController.shared

    @State var showInviteView = false
    @State var profileView: Bool = true
    @Binding var friend: UserData
    @Binding var friendDetailOpen: Bool
    @State var currentFriends: [UserData] = []
    @Binding var globalChat: Bool

    
    var body: some View {
        ZStack {
            GeometryReader {
                let size = $0.size
                let safeArea = $0.safeAreaInsets
                
                UserPublicView(size: size, safeArea: safeArea, profileView: $profileView, friendDetailOpen: $friendDetailOpen, globalChat: $globalChat)
                    .ignoresSafeArea(.all, edges: .top)
                    .onAppear {
                        dataController.getUserDataFriends(uid: friend.froopUserID) { result in
                            switch result {
                            case .success(let friends):
                                self.currentFriends = friends
                            case .failure(let error):
                                print("🚫Error fetching friends 4: \(error.localizedDescription)")
                                // Handle the error appropriately
                            }
                        }
                    }
            }
            
            if dataController.allSelected > 0 {
                VStack {
                    Spacer()
                    ZStack {
                        Rectangle()
                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                            .opacity(0.7)
                            .frame(height: 100)
                        Text("Invite to a Froop")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .fontWeight(.thin)
                            .padding(.horizontal)
                            .padding(.bottom, 40)
                    }
                    .transition(.opacity)
                    
                }
                .ignoresSafeArea()
            } else {
                EmptyView()
            }
        }
        .onAppear {
            globalChat = false
//            print("🙈")
        }
    }
}
