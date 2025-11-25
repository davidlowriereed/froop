//
//  FroopFeedCardView.swift
//  FroopProof
//
//  Created by David Reed on 5/22/23.
//

import SwiftUI
import Kingfisher

struct FroopFeedCardView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var navLocationServices = NavLocationServices.shared
    // @ObservedObject var froopDataListener = FroopDataListener.shared
    @ObservedObject var froopManager = FroopManager.shared
    @ObservedObject var timeZoneManager:TimeZoneManager = TimeZoneManager()

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
    
    let currentUserId = FirebaseServices.shared.uid
    let index: Int
    var db = FirebaseServices.shared.db
    
    let froopHostAndFriends: FroopHostAndFriends
    
    
    init(index: Int, froopHostAndFriends: FroopHostAndFriends) {
           self.index = index
           self.froopHostAndFriends = froopHostAndFriends
       }
    
    var body: some View {
        ZStack {
            VStack (){
                HStack {
                    ZStack {
                        KFImage(URL(string: froopHostAndFriends.FH.host.profileImageUrl))
                            .placeholder {
                                ProgressView()
                            }
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50, alignment: .leading)
                            .clipShape(Circle())
                    }
                    VStack (alignment:.leading){
                        Text(froopHostAndFriends.FH.froop.froopName)
                            .font(.system(size: 16))
                            .fontWeight(.semibold)
                            .foregroundColor(colorScheme == .dark ? .white : Color(red: 50/255, green: 46/255, blue: 62/255))
                            .multilineTextAlignment(.leading)
                            .offset(y: 6)
                        HStack (alignment: .center){
                            Text("Host:")
                                .font(.system(size: 14))
                                .fontWeight(.light)
                                .foregroundColor(colorScheme == .dark ? .white : Color(red: 50/255, green: 46/255, blue: 62/255))
                                .multilineTextAlignment(.leading)
                            
                            Text(froopHostAndFriends.FH.host.firstName)
                                .font(.system(size: 14))
                                .fontWeight(.light)
                                .foregroundColor(colorScheme == .dark ? .white : Color(red: 50/255, green: 46/255, blue: 62/255))
                                .multilineTextAlignment(.leading)
                            
                            Text(froopHostAndFriends.FH.host.lastName)
                                .font(.system(size: 14))
                                .fontWeight(.light)
                                .foregroundColor(colorScheme == .dark ? .white : Color(red: 50/255, green: 46/255, blue: 62/255))
                                .multilineTextAlignment(.leading)
                                .offset(x: -5)
                        }
                        .offset(y: 6)
                        
                        Text("\(formatDate(for: froopHostAndFriends.FH.froop.froopStartTime))")
                            .font(.system(size: 14))
                            .fontWeight(.thin)
                            .foregroundColor(colorScheme == .dark ? .white : Color(red: 50/255, green: 46/255, blue: 62/255))
                            .multilineTextAlignment(.leading)
                            .padding(.top, 2)
                            .offset(y: -6)
                    }
                    
                    Spacer()
                    
                }
                .background(Color(red: 251/255, green: 251/255, blue: 249/255))
                .padding(.horizontal, 10)
                .padding(.bottom, 1)
                .frame(maxHeight: 60)
                
                ZStack {
                    Rectangle()
                        .frame(minWidth: UIScreen.main.bounds.width, maxWidth: UIScreen.main.bounds.width, minHeight: UIScreen.main.bounds.width * 1.3333, maxHeight: UIScreen.main.bounds.width * 1.3333)
                        .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))

                    TabView(selection: $selectedImageIndex) {
                               ForEach(froopHostAndFriends.FH.froop.froopDisplayImages.indices, id: \.self) { index in
                                   ZStack {
                                       KFImage(URL(string: froopHostAndFriends.FH.froop.froopDisplayImages[index]))
                                           .resizable()
                                           .scaledToFit()
                                           .frame(minWidth: UIScreen.main.bounds.width, maxWidth: UIScreen.main.bounds.width, minHeight: UIScreen.main.bounds.width * 0.5, maxHeight: UIScreen.main.bounds.width * 1.3333)
                                           .overlay(downloadButton, alignment: .topTrailing)
                                   }
                               }
                           }
                           .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                }
                .background(Color(red: 50/255, green: 46/255, blue: 62/255))
                
                Divider()
                    .padding(.bottom, 10)
            }
            
        }
        .padding(.top, 100)
        .onTapGesture {
            print("tap")
            for friend in froopHostAndFriends.friends {
               
                print(friend.firstName)
            }
        }
    }
    
    func formatDate(for date: Date) -> String {
        let localDate = TimeZoneManager.shared.convertDateToLocalTime(for: date)

        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE MMM.dd.yyyy 'at' h:mm a"
        return formatter.string(from: localDate)
    }
    
    var downloadButton: some View {
        // check if current user's id is in the friend list
        let isFriend = froopHostAndFriends.friends.contains { $0.froopUserID == currentUserId }

        if isFriend {
            return AnyView(
                Button(action: {
                    isDownloading = true
                    downloadImage()
                }) {
                    Image(systemName: "arrow.down.square")
                        .font(.system(size: 30))
                        .fontWeight(.thin)
                        .foregroundColor(downloadedImages[froopHostAndFriends.FH.froop.froopImages[selectedImageIndex]] == true ? .white : Color(red: 249/255, green: 0/255, blue: 98/255)) // Change color based on isImageDownloaded
                        .background(.ultraThinMaterial)
                }
                .frame(width: 50, height: 50)
                .background(Color.white.opacity(0.8))
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .disabled(isDownloading)
                .padding()
            )
        } else {
            return AnyView(EmptyView())
        }
    }
    
    func downloadImage() {
        guard let url = URL(string: froopHostAndFriends.FH.froop.froopImages[selectedImageIndex]) else { return }
        
        // Check if the image has already been downloaded
        if downloadedImages[froopHostAndFriends.FH.froop.froopImages[selectedImageIndex]] == true {
            print("Image already downloaded")
            return
        }
        
        KingfisherManager.shared.retrieveImage(with: url) { result in
            switch result {
            case .success(let value):
                UIImageWriteToSavedPhotosAlbum(value.image, nil, nil, nil)
                downloadedImages[froopHostAndFriends.FH.froop.froopImages[selectedImageIndex]] = true
            case .failure(let error):
                print("🚫Error downloading image: \(error)")
            }
            isDownloading = false
        }
    }
}
