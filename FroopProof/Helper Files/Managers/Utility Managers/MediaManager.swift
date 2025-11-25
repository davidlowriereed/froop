//
//  MediaManager.swift
//  FroopProof
//
//  Created by David Reed on 4/19/23.
//

import Foundation
import Combine
import CoreLocation
import SwiftUI
import UIKit
import PhotosUI
import Photos
import MapKit
import AVKit
import AVFoundation
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import Kingfisher

class MediaManager: ObservableObject {
    static let shared = MediaManager()
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var froopManager = FroopManager.shared
    @ObservedObject var appStateManager = AppStateManager.shared
    // @ObservedObject var froopDataListener = FroopDataListener.shared
   
    /// Reference Properties
    @Published var selectedFroopHistory: FroopHistory = FroopManager.defaultFroopHistory()
    @Published var activeFroopHistory: FroopHistory
    @Published var activeFroopId: String = ""
    
    /// Video Properties
    @Published var selectedVideoItem: PhotosPickerItem?
    @Published var videoURL: URL? = nil
    @Published var videoThumbnail: UIImage?
    @Published var videoDuration: TimeInterval?
    @Published var selectedVideoURL: URL?
    @Published var selectedVideoDuration: TimeInterval?
    
    /// Status Properties
    @Published var uploadProgress: CGFloat = 0.0
    @Published var conversionProgress: CGFloat = 0.0
    @Published var isPreparingVideo = false
    @Published var isUploadingVideo = false
    @Published var uploadSuccessful = false
    @Published var uploadFailed = false


    private let imageManager = PHCachingImageManager()

    public init() {
           self.selectedFroopHistory = FroopManager.defaultFroopHistory()

           if AppStateManager.shared.aFHI >= 0 && AppStateManager.shared.aFHI < AppStateManager.shared.currentFilteredFroopHistory.count {
               self.activeFroopHistory = AppStateManager.shared.currentFilteredFroopHistory[safe: AppStateManager.shared.aFHI] ?? FroopManager.defaultFroopHistory()
           } else {
               self.activeFroopHistory = FroopManager.defaultFroopHistory()
           }
       }
    
    /// General
    
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
    
    func uploadSelectedMedia(_ mediaItems: [MediaData], onMediaUploaded: @escaping (MediaData) -> Void, onAllMediaUploaded: @escaping () -> Void) {
        let group = DispatchGroup()

        for mediaItem in mediaItems {
            group.enter()
            if mediaItem.type == .video {
                // Request AVAsset for the video
                PHImageManager.default().requestAVAsset(forVideo: mediaItem.asset, options: nil) { (avAsset, audioMix, info) in
                    DispatchQueue.main.async {
                        if let avAsset = avAsset {
                            // Pass the AVAsset directly to uploadVideo
                            self.uploadVideo(avAsset: avAsset, mediaItem: mediaItem, completion: { success in
                                print("Upload completed: \(success)")
                                onMediaUploaded(mediaItem)
                                group.leave()
                            })
                        } else {
                            print("Could not obtain AVAsset from PHAsset")
                            group.leave()
                        }
                    }
                }
            } else {
                // Image uploading logic
                self.uploadImage(mediaItem: mediaItem, completion: { success in
                    print("Image upload completed: \(success)")
                    onMediaUploaded(mediaItem)
                    group.leave()
                })
            }
        }

        group.notify(queue: .main) {
            onAllMediaUploaded()
        }
    }
    
    func uploadSelectedArchivedMedia(_ mediaItems: [MediaData], onMediaUploaded: @escaping (MediaData) -> Void, onAllMediaUploaded: @escaping () -> Void) {
        let group = DispatchGroup()

        for mediaItem in mediaItems {
            group.enter()
            if mediaItem.type == .video {
                // Request AVAsset for the video
                PHImageManager.default().requestAVAsset(forVideo: mediaItem.asset, options: nil) { (avAsset, audioMix, info) in
                    DispatchQueue.main.async {
                        if let avAsset = avAsset {
                            // Pass the AVAsset directly to uploadVideo
                            self.uploadVideo(avAsset: avAsset, mediaItem: mediaItem, completion: { success in
                                print("Upload completed: \(success)")
                                onMediaUploaded(mediaItem)
                                group.leave()
                            })
                        } else {
                            print("Could not obtain AVAsset from PHAsset")
                            group.leave()
                        }
                    }
                }
            } else {
                // Image uploading logic
                self.uploadArchivedImage(mediaItem: mediaItem, completion: { success in
                    print("Image upload completed: \(success)")
                    onMediaUploaded(mediaItem)
                    group.leave()
                })
            }
        }

        group.notify(queue: .main) {
            onAllMediaUploaded()
        }
    }

    func requestPhotoLibraryAuthorization(completion: @escaping (Bool) -> Void) {
        PrintControl.shared.printMediaManager("-MediaManager: Function: requestPhotoLibraryAuthorization is firing!")
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                completion(status == .authorized)
            }
        }
    }
    
    func fetchMediaFromPhotoLibrary(froopStartTime: Date, froopEndTime: Date, includeVideos: Bool, completion: @escaping ([PHAsset]) -> Void) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "creationDate >= %@ AND creationDate <= %@", froopStartTime as NSDate, froopEndTime as NSDate)
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        // Adjust the fetch options to include videos if required
        if includeVideos {
            fetchOptions.predicate = NSPredicate(format: "(creationDate >= %@ AND creationDate <= %@) AND (mediaType == %d OR mediaType == %d)", froopStartTime as NSDate, froopEndTime as NSDate, PHAssetMediaType.image.rawValue, PHAssetMediaType.video.rawValue)
        }
        
        let fetchResult = PHAsset.fetchAssets(with: fetchOptions)
        var assets: [PHAsset] = []
        fetchResult.enumerateObjects { (asset, _, _) in
            assets.append(asset)
        }
        
        completion(assets)
    }
    
    /// PhotoLibraryView
    
    private func uploadVideo(avAsset: AVAsset, mediaItem: MediaData, completion: @escaping (Bool) -> Void) {
        let exportSession = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPresetHighestQuality)
        exportSession?.outputFileType = .mp4
        let encodedVideoURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).mp4")
        exportSession?.outputURL = encodedVideoURL

        // Start encoding video
        exportSession?.exportAsynchronously {
            DispatchQueue.main.async {
                guard exportSession?.status == .completed else {
                    print("Failed to encode video: \(exportSession?.error?.localizedDescription ?? "unknown error")")
                    completion(false)
                    return
                }

                // Generate thumbnail for the video
                self.generateThumbnail(for: encodedVideoURL) { thumbnailImage in
                    guard let thumbnail = thumbnailImage, let thumbnailData = thumbnail.jpegData(compressionQuality: 0.7) else {
                        print("Failed to generate or encode thumbnail")
                        completion(false)
                        return
                    }

                    // Define paths for video and thumbnail in Firebase Storage
                    let froopId = mediaItem.froopId
                    let froopHost = self.appStateManager.currentFilteredFroopHistory[safe: self.appStateManager.aFHI]?.host.froopUserID
                    let storage = Storage.storage()
                    let storageRef = storage.reference()
                    let videoRef = storageRef.child("FroopMediaAssets/\(String(describing: froopHost))/\(froopId)/videos/\(UUID().uuidString).mp4")
                    let thumbnailRef = storageRef.child("FroopMediaAssets/\(String(describing: froopHost))/\(froopId)/thumbnails/\(UUID().uuidString).jpg")

                    // Upload video and track progress
                    let videoUploadTask = videoRef.putFile(from: encodedVideoURL, metadata: nil)
                    self.trackUploadProgress(uploadTask: videoUploadTask, mediaItem: mediaItem, segmentStart: 0.0, segmentSize: 2.0/3.0)

                    videoUploadTask.observe(.success) { _ in
                        // Upload thumbnail and track progress
                        let thumbnailUploadTask = thumbnailRef.putData(thumbnailData, metadata: nil)
                        self.trackUploadProgress(uploadTask: thumbnailUploadTask, mediaItem: mediaItem, segmentStart: 2.0/3.0, segmentSize: 1.0/3.0)

                        thumbnailUploadTask.observe(.success) { _ in
                            // Update Firestore with video and thumbnail URLs
                            videoRef.downloadURL { (videoURL, error) in
                                guard let videoDownloadURL = videoURL else {
                                    print("Video download URL not found: \(error?.localizedDescription ?? "unknown error")")
                                    completion(false)
                                    return
                                }

                                thumbnailRef.downloadURL { (thumbnailURL, error) in
                                    guard let thumbnailDownloadURL = thumbnailURL else {
                                        print("Thumbnail download URL not found: \(error?.localizedDescription ?? "unknown error")")
                                        completion(false)
                                        return
                                    }

                                    FroopManager.shared.addVideoAndThumbnailURLToDocument(froopHost: froopHost ?? "", froopId: froopId, videoUrl: videoDownloadURL, thumbnailUrl: thumbnailDownloadURL)
                                    completion(true)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private func uploadEncodedVideo(encodedVideoURL: URL, mediaItem: MediaData, completion: @escaping (Bool) -> Void, uploadProgress: @escaping (Double) -> Void) {
        let froopId = activeFroopHistory.froop.froopId
        let froopHost = activeFroopHistory.host.froopUserID
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let videoRef = storageRef.child("FroopMediaAssets/\(froopHost)/\(froopId)/videos/\(mediaItem.assetIdentifier).mp4")
        let metaData = StorageMetadata()
        metaData.contentType = "video/mp4"
        
        // Start the upload task
        let uploadTask = videoRef.putFile(from: encodedVideoURL, metadata: metaData)

        // Observe the upload progress
        uploadTask.observe(.progress) { snapshot in
            let progress = Double(snapshot.progress?.completedUnitCount ?? 0) / Double(snapshot.progress?.totalUnitCount ?? 1)
            uploadProgress(progress)
        }

        // Handle the completion of the upload task
        uploadTask.observe(.success) { snapshot in
            videoRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    print("Video download URL not found: \(error?.localizedDescription ?? "unknown error")")
                    completion(false)
                    return
                }
                
                // Handle the download URL as needed
                print("Video uploaded and available at: \(downloadURL)")
                completion(true)
            }
        }

        uploadTask.observe(.failure) { snapshot in
            if let error = snapshot.error {
                print("Failed to upload video: \(error.localizedDescription)")
                completion(false)
            }
        }
    }
    
    /// DetailsGuestViewModel
    
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
    
    func generateThumbnail(for url: URL, completion: @escaping (UIImage?) -> Void) {
        let asset = AVAsset(url: url)
        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        let scale = UIScreen.main.scale
        // Define a target size for your thumbnail, considering the scale of the device's screen
        let targetSize = CGSize(width: UIScreen.screenWidth, height: UIScreen.screenHeight ) // Example size, adjust as needed
        assetImgGenerate.maximumSize = targetSize

        // Choose a time for the thumbnail that you think best represents the video
        let time = CMTime(seconds: 1.0, preferredTimescale: 600) // Adjust time as needed

        DispatchQueue.global().async {
            do {
                let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
                let thumbnail = UIImage(cgImage: img)
                DispatchQueue.main.async {
                    completion(thumbnail) // Return the high-quality thumbnail
                }
            } catch {
                print("🚫Error generating thumbnail: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(nil) // Handle the error case
                }
            }
        }
    }
    
    func convertVideo(toMPEG4FormatForVideo inputURL: URL, outputURL: URL, viewModel: MediaManager, completionHandler: @escaping (AVAssetExportSession) -> Void) {
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
    
    func uploadTOFireBaseVideo(url: URL, viewModel: MediaManager, success: @escaping (String, String?) -> Void, failure: @escaping (Error) -> Void) {
        let froopId = froopManager.selectedFroopHistory.froop.froopId
        let froopHost = froopManager.selectedFroopHistory.host.froopUserID
        let videoName = "\(UUID().uuidString).mp4"
        let thumbnailName = "\(UUID().uuidString).jpg"
        let videoPath = "FroopMediaAssets/\(froopHost)/\(froopId)/videos/\(videoName)"
        let thumbnailPath = "FroopMediaAssets/\(froopHost)/\(froopId)/thumbnails/\(thumbnailName)"

        // Define the output URL for the converted video
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let outputURL = documentsDirectory.appendingPathComponent(videoName)

        // Convert video to MPEG4 format and upload
        convertVideo(toMPEG4FormatForVideo: url, outputURL: outputURL, viewModel: viewModel) { exportSession in
            guard exportSession.status == .completed, let convertedURL = exportSession.outputURL else {
                failure(exportSession.error ?? NSError(domain: "VideoConversionError", code: 0, userInfo: nil))
                return
            }

            // Upload video
            let videoRef = Storage.storage().reference().child(videoPath)
            videoRef.putFile(from: convertedURL, metadata: nil) { metadata, error in
                if let error = error {
                    failure(error)
                    return
                }

                videoRef.downloadURL { videoURL, error in
                    if let error = error {
                        failure(error)
                        return
                    }

                    guard let videoURL = videoURL else {
                        failure(NSError(domain: "URLGenerationError", code: 0, userInfo: nil))
                        return
                    }

                    // Generate and upload thumbnail
                    self.generateThumbnail(for: url) { thumbnail in
                        guard let thumbnail = thumbnail, let thumbnailData = thumbnail.jpegData(compressionQuality: 0.8) else {
                            success(videoURL.absoluteString, nil) // No thumbnail case
                            return
                        }

                        let thumbnailRef = Storage.storage().reference().child(thumbnailPath)
                        thumbnailRef.putData(thumbnailData, metadata: nil) { metadata, error in
                            if let error = error {
                                failure(error)
                                return
                            }

                            thumbnailRef.downloadURL { thumbnailURL, error in
                                if let error = error {
                                    failure(error)
                                    return
                                }

                                guard let thumbnailURL = thumbnailURL else {
                                    failure(NSError(domain: "URLGenerationError", code: 0, userInfo: nil))
                                    return
                                }

                                // Success case with both video and thumbnail URLs
                                success(videoURL.absoluteString, thumbnailURL.absoluteString)
                                FroopManager.shared.addVideoAndThumbnailURLToDocument(froopHost: froopHost, froopId: froopId, videoUrl: videoURL, thumbnailUrl: thumbnailURL)
                            }
                        }
                    }
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
    
    
    /// Image Uploading
    
    private func uploadImage(mediaItem: MediaData, completion: @escaping (Bool) -> Void) {
        guard let image = mediaItem.highResImage else {
            print("🚫Error: Image is nil")
            completion(false)
            return
        }

        // Prepare image data for fullsize, display, and thumbnail images
        guard let fullsizeImageData = image.jpegData(compressionQuality: 1.0),
              let displayImageData = image.resized(toWidth: 750)?.jpegData(compressionQuality: 0.7),
              let thumbnailImageData = image.resized(toWidth: 200)?.jpegData(compressionQuality: 0.5) else {
            print("🚫Error: Could not convert image to JPEG data")
            completion(false)
            return
        }

        // Define Firebase Storage paths
        let froopId = mediaItem.froopId
        let froopHost = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.host.froopUserID
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let froopMediaAssetsRef = storageRef.child("FroopMediaAssets/\(String(describing: froopHost))/\(froopId)")
        let imageName = UUID().uuidString

        // Define references for fullsize, display, and thumbnail images
        let fullsizeImageRef = froopMediaAssetsRef.child("\(imageName)/fullsize.jpg")
        let displayImageRef = froopMediaAssetsRef.child("\(imageName)/display.jpg")
        let thumbnailImageRef = froopMediaAssetsRef.child("\(imageName)/thumbnail.jpg")

        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"

        // Upload fullsize image and get its download URL
        let fullsizeUploadTask = fullsizeImageRef.putData(fullsizeImageData, metadata: metaData)
        trackUploadProgress(uploadTask: fullsizeUploadTask, mediaItem: mediaItem, segmentStart: 0.0, segmentSize: 1.0/3.0)

        fullsizeUploadTask.observe(.success) { _ in
            fullsizeImageRef.downloadURL { (fullsizeUrl, error) in
                guard let fullsizeUrl = fullsizeUrl else {
                    print("🚫Error getting fullsize image download URL: \(error!.localizedDescription)")
                    completion(false)
                    return
                }

                // Upload display image and get its download URL
                let displayUploadTask = displayImageRef.putData(displayImageData, metadata: metaData) { metadata, error in
                    guard error == nil else {
                        print("🚫Error uploading display image: \(error!.localizedDescription)")
                        return
                    }
                    // Proceed with display image URL retrieval and next upload steps here...
                }
                self.trackUploadProgress(uploadTask: displayUploadTask, mediaItem: mediaItem, segmentStart: 1.0/3.0, segmentSize: 1.0/3.0)

                displayUploadTask.observe(.success) { _ in
                    displayImageRef.downloadURL { (displayUrl, error) in
                        guard let displayUrl = displayUrl else {
                            print("🚫Error getting display image download URL: \(error!.localizedDescription)")
                            completion(false)
                            return
                        }

                        // Upload thumbnail image and get its download URL
                        let thumbnailUploadTask = thumbnailImageRef.putData(thumbnailImageData, metadata: metaData) { metadata, error in
                            guard error == nil else {
                                print("🚫Error uploading thumbnail image: \(error!.localizedDescription)")
                                return
                            }
                            // Proceed with thumbnail image URL retrieval and completion handling here...
                        }
                        self.trackUploadProgress(uploadTask: thumbnailUploadTask, mediaItem: mediaItem, segmentStart: 2.0/3.0, segmentSize: 1.0/3.0)

                        thumbnailUploadTask.observe(.success) { _ in
                            thumbnailImageRef.downloadURL { (thumbnailUrl, error) in
                                guard let thumbnailUrl = thumbnailUrl else {
                                    print("🚫Error getting thumbnail image download URL: \(error!.localizedDescription)")
                                    completion(false)
                                    return
                                }

                                // Now that all images are uploaded and we have their URLs, update the Froop document
                                FroopManager.shared.addMediaURLsToDocument(froopHost: froopHost ?? "", froopId: froopId, fullsizeImageUrl: fullsizeUrl, displayImageUrl: displayUrl, thumbnailImageUrl: thumbnailUrl, isImage: true)
                                completion(true)
                            }
                        }
                    }
                }
            }
        }
    }

    private func uploadArchivedImage(mediaItem: MediaData, completion: @escaping (Bool) -> Void) {
        guard let image = mediaItem.highResImage else {
            print("🚫Error: Image is nil")
            completion(false)
            return
        }

        // Prepare image data for fullsize, display, and thumbnail images
        guard let fullsizeImageData = image.jpegData(compressionQuality: 1.0),
              let displayImageData = image.resized(toWidth: 750)?.jpegData(compressionQuality: 0.7),
              let thumbnailImageData = image.resized(toWidth: 200)?.jpegData(compressionQuality: 0.5) else {
            print("🚫Error: Could not convert image to JPEG data")
            completion(false)
            return
        }

        // Define Firebase Storage paths
        let froopId = mediaItem.froopId
        let froopHost = froopManager.selectedFroopHistory.host.froopUserID
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let froopMediaAssetsRef = storageRef.child("FroopMediaAssets/\(String(describing: froopHost))/\(froopId)")
        let imageName = UUID().uuidString

        // Define references for fullsize, display, and thumbnail images
        let fullsizeImageRef = froopMediaAssetsRef.child("\(imageName)/fullsize.jpg")
        let displayImageRef = froopMediaAssetsRef.child("\(imageName)/display.jpg")
        let thumbnailImageRef = froopMediaAssetsRef.child("\(imageName)/thumbnail.jpg")

        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"

        // Upload fullsize image and get its download URL
        let fullsizeUploadTask = fullsizeImageRef.putData(fullsizeImageData, metadata: metaData)
        trackUploadProgress(uploadTask: fullsizeUploadTask, mediaItem: mediaItem, segmentStart: 0.0, segmentSize: 1.0/3.0)

        fullsizeUploadTask.observe(.success) { _ in
            fullsizeImageRef.downloadURL { (fullsizeUrl, error) in
                guard let fullsizeUrl = fullsizeUrl else {
                    print("🚫Error getting fullsize image download URL: \(error!.localizedDescription)")
                    completion(false)
                    return
                }

                // Upload display image and get its download URL
                let displayUploadTask = displayImageRef.putData(displayImageData, metadata: metaData) { metadata, error in
                    guard error == nil else {
                        print("🚫Error uploading display image: \(error!.localizedDescription)")
                        return
                    }
                    // Proceed with display image URL retrieval and next upload steps here...
                }
                self.trackUploadProgress(uploadTask: displayUploadTask, mediaItem: mediaItem, segmentStart: 1.0/3.0, segmentSize: 1.0/3.0)

                displayUploadTask.observe(.success) { _ in
                    displayImageRef.downloadURL { (displayUrl, error) in
                        guard let displayUrl = displayUrl else {
                            print("🚫Error getting display image download URL: \(error!.localizedDescription)")
                            completion(false)
                            return
                        }

                        // Upload thumbnail image and get its download URL
                        let thumbnailUploadTask = thumbnailImageRef.putData(thumbnailImageData, metadata: metaData) { metadata, error in
                            guard error == nil else {
                                print("🚫Error uploading thumbnail image: \(error!.localizedDescription)")
                                return
                            }
                            // Proceed with thumbnail image URL retrieval and completion handling here...
                        }
                        self.trackUploadProgress(uploadTask: thumbnailUploadTask, mediaItem: mediaItem, segmentStart: 2.0/3.0, segmentSize: 1.0/3.0)

                        thumbnailUploadTask.observe(.success) { _ in
                            thumbnailImageRef.downloadURL { (thumbnailUrl, error) in
                                guard let thumbnailUrl = thumbnailUrl else {
                                    print("🚫Error getting thumbnail image download URL: \(error!.localizedDescription)")
                                    completion(false)
                                    return
                                }

                                // Now that all images are uploaded and we have their URLs, update the Froop document
                                FroopManager.shared.addMediaURLsToDocument(froopHost: froopHost, froopId: froopId, fullsizeImageUrl: fullsizeUrl, displayImageUrl: displayUrl, thumbnailImageUrl: thumbnailUrl, isImage: true)
                                completion(true)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func trackUploadProgress(uploadTask: StorageUploadTask, mediaItem: MediaData, segmentStart: Float, segmentSize: Float) {
        uploadTask.observe(.progress) { snapshot in
            guard let progress = snapshot.progress else { return }
            let segmentProgress = Float(progress.completedUnitCount) / Float(progress.totalUnitCount)
            // Calculate cumulative progress within the segment
            let cumulativeProgress = segmentStart + segmentProgress * segmentSize
            DispatchQueue.main.async {
                mediaItem.uploadProgress = Double(cumulativeProgress)
            }
        }
    }
    
    /// Upload Tracking
    
    func markAssetAsUploaded(assetIdentifier: String) {
        var uploadedAssets = UserDefaults.standard.stringArray(forKey: "uploadedAssets") ?? []
        if !uploadedAssets.contains(assetIdentifier) {
            uploadedAssets.append(assetIdentifier)
            UserDefaults.standard.set(uploadedAssets, forKey: "uploadedAssets")
        }
    }

    func isAssetUploaded(assetIdentifier: String) -> Bool {
        let uploadedAssets = UserDefaults.standard.stringArray(forKey: "uploadedAssets") ?? []
        return uploadedAssets.contains(assetIdentifier)
    }

}


struct MediaUploadProgress {
    var currentStage: String
    var stageProgress: Double // 0.0 to 1.0
    var overallProgress: Double // 0.0 to 1.0
}
