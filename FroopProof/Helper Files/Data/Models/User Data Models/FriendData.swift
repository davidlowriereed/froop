//
//  FriendData.swift
//  FroopProof
//
//  Created by David Reed on 2/12/23.
//

import Foundation
 
import CoreLocation
import Firebase
import Combine
import SwiftUI
import UIKit
import FirebaseFirestore

class FriendData: ObservableObject, Decodable, Identifiable, Hashable {
    
    
    
    @ObservedObject var printControl = PrintControl.shared
   
    // @ObservedObject var froopDataListener = FroopDataListener.shared
   
 
    
    static func == (lhs: FriendData, rhs: FriendData) -> Bool {
        return lhs.id == rhs.id
    }
    var db = FirebaseServices.shared.db
    @Published var froopUserID: String = ""
    @Published var id = UUID()
    @Published var timeZone: String = ""
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var phoneNumber: String = ""
    @Published var profileImageUrl: String = ""
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(froopUserID)
        hasher.combine(id)
        hasher.combine(timeZone)
        hasher.combine(firstName)
        hasher.combine(lastName)
        hasher.combine(phoneNumber)
        hasher.combine(profileImageUrl)
    }
    
    var dictionary: [String: Any] {
        return [
            "froopUserID": froopUserID,
            "id": id,
            "timeZone": timeZone,
            "firstName": firstName,
            "lastName": lastName,
            "phoneNumber": phoneNumber,
            "profileImageUrl": profileImageUrl
        ]
    }
    
    init(dictionary: [String: Any]) {
        self.froopUserID = dictionary["froopUserID"] as? String ?? ""
        self.id = dictionary["id"] as? UUID ?? UUID()
        self.timeZone = dictionary["timeZone"] as? String ?? ""
        self.firstName = dictionary["firstName"] as? String ?? ""
        self.lastName = dictionary["lastName"] as? String ?? ""
        self.phoneNumber = dictionary["phoneNumber"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
    }
    
    enum CodingKeys: String, CodingKey {
        case froopUserID
        case id
        case timeZone
        case firstName
        case lastName
        case phoneNumber
        case profileImageUrl
    }
    
    init(froopUserID: String, timeZone: String, firstName: String, lastName: String, phoneNumber: String, profileImageUrl: String) {
        self.froopUserID = froopUserID
        self.timeZone = timeZone
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phoneNumber
        self.profileImageUrl = profileImageUrl
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        froopUserID = try values.decode(String.self, forKey: .froopUserID)
        timeZone = try values.decode(String.self, forKey: .timeZone)
        firstName = try values.decode(String.self, forKey: .firstName)
        lastName = try values.decode(String.self, forKey: .lastName)
        phoneNumber = try values.decode(String.self, forKey: .phoneNumber)
        profileImageUrl = try values.decode(String.self, forKey: .profileImageUrl)
    }
    
    init(froopUserID: String) {
        self.froopUserID = froopUserID
        
        db.collection("users").document(froopUserID).getDocument { (document, error) in
            if let error = error {
                PrintControl.shared.printErrorMessages("Error fetching friend data: \(error)")
                return
            }
            
            if let document = document, let data = document.data() {
                self.timeZone = data["timeZone"] as? String ?? ""
                self.firstName = data["firstName"] as? String ?? ""
                self.lastName = data["lastName"] as? String ?? ""
                self.phoneNumber = data["phoneNumber"] as? String ?? ""
                self.profileImageUrl = data["profileImageUrl"] as? String ?? ""
            }
        }
    }
}


