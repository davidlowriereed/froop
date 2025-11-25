//
//  DetailsGuestView.swift
//  FroopProof
//
//  Created by David Reed on 6/20/23.
//

import SwiftUI
import Foundation
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import UIKit
import Combine
import MapKit
import Kingfisher
import PhotosUI

struct DetailsGuestView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var friendRequestManager = FriendRequestManager.shared
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var navLocationServices = NavLocationServices.shared
//    @ObservedObject var froopDataListener = FroopDataListener.shared
    @ObservedObject var myData = MyData.shared
    @ObservedObject var froopManager = FroopManager.shared
    @ObservedObject var friendViewController = FriendViewController.shared
    @ObservedObject var timeZoneManager: TimeZoneManager = TimeZoneManager()
    @ObservedObject var froopData = FroopData.shared
    @ObservedObject var friendData: UserData = UserData()
    @ObservedObject var viewModel = DetailsGuestViewModel.shared
    
    @State var detailsTab = 1
    @State var selectedTab = 1
    @State var rectangleHeight: CGFloat = 100
    @State var rectangleY: CGFloat = 100
    
    @Binding var selectedFroopHistory: FroopHistory
    @Binding var miniFriendDetailOpen: Bool
    @Binding var miniFriend: UserData
    
    var gridItems = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        VStack (spacing: 0){
            ZStack {
                Rectangle()
                    .frame(height: 75)
                    .foregroundColor(.white)

                VStack {
                    Spacer()
                    ZStack{
                        HStack {
                            Spacer()
                            RoundedRectangle(cornerRadius: 2, style: .continuous)
                                .frame(width: selectedTab == 1 ? 125 : selectedTab == 2 ? 125 : 125, height: 30)
                                .foregroundColor(colorScheme == .dark ? .white : Color(red: 50/255, green: 46/255, blue: 62/255))
                                .opacity(colorScheme == .dark ? 0.2 : 0.05)
                                .ignoresSafeArea()
                                .offset(x: selectedTab == 0 ? -140 : selectedTab == 2 ? 140 : 0, y: 10)
                                .animation(.linear(duration: 0.2), value: selectedTab)
                                .padding(.leading, 15)
                                .padding(.trailing, 15)
                            Spacer()
                        }
                        VStack {
                            Text(froopManager.selectedFroopHistory.froop.froopType != 5009 ? "INVITED GUESTS" : "INVITED FRIENDS")
                                    .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                    .font(.system(size: 15))
                                    .fontWeight(.semibold)
                                    .offset(y: -15)

                            HStack {
                                Text("Invited:")
                                    .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                    .font(.system(size: 14))
                                    .fontWeight(.semibold)
                                    .onTapGesture {
                                        selectedTab = 0
                                    }
                                 
                                Text(viewModel.selectedFroopHistory.invitedFriends.count.description)
                                    .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                    .font(.system(size: 14))
                                    .fontWeight(.semibold)
                                Spacer()
                                Text("Confirmed:")
                                    .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                    .font(.system(size: 14))
                                    .fontWeight(.semibold)
                                    .onTapGesture {
                                        selectedTab = 1
                                    }
                                  
                                Text(viewModel.selectedFroopHistory.confirmedFriends.count.description)
                                    .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                    .font(.system(size: 14))
                                    .fontWeight(.semibold)
                                Spacer()
                                Text("Declined:")
                                    .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                    .font(.system(size: 14))
                                    .fontWeight(.semibold)
                                    .onTapGesture {
                                        selectedTab = 2
                                    }
                            
                                Text(viewModel.selectedFroopHistory.declinedFriends.count.description)
                                    .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                    .font(.system(size: 14))
                                    .fontWeight(.semibold)
                            }
                        }
                        .onAppear {
                            froopManager.updateFroopHistoryToggle.toggle()
                        }
                    }
                    .padding(.bottom, 10)
                    .padding(.trailing, 40)
                    .padding(.leading, 40)
                }
                .frame(maxHeight: 75)
            }
            .onChange(of: froopManager.updateFroopHistoryToggle) {
                viewModel.stampCurrentFroopHistory(for: froopManager.selectedFroopHistory.froop)
            }
            
            ZStack {
                Rectangle()
                    .border(Color(red: 50/255, green: 46/255, blue: 62/255), width: 0.25)
                    .frame(height: 100)
                    .foregroundColor(colorScheme == .dark ? Color(red: 250/255 ,green: 250/255, blue: 255/255) : Color(red: 250/255, green: 250/255, blue: 255/255))
                  
                TabView(selection: $selectedTab) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack (alignment: .center){
                            ForEach(viewModel.selectedFroopHistory.invitedFriends , id: \.self) { friend in
                                VStack {
                                    KFImage(URL(string: friend.profileImageUrl))
                                        .resizable()
                                        .scaledToFill()
                                        .clipShape(Circle())
                                        .frame(width: 50, height: 50)
                                    Text(friend.lastName != "" ? "\(friend.firstName) \(String(friend.lastName.prefix(1)))." : "\(friend.firstName)")
                                        .font(.system(size: 12))
                                        .frame(maxWidth: 75)
                                        .fontWeight(.light)
                                        .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                        .opacity(0.5)
                                }
                                .onTapGesture {
                                    friendRequestManager.selectedFriend = friend
                                    miniFriendDetailOpen = true
                                }
                            }
                        }
                        .padding(.leading, 25)
                        .padding(.trailing, 25)
                    }
                    .frame(height: rectangleHeight)
            
                    .tag(0)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(viewModel.selectedFroopHistory.confirmedFriends, id: \.self) { friend in
                                VStack {
                                    KFImage(URL(string: friend.profileImageUrl))
                                        .resizable()
                                        .scaledToFill()
                                        .clipShape(Circle())
                                        .frame(width: 50, height: 50)
                                    Text(friend.lastName != "" ? "\(friend.firstName) \(String(friend.lastName.prefix(1)))." : "\(friend.firstName)")
                                        .frame(maxWidth: 75)
                                        .font(.system(size: 12))
                                        .fontWeight(.light)
                                        .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                        .opacity(0.5)
                                }
                                .onTapGesture {
                                    friendRequestManager.selectedFriend = friend
                                    miniFriendDetailOpen = true
                                }
                            }
                        }
                        .padding(.leading, 25)
                        .padding(.trailing, 25)
                    }
                    .frame(height: rectangleHeight)
                    .tag(1)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(viewModel.selectedFroopHistory.declinedFriends , id: \.self) { friend in
                                VStack {
                                    KFImage(URL(string: friend.profileImageUrl))
                                        .resizable()
                                        .scaledToFill()
                                        .clipShape(Circle())
                                        .frame(width: 50, height: 50)
                                    Text(friend.lastName != "" ? "\(friend.firstName) \(String(friend.lastName.prefix(1)))." : "\(friend.firstName)")
                                        .font(.system(size: 12))
                                        .frame(minWidth: 75)
                                        .fontWeight(.regular)
                                        .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                }
                                .onTapGesture {
                                    friendRequestManager.selectedFriend = friend
                                    miniFriendDetailOpen = true
                                }
                            }
                        }
                        .padding(.leading, 25)
                        .padding(.trailing, 25)
                    }
                    .frame(height: rectangleHeight)
                    .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .padding(.trailing, 25)
                .padding(.leading, 25)
            }
        }
        Divider()
    }
}


class DetailsGuestViewModel: ObservableObject {
    static let shared = DetailsGuestViewModel()
    @ObservedObject var froopManager = FroopManager.shared
    @Published var selectedFroopHistory: FroopHistory = FroopManager.defaultFroopHistory()
    @Published var isPickerPresented: Bool = false
    @Published var videoURL: URL? = nil
    @Published var uploadProgress: CGFloat = 0.0
    @Published var videoThumbnail: UIImage?
    @Published var selectedVideoThumbnail: UIImage?
    @Published var isShowingProgressIndicator = false
    
    @Published var selectedVideoItem: PhotosPickerItem?
    @Published var videoDuration: TimeInterval?
    
    @Published var selectedVideoURL: URL?
    @Published var selectedVideoDuration: TimeInterval?
    @Published var conversionProgress: CGFloat = 0.0

    @Published var isPreparingVideo = false
    @Published var isUploadingVideo = false
    @Published var uploadSuccessful = false
    @Published var uploadFailed = false
    
    func resetVideoProperties() {
        selectedVideoItem = nil
        videoURL = nil
        videoThumbnail = nil
        videoDuration = nil
        selectedVideoURL = nil
        selectedVideoDuration = nil
        isPreparingVideo = false
        isUploadingVideo = false
        uploadSuccessful = false
        uploadFailed = false
    }
    
    func handleSelectedVideoItem(_ item: PhotosPickerItem?) {
        self.selectedVideoItem = item
        guard let item = item else {
            self.videoURL = nil
            self.videoDuration = nil
            return
        }
        
        item.loadTransferable(type: URL.self) { result in
            switch result {
                case .success(let url?):
                    DispatchQueue.main.async {
                        self.videoURL = url
                        // Load additional properties like duration if needed
                    }
                case .failure(let error):
                    print("🚫Error loading video: \(error)")
                    DispatchQueue.main.async {
                        self.videoURL = nil
                        self.videoDuration = nil
                    }
                case .success(.none):
                    self.videoURL = nil
                    self.videoDuration = nil
            }
        }
    }
    
    func generateThumbnail(for url: URL) {
//        print("Generating Thumbnail!")
        let asset = AVAsset(url: url)
        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        let time = CMTimeMakeWithSeconds(1.0, preferredTimescale: 600)
        
        DispatchQueue.global().async {
            do {
                let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
                let thumbnail = UIImage(cgImage: img)
                DispatchQueue.main.async {
                    self.videoThumbnail = thumbnail
                }
            } catch {
                print("🚫Error generating thumbnail: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.videoThumbnail = nil
                }
            }
        }
    }
    
    func stampCurrentFroopHistory(for froop: Froop) {
//        print("Stamp Current Froop History Function Fired! 🚫")
        print(froop)
        
        froopManager.createSingleFroopHistory(for: froop) { history in
            
            if let history = history {
//                print("printing history property 🦋")
                history.printDetails()
//                print("finished printing history property 🦋")
                DispatchQueue.main.async {
                    self.selectedFroopHistory = history
//                    print("Assigned history to selectedFroopHistory")
//                    print("Assigned FroopHistory: \(String(describing: self.selectedFroopHistory))")
//                    print("printing self?.selectedFroopHistory.printDetails() 👐")
                    self.selectedFroopHistory.printDetails()
//                    print("finished printing self?.selectedFroopHistory.printDetails() 👐")
                }
            } else {
                print("History is nil")
            }
            self.selectedFroopHistory.printDetails()
        }
    }
    
    func fetchGuests() {
        let group = DispatchGroup()
        
        group.enter()
        froopManager.fetchConfirmedFriendData(for: froopManager.selectedFroopHistory.froop) { result in
            switch result {
                case .success(let friends):
                    self.froopManager.confirmedFriends = friends
                case .failure(let error):
                    print("Failed to fetch confirmed friends: \(error)")
            }
            group.leave()
        }
        
        group.enter()
        froopManager.fetchInvitedFriendData(for: froopManager.selectedFroopHistory.froop) { result in
            switch result {
                case .success(let friends):
                    self.froopManager.invitedFriends = friends
                case .failure(let error):
                    print("Failed to fetch invited friends: \(error)")
            }
            group.leave()
        }
        
        group.enter()
        froopManager.fetchDeclinedFriendData(for: froopManager.selectedFroopHistory.froop) { result in
            switch result {
                case .success(let friends):
                    self.froopManager.declinedFriends = friends
                case .failure(let error):
                    print("Failed to fetch declined friends: \(error)")
            }
            group.leave()
        }
    }
    
    func uploadVideo(url: URL, viewModel: DetailsGuestViewModel) {
        // Indicate that video preparation is starting
        DispatchQueue.main.async {
            viewModel.isPreparingVideo = true
            viewModel.isUploadingVideo = false
            viewModel.uploadSuccessful = false
            viewModel.uploadFailed = false
        }

        // Define the output URL for the converted video
        let name = "\(Int(Date().timeIntervalSince1970)).mp4"
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let outputURL = documentsURL.appendingPathComponent(name)

        // Convert video to MPEG4 format
        convertVideo(toMPEG4FormatForVideo: url, outputURL: outputURL, viewModel: viewModel) { exportSession in
            DispatchQueue.main.async {
                // Update state based on conversion result
                viewModel.isPreparingVideo = false
                if exportSession.status == .completed, let convertedURL = exportSession.outputURL {
                    // Indicate that uploading is starting
                    viewModel.isUploadingVideo = true

                    // Upload to Firebase
                    self.uploadTOFireBaseVideo(url: convertedURL, thumbnail: viewModel.videoThumbnail, viewModel: viewModel, success: { videoURLString, thumbnailURLString in
                        // Update state on successful upload
                        viewModel.isUploadingVideo = false
                        viewModel.uploadSuccessful = true
//                        print("Video uploaded with URL: \(videoURLString)")
                        if thumbnailURLString != nil {
//                            print("Thumbnail uploaded with URL: \(thumbnailURLString)")
                        }
                    }, failure: { error in
                        // Update state on failed upload
                        viewModel.isUploadingVideo = false
                        viewModel.uploadFailed = true
                        print("Failed to upload video: \(error)")
                    })
                } else {
                    // Update state on failed conversion
                    viewModel.uploadFailed = true
                }
            }
        }
    }

    func convertVideo(toMPEG4FormatForVideo inputURL: URL, outputURL: URL, viewModel: DetailsGuestViewModel, completionHandler: @escaping (AVAssetExportSession) -> Void) {
        // Check if the file at outputURL already exists
        if FileManager.default.fileExists(atPath: outputURL.path) {
            do {
                // Attempt to remove the existing file
                try FileManager.default.removeItem(at: outputURL)
            } catch {
                print("🚫Error removing existing file: \(error)")
                return
            }
        }

        let asset = AVURLAsset(url: inputURL, options: nil)
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {
//            print("Failed to create AVAssetExportSession")
            return
        }
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4

        var timer: Timer?

        exportSession.exportAsynchronously {
            DispatchQueue.main.async {
                completionHandler(exportSession)
            }
        }

        // Setup timer to update progress
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            DispatchQueue.main.async {
                viewModel.conversionProgress = CGFloat(exportSession.progress)
//                print("Conversion progress: \(exportSession.progress * 100)%")

                // Invalidate timer if export session is completed or progress is near completion
                if exportSession.progress > 0.99 || exportSession.status != .exporting {
                    timer?.invalidate()
//                    print("Export session completed or progress near completion. Timer invalidated.")
                }
            }
        }
//        print("Timer set up to update conversion progress.")
    }
    
    func uploadTOFireBaseVideo(url: URL, thumbnail: UIImage?, viewModel: DetailsGuestViewModel, success: @escaping (String, String?) -> Void, failure: @escaping (Error) -> Void) {
        let froopId = froopManager.selectedFroopHistory.froop.froopId
        let froopHost = froopManager.selectedFroopHistory.host.froopUserID
        let name = "\(froopId)_introVideo.mp4"
        let thumbnailName = "\(froopId)_introVideoThumbnail.jpg"
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let outputURL = documentsURL.appendingPathComponent(name)

        // Convert video to MPEG4 format
        convertVideo(toMPEG4FormatForVideo: url, outputURL: outputURL, viewModel: viewModel) { exportSession in
            guard exportSession.status == .completed, let convertedURL = exportSession.outputURL else {
                failure(exportSession.error ?? NSError(domain: "VideoConversionError", code: 0, userInfo: nil))
                return
            }

            // Read data from the converted video file
            guard let videoData = NSData(contentsOf: convertedURL) else {
                failure(NSError(domain: "VideoDataError", code: 0, userInfo: nil))
                return
            }
            
            // Upload to Firebase
            let videoRef = Storage.storage().reference().child("FroopMediaAssets/\(froopHost)/\(froopId)/introVideo/\(name)")
            let uploadTask = videoRef.putData(videoData as Data, metadata: nil) { metadata, error in
                if let error = error {
                    failure(error)
                } else {
                    videoRef.downloadURL { videoURL, error in
                        if let error = error {
                            failure(error)
                        } else if let videoURL = videoURL {
                            // Check if there's a thumbnail to upload
                            if let thumbnail = thumbnail, let thumbnailData = thumbnail.jpegData(compressionQuality: 0.8) {
                                FroopManager.shared.videoThumbnail = thumbnail
                                
                                let thumbnailRef = Storage.storage().reference().child("FroopMediaAssets/\(froopHost)/\(froopId)/introVideo/\(thumbnailName)")
                                let thumbnailMetadata = StorageMetadata()
                                thumbnailMetadata.contentType = "image/jpeg"
                                thumbnailRef.putData(thumbnailData, metadata: thumbnailMetadata) { metadata, error in
                                    if let error = error {
                                        failure(error)
                                    } else {
                                        thumbnailRef.downloadURL { thumbnailURL, error in
                                            if let error = error {
                                                failure(error)
                                            } else if let thumbnailURL = thumbnailURL {
                                                // Call success and update Firestore with both URLs
                                                success(videoURL.absoluteString, thumbnailURL.absoluteString)
                                                FroopManager.shared.videoUrl = videoURL.absoluteString
                                                self.updateFirestoreWithVideoURLs(videoURL: videoURL.absoluteString, thumbnailURL: thumbnailURL.absoluteString)
                                            }
                                        }
                                    }
                                }
                            } else {
                                // No thumbnail to upload, update Firestore with video URL only
                                success(videoURL.absoluteString, nil)
                                self.updateFirestoreWithVideoURLs(videoURL: videoURL.absoluteString, thumbnailURL: nil)
                            }
                        }
                    }
                }
            }
            
            // Monitor upload progress
            uploadTask.observe(.progress) { snapshot in
                let percentComplete = Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
                DispatchQueue.main.async {
                    viewModel.uploadProgress = CGFloat(percentComplete)
                }
            }
        }
    }
    
    func updateFirestoreWithVideoURLs(videoURL: String, thumbnailURL: String?) {
        let db = Firestore.firestore()
        let froopId = froopManager.selectedFroopHistory.froop.froopId
        let hostUserId = froopManager.selectedFroopHistory.host.froopUserID
        let froopDocRef = db.collection("users").document(hostUserId).collection("myFroops").document(froopId)

        var updateData: [String: Any] = ["froopIntroVideo": videoURL]
        if let thumbnailURL = thumbnailURL {
            updateData["froopIntroVideoThumbnail"] = thumbnailURL
        }

        froopDocRef.updateData(updateData) { error in
            if let error = error {
                print("🚫Error updating document: \(error)")
            } else {
                print("Document successfully updated with video and thumbnail URLs")
            }
        }
    }
    
    func getImageUrl(from reference: StorageReference, completion: @escaping (Result<String, Error>) -> Void) {
        reference.downloadURL { url, error in
            if let url = url {
                completion(.success(url.absoluteString))
            } else if let error = error {
                print("🚫Error fetching URL: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                completion(.failure(UploadError.urlFetchFailed))
            }
        }
    }
}
