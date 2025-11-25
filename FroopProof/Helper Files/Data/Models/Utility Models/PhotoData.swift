//
//  photoData.swift
//  FroopProof
//
//  Created by David Reed on 2/5/23.
//

import Combine
import Foundation
import SwiftUI
import MapKit
import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore
 

class PhotoData: ObservableObject, Decodable, Identifiable {
    
    @ObservedObject var printControl = PrintControl.shared
//    // @ObservedObject var froopDataListener = FroopDataListener.shared
    private var listenerService = ListenerStateService.shared
    private let listenerKey = "photoDataListenerKey"

    
    var db = FirebaseServices.shared.db
    @Published var data = [String: Any]()
    let id: String = FirebaseServices.shared.uid
    @Published var uid: String = ""
    @Published var froopId: String = ""
    @Published var url: String = ""
    @Published var photoCoord: GeoPoint = GeoPoint(latitude: 0, longitude: 0)
    @Published var photoLatitude: Double = 0.0
    @Published var photoLongitude: Double = 0.0
    @Published var dateCreated: Date = Date()
    @Published var title: String = ""
    
    var dictionary: [String: Any] {
        return [
            "uid": uid,
            "froopId": froopId,
            "url": url,
            "photoCoord": photoCoord,
            "dateCreated": dateCreated,
            "title": title
        ]
    }
    
    enum CodingKeys: String, CodingKey {
       
        case uid
        case froopId
        case url
        case photoCoord
        case photoLatitude
        case photoLongitude
        case dateCreated
        case title
    }
    
    
    init(dictionary: [String: Any]) {
        self.data = dictionary
        self.uid = dictionary["uid"] as? String ?? ""
        self.froopId = dictionary["froopId"] as? String ?? ""
        self.url = dictionary["url"] as? String ?? ""
        self.photoCoord = dictionary["photoCoord"] as? GeoPoint ?? GeoPoint(latitude: 0, longitude: 0)
        self.photoLatitude = photoCoord.latitude
        self.photoLongitude = photoCoord.longitude
        self.dateCreated = dictionary["dateCreated"] as? Date ?? Date()
        self.title = dictionary["title"] as? String ?? ""
    }

    private var cancellable: ListenerRegistration?

    required init(from decoder:Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
       
        uid = try values.decode(String.self, forKey: .uid)
        froopId = try values.decode(String.self, forKey: .froopId)
        url = try values.decode(String.self, forKey: .url)
        photoLatitude = try values.decode(Double.self, forKey: .photoLatitude)
        photoLongitude = try values.decode(Double.self, forKey: .photoLongitude)
        dateCreated = try values.decode(Date.self, forKey: .dateCreated)
        title = try values.decode(String.self, forKey: .title)
    }


    init() {
            // Register the listener using ListenerStateService
            if listenerService.shouldCreateListener(forKey: listenerKey) {
                let collectionRef = db.collection("photos").document("profiles").collection("profilePhotos")
                let docRef = collectionRef.document(id)

                let listener = docRef.addSnapshotListener { (document, error) in
                    if let document = document, let data = document.data() {
                        self.uid = data["uid"] as? String ?? ""
                        self.froopId = data["froopId"] as? String ?? ""
                        self.url = data["url"] as? String ?? ""
                        self.photoCoord = data["photoCoord"] as? GeoPoint ?? GeoPoint(latitude: 0, longitude: 0)
                        self.photoLatitude = self.photoCoord.latitude
                        self.photoLongitude = self.photoCoord.longitude
                        self.dateCreated = data["dateCreated"] as? Date ?? Date()
                        self.title = data["title"] as? String ?? ""
                    }
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
