//
//  AddFriendCardView.swift
//  FroopProof
//
//  Created by David Reed on 3/8/23.
//

import SwiftUI
import UIKit
import Kingfisher
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct SelectFriendProfileView: View {
    @ObservedObject var froopManager = FroopManager.shared
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var navLocationServices = NavLocationServices.shared
    @ObservedObject var changeView = ChangeView.shared
    @State var guestStatus: GuestStatus = .none
    @Binding var invitedFriends: [UserData]
    @Binding var selectedFriend: UserData?
    var friend: UserData
    @State var selectedGuest = false
    
    var body: some View {
        ZStack {
            VStack (spacing: 0) {
                KFImage(URL(string: friend.profileImageUrl))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 90, height: 90)
                    .clipShape(Circle())
                    .opacity(guestStatus == .declined ? 0.25 : 1.0
                    )
                    .overlay(
                        
                        friend.froopUserID != selectedFriend?.froopUserID ?
                        Circle().stroke(Color(.clear), lineWidth: 0) :
                            
                            friend.froopUserID == selectedFriend?.froopUserID ?
                            Circle().stroke(Color(red: 249/255, green: 0/255, blue: 98/255), lineWidth: 5) :
                            Circle().stroke(Color.gray, lineWidth: 0))

                Text(friend.lastName != "" ? "\(friend.firstName) \(String(friend.lastName.prefix(1)))." : "\(friend.firstName)")
                    .font(.body)
                    .fontWeight(.light)
                    .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                    .padding(2)
            }
            .frame(width: 125, height: 125)
            .cornerRadius(10)
            .padding(.top, 5)
            
            ZStack {
                Circle()
                    .frame(width: 35, height: 35)
                    .foregroundColor(guestStatus == .invited || guestStatus == .inviting ? Color(red: 249/255, green: 0/255, blue: 98/255) : guestStatus == .confirmed ? .blue : .gray)
                
                Image(systemName: guestStatus == .declined ? "xmark" : "checkmark")
                    .font(.system(size: 14))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .opacity(friend.froopUserID != selectedFriend?.froopUserID ? 0.0 : 1.0)
            .offset(x: 35)
            .offset(y: -35)
        }
        .onTapGesture {
            handleTap(for: friend.froopUserID)
        }
    }
    
    private func handleTap(for friendID: String) {
        if let selectedFriend = selectedFriend, selectedFriend.froopUserID == friendID {
            // Deselect if the same friend is tapped
            self.selectedFriend = nil
            guestStatus = .none
        } else {
            // Select the new friend
            self.selectedFriend = friend
            changeView.singleUserData = friend
            guestStatus = .invited // Or any status you prefer for a selected state
        }
    }
}


