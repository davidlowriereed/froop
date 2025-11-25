//
//  UserPublicView.swift
//  FroopProof
//
//  Created by David Reed on 8/9/23.
//

import SwiftUI

struct UserPublicView: View {
    @ObservedObject var inviteManager = InviteManager.shared
    @ObservedObject var friendRequestManager = FriendRequestManager.shared
    var size: CGSize
    var safeArea: EdgeInsets
    @Binding var profileView: Bool
    @State var friendsView: Bool = false
    @State private var offsetY: CGFloat = 0
    @Binding var friendDetailOpen: Bool
    @Binding var globalChat: Bool

    
    var body: some View {
        ZStack {
            ScrollViewReader { scrollProxy in
                ZStack {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 5) {
                            ProfileHeaderView(offsetY: $offsetY, profileView: $profileView, size: size, safeArea: safeArea, friendDetailOpen: $friendDetailOpen, globalChat: $globalChat)
                                .zIndex(1000)
                                .ignoresSafeArea()
                            
                            if profileView {
                                if friendRequestManager.selectedFriend.froopUserID == "froop" {
                                    FroopFroopsView(friendDetailOpen: $friendDetailOpen)
                                        .transition(.opacity)
                                } else {
                                    FriendFroopsView(friendDetailOpen: $friendDetailOpen)
                                        .transition(.opacity)
                                }
                            } else {
                                FriendListView() 
                                    .transition(.opacity)
                            }
                        }
                        .id("SCROLLVIEW")
                        .background {
                            ScrollDetector { offset in
                                offsetY = -offset
                            } onDraggingEnd: { offset, velocity in
                                /// Resetting to Intial State, if not Completely Scrolled
                                let headerHeight = (size.height * 0.3) + safeArea.top
                                let minimumHeaderHeight = 65 + safeArea.top
                                
                                let targetEnd = offset + (velocity * 45)
                                if targetEnd < (headerHeight - minimumHeaderHeight) && targetEnd > 0 {
                                    withAnimation(.interactiveSpring(response: 0.55, dampingFraction: 0.65, blendDuration: 0.65)) {
                                        scrollProxy.scrollTo("SCROLLVIEW", anchor: .top)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            inviteManager.fetchFriendList(for: friendRequestManager.selectedFriend.froopUserID) { result in
                switch result {
                    case .success(let fetchedFriends):
                        inviteManager.friends = fetchedFriends
                    case .failure(let error):
                        print("🚫Error fetching friends 7: \(error)")
                }
            }
        }
    }
}




