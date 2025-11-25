//
//  FroopData.swift
//  FroopProof
//
//  Created by David Reed on 1/19/23.
//

import SwiftUI
import Firebase
import MapKit
import UIKit
import FirebaseFirestore
import CoreLocation
import Foundation

class Froop: NSObject, ObservableObject, Decodable {
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var froopDataController = FroopDataController.shared
    var db = FirebaseServices.shared.db
    let uid = FirebaseServices.shared.uid
    @Published var timeZoneManager = TimeZoneManager()
    @Published var data = [String: Any]()
    let id: UUID = UUID()
    @Published var froopId: String = ""
    @Published var froopName: String = ""
    @Published var froopType: Int = 0
    @Published var froopLocationid = 0
    @Published var froopLocationTimeZone = ""
    @Published var froopLocationtitle = ""
    @Published var froopLocationsubtitle = ""
    @Published var froopLocationlatitude: Double = 0.0
    @Published var froopLocationlongitude: Double = 0.0
    @Published var froopLocationCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
    var geoPoint: GeoPoint {
        get {
            return GeoPoint(latitude: froopLocationCoordinate.latitude, longitude: froopLocationCoordinate.longitude)
        }
        set {
            let newCoordinate = CLLocationCoordinate2D(latitude: newValue.latitude, longitude: newValue.longitude)
            if newCoordinate.latitude != froopLocationCoordinate.latitude || newCoordinate.longitude != froopLocationCoordinate.longitude {
                self.froopLocationCoordinate = newCoordinate
            }
        }
    }
    @Published var froopDate: Date = Date()
    @Published var froopStartTime: Date = Date()
    @Published var froopCreationTime: Date = Date()
    @Published var froopDuration: Int = 0
    @Published var froopInvitedFriends: [String] = []
    @Published var froopEndTime: Date = Date()
    @Published var froopImages: [String] = []
    @Published var froopDisplayImages: [String] = []
    @Published var froopThumbnailImages: [String] = []
    @Published var froopVideos: [String] = []
    @Published var froopVideoThumbnails: [String] = []
    @Published var froopIntroVideo: String = ""
    @Published var froopIntroVideoThumbnail: String = ""
    @Published var froopHost: String = ""
    @Published var froopHostPic: String = ""
    @Published var froopTimeZone: String = ""
    @Published var froopMessage: String = ""
    @Published var froopList: [String] = []
    @Published var template: Bool = false
    @Published var hidden: [String] = []
    @Published var inviteUrl: String = ""
    @Published var videoSubscribed: Bool = false
    @Published var guestApproveList: [String] = []
    @Published var flightData: ScheduledFlightAPI.FlightDetail?

    var nowIsAfterStartTime: Bool {
        return Date() > froopStartTime
    }

    var nowIsAfterEndTime: Bool {
        return Date() > froopEndTime
    }

    var nowIsBetweenStartAndEndTime: Bool {
        return Date() >= froopStartTime && Date() <= froopEndTime
    }

    var timeUntilFroopStart: TimeInterval {
        return froopStartTime.timeIntervalSinceNow
    }

    var timeUntilFroopEnd: TimeInterval {
        return froopEndTime.timeIntervalSinceNow
    }

    var listener: ListenerRegistration?

    required init(from decoder: Decoder) throws {
        super.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)
        froopId = try values.decode(String.self, forKey: .froopId)
        froopName = try values.decode(String.self, forKey: .froopName)
        froopType = try values.decode(Int.self, forKey: .froopType)
        froopLocationid = try values.decode(Int.self, forKey: .froopLocationid)
        froopLocationTimeZone = try values.decode(String.self, forKey: .froopLocationTimeZone)
        froopLocationtitle = try values.decode(String.self, forKey: .froopLocationtitle)
        froopLocationsubtitle = try values.decode(String.self, forKey: .froopLocationsubtitle)
        froopLocationlatitude = try values.decode(Double.self, forKey: .froopLocationlatitude)
        froopLocationlongitude = try values.decode(Double.self, forKey: .froopLocationlongitude)
        froopDate = try values.decode(Date.self, forKey: .froopDate)
        froopStartTime = try values.decode(Date.self, forKey: .froopStartTime)
        froopCreationTime = try values.decode(Date.self, forKey: .froopCreationTime)
        froopDuration = try values.decode(Int.self, forKey: .froopDuration)
        froopInvitedFriends = try values.decode([String].self, forKey: .froopInvitedFriends)
        froopEndTime = try values.decode(Date.self, forKey: .froopEndTime)
        froopImages = try values.decode([String].self, forKey: .froopImages)
        froopDisplayImages = try values.decode([String].self, forKey: .froopDisplayImages)
        froopThumbnailImages = try values.decode([String].self, forKey: .froopThumbnailImages)
        froopVideos = try values.decode([String].self, forKey: .froopVideos)
        froopVideoThumbnails = try values.decode([String].self, forKey: .froopVideoThumbnails)
        froopIntroVideo = try values.decode(String.self, forKey: .froopIntroVideo)
        froopIntroVideoThumbnail = try values.decode(String.self, forKey: .froopIntroVideoThumbnail)
        froopHost = try values.decode(String.self, forKey: .froopHost)
        froopHostPic = try values.decode(String.self, forKey: .froopHostPic)
        froopTimeZone = try values.decode(String.self, forKey: .froopTimeZone)
        froopMessage = try values.decode(String.self, forKey: .froopMessage)
        froopList = try values.decode([String].self, forKey: .froopList)
        template = try values.decode(Bool.self, forKey: .template)
        hidden = try values.decode([String].self, forKey: .hidden)
        inviteUrl = try values.decode(String.self, forKey: .inviteUrl)
        videoSubscribed = try values.decode(Bool.self, forKey: .videoSubscribed)
        guestApproveList = try values.decode([String].self, forKey: .guestApproveList)
        setupListener()
    }

    enum CodingKeys: String, CodingKey {
        case froopId
        case froopName
        case froopType
        case froopLocationid
        case froopLocationtitle
        case froopLocationsubtitle
        case froopLocationlatitude
        case froopLocationlongitude
        case froopLocationTimeZone
        case froopDate
        case froopStartTime
        case froopCreationTime
        case froopDuration
        case froopInvitedFriends
        case froopEndTime
        case froopImages
        case froopDisplayImages
        case froopThumbnailImages
        case froopVideos
        case froopVideoThumbnails
        case froopIntroVideo
        case froopIntroVideoThumbnail
        case froopHost
        case froopHostPic
        case froopTimeZone
        case froopMessage
        case froopList
        case template
        case hidden
        case inviteUrl
        case videoSubscribed
        case guestApproveList
    }

    override init() {
        super.init()
        setupListener()
    }

    private func setupListener() {
        if !uid.isEmpty && !froopId.isEmpty {
            let listenerKey = "froop_\(froopId)"
            
            if ListenerStateService.shared.shouldCreateListener(forKey: listenerKey) {
                listener = FirebaseServices.shared.listenToFroopData(uid: uid, froopId: froopId) { [weak self] data in
                    DispatchQueue.main.async {
                        self?.updateProperties(with: data)
                    }
                }
                
                if let listener = listener {
                    ListenerStateService.shared.registerListener(listener, forKey: listenerKey)
                }
            }
        }
    }

    var dictionary: [String: Any] {
        let geoPoint = convertToGeoPoint(coordinate: froopLocationCoordinate)
        return [
            "froopId": self.froopId,
            "froopName": froopName,
            "froopType": froopType,
            "froopLocationid": froopLocationid,
            "froopLocationtitle": froopLocationtitle,
            "froopLocationsubtitle": froopLocationsubtitle,
            "froopLocationCoordinate": geoPoint,
            "froopDate": convertLocalDateToUTC(date: froopDate, froopTimeZone: timeZoneManager.froopTimeZone ?? TimeZone.current),
            "froopStartTime": froopStartTime,
            "froopCreationTime": froopCreationTime,
            "froopDuration": froopDuration,
            "froopInvitedFriends": froopInvitedFriends,
            "froopEndTime": froopEndTime,
            "froopImages": froopImages,
            "froopDisplayImages": froopDisplayImages,
            "froopThumbnailImages": froopThumbnailImages,
            "froopVideos": froopVideos,
            "froopVideoThumbnails": froopVideoThumbnails,
            "froopIntroVideo": froopIntroVideo,
            "froopIntroVideoThumbnail": froopIntroVideoThumbnail,
            "froopHost": froopHost,
            "froopHostPic": froopHostPic,
            "froopTimeZone": froopTimeZone,
            "froopMessage": froopMessage,
            "froopList": froopList,
            "template": template,
            "hidden": hidden,
            "inviteUrl": inviteUrl,
            "videoSubscribed": videoSubscribed,
            "guestApproveList": guestApproveList
        ]
    }

    init?(dictionary: [String: Any]) {
        PrintControl.shared.printFroopData("Attempting to create Froop object from dictionary: \(dictionary)")
        super.init()
        updateProperties(with: dictionary)
        PrintControl.shared.printFroopData("Froop object created successfully")
    }

    deinit {
        listener?.remove()
    }

    private var cancellable: ListenerRegistration?
    private var _coordinate = CLLocationCoordinate2D()
    var mkLocalSearchCompletion: MKLocalSearchCompletion?

    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: froopLocationlatitude, longitude: froopLocationlongitude)
    }
    var coordinateString: String {
        return "\(coordinate.latitude), \(coordinate.longitude)"
    }

    func updateLocation(title: String, subtitle: String, latitude: Double, longitude: Double) {
        PrintControl.shared.printFroopData("-FroopData: Function: updateLocation is firing!")
        self.froopLocationtitle = title
        self.froopLocationsubtitle = subtitle
        self.froopLocationlatitude = latitude
        self.froopLocationlongitude = longitude
    }

    func saveData() async throws -> String {
        PrintControl.shared.printFroopData("-FroopData: Function: saveData firing")
        let dateFormatter = DateFormatter()
        let newFroopId = UUID().uuidString
        self.froopId = newFroopId
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        if froopType != 5009 {
            dateFormatter.timeZone = TimeZone(identifier: "America/Los_Angeles")
            if let froopTimeZone = timeZoneManager.froopTimeZone {
                froopStartTime = convertLocalDateToUTC(date: froopStartTime, froopTimeZone: froopTimeZone)
            }
        }
        
        self.froopList = [""]
        self.froopMessage = "The Host has not added a message yet, stay tuned!"
        let uid = FirebaseServices.shared.uid
        
        // Save Froop data to Firestore
        let myFroopDocRef = db.collection("users").document(uid).collection("myFroops").document(froopId)
        try await myFroopDocRef.setData(self.dictionary)
        
        
        // Add Host to Froop inviteList Array
        let froopConfirmedListDocumentRef = db.collection("users").document(uid).collection("myFroops").document(froopId).collection("invitedFriends").document("confirmedList")
        
        // Use arrayUnion to add the uid to an array field without duplicates
        try await froopConfirmedListDocumentRef.setData(["uid": FieldValue.arrayUnion([uid])])
        
        // Add the Froop ID to the host's confirmed list
        let froopConfirmedListCollectionRef = db.collection("users").document(uid).collection("froopDecisions").document("froopLists").collection("myConfirmedList")
        froopConfirmedListCollectionRef.addDocument(data: [
            "froopHost": uid,
            "froopId": froopId
        ]) { err in
            if let err = err {
                PrintControl.shared.printErrorMessages("Error adding froopId to confirmedList: \(err)")
            } else {
                PrintControl.shared.printFroopData("FroopId added to myConfirmedList")
            }
        }
        
        // Update Froop ID listener
        self.updateFroopIdAndStartListener(newFroopId: froopId)
        
        
        if let flightDetail = flightData {
            let flightDetailDict = flightDetail.toDictionary()
            // Assuming you have a subcollection for flight details
            let flightDetailRef = myFroopDocRef.collection("flightDetails").document()
            try await flightDetailRef.setData(flightDetailDict)
            print("Flight details saved successfully.")
        }
        
        return newFroopId
    }

    func convertLocalDateToUTC(date: Date, froopTimeZone: TimeZone) -> Date {
        PrintControl.shared.printFroopData("-FroopData: Function: convertLocalDateToUTC in FroopData firing")
        let timezoneOffset = froopTimeZone.secondsFromGMT()
        return date.addingTimeInterval(TimeInterval(-timezoneOffset))
    }

    private func updateProperties(with data: [String: Any]) {
        PrintControl.shared.printFroopData("-FroopData: Function: updateProperties is firing!")
        self.data = data
        self.froopId = data["froopId"] as? String ?? ""
        self.froopName = data["froopName"] as? String ?? ""
        self.froopType = data["froopType"] as? Int ?? 0
        self.froopLocationid = data["froopLocationid"] as? Int ?? 0
        self.froopLocationTimeZone = data["froopLocationTimeZone"] as? String ?? ""
        self.froopLocationtitle = data["froopLocationtitle"] as? String ?? ""
        self.froopLocationsubtitle = data["froopLocationsubtitle"] as? String ?? ""
        if let geoPoint = data["froopLocationCoordinate"] as? GeoPoint {
            self.froopLocationCoordinate = CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
        }
        self.froopDate = (data["froopDate"] as? Timestamp)?.dateValue() ?? Date()
        self.froopStartTime = (data["froopStartTime"] as? Timestamp)?.dateValue() ?? Date()
        self.froopCreationTime = (data["froopCreationTime"] as? Timestamp)?.dateValue() ?? Date()
        self.froopDuration = data["froopDuration"] as? Int ?? 0
        self.froopInvitedFriends = data["froopInvitedFriends"] as? [String] ?? []
        self.froopEndTime = (data["froopEndTime"] as? Timestamp)?.dateValue() ?? Date()
        self.froopImages = data["froopImages"] as? [String] ?? []
        self.froopDisplayImages = data["froopDisplayImages"] as? [String] ?? []
        self.froopThumbnailImages = data["froopThumbnailImages"] as? [String] ?? []
        self.froopVideos = data["froopVideos"] as? [String] ?? []
        self.froopVideoThumbnails = data["froopVideoThumbnails"] as? [String] ?? []
        self.froopHost = data["froopHost"] as? String ?? (FirebaseServices.shared.uid)
        self.froopHostPic = data["froopHostPic"] as? String ?? ""
        self.froopTimeZone = data["froopTimeZone"] as? String ?? ""
        self.template = data["template"] as? Bool ?? false
        self.hidden = data["hidden"] as? [String] ?? []
        self.inviteUrl = data["inviteUrl"] as? String ?? ""
        self.videoSubscribed = data["videoSubscribed"] as? Bool ?? false
        self.guestApproveList = data["guestApproveList"] as? [String] ?? []
        PrintControl.shared.printFroopData("retrieving froopData Data")
    }

    private func convertTimestampToUTCDate(timestamp: Timestamp) -> Date {
        PrintControl.shared.printFroopData("-FroopData: Function: convertTimestampToUTCDate is firing!")
        let utcCalendar = Calendar.current
        let date = timestamp.dateValue()
        let components = utcCalendar.dateComponents(in: TimeZone(identifier: "UTC")!, from: date)
        return utcCalendar.date(from: components)!
    }

    func updateFroopIdAndStartListener(newFroopId: String) {
        self.froopId = newFroopId
        startListener()
    }

    func startListener() {
        if !uid.isEmpty && !froopId.isEmpty {
            let listenerKey = "froop_\(froopId)"
            
            // Only create a new listener if one does not already exist
            if ListenerStateService.shared.shouldCreateListener(forKey: listenerKey) {
                let listener = FirebaseServices.shared.listenToFroopData(uid: uid, froopId: froopId) { [weak self] data in
                    self?.updateProperties(with: data)
                }
                
                // Assuming we get a ListenerRegistration object from FirebaseServices, we register it
                if let listener = listener {
                    ListenerStateService.shared.registerListener(listener, forKey: listenerKey)
                }
            }
        }
    }

    func convertToGeoPoint(coordinate: CLLocationCoordinate2D) -> GeoPoint {
        return GeoPoint(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }

    static func emptyFroop() -> Froop {
        let emptyDict: [String: Any] = [
            "froopId": "",
            "froopName": "",
            "froopType": 0,
            "froopLocationid": 0,
            "froopLocationtitle": "",
            "froopLocationsubtitle": "",
            "froopLocationCoordinate": GeoPoint(latitude: 0.0, longitude: 0.0),
            "froopDate": Date(),
            "froopStartTime": Date(),
            "froopCreationTime": Date(),
            "froopDuration": 0,
            "froopInvitedFriends": [],
            "froopEndTime": Date(),
            "froopImages": [],
            "froopDisplayImages": [],
            "froopThumbnailImages": [],
            "froopVideos": [],
            "froopVideoThumbnails": [],
            "froopIntroVideo": "",
            "froopIntroVideoThumbnail": "",
            "froopHost": "",
            "froopHostPic": "",
            "froopTimeZone": "",
            "froopMessage": "",
            "froopList": [],
            "template": false,
            "hidden": [],
            "inviteUrl": "",
            "videoSubscribed": false,
            "guestApproveList": []
        ]
        return Froop(dictionary: emptyDict)!
    }
}
