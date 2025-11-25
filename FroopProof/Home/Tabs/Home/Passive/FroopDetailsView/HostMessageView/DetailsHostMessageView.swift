//
//  DetailsHostMessageView.swift
//  Design_Layouts
//
//  Created by David Reed on 6/20/23.
//

import SwiftUI
import SwiftUIBlurView
import Kingfisher
import Firebase
import FirebaseAuth
import FirebaseFirestore
import Foundation
import MapKit
import EventKit
import FirebaseCrashlytics
import AVKit
import Combine


struct DetailsHostMessageView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var navLocationServices = NavLocationServices.shared
    // @ObservedObject var froopDataListener = FroopDataListener.shared
    @ObservedObject var myData = MyData.shared
    @ObservedObject var froopManager = FroopManager.shared
    @ObservedObject var friendViewController = FriendViewController.shared
    @ObservedObject var timeZoneManager: TimeZoneManager = TimeZoneManager()
    @ObservedObject var froopData = FroopData.shared
    @Binding var selectedFroopHistory: FroopHistory
//    @ObservedObject var friendData: UserData = UserData()
    
    @State private var showAlert = false
    

    @Binding var messageEdit: Bool
    
    var body: some View {
        ZStack {
            VStack (spacing: 0){
                
                ZStack {
                    Rectangle()
                        .frame(height: 50)
                        .foregroundColor(colorScheme == .dark ? Color(red: 250/255 , green: 250/255, blue: 255/255) : Color(red: 250/255 , green: 250/255, blue: 255/255))
                    VStack {
                        Spacer()
                        
                        HStack {
                            Text("Message from the Host")
                                .font(.system(size: 14))
                                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                .opacity(0.7)
                                .fontWeight(.semibold)
                                .padding(.top, 10)
                                .padding(.leading, 15)
                                .padding(.bottom, 15)
                            Spacer()
                            if FirebaseServices.shared.uid == selectedFroopHistory.host.froopUserID {
                                Text("Edit Message")
                                    .foregroundColor(Color(red: 255/255, green: 49/255, blue: 97/255))
                                    .font(.system(size: 14))
                                    .fontWeight(.light)
                                    .opacity(1)
                                    .multilineTextAlignment(.center)
                                    .padding(.bottom, 10)
                                    .padding(.trailing, 15)
                                    .offset(y: 2)
                                    .onTapGesture {
                                        messageEdit = true
                                    }
                            } else {
                                Text("")
                            }
                            
                        }
                        .padding(.trailing, 5)
                        .padding(.leading, 5)
                    }
                    .frame(maxHeight: 50)
                }
                Divider()
                ZStack {
                    Rectangle()
                        .frame(height: 125)
                        .foregroundColor(colorScheme == .dark ? Color(red: 250/255 , green: 250/255, blue: 255/255) : Color(red: 250/255 , green: 250/255, blue: 255/255))
                    HStack (alignment: .top) {
                        ZStack {
                            if froopManager.selectedFroopHistory.froop.froopIntroVideoThumbnail == "" {
                                Rectangle()
                                    .frame(maxWidth: 75, maxHeight: 125)
                                    .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.5))
                                    .ignoresSafeArea()
                            }
                            Image(uiImage: froopManager.videoThumbnail)
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: 75, maxHeight: 125)
                                .ignoresSafeArea()
                            
                            KFImage(URL(string: froopManager.selectedFroopHistory.froop.froopIntroVideoThumbnail))
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: 75, maxHeight: 125)
                                .ignoresSafeArea()
                            Image(systemName: "play.circle")
                                .foregroundColor(.white)
                                .font(.system(size: 28))
                        }
                        .onTapGesture {
                            if froopManager.selectedFroopHistory.froop.froopIntroVideo != "" || froopManager.videoUrl != "" {
                                froopManager.showVideoPlayer = true
                            }
                        }
                        
                        
                        Text (froopManager.selectedFroopHistory.froop.froopIntroVideo == "" ? "You can choose either to add a Text Message OR a Video, but not Both.  The Video will supercede your Text message." : selectedFroopHistory.froop.froopMessage)
                            .font(.system(size: 16))
                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.5))
                            .fontWeight(.light)
                            .padding(.top, 5)
                            .padding(.bottom, 5)
                        Spacer()
                        
                    }
                    .padding(.trailing, 5)
                    .padding(.leading, 5)
                }
                .frame(maxHeight: 125)
                .onTapGesture {
                    messageEdit = true
                }
                
            }
            
        }
        Divider()
    }
}

struct CustomVideoPlayerView: View {
    @ObservedObject var froopManager = FroopManager.shared
    var videoURLString: String
    var onClose: () -> Void
    @State private var player = AVPlayer() // Initialize an empty player
    @State private var playerItem: AVPlayerItem?
    @State private var statusObserver: AnyCancellable?
    @State private var isLoading = true // Track the loading state

    var body: some View {
        ZStack {
            Rectangle()
           
            
            PlayerView(player: player) // Use the state player instance
                .onAppear {
                    prepareToPlay()
                }
                .onDisappear {
                    player.pause()
                }
            
            if isLoading {
                VStack {
                    Text("Loading...")
                        .foregroundColor(.white)
                        .background(Color.black.opacity(0.7))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    // Optionally, add an activity indicator if you're targeting iOS 14+
                    ProgressView() // This requires iOS 14+
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
            }
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        print("Close button tapped")
                        player.pause()
                        onClose() // Use the onClose closure to handle closing
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.ultraThinMaterial)
                                .frame(width: UIScreen.main.bounds.width * 0.4, height: UIScreen.main.bounds.height * 0.05)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 0.5)
                                )
                            
                            Text("Close")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                                .fontWeight(.light)
                        }
                    }
                    Spacer()
                }
            }
            .padding(.bottom, 100)
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            print("CustomVideoPlayerView's SwiftUI view appeared")
        }
    }
    
    private func prepareToPlay() {
        guard let videoURL = URL(string: videoURLString) else {
            print("Invalid video URL")
            return
        }
        
        isLoading = true // Start loading
        let asset = AVAsset(url: videoURL)
        playerItem = AVPlayerItem(asset: asset)
        
        // Observe the player item's status
        statusObserver = playerItem?.publisher(for: \.status)
            .receive(on: DispatchQueue.main)
            .sink { [self] status in
                switch status {
                    case .readyToPlay:
                        isLoading = false // Stop loading
                        self.player.play()
                    case .failed:
                        isLoading = false // Update loading state in case of failure
                        print("Player item failed to load.")
                    default:
                        break
                }
            }
        
        // Set the player's item
        player.replaceCurrentItem(with: playerItem)
    }
}




struct IdentifiableURL: Identifiable {
    let id = UUID()
    let url: URL
}

struct PlayerView: UIViewControllerRepresentable {
    var player: AVPlayer

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        // Update the view controller if needed.
    }
}


