//
//  FriendRequest.swift
//  FroopProof
//
//  Created by David Reed on 2/28/23.
//

import SwiftUI
import MapKit
import Foundation
import FirebaseFirestore
import FirebaseAuth


struct FriendRequest: Identifiable {
    
    
    
    @ObservedObject var printControl = PrintControl.shared
   
    // @ObservedObject var froopDataListener = FroopDataListener.shared
   
 
    
    let id = UUID()
    let fromUserID: String
    let toUserInfo: UserData
    let toUserID: String
    let status: String
    let timestamp: Date
    let documentID: String = ""
    let firstName: String
    let lastName: String
    let profileImageUrl: String
    let phoneNumber: String
    let friendsInCommon: [String] // Array property for profile image URLs

    var dictionary: [String: Any] {
        return [
            "fromUserID": fromUserID,
            "toUserID": toUserInfo.froopUserID,
            "status": status,
            "timestamp": timestamp,
            "documentID": documentID,
            "firstName": firstName,
            "lastName": lastName,
            "profileImageUrl": profileImageUrl,
            "phoneNumber": phoneNumber,
            "friendsInCommon": friendsInCommon // Add profile image URLs to dictionary
        ]
    }
}


