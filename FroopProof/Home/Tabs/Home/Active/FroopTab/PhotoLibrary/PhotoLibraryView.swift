//
//  PhotoLibraryView.swift
//  FroopProof
//
//  Created by David Reed on 5/5/23.
//

import SwiftUI
import PhotosUI
import FirebaseStorage
import FirebaseFirestore
import CommonCrypto

struct PhotoLibraryView: View {
    
    @ObservedObject var printControl = PrintControl.shared
    // @ObservedObject var froopDataListener = FroopDataListener.shared
    var appStateManager: AppStateManager {
        return AppStateManager.shared
    }
    @ObservedObject var viewModel = MediaGridViewModel.shared
    @ObservedObject var mediaManager = MediaManager.shared
    @ObservedObject var froopManager = FroopManager.shared
    var isPassiveMode: Bool {
        return AppStateManager.shared.currentFilteredFroopHistory[safe: AppStateManager.shared.aFHI]?.froop.froopId == ""
    }
    @State var uniqueID = UUID()
    @State private var uploading = false
    @Binding var uploadedMedia: [MediaData]
    
    
    let calendar = Calendar.current
    let froopStartTime: Date
    let froopEndTime: Date
    let validData = Data()
    let validString = ""
    
    public init(uploadedMedia: Binding<[MediaData]>) {
        let froopDate = AppStateManager.shared.currentFilteredFroopHistory[safe: AppStateManager.shared.aFHI]?.froop.froopStartTime ?? Date()
        self.froopStartTime = calendar.startOfDay(for: froopDate)
        self.froopEndTime = calendar.date(byAdding: .day, value: 1, to: self.froopStartTime)?.addingTimeInterval(-1) ?? froopDate
        self._uploadedMedia = uploadedMedia
    }
    
    var body: some View {
        ZStack {
            VStack {
                if !isPassiveMode {
                    MediaGridView(
                        onAddToFroop: { image, creationDate, assetIdentifier, completion in
                            onAddToFroop(image: image, creationDate: creationDate, assetIdentifier: assetIdentifier, completion: completion)
                        },
                        uploadSelectedMedia: mediaManager.uploadSelectedMedia,
                        uniqueID: $uniqueID
                    )
                }
            }
            
            if uploading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    .scaleEffect(2)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.blue.opacity(1))
                    .edgesIgnoringSafeArea(.all)
            }
            
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .onAppear {
            viewModel.loadMedia(from: froopStartTime, to: froopEndTime, validData: validData, validString: validString)
        }
        .navigationTitle("\(appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopName ?? "")")
    }
    
    func onAddToFroop(image: UIImage, creationDate: Date, assetIdentifier: String, completion: @escaping (Bool) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            print("🚫Error: Could not convert image to JPEG data")
            completion(false)
            return
        }
        
        let froopId = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopId ?? ""
        let hostId = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.host.froopUserID ?? ""
        let froopHost = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.host.froopUserID ?? ""
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let froopMediaAssetsRef = storageRef.child("FroopMediaAssets/\(String(describing: froopHost))/\(String(describing: froopId))")
        let imageName = UUID().uuidString
        let imageRef = froopMediaAssetsRef.child("\(imageName).jpg")
        
        uploading = true
        
        _ = imageRef.putData(imageData, metadata: nil) { (metadata, error) in
            DispatchQueue.main.async {
                self.uploading = false
            }
            if let error = error {
                print("🚫Error: Failed to upload image to Firebase Storage with error: \(error.localizedDescription)")
                completion(false)
                return
            }
            imageRef.downloadURL { (url, error) in
                if let error = error {
                    print("🚫Error: Failed to get the download URL with error: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                guard let downloadURL = url else {
                    print("🚫Error: Download URL was not found.")
                    completion(false)
                    return
                }
                
                // Here is where you would store the assetIdentifier along with the image URL
                FroopManager.shared.addMediaURLAndAssetIdentifierToDocument(
                    froopHost: froopHost,
                    froopId: froopId,
                    mediaURL: downloadURL,
                    assetIdentifier: assetIdentifier, // Storing the asset identifier
                    isImage: true
                )
                
                appStateManager.mediaTimeStamp.append(creationDate)
                completion(true)
            }
        }
    }
}

class MediaGridViewModel: ObservableObject {
    static let shared = MediaGridViewModel()
    @ObservedObject var scriptManager = UserSubscriptionManager.shared
    @ObservedObject var myData = MyData.shared
    @ObservedObject var froopManager = FroopManager.shared
    @Published var mediaItems: [MediaData] = []
    @Published var selectedMedia: [MediaData] = []
    @Published var uploadedMedia: [MediaData] = []
    @Published var isUploading: Bool = false
    @Published var toggle: Bool = false
    @Published var mediaCount: Int = 0
    var reversedMedia: [MediaData] {
        selectedMedia.reversed()
    }
    var appStateManager: AppStateManager {
        return AppStateManager.shared
    }
    
    var alreadyUploadedAssetIdentifiers = Set<String>()
    var displayedMediaIDs = Set<UUID>()
    
    private var lastFetchedIndex: Int = 0
    
    private var mediaManager = MediaManager()
    
    func sha256Data(_ data: Data) -> String {
        var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }
        return Data(hash).map { String(format: "%02x", $0) }.joined()
    }
    
    func loadNextBatchOfImages() {
        let batchSize = 2
        
        let rangeStart = lastFetchedIndex
        let rangeEnd = min(lastFetchedIndex + batchSize, mediaItems.count)
        
        for index in rangeStart..<rangeEnd {
            loadImage(for: self.mediaItems[index]) { highResImage, displayImage in
                DispatchQueue.main.async {
                    self.mediaItems[index].displayImage = displayImage
                }
            }
        }
        
        lastFetchedIndex = rangeEnd
    }
    
    func loadMedia(from froopStartTime: Date, to froopEndTime: Date, validData: Data, validString: String) {
           print("◆ froopStartTime: \(froopStartTime)")
           print("◆ froopEndTime: \(froopEndTime)")

        let froopId = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopId ?? ""
        let hostId = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.host.froopUserID ?? ""
        
        mediaManager.requestPhotoLibraryAuthorization { success in
               if success {
                   self.mediaManager.fetchMediaFromPhotoLibrary(
                       froopStartTime: froopStartTime - 14400,
                       froopEndTime: froopEndTime + 14400,
                       includeVideos: self.appStateManager.currentFilteredFroopHistory[safe: self.appStateManager.aFHI]?.host.premiumAccount ?? false
                   ) { assets in
                       let group = DispatchGroup()

                       var mediaItemsTemp: [MediaData] = []

                       for asset in assets {
                           group.enter()

                           if asset.mediaType == .video && self.appStateManager.activeHostData.premiumAccount == true {
                               let options = PHImageRequestOptions()
                               options.isNetworkAccessAllowed = true
                               options.deliveryMode = .highQualityFormat
                               options.resizeMode = .fast
                               let targetSize = CGSize(width: 200, height: 200)

                               PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options) { (image, _) in
                                   let mediaItem = MediaData(
                                    asset: asset, froopId: froopId, hostId: hostId, type: .video, imageData: validData, hash: validString, show: true, thumbnailImage: image)
                                   mediaItemsTemp.append(mediaItem)
                                   group.leave()
                               }
                           } else {
                               // Handle image assets
                               let mediaItem = MediaData(asset: asset, froopId: froopId, hostId: hostId,type: .image, imageData: validData, hash: validString, show: true)
                               mediaItemsTemp.append(mediaItem)
                               group.leave()
                           }
                       }

                       group.notify(queue: .main) {
                           self.mediaItems = mediaItemsTemp.sorted(by: { $0.asset.creationDate ?? Date() > $1.asset.creationDate ?? Date() })

                           // Load display images for image assets
                           for (index, mediaItem) in self.mediaItems.enumerated() {
                               if mediaItem.type == .image {
                                   self.loadDisplayImage(for: mediaItem) { displayImage in
                                       DispatchQueue.main.async {
                                           self.mediaItems[index].displayImage = displayImage
                                           self.mediaItems[index].show = true
                                       }
                                   }
                               }
                           }
                       }
                   }
               } else {
                   print("Authorization failed")
               }
           }
       }
    
    func loadArchivedMedia(from froopStartTime: Date, to froopEndTime: Date, validData: Data, validString: String) {
           print("◆ froopStartTime: \(froopStartTime)")
           print("◆ froopEndTime: \(froopEndTime)")

        let froopId = FroopManager.shared.selectedFroopHistory.froop.froopId
        let hostId = FroopManager.shared.selectedFroopHistory.host.froopUserID
        
        mediaManager.requestPhotoLibraryAuthorization { success in
               if success {
                   self.mediaManager.fetchMediaFromPhotoLibrary(
                       froopStartTime: froopStartTime - 14400,
                       froopEndTime: froopEndTime + 14400,
                       includeVideos: FroopManager.shared.selectedFroopHistory.host.premiumAccount
                       
                   ) { assets in
                       let group = DispatchGroup()

                       var mediaItemsTemp: [MediaData] = []

                       for asset in assets {
                           group.enter()

                           if asset.mediaType == .video && self.froopManager.selectedFroopHistory.host.premiumAccount == true {
                               let options = PHImageRequestOptions()
                               options.isNetworkAccessAllowed = true
                               options.deliveryMode = .highQualityFormat
                               options.resizeMode = .fast
                               let targetSize = CGSize(width: 200, height: 200)

                               PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options) { (image, _) in
                                   let mediaItem = MediaData(
                                    asset: asset, froopId: froopId, hostId: hostId, type: .video, imageData: validData, hash: validString, show: true, thumbnailImage: image)
                                   mediaItemsTemp.append(mediaItem)
                                   group.leave()
                               }
                           } else {
                               // Handle image assets
                               let mediaItem = MediaData(asset: asset, froopId: froopId, hostId: hostId,type: .image, imageData: validData, hash: validString, show: true)
                               mediaItemsTemp.append(mediaItem)
                               group.leave()
                           }
                       }

                       group.notify(queue: .main) {
                           self.mediaItems = mediaItemsTemp.sorted(by: { $0.asset.creationDate ?? Date() > $1.asset.creationDate ?? Date() })

                           // Load display images for image assets
                           for (index, mediaItem) in self.mediaItems.enumerated() {
                               if mediaItem.type == .image {
                                   self.loadDisplayImage(for: mediaItem) { displayImage in
                                       DispatchQueue.main.async {
                                           self.mediaItems[index].displayImage = displayImage
                                           self.mediaItems[index].show = true
                                       }
                                   }
                               }
                           }
                       }
                   }
               } else {
                   print("Authorization failed")
               }
           }
       }
    
    func loadHighResImagesForSelectedItems(selectedItems: [MediaData], completion: @escaping () -> Void) {
        print("loadHighResimageForSelectedItems firing!")
        let group = DispatchGroup()
        
        for item in selectedItems {
            group.enter()
            if let index = self.mediaItems.firstIndex(where: { $0.id == item.id }) {
                self.mediaItems[index].isLoadingHighResImage = true
            }
            
            self.loadHighResImage(for: item) { highResImage in
                DispatchQueue.main.async {
                    if let index = self.mediaItems.firstIndex(where: { $0.id == item.id }) {
                        self.mediaItems[index].highResImage = highResImage
                        self.mediaItems[index].isLoadingHighResImage = false
                    }
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            completion()
        }
    }
    
    func loadDisplayImage(for imageItem: MediaData, completion: @escaping (UIImage?) -> Void) {
        print("loadDisplayImage function firing!")
        let manager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.version = .current
        requestOptions.isNetworkAccessAllowed = true
        requestOptions.deliveryMode = .highQualityFormat
        requestOptions.resizeMode = .fast // Resize the image quickly for display purposes
        let targetSize = CGSize(width: UIScreen.screenWidth, height: UIScreen.screenWidth) // Adjust size as needed
        
        manager.requestImage(for: imageItem.asset, targetSize: targetSize, contentMode: .aspectFit, options: requestOptions) { (image, _) in
            DispatchQueue.main.async {
                if image != nil {
                    print("Display Image Loaded")
                } else {
                    print("Display Image is nil")
                }
                completion(image) // Return the resized image for display
                self.toggle.toggle()
            }
        }
    }
    
    func loadHighResImage(for imageItem: MediaData, completion: @escaping (UIImage?) -> Void) {
        print("loadHighResImage function firing!")
        let manager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isNetworkAccessAllowed = true
        requestOptions.deliveryMode = .highQualityFormat
        
        manager.requestImageDataAndOrientation(for: imageItem.asset, options: requestOptions) { (data, dataUTI, _, info) in
            DispatchQueue.main.async {
                if let data = data, let highResImage = UIImage(data: data) {
                    print("High-Res Image Loaded")
                    completion(highResImage)
                } else {
                    print("High-Res Image is nil")
                    completion(nil)
                }
            }
        }
    }
    
    func loadImage(for imageItem: MediaData, completion: @escaping (UIImage?, UIImage?) -> Void) {
        let manager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isNetworkAccessAllowed = true // Allow fetching from iCloud
        requestOptions.deliveryMode = .highQualityFormat // Request the full-resolution image
        
        manager.requestImageDataAndOrientation(for: imageItem.asset, options: requestOptions) { data, _, orientation, _ in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, nil) // No data could be fetched
                }
                return
            }
            
            // Convert the image data to a UIImage
            if let highResImage = UIImage(data: data) {
                let displayImage = highResImage.resized(toWidth: UIScreen.screenWidth) // Define thumbnailWidth as needed
                DispatchQueue.main.async {
                    completion(highResImage, displayImage) // Return both images
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil, nil)
                }
            }
        }
    }
}


struct MediaGridView: View {
    let onAddToFroop: ((UIImage, Date, String, @escaping (Bool) -> Void) -> Void)?
    let uploadSelectedMedia: ((_ media: [MediaData], _ onMediaUploaded: @escaping (MediaData) -> Void, _ onAllMediaUploaded: @escaping () -> Void) -> Void)?
    @ObservedObject var viewModel = MediaGridViewModel.shared
    @State var showingFullScreenImageView = false
    @State var selectedMediaIndex: Int?
    @State var selectedMediaItem: MediaData?
//    @State var selectedMedia: [MediaData] = []
    @State var numColumns = 2
//    @Binding var uploadedMedia: [MediaData]
    @Binding var uniqueID: UUID
    @State private var isPresentingPhotoPicker = false
    @State private var photoPickerSelection: PhotosPickerItem? = nil // Updated to use PhotosPickerItem
    
    init(onAddToFroop: ((UIImage, Date, String, @escaping (Bool) -> Void) -> Void)?, uploadSelectedMedia: ((_ images: [MediaData], _ onImageUploaded: @escaping (MediaData) -> Void, _ onAllImagesUploaded: @escaping () -> Void) -> Void)?, uniqueID: Binding<UUID>) {
        self.onAddToFroop = onAddToFroop
        self.uploadSelectedMedia = uploadSelectedMedia
        _uniqueID = uniqueID
    }
   
    
    var body: some View {
        VStack{
            HStack {
                Spacer()
                Button(action: {
                    // Save selected images to the Froop
                    if let uploadSelectedMedia = uploadSelectedMedia {
                        viewModel.isUploading = true
                        print("uploadedMedia before removeall \(viewModel.uploadedMedia)")
                        
                        uploadSelectedMedia(viewModel.selectedMedia, { uploadedImage in
                            viewModel.uploadedMedia.append(uploadedImage)
                            viewModel.selectedMedia.removeAll { $0 == uploadedImage }
                        }, {
                            // Clear the selectedImages array after all images have been uploaded
                            viewModel.selectedMedia.removeAll()
                        })
                        print("selectedImages after removeall \(viewModel.selectedMedia)")
                        print("uploadedImages after removeall \(viewModel.uploadedMedia)")
                    }
                }, label: {
                    HStack(spacing: 5) {
                        Spacer()
                        Text("\(viewModel.selectedMedia.count) ASSETS TO UPLOAD")
                            .font(.system(size: 14))
                            .fontWeight(.bold)
                            .foregroundColor(Color(red: 249/255, green: 0/255, blue: 95/255).opacity(0.5))
                        Image(systemName: "icloud.and.arrow.up")
                            .font(.system(size: 28))
                            .fontWeight(.light)
                            .foregroundColor(Color(red: 249/255, green: 0/255, blue: 95/255))
                    }
                })
                //                .buttonStyle(FroopButtonStyle())
                .frame(width: 400, height: 30 )
                .opacity(viewModel.selectedMedia.isEmpty || viewModel.isUploading ? 0.05 : 1)
                .padding(.trailing, 15)
                .padding(.top, 15)
                .onChange(of: viewModel.selectedMedia) { oldValue, newValue in
                    if newValue.isEmpty {
                        MediaGridViewModel.shared.isUploading = false
                    }
                }

            }
            
            Spacer()
        }
        .frame(maxHeight: 50)
        
        ZStack {
            GeometryReader { geometry in
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: numColumns), spacing: 5) {
                        // Use viewModel.imageItems directly
                        ForEach(viewModel.mediaItems.indices, id: \.self) { index in
                            let mediaItem = viewModel.mediaItems[index]
                            MediaWithCheckmarkOverlay(mediaItem: mediaItem, index: index, geometry: geometry)
                        }
                        .id(uniqueID)
                    }
                }
                .frame(height: UIScreen.screenHeight * 0.60)
            }
        }
        .padding(.leading, 5)
        .padding(.trailing, 5)
    }
    
    func toggleImageSelection(imageItem: MediaData, index: Int) {
        if let itemIndex = viewModel.mediaItems.firstIndex(where: { $0.id == imageItem.id }) {
            viewModel.mediaItems[itemIndex].isSelected.toggle()
            
            if viewModel.mediaItems[itemIndex].isSelected {
                // Item is selected
                viewModel.loadHighResImage(for: viewModel.mediaItems[itemIndex]) { highResImage in
                    DispatchQueue.main.async {
                        if let highResImage = highResImage {
                            self.viewModel.mediaItems[itemIndex].highResImage = highResImage
                            // Add to selectedMedia and displayedMediaIDs
                            self.viewModel.selectedMedia.append(self.viewModel.mediaItems[itemIndex])
                            self.viewModel.displayedMediaIDs.insert(self.viewModel.mediaItems[itemIndex].id)
                        }
                    }
                }
            } else {
                // Item is deselected
                viewModel.selectedMedia.removeAll { $0.id == viewModel.mediaItems[itemIndex].id }
                viewModel.displayedMediaIDs.remove(viewModel.mediaItems[itemIndex].id) // Remove ID from displayedMediaIDs
            }
        }
    }
    
    @ViewBuilder
    private func MediaWithCheckmarkOverlay(mediaItem: MediaData, index: Int, geometry: GeometryProxy) -> some View {
        ZStack {
            if mediaItem.type == .image {
                if let displayImage = mediaItem.displayImage ?? mediaItem.thumbnailImage ?? mediaItem.highResImage {
                    Image(uiImage: displayImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: (geometry.size.width / CGFloat(numColumns)), height: (geometry.size.width / CGFloat(numColumns)))
                        .clipped()
                        .onAppear {
                            print("ImageLoaded")
                        }
                } else {
                    Color.gray
                        .frame(width: (geometry.size.width / CGFloat(numColumns)), height: (geometry.size.width / CGFloat(numColumns)))
                        .onAppear {
                            retryLoadDisplayImage(mediaItem: mediaItem) { success in
                                if success {
                                    print("Display image loaded successfully")
                                } else {
                                    retryLoadDisplayImage(mediaItem: mediaItem) { success in
                                        if success {
                                            print("Display image loaded successfully")
                                        } else {
                                            retryLoadDisplayImage(mediaItem: mediaItem) { success in
                                                if success {
                                                    print("Display image loaded successfully")
                                                } else {
                                                    retryLoadDisplayImage(mediaItem: mediaItem) { success in
                                                        if success {
                                                            print("Display image loaded successfully")
                                                        } else {
                                                            print("Failed to load display image")
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                }
            } else if mediaItem.type == .video {
                if let thumbnailImage = mediaItem.thumbnailImage {
                    Image(uiImage: thumbnailImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: (geometry.size.width / CGFloat(numColumns)), height: (geometry.size.width / CGFloat(numColumns)))
                        .clipped()
                        .overlay(
                            ZStack {
                                Circle()
                                    .fill(Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.5))
                                    .frame(width: 70, height: 70)
                                
                                Image(systemName: "video.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(.white)
                                    .opacity(0.9)
                                    .frame(width: 35, height: 35)
                            },
                            alignment: .center
                        )
                    
                } else {
                    Color(red: 50/255, green: 46/255, blue: 62/255)
                        .frame(width: (geometry.size.width / CGFloat(numColumns)), height: (geometry.size.width / CGFloat(numColumns)))
                        .onAppear {
                            viewModel.loadImage(for: mediaItem) { highResImage, displayImage in
                                if let index = viewModel.mediaItems.firstIndex(where: { $0.id == mediaItem.id }) {
                                    DispatchQueue.main.async {
                                        viewModel.mediaItems[index].displayImage = displayImage
                                    }
                                }
                            }
                        }
                }
            }
            
            if mediaItem.isSelected {
                ZStack(alignment: .center) {
                    Circle()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.white)
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .foregroundColor(viewModel.uploadedMedia.contains(where: { $0.id == mediaItem.id }) ? .green : .blue)
                        .fontWeight(.thin)
                }
                .offset(x: numColumns == 2 ? UIScreen.screenWidth / 5 : UIScreen.screenWidth / 2.5, y: numColumns == 2 ? UIScreen.screenWidth / -5 : UIScreen.screenWidth / -2.5)
            }
            
            if mediaItem.isLoadingHighResImage {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture(count: 2) {
            withAnimation(.easeInOut(duration: 0.5)) {
                print("DoubleTap Firing!")
                selectedMediaIndex = index
                selectedMediaItem = mediaItem
                showingFullScreenImageView = true
                if numColumns == 1 {
                    numColumns = 2
                } else {
                    numColumns = 1
                }
            }
        }
        .simultaneousGesture(TapGesture().onEnded {
            withAnimation(.easeInOut(duration: 0.5)) {
                toggleImageSelection(imageItem: mediaItem, index: index)
                viewModel.mediaCount = viewModel.selectedMedia.count
            }
        })
    }
    
    private func retryLoadDisplayImage(mediaItem: MediaData, completion: @escaping (Bool) -> Void) {
        // Check if the image is already present in the array
        if let index = viewModel.mediaItems.firstIndex(where: { $0.id == mediaItem.id }),
           let displayImage = viewModel.mediaItems[index].displayImage ?? viewModel.mediaItems[index].thumbnailImage ?? viewModel.mediaItems[index].highResImage {
            // Image is already loaded, update the display image and call completion with success
            viewModel.mediaItems[index].displayImage = displayImage
            completion(true)
        } else {
            // Image is not loaded, attempt to re-load it from the device
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                if let index = viewModel.mediaItems.firstIndex(where: { $0.id == mediaItem.id }) {
                    viewModel.loadDisplayImage(for: viewModel.mediaItems[index]) { displayImage in
                        DispatchQueue.main.async {
                            viewModel.mediaItems[index].displayImage = displayImage
                            completion(displayImage != nil)
                        }
                    }
                } else {
                    completion(false)
                }
            }
        }
    }
}

struct ArchivedMediaGridView: View {
    let onAddToFroop: ((UIImage, Date, String, @escaping (Bool) -> Void) -> Void)?
    let uploadSelectedArchivedMedia: ((_ media: [MediaData], _ onMediaUploaded: @escaping (MediaData) -> Void, _ onAllMediaUploaded: @escaping () -> Void) -> Void)?
    @ObservedObject var viewModel = MediaGridViewModel.shared
    @State var showingFullScreenImageView = false
    @State var selectedMediaIndex: Int?
    @State var selectedMediaItem: MediaData?
//    @State var selectedMedia: [MediaData] = []
    @State var numColumns = 2
//    @Binding var uploadedMedia: [MediaData]
    @Binding var uniqueID: UUID
    @State private var isPresentingPhotoPicker = false
    @State private var photoPickerSelection: PhotosPickerItem? = nil // Updated to use PhotosPickerItem
    
    init(onAddToFroop: ((UIImage, Date, String, @escaping (Bool) -> Void) -> Void)?, uploadSelectedArchivedMedia: ((_ images: [MediaData], _ onImageUploaded: @escaping (MediaData) -> Void, _ onAllImagesUploaded: @escaping () -> Void) -> Void)?, uniqueID: Binding<UUID>) {
        self.onAddToFroop = onAddToFroop
        self.uploadSelectedArchivedMedia = uploadSelectedArchivedMedia
        _uniqueID = uniqueID
    }
   
    
    var body: some View {
        VStack{
            HStack {
                Spacer()
                Button(action: {
                    // Save selected images to the Froop
                    if let uploadSelectedArchivedMedia = uploadSelectedArchivedMedia {
                        viewModel.isUploading = true
                        print("uploadedMedia before removeall \(viewModel.uploadedMedia)")
                        
                        uploadSelectedArchivedMedia(viewModel.selectedMedia, { uploadedImage in
                            viewModel.uploadedMedia.append(uploadedImage)
                            viewModel.selectedMedia.removeAll { $0 == uploadedImage }
                        }, {
                            // Clear the selectedImages array after all images have been uploaded
                            viewModel.selectedMedia.removeAll()
                        })
                        print("selectedImages after removeall \(viewModel.selectedMedia)")
                        print("uploadedImages after removeall \(viewModel.uploadedMedia)")
                    }
                }, label: {
                    HStack(spacing: 5) {
                        Spacer()
                        Text("\(viewModel.selectedMedia.count) ASSETS TO UPLOAD")
                            .font(.system(size: 14))
                            .fontWeight(.bold)
                            .foregroundColor(Color(red: 249/255, green: 0/255, blue: 95/255).opacity(0.5))
                        Image(systemName: "icloud.and.arrow.up")
                            .font(.system(size: 28))
                            .fontWeight(.light)
                            .foregroundColor(Color(red: 249/255, green: 0/255, blue: 95/255))
                    }
                })
                //                .buttonStyle(FroopButtonStyle())
                .frame(width: 400, height: 30 )
                .opacity(viewModel.selectedMedia.isEmpty || viewModel.isUploading ? 0.05 : 1)
                .padding(.trailing, 15)
                .padding(.top, 15)
                .onChange(of: viewModel.selectedMedia) { oldValue, newValue in
                    if newValue.isEmpty {
                        MediaGridViewModel.shared.isUploading = false
                    }
                }

            }
            
            Spacer()
        }
        .frame(maxHeight: 50)
        
        ZStack {
            GeometryReader { geometry in
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: numColumns), spacing: 5) {
                        // Use viewModel.imageItems directly
                        ForEach(viewModel.mediaItems.indices, id: \.self) { index in
                            let mediaItem = viewModel.mediaItems[index]
                            MediaWithCheckmarkOverlay(mediaItem: mediaItem, index: index, geometry: geometry)
                        }
                        .id(uniqueID)
                    }
                }
                .frame(height: UIScreen.screenHeight * 0.60)
            }
        }
        .padding(.leading, 5)
        .padding(.trailing, 5)
    }
    
    func toggleImageSelection(imageItem: MediaData, index: Int) {
        if let itemIndex = viewModel.mediaItems.firstIndex(where: { $0.id == imageItem.id }) {
            viewModel.mediaItems[itemIndex].isSelected.toggle()
            
            if viewModel.mediaItems[itemIndex].isSelected {
                // Item is selected
                viewModel.loadHighResImage(for: viewModel.mediaItems[itemIndex]) { highResImage in
                    DispatchQueue.main.async {
                        if let highResImage = highResImage {
                            self.viewModel.mediaItems[itemIndex].highResImage = highResImage
                            // Add to selectedMedia and displayedMediaIDs
                            self.viewModel.selectedMedia.append(self.viewModel.mediaItems[itemIndex])
                            self.viewModel.displayedMediaIDs.insert(self.viewModel.mediaItems[itemIndex].id)
                        }
                    }
                }
            } else {
                // Item is deselected
                viewModel.selectedMedia.removeAll { $0.id == viewModel.mediaItems[itemIndex].id }
                viewModel.displayedMediaIDs.remove(viewModel.mediaItems[itemIndex].id) // Remove ID from displayedMediaIDs
            }
        }
    }
    
    @ViewBuilder
    private func MediaWithCheckmarkOverlay(mediaItem: MediaData, index: Int, geometry: GeometryProxy) -> some View {
        ZStack {
            if mediaItem.type == .image {
                if let displayImage = mediaItem.displayImage ?? mediaItem.thumbnailImage ?? mediaItem.highResImage {
                    Image(uiImage: displayImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: (geometry.size.width / CGFloat(numColumns)), height: (geometry.size.width / CGFloat(numColumns)))
                        .clipped()
                        .onAppear {
                            print("ImageLoaded")
                        }
                } else {
                    Color.gray
                        .frame(width: (geometry.size.width / CGFloat(numColumns)), height: (geometry.size.width / CGFloat(numColumns)))
                        .onAppear {
                            retryLoadDisplayImage(mediaItem: mediaItem) { success in
                                if success {
                                    print("Display image loaded successfully")
                                } else {
                                    retryLoadDisplayImage(mediaItem: mediaItem) { success in
                                        if success {
                                            print("Display image loaded successfully")
                                        } else {
                                            retryLoadDisplayImage(mediaItem: mediaItem) { success in
                                                if success {
                                                    print("Display image loaded successfully")
                                                } else {
                                                    retryLoadDisplayImage(mediaItem: mediaItem) { success in
                                                        if success {
                                                            print("Display image loaded successfully")
                                                        } else {
                                                            print("Failed to load display image")
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                }
            } else if mediaItem.type == .video {
                if let thumbnailImage = mediaItem.thumbnailImage {
                    Image(uiImage: thumbnailImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: (geometry.size.width / CGFloat(numColumns)), height: (geometry.size.width / CGFloat(numColumns)))
                        .clipped()
                        .overlay(
                            ZStack {
                                Circle()
                                    .fill(Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.5))
                                    .frame(width: 70, height: 70)
                                
                                Image(systemName: "video.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(.white)
                                    .opacity(0.9)
                                    .frame(width: 35, height: 35)
                            },
                            alignment: .center
                        )
                    
                } else {
                    Color(red: 50/255, green: 46/255, blue: 62/255)
                        .frame(width: (geometry.size.width / CGFloat(numColumns)), height: (geometry.size.width / CGFloat(numColumns)))
                        .onAppear {
                            viewModel.loadImage(for: mediaItem) { highResImage, displayImage in
                                if let index = viewModel.mediaItems.firstIndex(where: { $0.id == mediaItem.id }) {
                                    DispatchQueue.main.async {
                                        viewModel.mediaItems[index].displayImage = displayImage
                                    }
                                }
                            }
                        }
                }
            }
            
            if mediaItem.isSelected {
                ZStack(alignment: .center) {
                    Circle()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.white)
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .foregroundColor(viewModel.uploadedMedia.contains(where: { $0.id == mediaItem.id }) ? .green : .blue)
                        .fontWeight(.thin)
                }
                .offset(x: numColumns == 2 ? UIScreen.screenWidth / 5 : UIScreen.screenWidth / 2.5, y: numColumns == 2 ? UIScreen.screenWidth / -5 : UIScreen.screenWidth / -2.5)
            }
            
            if mediaItem.isLoadingHighResImage {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture(count: 2) {
            withAnimation(.easeInOut(duration: 0.5)) {
                print("DoubleTap Firing!")
                selectedMediaIndex = index
                selectedMediaItem = mediaItem
                showingFullScreenImageView = true
                if numColumns == 1 {
                    numColumns = 2
                } else {
                    numColumns = 1
                }
            }
        }
        .simultaneousGesture(TapGesture().onEnded {
            withAnimation(.easeInOut(duration: 0.5)) {
                toggleImageSelection(imageItem: mediaItem, index: index)
                viewModel.mediaCount = viewModel.selectedMedia.count
            }
        })
    }
    
    private func retryLoadDisplayImage(mediaItem: MediaData, completion: @escaping (Bool) -> Void) {
        // Check if the image is already present in the array
        if let index = viewModel.mediaItems.firstIndex(where: { $0.id == mediaItem.id }),
           let displayImage = viewModel.mediaItems[index].displayImage ?? viewModel.mediaItems[index].thumbnailImage ?? viewModel.mediaItems[index].highResImage {
            // Image is already loaded, update the display image and call completion with success
            viewModel.mediaItems[index].displayImage = displayImage
            completion(true)
        } else {
            // Image is not loaded, attempt to re-load it from the device
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                if let index = viewModel.mediaItems.firstIndex(where: { $0.id == mediaItem.id }) {
                    viewModel.loadDisplayImage(for: viewModel.mediaItems[index]) { displayImage in
                        DispatchQueue.main.async {
                            viewModel.mediaItems[index].displayImage = displayImage
                            completion(displayImage != nil)
                        }
                    }
                } else {
                    completion(false)
                }
            }
        }
    }
}


///New
struct PickerResult {
    let itemProvider: NSItemProvider
    let id: UUID
}



extension UIImage {
    func imageWithProperOrientation(orientation: CGImagePropertyOrientation) -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }
        // Convert CGImagePropertyOrientation to UIImage.Orientation
        let uiOrientation = UIImage.Orientation(orientation)
        return UIImage(cgImage: cgImage, scale: 1, orientation: uiOrientation)
    }
}

extension UIImage.Orientation {
    init(_ cgOrientation: CGImagePropertyOrientation) {
        // Map the CGImagePropertyOrientation to UIImage.Orientation
        switch cgOrientation {
            case .up: self = .up
            case .upMirrored: self = .upMirrored
            case .down: self = .down
            case .downMirrored: self = .downMirrored
            case .left: self = .left
            case .leftMirrored: self = .leftMirrored
            case .right: self = .right
            case .rightMirrored: self = .rightMirrored
        }
    }
}
