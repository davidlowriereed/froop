//
//  FroopCardView.swift
//  FroopProof
//
//  Created by David Reed on 2/6/23.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth
import MapKit


struct FroopCardView: View {
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var navLocationServices = NavLocationServices.shared
    // @ObservedObject var froopDataListener = FroopDataListener.shared
    @ObservedObject var froopData = FroopData.shared
    @ObservedObject var changeView = ChangeView.shared
    
    @State private var showDeleteAlert = false
    @ObservedObject var froopManager = FroopManager.shared
    
    var db = FirebaseServices.shared.db
    @ObservedObject var myData = MyData.shared
    @ObservedObject var friendViewController = FriendViewController.shared
    @ObservedObject var timeZoneManager: TimeZoneManager = TimeZoneManager()
    
//    @State var froop: Froop = Froop(dictionary: [:])
    var froop: Froop
    @Binding var froopDetailOpen: Bool
    //@ObservedObject var froopData: FroopData
  
    @Binding var invitedFriends: [UserData]
    @State private var confirmedFriends: [UserData] = []
    @State private var declinedFriends: [UserData] = []
    @State private var invitedFriendsLocal: [UserData] = []
    @State private var identifiableInvitedFriends: [IdentifiableFriendData] = []
    @State var froopStartTime: Date? = Date()
    @State private var dataLoaded = false
    let visibleFriendsLimit = 8
    @State var myTimeZone: TimeZone = TimeZone.current
    
    
    init(froop: Froop, froopData: FroopData, froopDetailOpen: Binding<Bool>, invitedFriends: Binding<[UserData]>) {
        self.froop = froop
        self._froopDetailOpen = froopDetailOpen
        self._invitedFriends = invitedFriends
        self.froopData = froopData
        
        self.timeZoneManager = TimeZoneManager()

        // Ensure all properties are initialized before this line.
        self.loadConfirmedFriends()
    }


    var body: some View {
        
        ZStack (alignment: .top) {
            RoundedRectangle(cornerRadius: 10)
                .fill(.white)
                .padding(.top, 20)
                .padding(.leading, 25)
                .padding(.trailing, 25)
                .frame(height: 300)
                .shadow(color: .gray, radius: 2)
            VStack (spacing: 0){
                RoundedRectangle(cornerRadius: 10)
                    .fill(.white)
                    .padding(.top, 20)
                    .padding(.leading, 25)
                    .padding(.trailing, 25)
                    .frame(height: 85)
                    .onAppear {
                        FroopManager.shared.froopHolder = froop
                        fetchFriendsData(from: froop.froopInvitedFriends) { fetchedFriends in
                            self.confirmedFriends = fetchedFriends
                            // Additional actions if needed
                        }
                    }
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(red: 245 / 255, green: 245 / 255, blue: 255 / 255 ))
                    .padding(.leading, 25)
                    .padding(.trailing, 25)
                    .frame(height: 215)
                
            }
            .frame(height: 300)
           
            
            
            VStack (alignment: .leading) {
                HStack (spacing: 0 ){
                    VStack (alignment: .leading){
                        Text(froop.froopName)
                            .font(.system(size: 18))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                            .frame(alignment: .leading)
                        
                        Text("Created: \(timeZoneManager.formatDurationSinceCreation(creationDate: froop.froopCreationTime)) ago")
                            .font(.system(size: 11))
                            .fontWeight(.medium)
                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                            .opacity(0.7)
                            .frame(alignment: .leading)
                    }
                    .padding(.leading, 10)
                    
                    Spacer()
                    
                    Button(action: {
                        showDeleteAlert = true
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(Color("FroopPink"))
                    }
                }
                .padding(.top, 35)
                .padding(.leading, 35)
                .padding(.trailing, 35)

                
                ZStack {
                    VStack {
                        HStack {
                            Text("Invite List")
                                .font(.system(size: 12))
                                .fontWeight(.medium)
                                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                .multilineTextAlignment(.leading)
                                .padding(.leading, 5)
                        Spacer()
                        }
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(confirmedFriends.prefix(visibleFriendsLimit - 1), id: \.self.id) { friend in
                                    FriendProfilePhotoView(imageUrl: friend.profileImageUrl)
                                        .frame(width: 45, height: 45)
                                }
                                
                                if confirmedFriends.isEmpty {
                                    Text("Invited Friends \(froop.froopInvitedFriends.count) confirmedFriends: \(confirmedFriends.count)")
                                        .font(.system(size: 16))
                                        .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255))
                                        .frame(height: 45)
                                } else if confirmedFriends.count > visibleFriendsLimit {
                                    ZStack {
                                        FriendProfilePhotoView(imageUrl: "")
                                            .frame(width: 45, height: 45)
                                            .opacity(0.5)
                                        
                                        Text("+\(confirmedFriends.count - visibleFriendsLimit + 1)")
                                            .font(.system(size: 16))
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                            .background(.clear)
                        }
                    }
                    .background(.clear)
                    .padding(.leading, 35)
                    .padding(.trailing, 35)
                }
                .padding(.top, 20)
                
                Divider()
                    .padding(.leading, 35)
                    .padding(.trailing, 35)
                
                VStack (alignment: .leading) {
                    HStack {
                        Image(systemName: "clock")
                            .frame(width: 30, height: 30)
                            .scaledToFill()
                            .font(.system(size: 18))
                            .fontWeight(.light)
                            .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255 ))
                        Text(formatDateToTimeZone(passedDate: froop.froopStartTime, timeZone: myTimeZone))
                            .font(.system(size: 16))
                            .fontWeight(.medium)
                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                        Spacer()
                    }
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                            .frame(width: 30, height: 30)
                            .scaledToFill()
                            .font(.system(size: 18))
                            .fontWeight(.light)
                            .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255 ))
                        VStack (alignment: .leading){
                            Text(froop.froopLocationtitle)
                                .font(.system(size: 16))
                                .fontWeight(.medium)
                                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                            Text(froop.froopLocationsubtitle)
                                .font(.system(size: 14))
                                .fontWeight(.light)
                                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                .lineLimit(2)
                                .padding(.trailing, 35)
                        }
                        Spacer()
                    }
                }
                .padding(.leading, 35)
                
                Spacer()
            }
        }
        .onTapGesture {
            froopData.froopName = froop.froopName
            froopData.froopLocationtitle = froop.froopLocationtitle
            froopData.froopLocationsubtitle = froop.froopLocationsubtitle
            froopData.froopLocationCoordinate = froop.froopLocationCoordinate 
            froopData.froopDuration = froop.froopDuration
            froopData.froopInvitedFriends = froop.froopInvitedFriends
            froopData.froopEndTime = froop.froopEndTime
            froopData.froopMessage = froop.froopMessage
            froopData.froopList = froop.froopList
            froopData.template = froop.template
            froopData.froopInvitedFriends = froop.froopInvitedFriends
            
            var froopTypeData: FroopType? {
                FroopTypeStore.shared.froopTypes.first { $0.id == froop.froopType }
            }
        
            changeView.froopTypeData = froopTypeData
            
            
            if let froopTypeData = FroopTypeStore.shared.froopTypes.first(where: { $0.id == froop.froopType }) {
                froopData.froopType = froopTypeData.id
            }
            
            if changeView.froopTypeData?.viewPositions[1] == 0 {
                changeView.addressAtMyLocation = true
            } else {
                changeView.addressAtMyLocation = false
            }
            
            changeView.configureViewBuildOrder()
            
            changeView.froopIsEditing = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                if changeView.froopIsEditing {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        changeView.pageNumber = changeView.showSummary
                    }
                } else {
                    changeView.pageNumber += 1
                }
            }
//            print(changeView.pageNumber)
        }
        .alert(isPresented: $showDeleteAlert) {
            Alert(
                title: Text("Delete Template"),
                message: Text("Are you sure you want to delete this template? This action cannot be undone."),
                primaryButton: .destructive(Text("Delete")) {
                    deleteTemplate()
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    func printFroop () {
        print(froop)
    }
    
    func deleteTemplate() {
        let db = Firestore.firestore()
        let templateRef = db.collection("users").document(FirebaseServices.shared.uid).collection("templates").document(froop.froopId)
        
        templateRef.delete() { error in
            if let error = error {
                print("Error removing document: \(error)")
            } else {
                print("Document successfully removed!")
                // Refresh the list of templates
                froopManager.setupTemplateStoreListener()
            }
        }
    }
    
    func formatTime(creationTime: Date) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .hour, .day]
        formatter.unitsStyle = .abbreviated
        
        let currentTime = Date()
        let timeSinceCreation = currentTime.timeIntervalSince(creationTime)
        
        let formattedTime = formatter.string(from: timeSinceCreation) ?? ""
        
        return formattedTime
    }
    func formatDate(passedDate: Date) -> String {
        // Convert the date from UTC to the user's local time zone using TimeZoneManager
        let localDate = TimeZoneManager.shared.convertDateToLocalTime(for: passedDate)

        // Now format the local date
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, h:mm a"
        let formattedDate = formatter.string(from: localDate)
        return formattedDate
    }

    
    func loadFriends(listType: String) {
        let uid = FirebaseServices.shared.uid
        let froopRef = db.collection("users").document(uid).collection("myFroops").document(froop.froopId).collection("invitedFriends").document(listType)
        
        froopRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let friendUIDs = document.data()?["uid"] as? [String] ?? []
                self.fetchFriendsData(from: friendUIDs) { friends in
                    if listType == "confirmedList" {
                        self.confirmedFriends = friends
                    } else if listType == "declinedList" {
                        self.declinedFriends = friends
                    }
                }
            } else {
                print("No friends found in the \(listType).")
            }
        }
    }
    
    func fetchFriendsData(from friendUIDs: [String], completion: @escaping ([UserData]) -> Void) {
        let usersRef = db.collection("users")
        var friends: [UserData] = []

        let group = DispatchGroup()

        for friendUID in friendUIDs {
            group.enter()

            usersRef.document(friendUID).getDocument { document, error in
                if let document = document, document.exists, let userData = document.data() {
                    let friend = UserData(dictionary: userData)
                    friends.append(friend ?? UserData())
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            self.confirmedFriends = friends
            completion(friends)
        }
    }
    
    func formatDateToTimeZone(passedDate: Date, timeZone: TimeZone) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d, h:mm a"
        dateFormatter.timeZone = timeZone
        return dateFormatter.string(from: passedDate)
    }

    
    func loadConfirmedFriends() {
        fetchFriendsData(from: froop.froopInvitedFriends) { [self] friends in
            self.confirmedFriends = friends
            // Add the current user (host) data to the array
            if let currentUser = UserData(dictionary: ["uid": FirebaseServices.shared.uid]) {
                self.confirmedFriends.append(currentUser)
            }
        }
    }
    
}



