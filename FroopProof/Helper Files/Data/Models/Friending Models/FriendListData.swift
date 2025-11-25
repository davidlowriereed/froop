import Foundation
import Combine
import FirebaseFirestore
import FirebaseAuth
import SwiftUI
import UIKit

class FriendListData: ObservableObject, Decodable, Identifiable, Hashable {
    @ObservedObject var printControl = PrintControl.shared
    // @ObservedObject var froopDataListener = FroopDataListener.shared
    var db = FirebaseServices.shared.db
    @Published var froopUserID: String = ""
    @Published var timeZone: String = ""
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var phoneNumber: String = ""
    @Published var profileImageUrl: String = ""
    private var listenerService = ListenerStateService.shared
    private var listenerKey: String { return "friendListDataListenerKey_\(froopUserID)" }
    static func == (lhs: FriendListData, rhs: FriendListData) -> Bool {
        return lhs.froopUserID == rhs.froopUserID
    }
    
    var dictionary: [String: Any] {
        return ["froopUserID": froopUserID,
                "timeZone": timeZone,
                "firstName": firstName,
                "lastName": lastName,
                "phoneNumber": phoneNumber,
                "profileImageUrl": profileImageUrl
        ]
    }
    
    init(dictionary: [String: Any], froopUserID: String? = nil) {
        self.froopUserID = dictionary["froopUserID"] as? String ?? froopUserID ?? ""
        self.timeZone = dictionary["timeZone"] as? String ?? ""
        self.firstName = dictionary["firstName"] as? String ?? ""
        self.lastName = dictionary["lastName"] as? String ?? ""
        self.phoneNumber = dictionary["phoneNumber"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
        
        if let froopUserID = froopUserID {
            // Register the listener using ListenerStateService
            if listenerService.shouldCreateListener(forKey: listenerKey) {
                let listener = db.collection("users").document(froopUserID)
                    .addSnapshotListener { documentSnapshot, error in
                        guard let document = documentSnapshot else {
                            PrintControl.shared.printErrorMessages("Error fetching user data: \(error?.localizedDescription ?? "Unknown error")")
                            return
                        }
                        self.timeZone = document["timeZone"] as? String ?? ""
                        self.firstName = document["firstName"] as? String ?? ""
                        self.lastName = document["lastName"] as? String ?? ""
                        self.phoneNumber = document["phoneNumber"] as? String ?? ""
                        self.profileImageUrl = document["profileImageUrl"] as? String ?? ""
                    }
                
                // Store the listener in ListenerStateService
                listenerService.addListener(listener, forKey: listenerKey)
            }
        }
    }
    
    func hash(into hasher: inout Hasher) {
        PrintControl.shared.printInviteFriends("-FriendListData: Function: hash firing")
        hasher.combine(froopUserID)
        hasher.combine(timeZone)
        hasher.combine(firstName)
        hasher.combine(lastName)
        hasher.combine(phoneNumber)
        hasher.combine(profileImageUrl)
    }
    
    enum CodingKeys: String, CodingKey {
        case froopUserID, timeZone, firstName, lastName, phoneNumber, profileImageUrl
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.froopUserID = try container.decode(String.self, forKey: .froopUserID)
        self.timeZone = try container.decode(String.self, forKey: .timeZone)
        self.firstName = try container.decode(String.self, forKey: .firstName)
        self.lastName = try container.decode(String.self, forKey: .lastName)
        self.phoneNumber = try container.decode(String.self, forKey: .phoneNumber)
        self.profileImageUrl = try container.decode(String.self, forKey: .profileImageUrl)
    }
    
    private var cancellable: ListenerRegistration?
    
    init(froopUserID: String) {
        self.froopUserID = froopUserID
        
        // Register the listener using ListenerStateService
        if listenerService.shouldCreateListener(forKey: listenerKey) {
            let listener = db.collection("users").document(froopUserID)
                .addSnapshotListener { documentSnapshot, error in
                    guard let document = documentSnapshot else {
                        PrintControl.shared.printErrorMessages("Error fetching user data: \(error?.localizedDescription ?? "Unknown error")")
                        return
                    }
                    self.timeZone = document["timeZone"] as? String ?? ""
                    self.firstName = document["firstName"] as? String ?? ""
                    self.lastName = document["lastName"] as? String ?? ""
                    self.phoneNumber = document["phoneNumber"] as? String ?? ""
                    self.profileImageUrl = document["profileImageUrl"] as? String ?? ""
                }
            
            // Store the listener in ListenerStateService
            listenerService.addListener(listener, forKey: listenerKey)
        }
    }
    
    deinit {
        // Remove the listener using ListenerStateService
        listenerService.removeListener(forKey: listenerKey)
    }
}

