//
//  PendingGuestView.swift
//  FroopProof
//
//  Created by David Reed on 3/6/24.
//

import SwiftUI
import Foundation
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import UIKit
import Combine
import MapKit
import Kingfisher
import PhotosUI

struct PendingGuestView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var navLocationServices = NavLocationServices.shared
    @ObservedObject var myData = MyData.shared
    @ObservedObject var froopManager = FroopManager.shared
    @ObservedObject var friendViewController = FriendViewController.shared
    @ObservedObject var timeZoneManager: TimeZoneManager = TimeZoneManager()
    @ObservedObject var froopData = FroopData.shared
    @ObservedObject var friendData: UserData = UserData()
    @ObservedObject var viewModel = DetailsGuestViewModel.shared
    
    @State var detailsTab = 1
    @State var selectedTab = 1
    @State var rectangleHeight: CGFloat = 100
    @State var rectangleY: CGFloat = 100
    @State var pendingHelp: Bool = false
    @State var approveGuest: Bool = false
    
    @Binding var selectedFroopHistory: FroopHistory
    @Binding var miniFriendDetailOpen: Bool
    @Binding var miniFriend: UserData
    
    var db = FirebaseServices.shared.db
    var uid = FirebaseServices.shared.uid
    var gridItems = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        VStack (spacing: 0){
            ZStack {
                Rectangle()
                    .frame(height: 75)
                    .foregroundColor(colorScheme == .dark ? Color(red: 250/255 , green: 250/255, blue: 255/255) : Color(red: 250/255 , green: 250/255, blue: 255/255))
                
                VStack {
                    Spacer()
                    ZStack{
                        VStack {
                            ZStack {
                                HStack {
                                    Spacer()
                                    Image(systemName: "questionmark.circle")
                                        .foregroundColor(Color(red: 255/255, green: 49/255, blue: 97/255))
                                        .font(.system(size: 20))
                                        .fontWeight(.regular)
                                        .offset(x: 20)
                                        .offset(y: -15)
                                        .onTapGesture {
                                            pendingHelp = true
                                        }
                                }
                                Text("GUESTS PENDING YOUR APPROVAL")
                                    .foregroundColor(Color(red: 255/255, green: 49/255, blue: 97/255))
                                    .font(.system(size: 15))
                                    .fontWeight(.semibold)
                                    .offset(y: -15)
                                    .onTapGesture {
                                        print("invited: \(viewModel.selectedFroopHistory.pendingFriends.count)")
                                    }
                            }
                            HStack {
                                
                                Spacer()
                                Text("Guests Still Pending:")
                                    .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                    .font(.system(size: 14))
                                    .fontWeight(.semibold)
                                    .onTapGesture {
                                        selectedTab = 1
                                    }
                                
                                Text(viewModel.selectedFroopHistory.pendingFriends.count.description)
                                    .foregroundColor(Color(red: 255/255, green: 49/255, blue: 97/255))
                                    .font(.system(size: 14))
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                        }
                    }
                    .padding(.bottom, 10)
                    .padding(.trailing, 40)
                    .padding(.leading, 40)
                }
                .frame(maxHeight: 75)
            }
            .onChange(of: froopManager.updateFroopHistoryToggle) {
                viewModel.stampCurrentFroopHistory(for: froopManager.selectedFroopHistory.froop)
            }
            
            ZStack {
                Rectangle()
                    .border(Color(red: 50/255, green: 46/255, blue: 62/255), width: 0.25)
                    .frame(height: 100)
                    .foregroundColor(colorScheme == .dark ? Color(red: 250/255 ,green: 250/255, blue: 255/255) : Color(red: 250/255, green: 250/255, blue: 255/255))
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(viewModel.selectedFroopHistory.pendingFriends, id: \.self) { friend in
                            VStack {
                                KFImage(URL(string: friend.profileImageUrl))
                                    .resizable()
                                    .scaledToFill()
                                    .clipShape(Circle())
                                    .frame(width: 50, height: 50)
                                Text(friend.lastName != "" ? "\(friend.firstName) \(String(friend.lastName.prefix(1)))." : "\(friend.firstName)")
                                    .frame(maxWidth: 75)
                                    .font(.system(size: 12))
                                    .fontWeight(.regular)
                                    .foregroundColor(Color(red: 255/255, green: 49/255, blue: 97/255))
                            }
                            .onTapGesture {
                                miniFriend = friend
                                //                                miniFriendDetailOpen = true
                                approveGuest = true
                            }
                        }
                    }
                    .padding(.leading, 25)
                    .padding(.trailing, 25)
                }
                .frame(height: rectangleHeight)
                
                .padding(.trailing, 25)
                .padding(.leading, 25)
            }
        }
        Divider()
            .alert(isPresented: $pendingHelp) {
                Alert(title: Text("Pending Guest Invites"), message: Text("When guests are invited via a Froop Invitation URL, we check if the guest is already in your list of trusted friends.  If they are not in that list, then you will have to approve them before they can join the Froop.  Simply Tap on their profile image, then tap 'Approve'"), dismissButton: .default(Text("OK")))
            }
            .alert(isPresented: $approveGuest) {
                Alert(
                    title: Text("Approve \(miniFriend.firstName)"),
                    message: Text("Would you like to approve \(miniFriend.firstName) \(miniFriend.lastName) with phone number: \(formatPhoneNumber(miniFriend.phoneNumber)) to join your Froop?"),
                    primaryButton: .default(Text("Approve")) {
                        Task {
                            await approveGuest()
                        }
                    },
                    secondaryButton: .destructive(Text("Deny")) {
                        Task {
                            await denyGuest()
                        }
                    }
                )
            }
        
    }
    
    func formatPhoneNumber(_ phoneNumber: String) -> String {
        let cleanedPhoneNumber = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        let mask = "(XXX) XXX-XXXX"
        var result = ""
        var index = cleanedPhoneNumber.startIndex
        for ch in mask where index < cleanedPhoneNumber.endIndex {
            if ch == "X" {
                result.append(cleanedPhoneNumber[index])
                index = cleanedPhoneNumber.index(after: index)
            } else {
                result.append(ch)
            }
        }
        return result
    }
    
    func approveGuest() async {
        // Define the Firestore references
        let froopRef = db.collection("users").document(viewModel.selectedFroopHistory.host.froopUserID)
            .collection("myFroops").document(viewModel.selectedFroopHistory.froop.froopId)
        let myPendingListRef = db.collection("users").document(miniFriend.froopUserID)
            .collection("froopDecisions").document("froopLists")
            .collection("myPendingList")
        
        do {
            // Remove the guest's UID from the guestApproveList
            try await froopRef.updateData([
                "guestApproveList": FieldValue.arrayRemove([miniFriend.froopUserID])
            ])
            
            // Fetch documents from the guest's myPendingList containing the froopId
            let querySnapshot = try await myPendingListRef.whereField("froopId", isEqualTo: viewModel.selectedFroopHistory.froop.froopId).getDocuments()
            
            for document in querySnapshot.documents {
                // Delete each document
                try await myPendingListRef.document(document.documentID).delete()
            }
            
            print("Successfully removed guest and cleared pending invites.")
        } catch {
            print("🚫Error approving guest: \(error.localizedDescription)")
        }
    }
    
    func denyGuest() async {
        // Implement logic for denying the guest here
        print("Guest denied")
    }
}



