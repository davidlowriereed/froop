import Combine
import Foundation
import SwiftUI
import MapKit
import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore
 

class FriendInviteData: ObservableObject, Decodable, Identifiable, Hashable {
    @ObservedObject var printControl = PrintControl.shared
    // @ObservedObject var froopDataListener = FroopDataListener.shared
    private var listenerService = ListenerStateService.shared
    private var listenerKey: String { return "friendInviteDataListenerKey_\(documentID)" }
    
    static func == (lhs: FriendInviteData, rhs: FriendInviteData) -> Bool {
        return lhs.toUserID == rhs.toUserID && lhs.fromUserID == rhs.fromUserID && lhs.documentID == rhs.documentID && lhs.status == rhs.status
    }
    var db = FirebaseServices.shared.db
    @Published var toUserID: String = ""
    @Published var fromUserID: String = ""
    @Published var documentID: String = ""
    @Published var status: String = ""
    
    func hash(into hasher: inout Hasher) {
        PrintControl.shared.printInviteFriends("FriendInviteData: Function: hash is firing!")
        hasher.combine(toUserID)
        hasher.combine(fromUserID)
        hasher.combine(documentID)
        hasher.combine(status)
    }
    
    var dictionary: [String: Any] {
        return [
            "toUserID": toUserID,
            "fromUserID": fromUserID,
            "documentID": documentID,
            "status": status
        ]
    }
    
    enum CodingKeys: String, CodingKey {
        case toUserID
        case fromUserID
        case documentID
        case status
    }
    
    init(dictionary: [String: Any]) {
        self.toUserID = dictionary["toUserID"] as? String ?? ""
        self.fromUserID = dictionary["fromUserID"] as? String ?? ""
        self.documentID = dictionary["documentID"] as? String ?? ""
        self.status = dictionary["status"] as? String ?? ""
    }
    
    required init(from decoder:Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        toUserID = try values.decode(String.self, forKey: .toUserID)
        fromUserID = try values.decode(String.self, forKey: .fromUserID)
        documentID = try values.decode(String.self, forKey: .documentID)
        status = try values.decode(String.self, forKey: .status)
    }
    
    private var cancellable: ListenerRegistration?
    
    init(documentId: String) {
        let docRef = db.collection("friendRequests").document(documentId)
        
        self.toUserID = ""
        self.fromUserID = ""
        self.documentID = ""
        self.status = ""
        
        // Check and register the listener using ListenerStateService
        if listenerService.shouldCreateListener(forKey: listenerKey) {
            let listener = docRef.addSnapshotListener { (document, error) in
                if let error = error {
                    PrintControl.shared.printErrorMessages("Error fetching friend request data: \(error)")
                    return
                }
                if let document = document, let data = document.data() {
                    self.toUserID = data["toUserID"] as? String ?? ""
                    self.fromUserID = data["fromUserID"] as? String ?? ""
                    self.documentID = data["documentID"] as? String ?? ""
                    self.status = data["status"] as? String ?? ""
                }
            }
            
            // Store the listener in ListenerStateService
            listenerService.addListener(listener, forKey: listenerKey)
        }
    }
    
    deinit {
        listenerService.removeListener(forKey: listenerKey)
    }

}
