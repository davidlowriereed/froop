//
//  InviteData.swift
//  FroopProof
//
//  Created by David Reed on 3/3/24.
//

import Combine
import Foundation
import SwiftUI
import MapKit
import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore
 

class InviteData: ObservableObject, Decodable, Identifiable {
    var db = FirebaseServices.shared.db
    @Published var data = [String: Any]()
    @Published var inviteUid: String = ""
    @Published var froopId: String = ""
    @Published var hostId: String = ""
    @Published var url: String = ""
    @Published var openCount: Int = 0
    @Published var dateCreated: Date = Date()
    @Published var dateExpires: Date = Date()
    @Published var respondingUsers: [String] = []
    
    
    var dictionary: [String: Any] {
        return [
            "inviteUid": inviteUid,
            "froopId": froopId,
            "hostId": hostId,
            "url": url,
            "openCount": openCount,
            "dateCreated": dateCreated,
            "dateExpires": dateExpires,
            "respondingUsers": respondingUsers
        ]
    }
    
    enum CodingKeys: String, CodingKey {
       
        case inviteUid
        case froopId
        case hostId
        case url
        case openCount
        case dateCreated
        case dateExpires
        case respondingUsers
    }
    
    init(dictionary: [String: Any]) {
        self.data = dictionary
        self.inviteUid = dictionary["inviteUid"] as? String ?? ""
        self.froopId = dictionary["froopId"] as? String ?? ""
        self.hostId = dictionary["hostId"] as? String ?? ""
        self.url = dictionary["url"] as? String ?? ""
        self.openCount = dictionary["openCount"] as? Int ?? 0
        self.dateCreated = dictionary["dateCreated"] as? Date ?? Date()
        self.dateExpires = dictionary["dateExpires"] as? Date ?? Date()
        self.respondingUsers = dictionary["respondingUsers"] as? [String] ?? []
    }

    required init(from decoder:Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
       
        inviteUid = try values.decode(String.self, forKey: .inviteUid)
        froopId = try values.decode(String.self, forKey: .froopId)
        hostId = try values.decode(String.self, forKey: .hostId)
        url = try values.decode(String.self, forKey: .url)
        openCount = try values.decode(Int.self, forKey: .openCount)
        dateCreated = try values.decode(Date.self, forKey: .dateCreated)
        dateExpires = try values.decode(Date.self, forKey: .dateExpires)
        respondingUsers = try values.decode([String].self, forKey: .respondingUsers)
    }
}
