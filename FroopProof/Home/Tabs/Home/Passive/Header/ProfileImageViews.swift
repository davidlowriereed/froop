//
//  ProfileImageViews.swift
//  FroopProof
//
//  Created by David Reed on 4/4/24.
//

import SwiftUI
import Kingfisher

struct ProfileImage: View {
    @ObservedObject var friendRequestManager = FriendRequestManager.shared
    var progress: CGFloat
    var headerHeight: CGFloat
    
    var body: some View {
        GeometryReader {
            let rect = $0.frame(in: .global)
            let halfScaledHeight = (rect.height * 1) * 0.15
            let halfScaledWidth = (rect.width * 0.4) * 0.5
            let midY = rect.midY - rect.height / 2
            let midX = rect.midX - rect.width / 2
            let bottomPadding: CGFloat = 0
            let leadingPadding: CGFloat = 0
            let minimumHeaderHeight = 50
            let minimumHeaderWidth = 50
            let resizedOffsetY = (midY - (CGFloat(minimumHeaderHeight) - halfScaledHeight - bottomPadding))
            let resizedOffsetX = (midX - (CGFloat(minimumHeaderWidth) - halfScaledWidth - leadingPadding))
            ZStack {
                Circle()
                    .frame(width: (rect.width + 2) * 1, height: (rect.height + 2) * 1)
                    .foregroundStyle(.white)
                    .shadow(color: Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.2), radius: 7, x: 0, y: -7)
                    .scaleEffect(1 - (progress * 0.6), anchor: .leading)
                    .offset(x: -resizedOffsetX * progress, y: -resizedOffsetY * progress)
                
                KFImage(URL(string: friendRequestManager.selectedFriend.profileImageUrl))
                    .resizable()
                    .scaledToFill()
                    .clipShape(Circle())
                    .frame(width: rect.width * 1, height: rect.height * 1)
                    .scaleEffect(1 - (progress * 0.6), anchor: .leading)
                    .offset(x: -resizedOffsetX * progress, y: -resizedOffsetY * progress)
            }
        }
        .frame(width: headerHeight * 0.35, height: headerHeight * 0.35)
    }
}

struct ProfileImage2: View {
    @ObservedObject var chatManager = GlobalChatNotificationsManager.shared
    
    var body: some View {
        KFImage(URL(string: chatManager.otherUserProfileImageUrl))
            .resizable()
            .scaledToFill()
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            .frame(width: 50, height: 50)
    }
}

struct ProfileImage3: View {
    @ObservedObject var chatManager = GlobalChatNotificationsManager.shared
    @Binding var selectedFriend: UserData
    
    var body: some View {
        KFImage(URL(string: chatManager.otherUserProfileImageUrl))
            .resizable()
            .scaledToFill()
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            .frame(width: 50, height: 50)
    }
}



struct ProfileImage4: View {
//    @ObservedObject var chatManager = GlobalChatNotificationsManager.shared
    let userUrl: String
    
    var body: some View {
        KFImage(URL(string: userUrl))
            .resizable()
            .scaledToFill()
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            .frame(width: 50, height: 50)
    }
}
