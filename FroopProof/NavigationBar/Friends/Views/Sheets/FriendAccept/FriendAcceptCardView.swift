//
//  FriendAcceptCardView.swift
//  FroopProof
//
//  Created by David Reed on 2/18/23.
//

import SwiftUI
import UIKit
import Kingfisher

struct FriendAcceptCardView: View {
    
//    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var navLocationServices = NavLocationServices.shared
    // @ObservedObject var froopDataListener = FroopDataListener.shared
    
    
    @ObservedObject var myData = MyData.shared
    @ObservedObject var friendViewController = FriendViewController.shared
    @ObservedObject var friendInviteData: FriendInviteData = FriendInviteData(dictionary: [:])
    
    @State var friendInvite: FriendInviteData = FriendInviteData(dictionary: [:])
    @State var fromUserID: String = ""
    @State var friendDataList: [UserData] = []
    @State var extractedFD: UserData = UserData()
    @State private var isConfirmed = false
    @State private var isAccepted = false
    @State private var isRejected = false
    
    @State private var isLoading = false
    
    var timestamp: Date = Date ()
    var uid = FirebaseServices.shared.uid
    
    
    var body: some View {
        ZStack (alignment: .top){
            RoundedRectangle(cornerRadius: 10)
                .frame(height: 280)
                .foregroundColor(.white)
                .padding(.leading, 10)
                .padding(.trailing, 10)
                .onTapGesture {
                    print("From User ID \(fromUserID))")
                    print("Current User ID \(MyData.shared.froopUserID)")
                }
                .onAppear {
                    FriendViewController.shared.convertIDToFriendData(uid: fromUserID) { friendData, error in
                        if let error = error {
                            print("🚫Error converting ID to friend data: \(error.localizedDescription)")
                            return
                        }
                        extractedFD = friendData ?? UserData()
                    }
                    FriendViewController.shared.getUserFriends(userID: fromUserID) { userFriendsList, error in
                        if let error = error {
                            print("🚫Error getting user friends: \(error.localizedDescription)")
                            return
                        }
                        print("User Friends List: \(userFriendsList))")
                        
                        FriendViewController.shared.getUserFriends(userID: uid) { uidFriendsList, error in
                            if let error = error {
                                print("🚫Error getting user friends: \(error.localizedDescription)")
                                return
                            }
                            print("Current User Friends List: \(uidFriendsList))")
                            
                            FriendViewController.shared.findCommonFriends(userFriendsList: userFriendsList, uidFriendsList: uidFriendsList) { friendsInCommonList, error in
                                if let error = error {
                                    print("🚫Error finding common friends: \(error.localizedDescription)")
                                    return
                                }
                                print("Friends In Common List: \(friendsInCommonList))")
                                
                                FriendViewController.shared.convertListToFriendData(uidList: friendsInCommonList) { friendDataList, error in
                                    if let error = error {
                                        print("🚫Error converting list to friend data: \(error.localizedDescription)")
                                        return
                                    }
                                    print("Friend Data List: \(friendDataList))")
                                    
                                    self.friendDataList = friendDataList
                                }
                            }
                        }
                    }
                    isLoading = true
                }
            
            VStack (alignment: .leading) {
                HStack (alignment: .center){
                    HostProfilePhotoView(imageUrl: isLoading ? extractedFD.profileImageUrl : "")
                        .frame(width: 80, height: 80)
                        .padding(.leading, 10)
                    VStack (alignment: .leading) {
                        Text("Friend Request sent: \(timestamp.addingTimeInterval(600), style: .date)")
                            .font(.system(size: 12))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                            .frame(alignment: .leading)
                        Text(isLoading ? "\(extractedFD.firstName) \(extractedFD.lastName)" : "")
                            .font(.system(size: 18))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                            .frame(alignment: .leading)
                        
                        Text(isLoading ? "Phone Number: \(formatPhoneNumber(extractedFD.phoneNumber))" : "")
                            .font(.system(size: 14))
                            .fontWeight(.light)
                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                            .frame(alignment: .leading)
                            .padding(.top, 10)
                    }
                    .padding(.leading, 10)
                }
                .padding(.top, 10)
                .padding(.leading, 10)
                
                Divider()
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                    .padding(1)
                    .padding(1)
                Text ("Friends in common...")
                    .font(.system(size: 14))
                    .fontWeight(.regular)
                    .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                    .frame(alignment: .leading)
                    .padding(.leading, 25)
                    .padding(.trailing, 25)
                
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 5) {
                        if isLoading {
                            ForEach(friendDataList, id: \.self) { url in
                                KFImage(URL(string: url.profileImageUrl))
                                    .placeholder {
                                        Image(systemName: "person.crop.circle.fill")
                                            .font(.system(size: 45))
                                            .foregroundColor(.gray)
                                    }
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 45, height: 45)
                                    .clipShape(Circle())
                            }
                        }
                    }
                    .padding(1)
                    .padding(1)
                    .padding(.leading, 25)
                    .padding(.trailing, 25)
                }
                
                
                Divider()
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                    .padding(1)
                    .padding(1)
                
                VStack(alignment: .center) {
                    if isConfirmed == false {
                        HStack {
                            Button {
                                let friendRequestManager = FriendRequestManager(timestamp: timestamp)
                                friendRequestManager.acceptFriendRequest(fromUserID: fromUserID, toUserID: MyData.shared.froopUserID) { (success) in
                                    isConfirmed = true
                                    isAccepted = true
                                    print("Friend Accepted")
                                }
                            } label: {
                                Text("Accept")
                                    .font(.system(size: 16))
                                    .fontWeight(.medium)
                                    .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                    .frame(width: 150, height: 35)
                                    .border(.gray, width: 0.25)
                            }
                            .padding(.leading, 25)
                            
                            Button {
                                let friendRequestManager = FriendRequestManager(timestamp: timestamp)
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    friendRequestManager.rejectFriendRequest(documentID: friendInvite.documentID)
                                    
                                }
                                isConfirmed = true
                                isAccepted = false
                                withAnimation(.easeInOut(duration: 2)) {
                                    isRejected = true
                                }
                                print("Friend Rejected")
                            } label: {
                                Text("Decline")
                                    .font(.system(size: 16))
                                    .fontWeight(.medium)
                                    .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                    .frame(width: 150, height: 35)
                                    .border(.gray, width: 0.25)
                                
                            }
                            .padding(.leading, 25)
                            .padding(.trailing, 25)
                        }
                        .padding(.top, 10)
                    } else {
                        Text(isAccepted ? ("\(extractedFD.firstName) \(extractedFD.lastName) is now a Friend!") : "You Declined Friendship.")
                            .font(.system(size: 16))
                            .fontWeight(.medium)
                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                            .frame(width: 350, height: 35)
                            .border(.gray, width: 0.25)
                            .padding(.top, 10)
                    }
                }
                .padding(.leading, 30)
                
                Spacer()
            }
        }
        .opacity(isRejected ? 0.0 : 1.0)
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
}
