//
//  MediaData.swift
//  FroopProof
//
//  Created by David Reed on 4/19/23.
//

import Foundation
import CoreLocation
import SwiftUI
import MapKit
import Photos


class MediaData: ObservableObject, Identifiable, Hashable {
    @Published var uploadProgress: Double = 0.0
    @Published var conversionProgress: Double = 0.0
    
    let id: UUID
    let owner: String
    let hostId: String
    let froopId: String
    let type: MediaType
    let asset: PHAsset
//    @Published var highResImage: UIImage? = nil
//    @Published var displayImage: UIImage?
    @Published var show: Bool
    @Published var isSelected: Bool = false
    @Published var assetIdentifier: String
    let imageData: Data
    let hash: String
    @Published var isLoadingHighResImage: Bool = false
    @Published var videoURL: URL?  // Optional URL for the video file
//    @Published var thumbnailImage: UIImage?  // Optional thumbnail image for videos

    private var _highResImage: UIImage? = nil
    var highResImage: UIImage? {
        get { _highResImage }
        set {
            DispatchQueue.main.async {
                self.objectWillChange.send()
                self._highResImage = newValue
            }
        }
    }
    
    private var _displayImage: UIImage? = nil
    var displayImage: UIImage? {
        get { _displayImage }
        set {
            DispatchQueue.main.async {
                self.objectWillChange.send()
                self._displayImage = newValue
            }
        }
    }
    
    private var _thumbnailImage: UIImage? = nil
    var thumbnailImage: UIImage? {
        get { _thumbnailImage }
        set {
            DispatchQueue.main.async {
                self.objectWillChange.send()
                self._thumbnailImage = newValue
            }
        }
    }
    
    static func == (lhs: MediaData, rhs: MediaData) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    init(asset: PHAsset, froopId: String, hostId: String, type: MediaType, highResImage: UIImage? = nil, displayImage: UIImage? = nil, imageData: Data, hash: String, show: Bool, isSelected: Bool = false, videoURL: URL? = nil, thumbnailImage: UIImage? = nil) {
        self.id = UUID()
        self.owner = FirebaseServices.shared.uid
        self.froopId = froopId
        self.hostId = hostId
        self.type = type
        self.asset = asset
        // Initialize all other stored properties before setting images
        self.imageData = imageData
        self.hash = hash
        self.show = show
        self.isSelected = isSelected
        self.assetIdentifier = asset.localIdentifier
        self.isLoadingHighResImage = false
        self.videoURL = videoURL
        // Now set the images
        self._highResImage = highResImage
        self._displayImage = displayImage
        self._thumbnailImage = thumbnailImage
    }


    // New initializer to create MediaData from a dictionary
    init?(dictionary: [String: Any]) {
        guard let asset = dictionary["asset"] as? PHAsset,
              let froopId = dictionary["froopId"] as? String,
              let hostId = dictionary["hostId"] as? String,
              let typeRawValue = dictionary["type"] as? String,
              let type = MediaType(rawValue: typeRawValue),
              let imageData = dictionary["imageData"] as? Data,
              let hash = dictionary["hash"] as? String,
              let show = dictionary["show"] as? Bool
        else {
            return nil
        }

        self.id = UUID()
        self.owner = FirebaseServices.shared.uid
        self.froopId = froopId
        self.hostId = hostId
        self.type = type
        self.asset = asset
        // Initialize all other stored properties before setting images
        self.imageData = imageData
        self.hash = hash
        self.show = show
        self.isSelected = dictionary["isSelected"] as? Bool ?? false
        self.assetIdentifier = asset.localIdentifier
        self.isLoadingHighResImage = false
        self.videoURL = dictionary["videoURL"] as? URL
        // Now set the images
        self._highResImage = dictionary["highResImage"] as? UIImage
        self._displayImage = dictionary["displayImage"] as? UIImage
        self._thumbnailImage = dictionary["thumbnailImage"] as? UIImage
    }

    enum ImageShape {
        case square
        case rectangleTwoToOne
        case rectangleOneToTwo
        case unknown
    }

    var shape: ImageShape {
        guard let displayImage = displayImage else {
            return .unknown
        }

        let aspectRatio = displayImage.size.width / displayImage.size.height

        if abs(aspectRatio - 1) < 0.1 {
            return .square
        } else if abs(aspectRatio - 2) < 0.1 {
            return .rectangleTwoToOne
        } else {
            return .rectangleOneToTwo
        }
    }
}


