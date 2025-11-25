//
//  BeMyFriendView.swift
//  FroopProof
//
//  Created by David Reed on 2/12/23.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import iPhoneNumberField
import UIKit
import Kingfisher

struct BeMyFriendView: View {
    
    
//    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var navLocationServices = NavLocationServices.shared
    // @ObservedObject var froopDataListener = FroopDataListener.shared
 
    
    @ObservedObject var myData = MyData.shared
    @ObservedObject var friendViewController = FriendViewController.shared
    @State var friendInviteList: [FriendInviteData] = []
    
    @State var friendInvite: FriendInviteData = FriendInviteData(dictionary: [:])
    private let uid = FirebaseServices.shared.uid
    @Binding var toUserID: String
    @State private var isLoaded = false // Add a new state property for loading data
    @State private var pendingFriends = true
    @State var statusX: String = "pending"
    
    var body: some View {
        
     
        ScrollView(showsIndicators: false) {
            VStack(spacing: 10) {
                if isLoaded {
                    if friendInviteList.isEmpty {
                        Text("You have no friend requests at this time.")
                            .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255))
                            .font(.system(size: 24))
                            .fontWeight(.light)
                            .padding(.top, 100)
                            .padding(.leading, 25)
                            .padding(.trailing, 25)
                            .multilineTextAlignment(.center)
                    } else {
                        ForEach(friendInviteList, content: { result in
                            FriendAcceptCardView(friendInvite: result, fromUserID: result.fromUserID)
                        })
                    }
                }
            }
        }
            
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .onAppear {
                FriendViewController.shared.findFriendInvites(thisUser: uid, statusX: statusX) { friendInviteList, error in
                    if let error = error {
                        print("🚫Error fetching friend invites: \(error.localizedDescription)")
                        return
                    }
                    self.friendInviteList = friendInviteList
                }
                isLoaded = true
            }
            .onAppear {
                print("Loading friend requests...")
            }
            .onDisappear {
                isLoaded = false
            }
            .onChange(of: statusX, initial: true) { _, newValue in
                FriendViewController.shared.findFriendInvites(thisUser: uid, statusX: statusX) { friendInviteList, error in
                    if let error = error {
                        print("🚫Error fetching friend invites: \(error.localizedDescription)")
                        return
                    }
                    self.friendInviteList = friendInviteList
                }
                isLoaded = true
            }

        
        Button {
            if pendingFriends {
                statusX = "rejected"
                pendingFriends = false
                isLoaded = false
            } else {
                statusX = "pending"
                pendingFriends = true
                isLoaded = false
            }
        } label: {
            Text(pendingFriends ? "View Declined Friend Requests" : "View Pending Friend Requests")
                .font(.system(size: 16))
                .fontWeight(.medium)
                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                .frame(width: 270, height: 35)
                .border(.gray, width: 0.25)
            
        }
        .padding(.leading, 25)
        .padding(.trailing, 25)
        
        
    }
        
}

