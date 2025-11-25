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

struct AddFriendCardView: View {
    @ObservedObject var froopManager = FroopManager.shared
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var navLocationServices = NavLocationServices.shared
    
    var db = FirebaseServices.shared.db
    @State var guestStatus: GuestStatus = .none
    @Binding var invitedFriends: [UserData]
    var friend: UserData
    @State var selectedGuest = false
    @Binding var detailGuests: [UserData]
    
    var isSelectedFroopInFilteredHistory: Bool {
        appStateManager.currentFilteredFroopHistory.contains { froopHistory in
            froopHistory.froop.froopId == froopManager.selectedFroopHistory.froop.froopId
        }
    }
    
    var body: some View {
        ZStack {
            VStack (spacing: 0) {
                KFImage(URL(string: friend.profileImageUrl))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 90, height: 90)
                    .clipShape(Circle())
                    .opacity(guestStatus == .declined ? 0.25 : 1.0)
                    .overlay(guestStatus == .none ? Circle().stroke(Color(.clear), lineWidth: 0) : guestStatus == .inviting ? Circle().stroke(Color(red: 249/255, green: 0/255, blue: 98/255), lineWidth: 5) : guestStatus == .invited ? Circle().stroke(Color(red: 249/255, green: 0/255, blue: 98/255), lineWidth: 5) : (guestStatus == .confirmed ? Circle().stroke(Color.blue, lineWidth: 5) : Circle().stroke(Color.gray, lineWidth: 0)))

                Text(friend.lastName != "" ? "\(friend.firstName) \(String(friend.lastName.prefix(1)))." : "\(friend.firstName)")
                    .font(.body)
                    .fontWeight(.light)
                    .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                    .padding(2)
            }
            .frame(width: 125, height: 125)
            .cornerRadius(10)
            .padding(.top, 5)
            .onAppear {
                print("👩‍❤️‍👨👩‍❤️‍👨 \(friend.firstName) \(friend.lastName) \(friend.froopUserID)")
            }
            
            ZStack {
                Circle()
                    .frame(width: 35, height: 35)
                    .foregroundColor(guestStatus == .invited || guestStatus == .inviting ? Color(red: 249/255, green: 0/255, blue: 98/255) : guestStatus == .confirmed ? .blue : .gray)
                    .opacity(guestStatus != .none ? 1.0 : 0.0)
                
                Image(systemName: guestStatus == .declined ? "xmark" : "checkmark")
                    .font(.system(size: 14))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .opacity(guestStatus != .none ? 1.0 : 0.0)
            }
            .offset(x: 35)
            .offset(y: -35)
        }
        .onTapGesture {
            handleTap(for: friend.froopUserID)
        }
        .onAppear {
            guestStatus = getGuestStatus(for: friend.froopUserID)
            // Set guestStatus based on the guest's presence in inviteList, confirmedList, or declinedList documents
            let uid = FirebaseServices.shared.uid
          
            let invitedFriendsRef: CollectionReference
              
              if !isSelectedFroopInFilteredHistory {
                  invitedFriendsRef = db.collection("users").document(froopManager.selectedFroopHistory.host.froopUserID).collection("myFroops").document(froopManager.selectedFroopUUID ?? "" ).collection("invitedFriends")
              } else {
                  invitedFriendsRef = db.collection("users").document(appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.host.froopUserID ?? "").collection("myFroops").document(appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopId ?? "" ).collection("invitedFriends")
              }
            
            let inviteListDocRef = invitedFriendsRef.document("inviteList")
            let declinedListDocRef = invitedFriendsRef.document("declinedList")
            let confirmedListDocRef = invitedFriendsRef.document("confirmedList")
            
            inviteListDocRef.getDocument { document, error in
                if let document = document, document.exists {
                    let invitedFriendUIDs = document.data()?["uid"] as? [String] ?? []
                    if invitedFriendUIDs.contains(friend.froopUserID) {
                        guestStatus = .invited
                    }
                }
            }
            
            declinedListDocRef.getDocument { document, error in
                if let document = document, document.exists {
                    let declinedFriendUIDs = document.data()?["uid"] as? [String] ?? []
                    if declinedFriendUIDs.contains(friend.froopUserID) {
                        guestStatus = .declined
                    }
                }
            }
            
            confirmedListDocRef.getDocument { document, error in
                if let document = document, document.exists {
                    let confirmedFriendUIDs = document.data()?["uid"] as? [String] ?? []
                    if confirmedFriendUIDs.contains(friend.froopUserID) {
                        guestStatus = .confirmed
                    }
                }
            }
            
        }
        .onAppear {
            // check if friend.froopUserId is present in detailGuests.friend.froopUserId
            selectedGuest = detailGuests.contains { $0.froopUserID == friend.froopUserID }
        }
    }
    private func getGuestStatus(for friendID: String) -> GuestStatus {
        if invitedFriends.contains(where: { $0.froopUserID == friendID }) {
            return .invited
        } else if detailGuests.contains(where: { $0.froopUserID == friendID }) {
            return .confirmed
        } else if detailGuests.contains(where: { $0.froopUserID == friendID }) {
            return .declined
        }
        return .none
    }
    
    private func handleTap(for friendID: String) {
        switch guestStatus {
            case .none:
                guestStatus = .inviting
                invitedFriends.append(friend)
//                print("case .none - user's ID:  \(friendID)")
            case .inviting:
                guestStatus = .none
                invitedFriends.removeAll(where: { $0.froopUserID == friendID })
//                print("case .inviting - user's ID:  \(friendID)")
                
            case .invited:
                guestStatus = .none
                invitedFriends.removeAll(where: { $0.froopUserID == friendID })
//                print("case .invited - user's ID:  \(friendID)")
                
            default:
                break
        }
    }
}


