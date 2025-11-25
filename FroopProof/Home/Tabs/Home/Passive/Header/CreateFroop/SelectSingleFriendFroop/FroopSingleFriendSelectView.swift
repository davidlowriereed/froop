//
//  FroopSingleFriendSelectView.swift
//  FroopProof
//
//  Created by David Reed on 3/20/24.
//

import Foundation
import SwiftUI
import UIKit
import SwiftUIBlurView

struct FroopSingleFriendSelectView: View {
    
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var navLocationServices = NavLocationServices.shared
    @ObservedObject var changeView = ChangeView.shared
//    @ObservedObject var froopDataListener = FroopDataListener.shared
    @ObservedObject var myData = MyData.shared
    @ObservedObject var froopDataController = FroopDataController.shared
    @ObservedObject var froopManager = FroopManager.shared
    @ObservedObject var froopData = FroopData.shared

    var uid = FirebaseServices.shared.uid
    @ObservedObject var friendData: UserData = UserData()
    @ObservedObject var userData = UserData()
    @ObservedObject var friendViewController = FriendViewController.shared
//    @ObservedObject var friendListData = FriendListData(dictionary: [:])
    @State var invitedFriends: [UserData] = []
    @State var inviteExternalFriendsOpen = false
    @State var selectedFriend: UserData? = nil
    @State var addFraction = 0.3
    @State private var searchText: String = ""
    @State var refresh = false
    var timestamp: Date
    @State var fromUserID: String = ""
    @Environment(\.presentationMode) var presentationMode
    @State private var showingAlert = false
    
    var editable = {
        if ChangeView.shared.currentViewBuildOrder[5] != 0 {
            true
        } else {
            false
        }
    }

    
    
    private var guestUidList: [String] {
        return invitedFriends.map { $0.froopUserID }
    }
    @State var userFriendList: [UserData] = []
    
    var filteredFriends: [UserData] {
        return FriendViewController.shared.filteredFriends(friends: myData.myFriends, searchText: searchText)
    } 
    
    var blurRadius = 10
    
    var body: some View {
        ZStack (alignment: .top){
            Rectangle()
                .foregroundColor(.white)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .onAppear {
                    print("Filtered friends: \(filteredFriends)")
                    print("myData.myFriends: \(myData.myFriends)")
                }
            
            VStack {
                Text("Who will pick you up?")
                    .font(.system(size: 36))
                    .fontWeight(.thin)
                    .multilineTextAlignment(.center)
                    .padding(.top, 100)
                    .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                    
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        ForEach(filteredFriends.chunked(into: 3), id: \.self) { friendGroup in
                            HStack(spacing: 0) {
                                ForEach(friendGroup, id: \.id) { friend in
                                    SelectFriendProfileView(
                                        invitedFriends: $invitedFriends, // Provide a non-optional binding
                                        selectedFriend: $selectedFriend, friend: friend
                                    )
                                }
                            }
                        }
                    }
                }
                
                .searchable(text: $searchText)
                .font(.system(size: 18))
                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                .offset(y: -15)
                Spacer()
                
                Button(action: {
                    if let selectedFriend = selectedFriend {
                        if !froopData.froopInvitedFriends.contains(selectedFriend.froopUserID) {
                            froopData.froopInvitedFriends.append(selectedFriend.froopUserID)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                if changeView.froopIsEditing {
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        changeView.pageNumber = changeView.showSummary
                                    }
                                } else {
                                    changeView.pageNumber += 1
                                }
                            }
                            print("Friend invited: \(selectedFriend.firstName) \(selectedFriend.lastName)")
                        }
                    }
                }) {
                    Text(selectedFriend?.froopUserID != nil ? "Confirm Friend" : "Select Later")
                        .font(.headline)
                        .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                        .font(.system(size: 24))
                        .fontWeight(.medium)
                        .padding()
                        .cornerRadius(5)
                        .border(.gray, width: 0.25)
                        .padding(.bottom, 60)
                }
            }
            .padding(.top, 100)
            .ignoresSafeArea()
        }
    }
}



