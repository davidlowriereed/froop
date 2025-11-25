//
//  FroopGuestsSummaryView.swift
//  FroopProof
//
//  Created by David Reed on 6/20/23.
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

struct FroopGuestsSummaryView: View {
    @ObservedObject var froopData = FroopData.shared
    @ObservedObject var myData = MyData.shared
    @ObservedObject var changeView = ChangeView.shared
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var froopManager = FroopManager.shared

    var editable: Bool {
        if ChangeView.shared.froopTypeData?.viewPositions[5] != 0 {
            return true
        } else {
            return false
        }
    }
    
    var body: some View {
        VStack (alignment: .leading) {

            Text("Invite List")
                .font(.system(size: 14))
                .fontWeight(.semibold)
                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.9))
//                .padding(.leading, 15)
                .offset(y: 5)
            
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.white)
                    .opacity(0.8)
                    .frame(height: 75)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.25), lineWidth: 0.25)
                    )
//                    .padding(.leading, 15)
//                    .padding(.trailing, 15)
                
                HStack (alignment: .center, spacing: 0 ){
                    VStack(alignment: .center, spacing: 1 ) {
                        Image(systemName: "person.3.sequence.fill")
                            .scaledToFill()
                            .font(.system(size: 20))
                            .fontWeight(.medium)
                        Text(String(describing: changeView.invitedFriends.count))
                            .font(.system(size: 14))
                            .fontWeight(.bold)
                            .lineLimit(1)
                    }
                    .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255 ))
                    .frame(width: 60, height: 60)
                    .frame(alignment: .center)
//                    .padding(.leading, 10)

                    VStack (alignment: .leading) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                // Check if froopData.froopInvitedFriends has at least one element and get the first froopUserID
                                if let firstFroopUserID = froopData.froopInvitedFriends.first {
                                    ForEach(changeView.invitedFriends, id: \.self) { friend in
                                        VStack {
                                            KFImage(URL(string: friend.profileImageUrl))
                                                .resizable()
                                                .scaledToFill()
                                                .clipShape(Circle())
                                                .frame(width: 40, height: 40)
                                            Text(friend.lastName != "" ? "\(friend.firstName) \(String(friend.lastName.prefix(1)))." : "\(friend.firstName)")
                                                .font(.system(size: 10))
                                                .fontWeight(.medium)
                                                .lineLimit(1)
//                                                .minimumScaleFactor(0.5)
                                                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                                .frame(width: 55)
                                        }
                                    }
                                } else {
                                    // Handle the case where there are no invited friends in froopData.froopInvitedFriends
                                    Text("Adding Friend Later")
                                }
                            }
//                            .padding(.leading, 25)
                            .padding(.trailing, 10)
                        }
                        .padding(.leading, 5)
                    }
                    Spacer()
                }
            }
        }
        .onAppear {
            fetchInvitedFriendsData()
        }
        .frame(width: UIScreen.screenWidth - 40, height: 100)
        .onTapGesture {
            if editable {
                print("💠 changeView.showGuest: \(changeView.showGuest)")
                print(changeView.currentViewBuildOrder)
                froopData.froopInvitedFriends = []
                changeView.pageNumber = changeView.showGuest
            }
        }
    }
    func fetchInvitedFriendsData() {
        // Clear existing data
        changeView.invitedFriends.removeAll()
        
        // Fetch new data
        for uid in froopData.froopInvitedFriends {
            FroopManager.shared.fetchUserData(for: uid) { result in
                switch result {
                    case .success(let userData):
                        DispatchQueue.main.async {
                            changeView.invitedFriends.append(userData)
                        }
                    case .failure(let error):
                        print("Error fetching user data for UID \(uid): \(error)")
                }
            }
        }
    }
}



