//
//  FroopGuestSummaryView.swift
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

struct FroopGuestSummaryView: View {
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

            Text("PERSON PICKING YOU UP")
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
                
                HStack (spacing: 0 ){
                    Image(systemName: "point.filled.topleft.down.curvedto.point.bottomright.up")
                        .frame(width: 60, height: 60)
                        .scaledToFill()
                        .font(.system(size: 24))
                        .fontWeight(.medium)
                        .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255 ))
//                        .padding(.leading, 25)
                        .frame(alignment: .center)
                    
                    VStack (alignment: .leading) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                // Check if froopData.froopInvitedFriends has at least one element and get the first froopUserID
                                if let firstFroopUserID = froopData.froopInvitedFriends.first {
                                    ForEach(myData.myFriends.filter { $0.froopUserID == firstFroopUserID }, id: \.self) { friend in
                                        HStack {
                                            KFImage(URL(string: friend.profileImageUrl))
                                                .resizable()
                                                .scaledToFill()
                                                .clipShape(Circle())
                                                .frame(width: 50, height: 50)
                                            Text(friend.lastName != "" ? "\(friend.firstName) \(String(friend.lastName))" : "\(friend.firstName)")
                                                .font(.system(size: 16))
                                                .fontWeight(.medium)
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.5)
                                                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                            Spacer()
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
                    }
                    Spacer()
                }
            }
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
}



