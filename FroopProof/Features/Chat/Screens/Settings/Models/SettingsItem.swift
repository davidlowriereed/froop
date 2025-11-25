//
//  SettingsItem.swift
//  FroopChatApp
//
//  Created by David Reed on 6/12/24.
//

import Foundation
import SwiftUI

struct SettingsItem {
    let imageName: String
    var imageType: ImageType = .systemImage
    let backgroundColor: Color
    let title: String
    
    enum ImageType {
        case systemImage, assetImage
    }
}




//MARK: Settings Data
extension SettingsItem {
    static let avatar = SettingsItem(
        imageName: "photo",
        imageType: .systemImage,
        backgroundColor: .blue,
        title: "Change Profile Photo"
    )
    
    static let broadCastLists = SettingsItem(
        imageName: "megaphone.fill",
        imageType: .systemImage,
        backgroundColor: .green,
        title: "Broadcast Lists"
    )
    
    static let starredMessages = SettingsItem(
        imageName: "star.fill",
        imageType: .systemImage,
        backgroundColor: .yellow,
        title: "Starred Messages"
    )
    
    static let linkedDevices = SettingsItem(
        imageName: "laptopcomputer",
        imageType: .systemImage,
        backgroundColor: .green,
        title: "Linked Devices"
    )
    
    static let account = SettingsItem(
        imageName: "key.fill",
        imageType: .systemImage,
        backgroundColor: .blue,
        title: "Account"
    )
    
    static let privacy = SettingsItem(
        imageName: "lock.fill",
        imageType: .systemImage,
        backgroundColor: .cyan,
        title: "Privacy"
    )
    
    static let chats = SettingsItem(
        imageName: "message.fill",
        imageType: .systemImage,
        backgroundColor: .green,
        title: "Chats"
    )
    
    static let notifications = SettingsItem(
        imageName: "bell.badge.fill",
        imageType: .systemImage,
        backgroundColor: .red,
        title: "Notifications"
    )
    
    static let storage = SettingsItem(
        imageName: "arrow.up.arrow.down",
        imageType: .systemImage,
        backgroundColor: .green,
        title: "Storage and Data"
    )
    
    static let help = SettingsItem(
        imageName: "info",
        imageType: .systemImage,
        backgroundColor: .blue,
        title: "Help"
    )
    
    static let tellFriend = SettingsItem(
        imageName: "heart.fill",
        imageType: .systemImage,
        backgroundColor: .red,
        title: "Tell a Friend"
    )
}


//MARK: Contact Info Data
extension SettingsItem {
    static let media = SettingsItem(
        imageName: "photo",
        imageType: .systemImage,
        backgroundColor: .blue,
        title: "Media, Links and Docs"
    )
    
    static let mute = SettingsItem(
        imageName: "speaker.wave.2.fill",
        imageType: .systemImage,
        backgroundColor: .green,
        title: "Mute"
    )
    
    static let wallpaper = SettingsItem(
        imageName: "circles.hexagongrid",
        imageType: .systemImage,
        backgroundColor: .mint,
        title: "Wallpaper and Sound"
    )
    
    static let saveToCameraRoll = SettingsItem(
        imageName: "square.and.arrow.down",
        imageType: .systemImage,
        backgroundColor: .yellow,
        title: "Save to Camera Roll"
    )
    
    static let encryption = SettingsItem(
        imageName: "lock.fill",
        imageType: .systemImage,
        backgroundColor: .blue,
        title: "Encryption"
    )
    
    static let disappearingMessages = SettingsItem(
        imageName: "timer",
        imageType: .systemImage,
        backgroundColor: .blue,
        title: "Disappearing Messages"
    )
    
    static let lockChat = SettingsItem(
        imageName: "lock.fill",
        imageType: .systemImage,
        backgroundColor: .blue,
        title: "Lock Chat"
    )
    
    static let contentDetails = SettingsItem(
        imageName: "person.circle",
        imageType: .systemImage,
        backgroundColor: .gray,
        title: "Contact Details"
    )
    
    
}
