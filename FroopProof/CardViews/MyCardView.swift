//
//  MyCardsView.swift
//  FroopProof
//
//  Created by David Reed on 8/9/23.
//


import SwiftUI
import Kingfisher
import AVKit

enum CardHeight {
    case collapsed
    case expandedInvite
    case expandedConfirmed
    case expandedArchived
    
    var height: CGFloat {
        switch self {
            case .collapsed:
                return 75
            case .expandedInvite:
                return 350
            case .expandedConfirmed:
                return UIScreen.screenWidth * 1.3333 + 120 // Image ratio plus header/footer space
            case .expandedArchived:
                return 220
        }
    }
}

struct MyCardsView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var navLocationServices = NavLocationServices.shared
    // @ObservedObject var froopDataListener = FroopDataListener.shared
    @ObservedObject var froopManager = FroopManager.shared
    @ObservedObject var froopTypeStore = FroopTypeStore.shared
    
    let currentUserId = FirebaseServices.shared.uid
    var db = FirebaseServices.shared.db
    let froopHistory: FroopHistory
    @State private var offset: CGFloat = 0
    @State private var isDragging = false
    @State private var hostFirstName: String = ""
    @State private var hostLastName: String = ""
    @State private var hostURL: String = ""
    @State private var showAlert = false
    @State private var selectedImageIndex = 0
    @State private var isMigrating = false
    @State private var isDownloading = false
    @State private var downloadedImages: [String: Bool] = [:]
    @State private var isImageSectionVisible: Bool = true
    @State private var froopTypeArray: [FroopType] = []
    @State private var thisFroopType: String = ""
    @Binding var friendDetailOpen: Bool
    @State private var selectedMediaIndex = 0 // To track the selected media index
    
    @State var openFroop: Bool = false
    
    init(froopHistory: FroopHistory, thisFroopType: String, friendDetailOpen: Binding <Bool>) {
        self.froopHistory = froopHistory
        _friendDetailOpen = friendDetailOpen
    }
    
    var body: some View {
        ZStack {
            VStack (){
                HStack {
                    KFImage(URL(string: froopHistory.host.profileImageUrl))
                        .placeholder {
                            ProgressView()
                        }
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50, alignment: .leading)
                        .clipShape(Circle())
                        .padding(.leading, 10)
                        .padding(.top, 5)
                    
                        .onTapGesture {
                            friendDetailOpen = true
                        }
                    VStack (alignment:.leading){
                        Text(froopHistory.froop.froopName)
                            .font(.system(size: 16))
                            .fontWeight(.semibold)
                            .foregroundColor(colorScheme == .dark ? Color(red: 50/255, green: 46/255, blue: 62/255) : Color(red: 50/255, green: 46/255, blue: 62/255))
                            .multilineTextAlignment(.leading)
                            .offset(y: 6)
                        HStack (alignment: .center){
                            Text("Host:")
                                .font(.system(size: 14))
                                .fontWeight(.light)
                                .foregroundColor(colorScheme == .dark ? Color(red: 50/255, green: 46/255, blue: 62/255) : Color(red: 50/255, green: 46/255, blue: 62/255))
                                .multilineTextAlignment(.leading)
                            
                            Text(froopHistory.host.firstName)
                                .font(.system(size: 14))
                                .fontWeight(.light)
                                .foregroundColor(colorScheme == .dark ? Color(red: 50/255, green: 46/255, blue: 62/255) : Color(red: 50/255, green: 46/255, blue: 62/255))
                                .multilineTextAlignment(.leading)
                            
                            Text(froopHistory.host.lastName)
                                .font(.system(size: 14))
                                .fontWeight(.light)
                                .foregroundColor(colorScheme == .dark ? Color(red: 50/255, green: 46/255, blue: 62/255) : Color(red: 50/255, green: 46/255, blue: 62/255))
                                .multilineTextAlignment(.leading)
                                .offset(x: -5)
                        }
                        .offset(y: 6)
                        
                        Text("\(formatDate(for: froopHistory.froop.froopStartTime))")
                            .font(.system(size: 14))
                            .fontWeight(.thin)
                            .foregroundColor(colorScheme == .dark ? Color(red: 50/255, green: 46/255, blue: 62/255) : Color(red: 50/255, green: 46/255, blue: 62/255))
                            .multilineTextAlignment(.leading)
                            .padding(.top, 2)
                            .offset(y: -6)
                    }
                    .padding(.top, 5)
                    
                    Spacer()
                    
                }
                .background(Color(red: 251/255, green: 251/255, blue: 249/255))
                //                .padding(.horizontal, 10)
                .padding(.bottom, 1)
                .frame(maxHeight: 60)
                
                ZStack {
                    Rectangle()
                        .frame(minWidth: UIScreen.main.bounds.width, maxWidth: UIScreen.main.bounds.width, minHeight: UIScreen.main.bounds.width * 1.3333, maxHeight: UIScreen.main.bounds.width * 1.3333)
                        .foregroundColor(.white)
                    TabView(selection: $selectedMediaIndex) {
                        // Check if there are video thumbnails to display
                        if !froopHistory.froop.froopVideoThumbnails.isEmpty {
                            ForEach(froopHistory.froop.froopVideos.indices, id: \.self) { index in
                                ZStack {
                                    // Blurred background
                                    KFImage(URL(string: froopHistory.froop.froopVideoThumbnails[safe: index] ?? ""))
                                        .resizable()
                                        .scaledToFill()
                                        .blur(radius: 3)
                                        .grayscale(0.5)
                                        .opacity(0.5)
                                        .frame(minWidth: UIScreen.main.bounds.width, maxWidth: UIScreen.main.bounds.width, minHeight: UIScreen.main.bounds.width * 1.3333, maxHeight: UIScreen.main.bounds.width * 1.3333)
                                        .clipped()
                                    
                                    // Foreground image
                                    KFImage(URL(string: froopHistory.froop.froopVideoThumbnails[safe: index] ?? ""))
                                        .resizable()
                                        .scaledToFit()
                                        .frame(minWidth: UIScreen.main.bounds.width, maxWidth: UIScreen.main.bounds.width, minHeight: UIScreen.main.bounds.width * 1.3333, maxHeight: UIScreen.main.bounds.width * 1.3333)
                                    
                                    Image(systemName: "play.circle")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .foregroundColor(.white)
                                        .frame(width: 50, height: 50)
                                }
                                .onTapGesture {
                                    froopManager.videoUrl = froopHistory.froop.froopVideos[safe: index] ?? ""
                                    froopManager.showVideoPlayer = true
                                }
                                .tag(index)
                            }
                        }
                        // Check if there are display images to show
                        if !froopHistory.froop.froopDisplayImages.isEmpty {
                            ForEach(froopHistory.froop.froopDisplayImages.indices, id: \.self) { index in
                                ZStack {
                                    // Blurred background
                                    KFImage(URL(string: froopHistory.froop.froopDisplayImages[safe: index] ?? ""))
                                        .resizable()
                                        .scaledToFill()
                                        .blur(radius: 3)
                                        .grayscale(0.5)
                                        .opacity(0.5)
                                        .frame(minWidth: UIScreen.main.bounds.width, maxWidth: UIScreen.main.bounds.width, minHeight: UIScreen.main.bounds.width * 1.3333, maxHeight: UIScreen.main.bounds.width * 1.3333)
                                        .clipped()
                                    
                                    // Foreground image
                                    KFImage(URL(string: froopHistory.froop.froopDisplayImages[safe: index] ?? ""))
                                        .resizable()
                                        .scaledToFit()
                                        .frame(minWidth: UIScreen.main.bounds.width, maxWidth: UIScreen.main.bounds.width, minHeight: UIScreen.main.bounds.width * 1.3333, maxHeight: UIScreen.main.bounds.width * 1.3333)
                                }
                                .tag(index + froopHistory.froop.froopVideos.count)
                            }
                        }
                    }
                    
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                }
                
                //.matchedGeometryEffect(id: "ZStackAnimation", in: animation)
                //.transition(froopManager.areAllCardsExpanded ? .move(edge: .top) : .move(edge: .bottom))
                .background(Color(.white))
                
                Divider()
                    .padding(.top, 10)
            }
            
        }
        .onTapGesture {
            print("tap")
            for friend in froopHistory.confirmedFriends {
                
                print(friend.firstName)
            }
        }
    }
    
    func playVideo(at index: Int) {
        // Assume you have URLs for videos similar to how you have froopDisplayImages
        guard let videoURLString = froopHistory.froop.froopVideos[safe: index],
              let url = URL(string: videoURLString) else { return }
        // Present a video player
        let player = AVPlayer(url: url)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        // Present the player view controller modally (requires UIViewControllerRepresentable or using UIKit integration)
        // Note: Implement this part based on your app's architecture, either via UIKit integration or another SwiftUI view
    }
    
    
    func formatDate(for date: Date) -> String {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE MMM.dd.yyyy 'at' h:mm a"
        // Set the time zone to the current location's time zone
        //        if let timeZone = TimeZoneManager.shared.userLocationTimeZone {
        //            formatter.timeZone = timeZone
        //        }
        return formatter.string(from: date)
    }
    
    var downloadButton: some View {
        // check if current user's id is in the friend list
        let isFriend = froopHistory.confirmedFriends.contains { $0.froopUserID == currentUserId }
        
        if isFriend {
            return AnyView(
                Button(action: {
                    isDownloading = true
                    downloadImage()
                }) {
                    if selectedImageIndex < froopHistory.froop.froopImages.count {
                        let imageKey = froopHistory.froop.froopImages[selectedImageIndex]
                        let isImageDownloaded = downloadedImages[imageKey] ?? false
                        ZStack {
                            RoundedRectangle(cornerRadius: 18)
                                .frame(width: 36, height: 36)
                                .foregroundColor(isImageDownloaded ? .clear : Color(.white).opacity(0.7))
                            Image(systemName: "icloud.and.arrow.down")
                                .font(.system(size: 20))
                                .fontWeight(.thin)
                                .foregroundColor(isImageDownloaded ? .clear : Color(red: 249/255, green: 0/255, blue: 98/255))
                        }
                    } else {
                        // You may want to provide some default Image or other view when there's an error
                        EmptyView()
                    }
                }
                    .frame(width: 36, height: 36)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .disabled(isDownloading)
                    .padding()
            )
        } else {
            return AnyView(EmptyView())
        }
    }
    
    func downloadImage() {
        guard let url = URL(string: froopHistory.froop.froopImages[selectedImageIndex]) else { return }
        
        // Check if the image has already been downloaded
        if downloadedImages[froopHistory.froop.froopImages[selectedImageIndex]] == true {
            print("Image already downloaded")
            return
        }
        
        KingfisherManager.shared.retrieveImage(with: url) { result in
            switch result {
                case .success(let value):
                    UIImageWriteToSavedPhotosAlbum(value.image, nil, nil, nil)
                    downloadedImages[froopHistory.froop.froopImages[selectedImageIndex]] = true
                case .failure(let error):
                    print("🚫Error downloading image: \(error)")
            }
            isDownloading = false
        }
    }
}
