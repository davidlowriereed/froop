//
//  ArchivedLibraryView.swift
//  FroopProof
//
//  Created by David Reed on 5/5/23.
//

import UIKit
import SwiftUI
import Photos
import PhotosUI
import FirebaseStorage
import Firebase
import FirebaseAuth
import FirebaseFirestore
import NavigationStack
import CommonCrypto

struct ArchivedLibraryView: View {

    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var mediaManager = MediaManager.shared
    @ObservedObject var viewModel = MediaGridViewModel.shared
    
    // @ObservedObject var froopDataListener = FroopDataListener.shared
    @ObservedObject var froopManager = FroopManager.shared
    var isPassiveMode: Bool {
        return FroopManager.shared.selectedFroopHistory.froop.froopId == ""
    }
    @State var uniqueID = UUID()
    @State private var uploading = false
    
    let froopStartTime = FroopManager.shared.selectedFroopHistory.froop.froopStartTime.addingTimeInterval(-30 * 60)
    let froopEndTime = FroopManager.shared.selectedFroopHistory.froop.froopEndTime.addingTimeInterval(30 * 60)
    let validData = Data()
    let validString = ""
    
    var body: some View {
        
        ZStack {
            
            VStack {
                if !isPassiveMode {
                    ArchivedMediaGridView(
                        onAddToFroop: {
                            image,
                            creationDate,
                            assetIdentifier,
                            completion in
                            onAddToFroop(
                                image: image,
                                creationDate: creationDate,
                                assetIdentifier: assetIdentifier,
                                completion: completion
                            )
                        },
                        uploadSelectedArchivedMedia: mediaManager.uploadSelectedArchivedMedia,
                        uniqueID: $uniqueID
                    )
                    
                }
            }
            
            if uploading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 255/255, green: 49/255, blue: 97/255)))
                    .scaleEffect(2)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(red: 255/255, green: 49/255, blue: 97/255).opacity(1))
                    .edgesIgnoringSafeArea(.all)
            }
            
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .onAppear {
            viewModel.loadArchivedMedia(from: froopStartTime , to: froopEndTime , validData: validData, validString: validString)
        }
    }
    
    
    func onAddToFroop(image: UIImage, creationDate: Date, assetIdentifier: String, completion: @escaping (Bool) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            print("🚫Error: Could not convert image to JPEG data")
            completion(false)
            return
        }
        
        let froopId = FroopManager.shared.selectedFroopHistory.froop.froopId
        let froopHost = FroopManager.shared.selectedFroopHistory.host.froopUserID
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let froopMediaAssetsRef = storageRef.child("FroopMediaAssets/\(froopHost)/\(froopId)")
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
                
                AppStateManager.shared.mediaTimeStamp.append(creationDate)
                completion(true)
            }
        }
    }

    
    func uploadSelectedImages(_ images: [MediaData]) {
        uploading = true
        DispatchQueue.global(qos: .background).async {
            for imageItem in images {
                if let image = imageItem.highResImage {
                    // Assuming you have access to the assetIdentifier for each imageItem here
                    let assetIdentifier = imageItem.asset.localIdentifier
                    onAddToFroop(image: image, creationDate: Date(), assetIdentifier: assetIdentifier) { uploadSuccessful in
                        DispatchQueue.main.async {
                            if uploadSuccessful {
                                // Handle the success case, perhaps by updating some state or UI
                            } else {
                                // Handle the failure case
                            }
                        }
                    }
                }
            }
            DispatchQueue.main.async {
                uploading = false
            }
        }
    }

    
    func uploadSelectedImages2(_ images: [MediaData], onImageUploaded: @escaping (MediaData) -> Void, onAllImagesUploaded: @escaping () -> Void) {
        let group = DispatchGroup()
        var imageUrls: [URL] = []
        
        for selectedImage in images {
            guard let image = selectedImage.highResImage else { continue }
            group.enter()
            
            guard let fullsizeImageData = image.jpegData(compressionQuality: 1.0),
                  let displayImageData = image.resized(toWidth: 750)?.jpegData(compressionQuality: 0.7),
                  let thumbnailImageData = image.resized(toWidth: 200)?.jpegData(compressionQuality: 0.5) else {
                print("🚫Error: Could not convert image to JPEG data")
                group.leave()
                continue
            }
            
            let froopId = froopManager.selectedFroopHistory.froop.froopId
            let froopHost = froopManager.selectedFroopHistory.host.froopUserID
            
            let storage = Storage.storage()
            let storageRef = storage.reference()
            let froopMediaAssetsRef = storageRef.child("FroopMediaAssets/\(froopHost)/\(froopId)")
            let imageName = UUID().uuidString
            
            let imageDirectoryRef = froopMediaAssetsRef.child(imageName)
            
            let fullsizeImageRef = imageDirectoryRef.child("fullsize.jpg")
            let displayImageRef = imageDirectoryRef.child("display.jpg")
            let thumbnailImageRef = imageDirectoryRef.child("thumbnail.jpg")
            
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpeg"
            
            let uploadTasks = [
                fullsizeImageRef.putData(fullsizeImageData, metadata: metaData),
                displayImageRef.putData(displayImageData, metadata: metaData),
                thumbnailImageRef.putData(thumbnailImageData, metadata: metaData)
            ]
            
            let dispatchGroup = DispatchGroup()
            
            var fullsizeImageUrl: URL?
            var displayImageUrl: URL?
            var thumbnailImageUrl: URL?
            
            for (index, uploadTask) in uploadTasks.enumerated() {
                dispatchGroup.enter()
                uploadTask.observe(.success) { snapshot in
                    snapshot.reference.downloadURL { url, error in
                        if let url = url {
                            switch index {
                                case 0:
                                    fullsizeImageUrl = url
                                case 1:
                                    displayImageUrl = url
                                case 2:
                                    thumbnailImageUrl = url
                                default:
                                    break
                            }
                        }
                        dispatchGroup.leave()
                    }
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                guard let fullsizeImageUrl = fullsizeImageUrl,
                      let displayImageUrl = displayImageUrl,
                      let thumbnailImageUrl = thumbnailImageUrl else {
                    print("🚫Error: Failed to get the download URLs")
                    group.leave()
                    return
                }
                
                froopManager.addMediaURLsToDocument(
                    froopHost: froopHost,
                    froopId: froopId,
                    fullsizeImageUrl: fullsizeImageUrl,
                    displayImageUrl: displayImageUrl,
                    thumbnailImageUrl: thumbnailImageUrl,
                    isImage: true
                )
                
                imageUrls.append(fullsizeImageUrl)
                onImageUploaded(selectedImage)
                group.notify(queue: .main) {
                    print("All images uploaded, urls: \(imageUrls)")
                    // Call the onAllImagesUploaded closure
                    onAllImagesUploaded()
                }
            }
        }
        
        group.notify(queue: .main) {
            print("All images uploaded, urls: \(imageUrls)")
            // Do any additional processing with the image URLs here
        }
    }
}
