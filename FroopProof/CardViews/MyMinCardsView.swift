////
////  MyCardsView.swift
////  FroopProof
////
////  Created by David Reed on 8/9/23.
////
//
//
//
//
//import SwiftUI
//import Kingfisher
//
//struct MyMinCardsView: View {
//    
//    @Environment(\.colorScheme) var colorScheme
//    @ObservedObject var appStateManager = AppStateManager.shared
//    @ObservedObject var printControl = PrintControl.shared
//    @ObservedObject var navLocationServices = NavLocationServices.shared
//    // @ObservedObject var froopDataListener = FroopDataListener.shared
//    @ObservedObject var froopManager = FroopManager.shared
//    @ObservedObject var froopTypeStore = FroopTypeStore.shared
//    @State private var previousAppState: AppState?
//    
//    let currentUserId = FirebaseServices.shared.uid
//    let db = FirebaseServices.shared.db
//    let uid = FirebaseServices.shared.uid
//    
//    @ObservedObject var froopHistory: FroopHistory
//    @State private var offset: CGFloat = 0
//    @State private var isDragging = false
//    @State private var hostFirstName: String = ""
//    @State private var hostLastName: String = ""
//    @State private var hostURL: String = ""
//    @State private var showAlert = false
//    @State private var selectedImageIndex = 0
//    @State private var isMigrating = false
//    @State private var isDownloading = false
//    @State private var downloadedImages: [String: Bool] = [:]
//    @State private var isImageSectionVisible: Bool = true
//    @State private var froopTypeArray: [FroopType] = []
//    @State private var thisFroopType: String = ""
//    @State var openFroop: Bool = false
//    @State private var isBlinking = false
//    @State private var indexOfFroopHistory: Int?
//    
//    var isCurrentUserInvited: Bool {
//        // Check if the currentUserUID exists in the invitedFriends array of froopHostAndFriends
//        return froopHistory.invitedFriends.contains { friend in
//            friend.froopUserID == uid
//        }
//    }
//    
//    // @Namespace private var animation
//    
//    init(froopHistory: FroopHistory, thisFroopType: String) {
//        self.froopHistory = froopHistory
//        _indexOfFroopHistory = State(initialValue: AppStateManager.shared.currentFilteredFroopHistory.firstIndex { $0.froop.froopId == froopHistory.froop.froopId })
//    }
//    
//    var body: some View {
//        ZStack {
//            if openFroop {
//                froopHistory.cardForStatus(openFroop: $openFroop)
//                    .padding(.bottom, 10)
//                    .padding(.leading, 5)
//                    .padding(.trailing, 5)
//            } else {
//                
//                VStack (){
//                    HStack {
//                        Image(systemName: thisFroopType)
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .frame(maxWidth: 50, maxHeight: 50)
//                            .foregroundColor(froopHistory.colorForStatus())
//                            .onAppear {
//                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                                    if let foundFroopType = froopTypeStore.froopTypes.first(where: { $0.id == froopHistory.froop.froopType }) {
//                                        self.thisFroopType = foundFroopType.imageName
//                                        PrintControl.shared.printForEach("Name: \(foundFroopType.name) ImageName: \(foundFroopType.imageName) Froop: \(froopHistory.froop.froopName)")
//                                    } else {
//                                        self.thisFroopType = ""
//                                    }
//                                }
//                            }
//                            .padding(.top, 5)
//                            .padding(.leading, 5)
//                        
//                        VStack (alignment:.leading){
//                            HStack (alignment: .center){
//                                Text(froopHistory.froop.froopName)
//                                    .font(.system(size: UIScreen.screenHeight < 925 ? 14 : 16))
//                                    .fontWeight(.semibold)
//                                    .foregroundColor(colorScheme == .dark ? Color(red: 50/255, green: 46/255, blue: 62/255) : Color(red: 50/255, green: 46/255, blue: 62/255))
//                                    .multilineTextAlignment(.leading)
//                                Spacer()
//                                ZStack {
//                                    if appStateManager.currentFilteredFroopHistory.contains(where: { $0.froop.froopId == froopHistory.froop.froopId }) {
//                                        Text("IN PROGRESS")
//                                            .font(.system(size: UIScreen.screenHeight < 925 ? 12 : 14))
//                                            .fontWeight(.semibold)
//                                            .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255 ))
//                                            .opacity(isBlinking ? 0.0 : 1.0)
//                                            .onChange(of: appStateManager.appState, initial: previousAppState != nil) { oldValue, newValue in
//                                                // Check if the newValue is different from the previous state, if necessary
//                                                // If they are the same, you may wish to skip any updates.
//                                                guard newValue != oldValue else { return }
//                                                
//                                                withAnimation(Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
//                                                    self.isBlinking = true
//                                                }
//                                                
//                                                // Update the previous state after processing the changes
//                                                previousAppState = newValue
//                                            }
//                                    } else if isCurrentUserInvited {
//                                        
//                                        Text("Invited!")
//                                            .font(.system(size: UIScreen.screenHeight < 925 ? 14 : 16))
//                                            .fontWeight(.semibold)
//                                            .foregroundColor(Color(red: 255/255, green: 0/255, blue: 98/255))
//                                            .multilineTextAlignment(.leading)
//                                        
//                                        if froopHistory.froop.froopImages.count != 0 {
//                                            Image(systemName: "camera.circle")
//                                                .font(.system(size: 20))
//                                                .fontWeight(.regular)
//                                                .foregroundColor(froopHistory.colorForStatus())
//                                                .multilineTextAlignment(.leading)
//                                                .offset(y: 25)
//                                        }
//                                       
//                                    } else {
//                                        
//                                        Text(froopHistory.textForStatus())
//                                            .font(.system(size: 14))
//                                            .fontWeight(.semibold)
//                                            .foregroundColor(froopHistory.colorForStatus())
//                                            .multilineTextAlignment(.leading)
//                                        
//                                        if froopHistory.froop.froopImages.count != 0 {
//                                            Image(systemName: "camera.circle")
//                                                .font(.system(size: 20))
//                                                .fontWeight(.regular)
//                                                .foregroundColor(froopHistory.colorForStatus())
//                                                .multilineTextAlignment(.leading)
//                                                .offset(y: 25)
//                                        }
//                                    }
//                                }
//                                .padding(.trailing, 15)
//                            }
//                            .offset(y: 6)
//                            
//                            HStack (alignment: .center){
//                                Text("Host:")
//                                    .font(.system(size: UIScreen.screenHeight < 925 ? 12 : 14))
//                                    .fontWeight(.light)
//                                    .foregroundColor(colorScheme == .dark ? Color(red: 50/255, green: 46/255, blue: 62/255) : Color(red: 50/255, green: 46/255, blue: 62/255))
//                                    .multilineTextAlignment(.leading)
//                                
//                                Text(froopHistory.host.firstName)
//                                    .font(.system(size: UIScreen.screenHeight < 925 ? 12 : 14))
//                                    .fontWeight(.light)
//                                    .foregroundColor(colorScheme == .dark ? Color(red: 50/255, green: 46/255, blue: 62/255) : Color(red: 50/255, green: 46/255, blue: 62/255))
//                                    .multilineTextAlignment(.leading)
//                                
//                                Text(froopHistory.host.lastName)
//                                    .font(.system(size: UIScreen.screenHeight < 925 ? 12 : 14))
//                                    .fontWeight(.light)
//                                    .foregroundColor(colorScheme == .dark ? Color(red: 50/255, green: 46/255, blue: 62/255) : Color(red: 50/255, green: 46/255, blue: 62/255))
//                                    .multilineTextAlignment(.leading)
//                                    .offset(x: -5)
//                            }
//                            .offset(y: 6)
//                            
//                            Text("\(formatDate(for: froopHistory.froop.froopStartTime))")
//                                .font(.system(size: UIScreen.screenHeight < 925 ? 12 : 14))
//                                .fontWeight(.thin)
//                                .foregroundColor(colorScheme == .dark ? Color(red: 50/255, green: 46/255, blue: 62/255) : Color(red: 50/255, green: 46/255, blue: 62/255))
//                                .multilineTextAlignment(.leading)
//                                .padding(.top, 2)
//                                .offset(y: -6)
//                        }
//                        .padding(.top, 5)
//                        
//                        Spacer()
//                        
//                    }
//                    .background(Color(red: 251/255, green: 251/255, blue: 249/255))
//                    .padding(.horizontal, 10)
//                    .padding(.bottom, 1)
//                    .frame(maxHeight: 60)
//                    
//                    Divider()
//                        .padding(.top, 10)
//                }
//            }
//            
//        }
//        .onTapGesture {
//            let now = Date()
//            withAnimation(.spring()) {
//                if froopHistory.froopStatus == .confirmed
//                    && now >= froopHistory.froop.froopStartTime
//                    && now <= froopHistory.froop.froopEndTime {
//
//                        appStateManager.appStateToggle = true
//                        // Now also set the aFHI to the found index
//                        if let index = indexOfFroopHistory {
//                            appStateManager.aFHI = index
//                        }
//                    
//                } else {
//                    openFroop.toggle()
//                }
//            }
//        }
//
//        
//        .onAppear {
//            // If not already set, find the index when the view appears
//            if indexOfFroopHistory == nil {
//                indexOfFroopHistory = AppStateManager.shared.currentFilteredFroopHistory.firstIndex { $0.froop.froopId == froopHistory.froop.froopId }
//            }
//        }
//        
//    }
//    
//    func formatDate(for date: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "EEEE MMM.dd.yyyy 'at' h:mm a zzz"
//        return formatter.string(from: date)
//    }
//
//    
//    var downloadButton: some View {
//        // check if current user's id is in the friend list
//        let isFriend = froopHistory.confirmedFriends.contains { $0.froopUserID == currentUserId }
//        
//        if isFriend {
//            return AnyView(
//                Button(action: {
//                    isDownloading = true
//                    downloadImage()
//                }) {
//                    Image(systemName: "arrow.down.square")
//                        .font(.system(size: 30))
//                        .fontWeight(.thin)
//                        .foregroundColor(downloadedImages[froopHistory.froop.froopImages[selectedImageIndex]] == true ? .white : Color(red: 249/255, green: 0/255, blue: 98/255)) // Change color based on isImageDownloaded
//                        .background(.ultraThinMaterial)
//                }
//                    .frame(width: 50, height: 50)
//                    .background(Color.white.opacity(0.8))
//                    .clipShape(RoundedRectangle(cornerRadius: 5))
//                    .disabled(isDownloading)
//                    .padding()
//            )
//        } else {
//            return AnyView(EmptyView())
//        }
//    }
//    
//    func downloadImage() {
//        guard let url = URL(string: froopHistory.froop.froopImages[selectedImageIndex]) else { return }
//        
//        // Check if the image has already been downloaded
//        if downloadedImages[froopHistory.froop.froopImages[selectedImageIndex]] == true {
//            print("Image already downloaded")
//            return
//        }
//        
//        KingfisherManager.shared.retrieveImage(with: url) { result in
//            switch result {
//                case .success(let value):
//                    UIImageWriteToSavedPhotosAlbum(value.image, nil, nil, nil)
//                    downloadedImages[froopHistory.froop.froopImages[selectedImageIndex]] = true
//                case .failure(let error):
//                    print("🚫Error downloading image: \(error)")
//            }
//            isDownloading = false
//        }
//    }
//}
