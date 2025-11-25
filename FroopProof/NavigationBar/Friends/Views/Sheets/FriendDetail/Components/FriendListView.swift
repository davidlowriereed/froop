import SwiftUI
import Firebase
import UIKit
import FirebaseFirestore
import SwiftUIBlurView

struct FriendListView: View {
    @ObservedObject var froopManager = FroopManager.shared
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var friendRequestManager = FriendRequestManager.shared
    var db = FirebaseServices.shared.db
//    @ObservedObject var friendData: UserData = UserData()
    @ObservedObject var myData = MyData.shared
    @State var refresh = false
    @ObservedObject var friendStore = FriendStore()
    let uid = FirebaseServices.shared.uid
    
    var body: some View {
        ZStack {
            Rectangle()
                .frame(height: 1200)
                .foregroundColor(.white)
                .opacity(0.001)
            if myData.myFriends.contains(where: { $0.froopUserID == friendRequestManager.selectedFriend.froopUserID}) || uid == uid {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 15) {
                        // Assuming friendRequestManager.currentFriends is an array of friends
                        ForEach(friendRequestManager.currentFriends.chunked(into: 3), id: \.self) { friendGroup in
                            HStack(spacing: 15) {
                                ForEach(friendGroup, id: \.id) { friend in
                                    FriendOfFriendCardView(friend: friend)
                                }
                            }
                        }
                    }
                }
                .padding(.top, 10)
                .shadow(color: .gray, radius: 2)
            } else {
                // Optionally handle the case where the condition is not met
                Text("You must be connected as Friends to see other people's friend lists.")
            }
        }
        .onAppear {
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
    }
}

