//
//  ArchivedMediaFeedView.swift
//  FroopProof
//
//  Created by David Reed on 5/5/23.
//



import SwiftUI
import Photos
import FirebaseStorage
import Firebase
import FirebaseAuth
import FirebaseFirestore
import Kingfisher
import SwiftUIBlurView


struct ArchivedMediaFeedView: View {
    
    @Environment(\.colorScheme) var colorScheme

    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var navLocationServices = NavLocationServices.shared
    // @ObservedObject var froopDataListener = FroopDataListener.shared
    @ObservedObject var froopManager = FroopManager.shared
    @ObservedObject var timeZoneManager:TimeZoneManager = TimeZoneManager()

    @StateObject private var viewModel = ArchivedMediaFeedViewModel()
    
    var mediaItems: [MediaData] = []
    var db = FirebaseServices.shared.db
    let imageItemskfs: [ImageItemkf] = []
    var isPassiveMode: Bool {
        return FroopManager.shared.selectedFroopHistory.froop.froopId == ""
    }
    
    @State private var uploading = false
    
    var body: some View {
        ZStack {
            VStack {
                if FroopManager.shared.selectedFroopHistory.froop.froopId != "" {
                    DownloadedMediaGridView(mediaItems: viewModel.mediaItems)
                } else {
                    Text("No active Froop ID available.")
                }
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .onAppear {
            if !isPassiveMode {
                viewModel.startListening()
            }
        }
        .onDisappear {
            viewModel.stopListening()
        }
    }
}

class ArchivedMediaFeedViewModel: ObservableObject {
    @Published var originalImageItems: [ImageItemkf] = []
    @Published var displayImageItems: [ImageItemkf] = []
    @Published var thumbnailImageItems: [ImageItemkf] = []
    @Published var mediaItems: [MediaData] = []
    
    let froopId = FroopManager.shared.selectedFroopHistory.froop.froopId
    let hostId = FroopManager.shared.selectedFroopHistory.host.froopUserID
    
    private var listener: ListenerRegistration?
    
    func startListening() {
        print("startListening Function Firing!")
        
        guard !froopId.isEmpty, !hostId.isEmpty else {
            print("🚫Error: froopId or host is empty")
            return
        }
        
        let froopRef = db.collection("users").document(hostId).collection("myFroops").document(froopId)
        
        listener = froopRef.addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("🚫Error fetching document: \(String(describing: error))")
                return
            }
            guard let data = document.data() else {
                print("Document data was empty.")
                return
            }
            
            // Process the document data as needed
            self.processDocumentData(data)
        }
    }
    
    func processDocumentData(_ data: [String: Any]) {
        // Clear the arrays
        self.originalImageItems.removeAll()
        self.displayImageItems.removeAll()
        self.thumbnailImageItems.removeAll()
        self.mediaItems.removeAll()
        
        // Process images
        if let froopImages = data["froopImages"] as? [String] {
            self.downloadImages(from: froopImages, type: .original)
        }
        if let froopDisplayImages = data["froopDisplayImages"] as? [String] {
            self.downloadImages(from: froopDisplayImages, type: .display)
        }
        if let froopThumbnailImages = data["froopThumbnailImages"] as? [String] {
            self.downloadImages(from: froopThumbnailImages, type: .thumbnail)
        }
        
        if let froopDisplayImages = data["froopDisplayImages"] as? [String] {
            for imageUrl in froopDisplayImages {
                if let imageURL = URL(string: imageUrl) {
                    downloadImage(imageURL) { downloadedImage in
                        let imageMediaData = MediaData(
                            asset: PHAsset(), // Placeholder or actual PHAsset if applicable
                            froopId: self.froopId,
                            hostId: self.hostId,
                            type: .image,
                            highResImage: downloadedImage, // Use the downloaded image
                            displayImage: downloadedImage, // Assuming displayImage is the same as highResImage
                            imageData: Data(), // Actual image data if needed
                            hash: "image-\(UUID().uuidString)", // Unique hash
                            show: true,
                            isSelected: false,
                            videoURL: nil, // No video URL for an image
                            thumbnailImage: nil // No thumbnail for a standard image
                        )
                        DispatchQueue.main.async {
                            self.mediaItems.append(imageMediaData)
                        }
                    }
                }
            }
        }
        
        // Process videos
        if let froopVideos = data["froopVideos"] as? [String], let froopVideoThumbnails = data["froopVideoThumbnails"] as? [String] {
            for (videoUrl, thumbnailUrl) in zip(froopVideos, froopVideoThumbnails) {
                if let videoURL = URL(string: videoUrl), let thumbnailURL = URL(string: thumbnailUrl) {
                    // Here you would download the thumbnail image for the video and then create a MediaData object
                    // For simplicity, let's assume you have a function to download the image and then create the MediaData object
                    downloadThumbnailImage(thumbnailURL) { thumbnailImage in
                        let videoMediaData = MediaData(
                            asset: PHAsset(), // Placeholder PHAsset
                            froopId: self.froopId,
                            hostId: self.hostId,
                            type: .video,
                            highResImage: nil, // No high-res image for a video
                            displayImage: thumbnailImage, // Use the downloaded thumbnail image
                            imageData: Data(), // Placeholder empty Data
                            hash: "video-\(UUID().uuidString)", // Generate a unique hash or use a placeholder
                            show: true, // Assuming you want to show this video
                            isSelected: false, // Default to not selected
                            videoURL: videoURL,
                            thumbnailImage: thumbnailImage
                        )
                        DispatchQueue.main.async {
                            self.mediaItems.append(videoMediaData)
                        }
                    }
                }
            }
        }
    }
    
    func downloadImage(_ url: URL, completion: @escaping (UIImage?) -> Void) {
        KingfisherManager.shared.retrieveImage(with: url) { result in
            switch result {
            case .success(let imageResult):
                completion(imageResult.image)
            case .failure(_):
                completion(nil)
            }
        }
    }
    
    func downloadThumbnailImage(_ url: URL, completion: @escaping (UIImage?) -> Void) {
        KingfisherManager.shared.retrieveImage(with: url) { result in
            switch result {
            case .success(let imageResult):
                completion(imageResult.image)
            case .failure(_):
                completion(nil)
            }
        }
    }
    
    func loadFroopContent(froopHost: String, froopId: String) {
        let froopRef = db.collection("users").document(froopHost).collection("myFroops").document(froopId)
        
        froopRef.getDocument { (documentSnapshot, error) in
            guard let document = documentSnapshot else {
                print("🚫Error fetching document: \(String(describing: error))")
                return
            }

            guard let data = document.data() else {
                print("Document data was empty.")
                return
            }

            if let froopImages = data["froopImages"] as? [String] {
                print("Froop original image URLs: \(froopImages)")
                self.downloadImages(from: froopImages, type: .original)
            }

            if let froopDisplayImages = data["froopDisplayImages"] as? [String] {
                print("Froop display image URLs: \(froopDisplayImages)")
                self.downloadImages(from: froopDisplayImages, type: .display)
            }

            if let froopThumbnailImages = data["froopThumbnailImages"] as? [String] {
                print("Froop thumbnail image URLs: \(froopThumbnailImages)")
                self.downloadImages(from: froopThumbnailImages, type: .thumbnail)
            }
        }
    }
    
    func stopListening() {
        listener?.remove()
    }
    
    func downloadImages(from urls: [String], type: ImageType, currentIndex: Int = 0) {
        guard currentIndex < urls.count else { return }
        
        if let url = URL(string: urls[currentIndex]) {
            KingfisherManager.shared.retrieveImage(with: url) { result in
                switch result {
                    case .success(let imageResult):
                        let image = imageResult.image
                        DispatchQueue.main.async {
                            print("Downloaded image successfully: \(urls[currentIndex])")
                            let imageItem = ImageItemkf(image: image, imageUrl: urls[currentIndex])
                            switch type {
                                case .original:
                                    self.originalImageItems.insert(imageItem, at: 0)
                                case .display:
                                    self.displayImageItems.insert(imageItem, at: 0)
                                case .thumbnail:
                                    self.thumbnailImageItems.insert(imageItem, at: 0)
                            }
                            
                            // Continue to the next image
                            self.downloadImages(from: urls, type: type, currentIndex: currentIndex + 1)
                        }
                    case .failure(let error):
                        print("🚫Error downloading image: \(error)")
                        // Continue to the next image even if there was an error
                        self.downloadImages(from: urls, type: type, currentIndex: currentIndex + 1)
                }
            }
        }
    }
}
