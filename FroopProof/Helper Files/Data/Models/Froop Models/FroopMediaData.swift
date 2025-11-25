//
//  FroopMediaData.swift
//  FroopProof
//
//  Created by David Reed on 2/10/24.
//

import Foundation


struct FroopMediaData {
    var froopImages: [String] // High-resolution images
    var froopDisplayImages: [String] // Medium resolution images
    var froopThumbnailImages: [String] // Low resolution images
    var froopIntroVideo: String // Greeting video URL
    var froopIntroVideoThumbnail: String // Greeting video thumbnail URL
    var froopVideos: [String] // Uploaded videos
    var froopVideoThumbnails: [String] // Thumbnails for uploaded videos
}
