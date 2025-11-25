//
//  FriendSearchCardView.swift
//  FroopProof
//
//  Created by David Reed on 2/23/23.
//
import SwiftUI
import UIKit
import Kingfisher
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct FriendSearchCardView: View {
    
//    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var navLocationServices = NavLocationServices.shared 
    // @ObservedObject var froopDataListener = FroopDataListener.shared
    
    @State private var showFriendRequestSentAlert = false
    var uid = FirebaseServices.shared.uid
    var db = FirebaseServices.shared.db
    @ObservedObject var myData = MyData.shared
    @ObservedObject var friendViewController = FriendViewController.shared
    @Binding var extractedFriendData: UserData
    var fromUserID = FirebaseServices.shared.uid
    @State var uidFriendsList: [UserData] = []
    @State var friendDataList: [UserData] = []
    @State var friendInviteData: FriendInviteData = FriendInviteData(dictionary: [:])
    var friendData: UserData
    @Binding var revealed: Bool
    @State private var previousExtractedFriendData: UserData?

    
    
    var body: some View {
        ZStack (alignment: .top){
            RoundedRectangle(cornerRadius: 10)
                .frame(width: UIScreen.screenWidth * 0.95, height: 280)
                .foregroundColor(.white)
                .padding(.leading, 10)
                .padding(.trailing, 10)
                .shadow(color: Color(red: 50/255, green: 46/255, blue: 62/255), radius: 1)
                .onChange(of: extractedFriendData, initial: previousExtractedFriendData != nil) { oldValue, newValue in
                    // Compare if the newValue is different from the previous value
                    guard newValue != oldValue else { return }

                    // Your existing logic
                    FriendViewController.shared.getUserFriends(userID: newValue.froopUserID) { userFriendsList, error in
                        if let error = error {
                            print("🚫Error fetching user friends: \(error.localizedDescription)")
                            return
                        }
                        print("NewValue \(newValue.froopUserID)")
                        print("extractedFriendData \(newValue.froopUserID)")
                        FriendViewController.shared.getUserFriends(userID: uid) { userDataFriendsList, error in
                            if let error = error {
                                print("🚫Error fetching user data friends: \(error.localizedDescription)")
                                return
                            }
                            FriendViewController.shared.findCommonFriends(userFriendsList: userFriendsList, uidFriendsList: userDataFriendsList) { friendsInCommonList, error in
                                if let error = error {
                                    print("🚫Error finding common friends: \(error.localizedDescription)")
                                    return
                                }
                                FriendViewController.shared.convertListToFriendData(uidList: friendsInCommonList) { friendDataList, error in
                                    if let error = error {
                                        print("🚫Error converting list to friend data: \(error.localizedDescription)")
                                        return
                                    }
                                    self.friendDataList = friendDataList
                                    PrintControl.shared.printLists("Dumping Friend Data List \(friendDataList)")
                                }
                            }
                        }
                    }

                    // Update the previous value after your logic
                    previousExtractedFriendData = newValue
                }


            
            VStack {
                VStack (alignment: .leading) {
                    HStack (alignment: .center){
                        HostProfilePhotoView(imageUrl: extractedFriendData.profileImageUrl)
                            .frame(width: 80, height: 80)
                            .padding(.leading, 10)
                        VStack (alignment: .leading){
                            Text("Is this your friend?")
                                .font(.system(size: 12))
                                .fontWeight(.semibold)
                                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                .frame(alignment: .leading)
                            Text("\(extractedFriendData.firstName) \(extractedFriendData.lastName)")
                                .font(.system(size: 18))
                                .fontWeight(.semibold)
                                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                .frame(alignment: .leading)
                            
                            Text("Phone Number: \(extractedFriendData.phoneNumber.formattedPhoneNumber)")
                                .font(.system(size: 14))
                                .fontWeight(.light)
                                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                .frame(alignment: .leading)
                                .padding(.top, 5)
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
                    
                    Text(friendDataList.count <= 0 ? "It doesn't look like you have any friends in common yet..." : " You have friends in common.")
                        .font(.system(size: 14))
                        .fontWeight(.regular)
                        .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                        .frame(alignment: .leading)
                        .padding(.leading, 25)
                        .padding(.trailing, 25)
                    
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 5) {
                            ForEach(friendDataList, id: \.self) { friendData in
                                FriendProfilePhotoView(imageUrl: friendData.profileImageUrl)
                                    .frame(width: 45, height: 45)
                            }
                        }
                    }
                    .padding(1)
                    .padding(1)
                    .padding(.leading, 25)
                    .padding(.trailing, 25)
                    
                    Divider()
                        .padding(.leading, 20)
                        .padding(.trailing, 20)
                        .padding(1)
                        .padding(1)
                }
                VStack (alignment: .center) {
                    HStack (){
                        Button {
                            let timestamp = Date()
                            sendFriendRequest(fromUserID: fromUserID, toUserID: extractedFriendData.froopUserID, friendRequest: friendInviteData, timestamp: timestamp) { result in
                                switch result {
                                case .success(let documentID):
                                    print("Friend request sent: \(documentID)")
                                case .failure(let error):
                                    print("🚫Error sending friend request: \(error.localizedDescription)")
                                }
                            }
                        } label: {
                            ZStack {
                                Rectangle()
                                    .frame(width: 175, height: 40)
                                    .foregroundColor(.clear)
                                    .border(.gray, width: 0.25)
                                Text("Send Friend Request")
                                    .font(.system(size: 16))
                                    .fontWeight(.medium)
                                    .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                            }
                        }
                    }
                }
                .padding(.top, 20)
                .frame(maxWidth: .infinity)
            }
        }
        .frame(width: UIScreen.screenWidth * 0.95)
        .alert(isPresented: $showFriendRequestSentAlert) {
            Alert(title: Text("Friend Request Sent"), message: Text("Your friend request has been sent successfully."), dismissButton: .default(Text("OK")))
        }
    }
       
    
    
    
    func sendFriendRequest(fromUserID: String, toUserID: String, friendRequest: FriendInviteData, timestamp: Date, completion: @escaping (Result<String, Error>) -> Void) {
        
        let friendRequestRef = db.collection("friendRequests").document()
        let documentID = friendRequestRef.documentID
        
        let friendRequest = FriendInviteData(dictionary: [
            "toUserID": toUserID,
            "fromUserID": fromUserID,
            "documentID": documentID,
            "status": "pending",
            "timestamp": timestamp
        ])
        
        friendRequestRef.setData(friendRequest.dictionary) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                // Add friend request to user's friend request list
                let uidRef = db.collection("users").document(fromUserID)
                uidRef.updateData(["friendRequests": FieldValue.arrayUnion([friendRequestRef.documentID])])
                
                // Send push notification to recipient
                let senderName = "\(MyData.shared.firstName) \(MyData.shared.lastName)"
                let message = "\(senderName) sent you a friend request."
                let recipientID = friendRequest.toUserID
                NotificationsManager.sendPushNotification(to: recipientID, title: "Friend Request", body: message, data: ["message": "Hello, you have a friend request from: \(MyData.shared.firstName)!"])
                
                completion(.success(friendRequestRef.documentID))
                self.showFriendRequestSentAlert = true
            }
        }
    }
}



