////
////  DetailFriendCardView.swift
////  FroopProof
////
////  Created by David Reed on 3/24/23.
////
//
//import SwiftUI
//import UIKit
//import Kingfisher
//import Firebase
//import FirebaseAuth
//import FirebaseFirestore
//
//struct DetailFriendCardView: View {
//    @ObservedObject var appStateManager = AppStateManager.shared
//    @ObservedObject var printControl = PrintControl.shared
//    @ObservedObject var navLocationServices = NavLocationServices.shared
//    // @ObservedObject var froopDataListener = FroopDataListener.shared
//    @ObservedObject var froopManager = FroopManager.shared
//    @ObservedObject var friendViewController = FriendViewController.shared
//    @ObservedObject var myData = MyData.shared
//    @ObservedObject var timeZoneManager: TimeZoneManager = TimeZoneManager()
//    
//    var db = FirebaseServices.shared.db
//    @State var guestStatus: detailGuestStatus = .none
//    @Binding var friendDetailOpen: Bool
//    @Binding var invitedFriends: [UserData]
//    var friend: UserData
//    @State var selectedGuest = false
//    @Binding var detailGuests: [UserData]
//    
//    var body: some View {
//        ZStack {
//            VStack (spacing: 0) {
//                KFImage(URL(string: friend.profileImageUrl))
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(width: 60, height: 60)
//                    .clipShape(Circle())
//                    .opacity(guestStatus == .declined ? 0.5 : 1.0)
//                    .overlay(guestStatus == .none ?
//                             
//                             Circle().stroke(
//                                Color(.clear),
//                                lineWidth: 0)
//                             :
//                                guestStatus == .inviting ?
//                             Circle().stroke(
//                                Color(red: 249/255, green: 0/255, blue: 98/255),
//                                lineWidth: 0)
//                             :
//                                guestStatus == .invited ?
//                             Circle().stroke(
//                                Color(red: 249/255, green: 0/255, blue: 98/255),
//                                lineWidth: 0)
//                             :
//                                guestStatus == .confirmed ?
//                             Circle().stroke(
//                                Color(red: 255/255, green: 49/255, blue: 97/255),
//                                lineWidth: 0)
//                             :
//                                Circle().stroke(Color.gray, lineWidth: 0)
//                    )
//                
//                
//                
//
//                Text(friend.lastName != "" ? "\(friend.firstName) \(String(friend.lastName.prefix(1)))." : "\(friend.firstName)")
//                    .font(.system(size: 12))
//                    .fontWeight(.light)
//                    .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
//                    .padding(4)
//            }
//            .frame(width: 100, height: 100)
//            .cornerRadius(10)
//            .padding(.top, 5)
//            
//            ZStack {
//                Circle()
//                    .frame(width: 25, height: 25)
//                    .foregroundColor(guestStatus == .invited || guestStatus == .inviting ? .clear : guestStatus == .confirmed ? .clear : .clear)
//                    .opacity(guestStatus != .none ? 1.0 : 0.0)
//                
//                Image(systemName: guestStatus == .declined ? "xmark" : "checkmark")
//                    .font(.system(size: 12))
//                    .fontWeight(.bold)
//                    .foregroundColor(.clear)
//                    .opacity(guestStatus != .none ? 1.0 : 0.0)
//            }
//            .offset(x: 25)
//            .offset(y: -25)
//        }
//        .onAppear {
//            guestStatus = getGuestStatus(for: friend.froopUserID)
//            // Set guestStatus based on the guest's presence in inviteList, confirmedList, or declinedList documents
//            let uid = FirebaseServices.shared.uid
//        
//            let invitedFriendsRef = db.collection("users").document(uid).collection("myFroops").document(froopManager.selectedFroopUUID ?? "").collection("invitedFriends")
//            
//            let inviteListDocRef = invitedFriendsRef.document("inviteList")
//            let declinedListDocRef = invitedFriendsRef.document("declinedList")
//            let confirmedListDocRef = invitedFriendsRef.document("confirmedList")
//            
//            inviteListDocRef.getDocument { document, error in
//                if let document = document, document.exists {
//                    let invitedFriendUIDs = document.data()?["uid"] as? [String] ?? []
//                    if invitedFriendUIDs.contains(friend.froopUserID) {
//                        guestStatus = .invited
//                    }
//                }
//            }
//            
//            declinedListDocRef.getDocument { document, error in
//                if let document = document, document.exists {
//                    let declinedFriendUIDs = document.data()?["uid"] as? [String] ?? []
//                    if declinedFriendUIDs.contains(friend.froopUserID) {
//                        guestStatus = .declined
//                    }
//                }
//            }
//            
//            confirmedListDocRef.getDocument { document, error in
//                if let document = document, document.exists {
//                    let confirmedFriendUIDs = document.data()?["uid"] as? [String] ?? []
//                    if confirmedFriendUIDs.contains(friend.froopUserID) {
//                        guestStatus = .confirmed
//                    }
//                }
//            }
//            
//        }
//        .onAppear {
//            // check if friend.froopUserId is present in detailGuests.friend.froopUserId
//            selectedGuest = detailGuests.contains { $0.froopUserID == friend.froopUserID }
//        }
//    }
//    private func getGuestStatus(for friendID: String) -> detailGuestStatus {
//        if invitedFriends.contains(where: { $0.froopUserID == friendID }) {
//            return .invited
//        } else if detailGuests.contains(where: { $0.froopUserID == friendID }) {
//            return .confirmed
//        } else if detailGuests.contains(where: { $0.froopUserID == friendID }) {
//            return .declined
//        }
//        return .none
//    }
//    private func handleTap(for friendID: String) {
//        switch guestStatus {
//        case .none:
//            guestStatus = .inviting
//            invitedFriends.append(friend)
//        case .inviting:
//            guestStatus = .none
//            invitedFriends.removeAll(where: { $0.froopUserID == friendID })
//        case .invited:
//            guestStatus = .none
//            invitedFriends.removeAll(where: { $0.froopUserID == friendID })
//        default:
//            break
//        }
//    }
//}
//
//
