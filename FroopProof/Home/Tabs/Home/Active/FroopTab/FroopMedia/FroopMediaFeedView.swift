//
//  FroopMediaFeedView.swift
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
import AVKit



struct FroopMediaFeedView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var navLocationServices = NavLocationServices.shared
    // @ObservedObject var froopDataListener = FroopDataListener.shared
    @ObservedObject var froopManager = FroopManager.shared
    @ObservedObject var timeZoneManager:TimeZoneManager = TimeZoneManager()
    
    @StateObject private var viewModel = FroopMediaFeedViewModel()
    
    
    var db = FirebaseServices.shared.db
    let imageItemskfs: [ImageItemkf] = []
    let mediaItems: [MediaData] = []
    var isPassiveMode: Bool {
        return appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopId == ""
    }
    
    @State private var uploading = false
    
    var body: some View {
        ZStack {
            VStack {
                if appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopId != "" {
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

class FroopMediaFeedViewModel: ObservableObject {
    @Published var originalImageItems: [ImageItemkf] = []
    @Published var displayImageItems: [ImageItemkf] = []
    @Published var thumbnailImageItems: [ImageItemkf] = []
    @Published var mediaItems: [MediaData] = []
    var appStateManager: AppStateManager {
        return AppStateManager.shared
    }
    
    let froopId = AppStateManager.shared.currentFilteredFroopHistory[safe: AppStateManager.shared.aFHI]?.froop.froopId ?? ""
    let hostId = AppStateManager.shared.currentFilteredFroopHistory[safe: AppStateManager.shared.aFHI]?.froop.froopHost ?? ""
    
    private var listener: ListenerRegistration?
    
    func startListening() {
        print("startListening Function Firing!")
        
        // Safely access the current FroopHistory using the active index
        guard appStateManager.aFHI >= 0,
              appStateManager.aFHI < appStateManager.currentFilteredFroopHistory.count else {
            print("Index out of bounds or no FroopHistory available.")
            return
        }

        // Check if froopId or host is empty
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


struct VideoItem: Identifiable {
    let id = UUID()
    let thumbnailImage: UIImage // Thumbnail image to represent the video
    let videoUrl: URL // URL of the video file
    let title: String? // Optional title for the video
    let duration: TimeInterval? // Optional duration of the video

    // Initializer
    init(thumbnailImage: UIImage, videoUrl: URL, title: String? = nil, duration: TimeInterval? = nil) {
        self.thumbnailImage = thumbnailImage
        self.videoUrl = videoUrl
        self.title = title
        self.duration = duration
    }
}

struct ImageItemkf: Identifiable {
    let id = UUID()
    let image: UIImage
    let imageUrl: String
}

struct ToggleViewButton: View {
    @Binding var numColumns: Int
    
    var body: some View {
        HStack {
            Spacer()
            Button(action: {
                withAnimation(.easeInOut(duration: 0.5)) {
                    numColumns = (numColumns == 1) ? 3 : 1
                }
            }, label: {
                ZStack (alignment: .center) {
                    Rectangle ()
                        .frame(width: UIScreen.screenWidth, height: 50)
                        .foregroundColor(Color(.white).opacity(1))
                        .ignoresSafeArea()
                    
                    HStack(spacing: 5) {
                        Spacer()
                        Text(numColumns == 1 ? "CHANGE TO GRID VIEW" : "CHANGE TO EXPANDED VIEW")
                            .font(.system(size: 14))
                            .fontWeight(.bold)
                            .foregroundColor(Color(red: 249/255, green: 0/255, blue: 95/255).opacity(1))
                        Image(systemName: numColumns == 1 ? "square.grid.3x3.square" : "square.dashed.inset.filled")
                            .font(.system(size: 36))
                            .fontWeight(.ultraLight)
                            .foregroundColor(Color(red: 249/255, green: 0/255, blue: 95/255))
                            .padding(.trailing, 15)
                    }
                    .frame(width: UIScreen.screenWidth, height: 50)

                }
            })
            .background(.white)
        }
        .frame(maxHeight: 50)
    }
}

struct DownloadedMediaGridView: View {
    @ObservedObject var mediaManager = MediaManager.shared
    let mediaItems: [MediaData]
    
    @State private var showFullScreen = false
    @State private var selectedImage: UIImage?
    @State private var selectedImageIndex: Int?
    @State private var numColumns = 3
    @State private var activeVideoURL: URL? = nil
    @State private var activeVideo: IdentifiableURL? = nil
    @State private var isVideoPlayerPresented: Bool = false
    @State private var selectedVideoURL: URL? = nil
    
    var appStateManager: AppStateManager {
        return AppStateManager.shared
    }
    
    var body: some View {
        ZStack {
            FTVBackGroundComponent()
            Rectangle()
                .foregroundColor(.white)
                .frame(width: UIScreen.screenWidth)
                .ignoresSafeArea()
            VStack {
                ToggleViewButton(numColumns: $numColumns) 
                GeometryReader { geometry in
                    ScrollView(showsIndicators: false) {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 5), count: numColumns), spacing: 3) {
                            ForEach(mediaItems) { mediaItem in
                                if mediaItem.type == .image, let image = mediaItem.highResImage {
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: geometry.size.width / CGFloat(numColumns) - 10, height: geometry.size.width / CGFloat(numColumns) - 10)
                                        .clipped()
                                        .onTapGesture(count: 2) {
                                            withAnimation(.easeInOut(duration: 0.5)) {
                                                print("DoubleTap Firing!")
                                                if numColumns == 1 {
                                                    numColumns = 3
                                                } else {
                                                    numColumns = 1
                                                }
                                            }
                                        }
                                    // Add any additional overlay or functionality specific to images
                                } else if mediaItem.type == .video, let thumbnailImage = mediaItem.thumbnailImage {
                                    Image(uiImage: thumbnailImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: geometry.size.width / CGFloat(numColumns) - 10, height: geometry.size.width / CGFloat(numColumns) - 10)
                                        .clipped()
                                        .overlay(
                                            Image(systemName: "play.circle.fill")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .foregroundColor(.white)
                                                .opacity(0.9)
                                                .frame(width: 35, height: 35)
                                            ,
                                            alignment: .center
                                        )
                                        .onTapGesture {
                                            print("Video URL tapped: \(String(describing: mediaItem.videoURL))")
                                            mediaManager.selectedVideoURL = mediaItem.videoURL
                                            if let videoURL = mediaItem.videoURL {
                                                print("Setting selectedVideoURL to: \(videoURL.absoluteString)")
                                                self.selectedVideoURL = videoURL
                                                self.isVideoPlayerPresented = true
                                            } else {
                                                print("mediaItem.videoURL is nil")
                                            }
                                        }
                                    // Add any additional overlay or functionality specific to videos
                                }
                            }
                        }
                        .padding(.top, 5)
                        .padding(.leading, 10)
                        .padding(.trailing, 10)
                    }
                    
                    .fullScreenCover(isPresented: $isVideoPlayerPresented) {
                        if case mediaManager.selectedVideoURL = selectedVideoURL {
                            CustomVideoPlayerView(videoURLString: mediaManager.selectedVideoURL?.absoluteString ?? "") {
                                print("CustomVideoPlayerView closure executed, dismissing video player")
                                self.isVideoPlayerPresented = false
                            }
                            .onAppear {
                                print("Passing video URL to CustomVideoPlayerView: \(String(describing: mediaManager.selectedVideoURL))")
                            }
                        } else {
                            Text("No video URL found, cannot present video player")
                                .onAppear {
                                    print("Empty View presented because no video URL was found")
                                }
                        }
                    }
                    
                }
            }
        }
    }
    
    
    func deleteImage(imageURL: String, completion: @escaping (Error?) -> Void) {
        // Determine the type of image (display, thumbnail, or fullsize)
//        let imageType = determineImageType(from: imageURL)
        
        // Get the current FroopHistory
        let currentFroopHistory = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI] ?? FroopManager.defaultFroopHistory()
        
        // Find the index of the image URL in the corresponding array
        guard let index = findImageIndex(imageURL: imageURL, in: currentFroopHistory.froop) else {
            completion(NSError(domain: "ImageIndexError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Image index not found"]))
            return
        }
        
        // Retrieve URLs from all three arrays
        let urls = retrieveURLs(from: currentFroopHistory, atIndex: index)
        
        // Verify that all URLs share the same base URL
        guard verifyBaseURLs(urls) else {
            completion(NSError(domain: "URLMismatchError", code: 400, userInfo: [NSLocalizedDescriptionKey: "URLs do not match"]))
            return
        }
        
        // Delete URLs from Firestore document
        removeImageReferencesFromFirestore(froopHistory: currentFroopHistory, urls: urls) { firestoreError in
            if let firestoreError = firestoreError {
                completion(firestoreError)
                return
            }
            
            // Delete images from Firebase Storage
            deleteImagesFromStorage(urls: urls) { storageError in
                completion(storageError)
            }
        }
    }
    
    func deleteImagesFromStorage(urls: (thumbnailURL: String?, displayURL: String?, fullsizeURL: String?), completion: @escaping (Error?) -> Void) {
        let storage = Storage.storage()
        let dispatchGroup = DispatchGroup()
        
        let urlsToDelete = [urls.thumbnailURL, urls.displayURL, urls.fullsizeURL].compactMap { $0 }
        for url in urlsToDelete {
            dispatchGroup.enter()
            let storageRef = storage.reference(forURL: url)
            storageRef.delete { error in
                if let error = error, (error as NSError).code != StorageErrorCode.objectNotFound.rawValue {
                    print("🚫Error deleting image: \(error)")
                } else {
                    print("Image deleted successfully or not found")
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(nil)
        }
    }
    
    func removeImageReferencesFromFirestore(froopHistory: FroopHistory, urls: (thumbnailURL: String?, displayURL: String?, fullsizeURL: String?), completion: @escaping (Error?) -> Void) {
        let froopId = froopHistory.froop.froopId
        let froopHost = froopHistory.host.froopUserID
        let froopRef = db.collection("users").document(froopHost).collection("myFroops").document(froopId)
        
        var updateData: [String: Any] = [:]
        if let thumbnailURL = urls.thumbnailURL {
            updateData["froopThumbnailImages"] = FieldValue.arrayRemove([thumbnailURL])
        }
        if let displayURL = urls.displayURL {
            updateData["froopDisplayImages"] = FieldValue.arrayRemove([displayURL])
        }
        if let fullsizeURL = urls.fullsizeURL {
            updateData["froopImages"] = FieldValue.arrayRemove([fullsizeURL])
        }
        
        froopRef.updateData(updateData) { error in
            completion(error)
        }
    }
    
    func verifyBaseURLs(_ urls: (thumbnailURL: String?, displayURL: String?, fullsizeURL: String?)) -> Bool {
        let baseURLs = [urls.thumbnailURL, urls.displayURL, urls.fullsizeURL]
            .compactMap { $0 }
            .map { url in
                url.components(separatedBy: "/").dropLast().joined(separator: "/")
            }
        
        guard let firstBaseURL = baseURLs.first else { return false }
        
        return baseURLs.allSatisfy { $0 == firstBaseURL }
    }
    
    func retrieveURLs(from froopHistory: FroopHistory, atIndex index: Int) -> (thumbnailURL: String?, displayURL: String?, fullsizeURL: String?) {
        let froop = froopHistory.froop
        
        let thumbnailURL = index < froop.froopThumbnailImages.count ? froop.froopThumbnailImages[index] : nil
        let displayURL = index < froop.froopDisplayImages.count ? froop.froopDisplayImages[index] : nil
        let fullsizeURL = index < froop.froopImages.count ? froop.froopImages[index] : nil
        
        return (thumbnailURL, displayURL, fullsizeURL)
    }
    
    func findImageIndex(imageURL: String, in froop: Froop) -> Int? {
        // Determine the type of the image
        let imageType = determineImageType(from: imageURL)
        
        switch imageType {
            case .display:
                return froop.froopDisplayImages.firstIndex(of: imageURL)
            case .thumbnail:
                return froop.froopThumbnailImages.firstIndex(of: imageURL)
            case .fullsize:
                return froop.froopImages.firstIndex(of: imageURL)
            default:
                // Handle the unknown case or return nil
                return nil
        }
    }
    
    func determineImageType(from url: String) -> ImageType {
        if url.contains("display.jpg") {
            return .display
        } else if url.contains("thumbnail.jpg") {
            return .thumbnail
        } else if url.contains("fullsize.jpg") {
            return .fullsize
        } else {
            // Default case or throw an error if none of the types match
            return .unknown // or throw an error
        }
    }
    
    enum ImageType {
        case display
        case thumbnail
        case fullsize
        case unknown // Optional, for URLs that don't match any type
    }
}
