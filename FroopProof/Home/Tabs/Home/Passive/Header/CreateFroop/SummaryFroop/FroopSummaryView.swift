//
//  NewFroopSummary.swift
//  FroopProof
//
//  Created by David Reed on 1/19/23.
//

import SwiftUI
import SwiftUIBlurView
import Kingfisher
import Firebase
import FirebaseAuth
import FirebaseFirestore


struct FroopSummaryView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var friendViewController = FriendViewController.shared
    @ObservedObject var payManager = PayWallManager.shared
    @ObservedObject var model: PaywallModel = PaywallModel(dictionary: [:])
    
    // @ObservedObject var froopDataListener = FroopDataListener.shared
    var db = FirebaseServices.shared.db
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var timeZoneManager: TimeZoneManager = TimeZoneManager()
    @ObservedObject var myData = MyData.shared
    @ObservedObject var froopData = FroopData.shared
    @ObservedObject var changeView = ChangeView.shared
    @State var selectedFroopType: FroopType?
    //    @State var confirmedFriends: [UserData] = []
    @ObservedObject var froopTypeStore = FroopTypeStore()
    @AppStorage("ProfileCompletionCurrentPage") var ProfileCompletionCurrentPage = 5
    @State var myTimeZone: TimeZone = TimeZone.current
    @State private var formattedDateString: String = ""
    @State private var showMap = false
    @State private var hide: Bool = false
    @State private var changeFroopType: Bool = false
    @State private var changeTemplateInvites = false
    
    
    var body: some View {
        
        ZStack {
            //MARK:  Background Layout Objects
            KFImage(URL(string: model.headerImage))
                .frame(width: 35, height: 35)
                .scaledToFill()
                .opacity(0.01)
            Rectangle()
                .foregroundColor(Color(red: 240/255, green: 240/255, blue: 240/255))
                .background(.ultraThinMaterial)
                .padding(.top)
                .ignoresSafeArea()
                .onAppear {
                    if froopData.template {
                        froopData.froopHost = FirebaseServices.shared.uid
                        froopData.froopId = String(describing: UUID())
                    }
                    changeView.froopIsEditing = true
//                    changeView.froopHolder = froopData.toFroop()
                    fetchFriendsData(from: froopData.froopInvitedFriends) { fetchedFriends in
                        changeView.confirmedFriends = fetchedFriends
                        print("🟡 printing Friends")
                        print(fetchedFriends)
                        print(changeView.confirmedFriends)
                        // Additional actions if needed
                    }
                }
            
            
            
            //MARK: Content
            
            VStack (alignment: .center, spacing: 5) {
                //MARK: Froop Content
                
                
                ScrollView (showsIndicators: false) {
                    
                    
                    HStack {
                        Spacer()
                        VStack (alignment: .center){
                            
                            VStack {
                                Text("Does everything look right?")
                                    .font(.system(size: 20))
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.9))
                                
//                                Text(String(describing: froopData.froopStartTime))
////                                Text("Tap below to make changes.")
//                                    .font(.system(size: 16))
//                                    .fontWeight(.regular)
//                                    .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.5))
                                
                                Spacer()
                            }
                            .frame(height: 35)
                        }
                        Spacer()
                    }
                    .padding(.top, 10)
                    
                    //MARK: Title
                    if changeView.showTitle != 0  || froopData.froopType == 5009 {
                        FroopTitleSummaryView()
                    }
                    
                    if froopData.froopType == 5009 {
                        FroopSummaryFlightHeaderView()
                    }
                    
                    //MARK: SingleGuest View
                    if changeView.showGuest != 0 {
                        FroopGuestSummaryView()
                    }
                    
                    //MARK: MultipleGuests View
                    if changeView.showGuests != 0 && froopData.froopType != 5009 {
                        FroopGuestsSummaryView()
                            .onTapGesture {
                                changeTemplateInvites = true
                            }
                    }
                    
                   
                    
                    //MARK: Froop Date
                    if changeView.showDate != 0 && froopData.froopType != 5009 {
                        FroopDateSummaryView()
                    }
                    
                    //MARK: Froop Location
                    if changeView.showLocation != 0 && froopData.froopType != 5009 {
                        FroopLocationSummaryView()
                    }
                    
                    //MARK: Froop Duration
                    if changeView.showDate != 0 && froopData.froopType != 5009 {
                        FroopDurationSummaryView()
                    }
                    
                    //MARK: Froop Type
                    FroopTypeSummaryView()
                        .onTapGesture {
                            changeFroopType = true
                        }
                }
//                .padding(.top, 15)
                .frame(height: UIScreen.screenHeight * 0.75)

                Spacer()

            }
            .padding(.top, 110)
            
            PremiumBannerInSummaryView()
                .onAppear {
                    timeZoneManager.convertUTCToCurrent(date: froopData.froopStartTime, currentTZ: TimeZone.current.identifier) { convertedDate in
                        formattedDateString = timeZoneManager.formatDate(passedDate: convertedDate)
                    }
                }
            
            VStack {
                Spacer()
                //MARK: Save Froop Button
                
                FroopSaveButtonSummaryView()
                    .padding(.bottom, UIScreen.screenHeight * 0.05)

            }
            .ignoresSafeArea()
            .onAppear {
                froopData.froopEndTime = froopData.froopStartTime.addingTimeInterval(TimeInterval(froopData.froopDuration))
                PrintControl.shared.printFroopCreation("Froop End Time:  \(froopData.froopEndTime)")
            }
            
            CustomPayWallView(
                model: $payManager.model
            )
            .offset(y: payManager.showIAPView ? 0 : UIScreen.main.bounds.height)
            .opacity(payManager.showIAPView ? 1 : 0)
            .edgesIgnoringSafeArea(.all)
            .alert(isPresented: $changeFroopType) {
                Alert(title: Text("About Changing Froop Type"), message: Text("If you want to change your Froop Type you should tap Exit in the top left navigation bar.  You can them proceed to selecting a new Froop Type.  However, you will lose any data you have added to this Froop when you do."), dismissButton: .default(Text("I Understand")))
            }
            .alert(isPresented: $changeTemplateInvites) {
                Alert(title: Text("Templates"), message: Text("Templates are designed to make creating Froops for repeating activities easy.  If you need to change the invite list please create a New Froop."), dismissButton: .default(Text("Ok")))
            }
            .onChange(of: payManager.showIAPView) { oldValue, newValue in
                if newValue {
                    Task {
                        do {
                            try await payManager.fetchPaywallData()
                        } catch {
                            print(error.localizedDescription)
                            payManager.showDefaultView = true
                        }
                    }
                }
            }
        }
    }
    
    func uploadData(froopData: FroopData) {
        PrintControl.shared.printFroopCreation("-FroopSummaryView: Function: uploadData is firing!")
        
        let uid = FirebaseServices.shared.uid
        db.collection("users").document(uid).collection("myFroops").addDocument(data: froopData.dictionary) { (error) in
            if let error = error {
                PrintControl.shared.printFroopCreation("Error uploading data: \(error)")
            } else {
                PrintControl.shared.printFroopCreation("Data successfully uploaded")
            }
        }
    }
    
    func formatTime(creationTime: Date) -> String {
        PrintControl.shared.printFroopCreation("-FroopSummaryView: Function: formatTime is firing!")
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .hour, .day]
        formatter.unitsStyle = .abbreviated
        
        let currentTime = Date()
        let timeSinceCreation = currentTime.timeIntervalSince(creationTime)
        
        let formattedTime = formatter.string(from: timeSinceCreation) ?? ""
        
        return formattedTime
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
            changeView.confirmedFriends = friends // Assign here, inside the notify closure
            completion(friends)
        }
    }
    
}
