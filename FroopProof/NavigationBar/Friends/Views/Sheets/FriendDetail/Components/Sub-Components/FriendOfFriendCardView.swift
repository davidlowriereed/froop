//
//  FriendOfFriendCardView.swift
//  FroopProof
//
//  Created by David Reed on 8/14/23.
//

import SwiftUI
import UIKit
import Kingfisher

struct FriendOfFriendCardView: View {
    
    @ObservedObject var dataController = DataController.shared
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var navLocationServices = NavLocationServices.shared
    @ObservedObject var friendRequestManager = FriendRequestManager.shared
    @ObservedObject var froopManager = FroopManager.shared
    @State private var selected: Bool = false
    @State var currentFriends: [UserData] = []
    
    var friend: UserData
    
    var body: some View {
        VStack (spacing: 0) {
            KFImage(URL(string: friend.profileImageUrl))
                .resizable()
                .scaledToFill()
                .frame(width: 90, height: 90)
                .border(.pink)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.gray, lineWidth: 0))
                .opacity(selected ? 0.5 : 1.0)
            
            Text(friend.lastName != "" ? "\(friend.firstName) \(String(friend.lastName.prefix(1)))." : "\(friend.firstName)")
                .font(.body)
                .fontWeight(.light)
                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                .padding(2)
        }
        .frame(width: 125, height: 125)
        .cornerRadius(10)
        .padding(.top, 5)
        .onTapGesture {
            withAnimation(.smooth()) {
                friendRequestManager.selectedFriend = friend
                
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
//            selected.toggle()
//            print("Selected was Toggled")
//            if selected {
//                print("allSelected as added 1")
//                dataController.allSelected += 1
//            } else {
//                print("allSelected as subtracted 1")
//                dataController.allSelected -= 1
//            }
//            print(dataController.allSelected)
//            print("selected or deselected")
//            print("\(friend.firstName) says they were tapped!")
        }
    }
}
