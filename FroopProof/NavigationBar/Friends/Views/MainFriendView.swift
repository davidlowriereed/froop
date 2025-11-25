import SwiftUI
import Firebase
import UIKit
import FirebaseFirestore
import SwiftUIBlurView

struct MainFriendView: View {
    
//    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var navLocationServices = NavLocationServices.shared
    @ObservedObject var dataController = DataController.shared
    @ObservedObject var friendRequestManager = FriendRequestManager.shared
    @ObservedObject var myData = MyData.shared
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var onboardingData = OnboardingData.shared
    var db = FirebaseServices.shared.db
    var uid = FirebaseServices.shared.uid
    @Binding var areThereFriendRequests: Bool
//    @ObservedObject var friendInviteData: FriendInviteData
//    @ObservedObject var friendStore = FriendStore()
    @ObservedObject var friendListData = FriendListData(dictionary: [:])
    @State var toUserInfo = UserData()
    @State var toUserID = String()
    @State var foundInvite: FriendInviteData?
    @State var friendDetailOpen = false
    @State var friendListViewOpen = false
    @State var selectedFriend: UserData = UserData()
    @State var presentSheetAccept = false
    @State var presentSheetAdd = false
    @State var addFraction = 0.3
    @State var acceptFraction = 0.75
//    @State var numberOfFriendRequests: Int = 0
    @State private var searchText: String = ""
    @State private var isInviteShowing = false
    @State var refresh = false
    @State var invitesNum: Int = 0
    var timestamp: Date
    @State var fromUserID: String = ""
    @State var friendsInCommon: [String] = [""]
    @State private var countUpdated = false
    @Binding var globalChat: Bool
    
    private var friends: Binding<[UserData]> {
        Binding<[UserData]>(
            get: {
                myData.myFriends
            },
            set: {
                myData.myFriends = $0
            }
        )
    }
    
    var friendsFilter: [UserData] {
        if searchText.isEmpty {
            return friends.wrappedValue
        } else {
            return friends.wrappedValue.filter { friend in
                friend.firstName.localizedCaseInsensitiveContains(searchText) ||
                friend.lastName.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var friendUUIDsBinding: Binding<[String]> {
        Binding<[String]>(
            get: { FriendStore.shared.friends.map { $0.froopUserID } },
            set: { friendUUIDs in
                FriendStore.shared.friends = friendUUIDs.map { id in UserData() }
            }
        )
    }
    
    private var friendsBinding: Binding<[UserData]> {
        Binding<[UserData]>(
            get: {
                friendsFilter
            },
            set: { newValue in
                friends.wrappedValue = newValue
            }
        )
    }
    
    var addBlurRadius: CGFloat {
        presentSheetAdd == true ? 10 : 0
    }
    var acceptBlurRadius: CGFloat {
        presentSheetAccept == true ? 10 : 0
    }
    var blurRadius = 10
    
    var body: some View {
        ZStack (alignment: .top){
            VStack {
                SearchBar(text: $searchText)
                    .padding(.top, 25)
                    .onAppear {
                        FirebaseServices.shared.checkSMSInvitations()
                    }
                    .padding(.leading, 75)
                    .padding(.trailing, 75)
                    .padding(.bottom, 25)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        ForEach(uniqueFriends(friends: myData.myFriends, searchText: searchText).chunked(into: 3), id: \.self) { friendGroup in
                            HStack(spacing: 0) {
                                ForEach(friendGroup, id: \.id) { friend in
                                    FriendCardView(friendDetailOpen: $friendDetailOpen, friend: friend)
                                }
                            }
                        }
                    }
                }
                
                //.searchable(text: $searchText)
                .font(.system(size: 18))
                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                .offset(y: -15)
                
            }
            
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    Text(myData.myFriends.isEmpty ? "Tap the" : "")
                        .font(.system(size: 28))
                        .fontWeight(.light)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                    
                    if myData.myFriends.isEmpty {
                        Image(systemName: "plus")
                            .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255))
                            .scaledToFill()
                            .frame(width: 25, height: 25)
                            .font(.system(size: 25))
                            .fontWeight(.semibold)
                    }
                    
                    Text(myData.myFriends.isEmpty ? "icon to add Friends!" : "")
                        .font(.system(size: 28))
                        .fontWeight(.light)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                }
                
                Spacer()
            }
            
            HStack {
                Button {
                    withAnimation (.easeInOut) {
                        presentSheetAccept.toggle()
                        
                    }
                    print("Open Friend Request Sheet View")
                } label: {
                    if countUpdated {
                        Image(systemName: "person.3.fill")
                            .foregroundColor(dataController.numberOfFriendRequests > 0 ? Color(red: 249/255, green: 0/255, blue: 98/255) : .gray)
                        
                            .scaledToFill()
                            .frame(width: 25, height: 25)
                            .font(.system(size: 25))
                            .fontWeight(.light)
                            .overlay(
                                Group {
                                    if dataController.numberOfFriendRequests > 0 {
                                        VStack {
                                            Text(String(dataController.numberOfFriendRequests))
                                                .foregroundColor(.white)
                                                .frame(width: 15, height: 15)
                                                .font(.system(size: 16))
                                                .padding(2)
                                                .background(Circle().foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255)))
                                                .offset(x: 25, y: -12)
                                        }
                                        
                                    }
                                }
                            )
                            .padding(.leading, 25)
                            .padding(.top, 25)
                    }
                    
                    Spacer()
                    Button {
                        withAnimation (.easeInOut) {
                            
                            presentSheetAdd.toggle()
                        }
                        print("CreateNewFriend")
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255))
                            .scaledToFill()
                            .frame(width: 25, height: 25)
                            .font(.system(size: 25))
                            .fontWeight(.semibold)
                        
                    }
                    .padding(.trailing, 25)
                    .padding(.top, 25)
                }
            }
            
        }
        .frame(width: UIScreen.screenWidth)
        .onAppear {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                appStateManager.updateOnboardingState(for: .friends)
//                print("🇧🇼 onboardingData.friendsOnboarding: \(String(describing: onboardingData.friendsOnboarding))")
//                print("🇧🇼 appStateManager.currentViewID: \(String(describing: appStateManager.currentViewID))")
//                print("🇧🇼 appStateManager.showFriendsOnboarding: \(String(describing: appStateManager.showFriendsOnboarding))")
//            }
            let friendRequestsRef = db.collection("friendRequests")
                .whereField("toUserID", isEqualTo: uid)
                .whereField("status", isEqualTo: "pending")
            
            friendRequestsRef.addSnapshotListener { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("🚫Error fetching friend requests: \(String(describing: error))")
                    return
                }
                print("Snapshot Count \(snapshot.documents.count)")
                self.dataController.numberOfFriendRequests = snapshot.documents.count
            }
            countUpdated = true
            
            if dataController.numberOfFriendRequests > 0 {
                isInviteShowing = true
            } else {
                isInviteShowing = false
            }
            myData.fetchFriendList(forUID: uid)
        }
        
        //MARK: FRIEND DETAIL VIEW OPEN
        .fullScreenCover(isPresented: $friendDetailOpen) {
            friendListViewOpen = false
        } content: {
            ZStack {
                VStack {
                    Spacer()
                    FriendDetailView(globalChat: $globalChat)
                    //                        .ignoresSafeArea()
                }
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "xmark")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .blendMode(.difference)
                            .padding(.trailing, 40)
                            .padding(.top, UIScreen.screenHeight * 0.005)
                            .onTapGesture {
                                dataController.allSelected = 0
                                self.friendDetailOpen = false
                                print("CLEAR TAP MainFriendView 3")
                            }
                    }
                    .frame(alignment: .trailing)
                    Spacer()
                }
            }
            .frame(width: UIScreen.screenWidth)
        }
        
        
        //MARK: ACCEPT SHEET
        .blurredSheet(.init(.ultraThinMaterial), show: $presentSheetAccept) {
        } content: {
            ZStack {
                Rectangle()
                    .foregroundColor(.white)
                    .opacity(0.01)
                    .onTapGesture {
                        self.presentSheetAccept = false
                        print("CLEAR TAP Main Friend View 2")
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                VStack {
                    Text("tap to close")
                        .font(.system(size: 18))
                        .fontWeight(.light)
                        .foregroundColor(.white)
                        .padding(.top, 25)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                    Spacer()
                }
                .frame(alignment: .center)
                
                VStack {
                    Spacer()
                    BeMyFriendView(
                        toUserID: $toUserID
                    )
                }
                .frame(height: acceptFraction * UIScreen.main.bounds.height)
            }
            .frame(width: UIScreen.screenWidth)
            .presentationDetents([.large])
        }
        //MARK: ADD SHEET
        .blurredSheet(.init(.ultraThinMaterial), show: $presentSheetAdd) {
        } content: {
            ZStack (alignment: .bottom) {
                Rectangle()
                    .foregroundColor(.white)
                    .opacity(0.01)
                    .onTapGesture {
                        self.presentSheetAdd = false
                        print("CLEAR TAP Main Friend View 3")
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                VStack {
                    Text("tap to close")
                        .font(.system(size: 18))
                        .fontWeight(.light)
                        .foregroundColor(.white)
                        .padding(.top, 25)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                    Spacer()
                }
                .frame(alignment: .center)
                
                VStack {
                    SearchUserView(toUserID: $toUserID)
                }
                //.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            }
            .frame(width: UIScreen.screenWidth)
            .presentationDetents([.large])
        }
    }
    
    func uniqueFriends(friends: [UserData], searchText: String) -> [UserData] {
        var uniqueFriendIDs = Set<String>()
        var uniqueFriends: [UserData] = []

        for friend in friends {
            if uniqueFriendIDs.insert(friend.froopUserID).inserted {
                if searchText.isEmpty || friend.firstName.localizedCaseInsensitiveContains(searchText) || friend.lastName.localizedCaseInsensitiveContains(searchText) {
                    uniqueFriends.append(friend)
                }
            }
        }
        return uniqueFriends
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            TextField("Search...", text: $text)
                .padding(7)
                .padding(.leading, 25)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                        Spacer()
                    }
                        .padding(.horizontal, 10)
                )
        }
        .padding(.horizontal, 10)
    }
}



