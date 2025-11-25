//
//  FriendDetailView.swift
//  FroopProof
//
//  Created by David Reed on 2/16/23.
//

import SwiftUI
import UserNotifications

struct FriendDetailView: View {
    @ObservedObject var dataController = DataController.shared
    @ObservedObject var froopManager = FroopManager.shared
    @ObservedObject var friendRequestManager = FriendRequestManager.shared
    @State var showInviteView = false
    @State var profileView: Bool = true
    @State var friendDetailOpen: Bool = false
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
            froopManager.fetchFriendLists(uid: friendRequestManager.selectedFriend.froopUserID) { friendList in
                froopManager.fetchUserDataFor(uids: friendList) { result in
                    switch result {
                        case .success(let retrievedFriends):
                            // If the operation is successful, assign the retrieved friends to currentFriends
                            friendRequestManager.currentFriends = retrievedFriends
                        case .failure(let error):
                            // If the operation fails, handle the error (e.g., show an error message)
                            print("Error fetching user data: \(error.localizedDescription)")
                            friendRequestManager.currentFriends = [] // Optionally reset or handle the UI accordingly
                    }
                }
            }
        }
    }
}

