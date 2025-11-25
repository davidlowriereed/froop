//
//  ProfileData.swift
//  FroopProof
//
//  Created by David Reed on 1/18/23.
//
import Foundation
import CoreLocation
import Firebase
import Combine
import SwiftUI
import UIKit
import FirebaseFirestore
import MapKit
import RevenueCat
import FirebaseAuth

final class ProfileData: ObservableObject {
    var uid = Auth.auth().currentUser?.uid ?? ""
    var db = Firestore.firestore()
    @Published var data = [String: Any]()
    let id: UUID = UUID()
    @Published var froopUserID: String = ""
    @Published var timeZone: String = TimeZone.current.identifier
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var phoneNumber: String = ""
    @Published var addressNumber: String = ""
    @Published var addressStreet: String = ""
    @Published var unitName: String = ""
    @Published var addressCity: String = ""
    @Published var addressState: String = ""
    @Published var addressZip: String = ""
    @Published var addressCountry: String = ""
    @Published var profileImageUrl: String = ""
    @Published var fcmToken: String = ""
    @Published var OTPVerified: Bool = false
    @Published var premiumAccount: Bool = false
    @Published var professionalAccount: Bool = false
    @Published var professionalTemplates: [String] = []
    @Published var myFriends: [UserData] = []
    @Published var creationDate: Date = Date()
    @Published var userDescription: String = ""
    @Published var myLocDerivedTitle: String? = nil
    @Published var myLocDerivedSubtitle: String? = nil
    @Published var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
    var geoPoint: GeoPoint {
        get {
            return GeoPoint(latitude: coordinate.latitude, longitude: coordinate.longitude)
        }
        set {
            let newCoordinate = CLLocationCoordinate2D(latitude: newValue.latitude, longitude: newValue.longitude)
            if newCoordinate.latitude != coordinate.latitude || newCoordinate.longitude != coordinate.longitude {
                self.coordinate = newCoordinate
            }
        }
    }
    
    @Published var badgeCount = 0
    
    var dictionary: [String: Any] {
        let geoPoint = convertToGeoPoint(coordinate: coordinate)
        return [
            "froopUserID": froopUserID,
            "firstName": firstName,
            "lastName": lastName,
            "phoneNumber": phoneNumber,
            "addressNumber": addressNumber,
            "addressStreet": addressStreet,
            "unitName": unitName,
            "addressCity": addressCity,
            "addressState": addressState,
            "addressZip": addressZip,
            "addressCountry": addressCountry,
            "timeZone": timeZone,
            "profileImageUrl": profileImageUrl,
            "fcmToken": fcmToken,
            "badgeCount" : badgeCount,
            "coordinate": geoPoint,
            "OTPVerified" : OTPVerified,
            "premiumAccount": premiumAccount,
            "professionalAccount": professionalAccount,
            "professionalTemplates": professionalTemplates,
            "myFriends": myFriends,
            "creationDate": creationDate,
            "userDescription": userDescription
        ]
    }
    
    init?(dictionary: [String: Any]) {
        updateProperties(with: dictionary)
        // Check if the required properties have been set
        guard !self.froopUserID.isEmpty else {
            return nil
        }
    }
        
    init() {
        guard !FirebaseServices.shared.uid.isEmpty else {
            PrintControl.shared.printErrorMessages("Error: no user is currently signed in.")
            return
        }
        let uid = Auth.auth().currentUser?.uid ?? ""
        let docRef = db.collection("users").document(uid)
    }
    
    func updateProperties(with data: [String: Any]) {
        PrintControl.shared.printUserData("-myData: Function: updateProperties is firing!")
        self.data = data
        self.froopUserID = data["froopUserID"] as? String ?? ""
        self.timeZone = data["timeZone"] as? String ?? TimeZone.current.identifier
        self.firstName = data["firstName"] as? String ?? ""
        self.lastName = data["lastName"] as? String ?? ""
        self.phoneNumber = data["phoneNumber"] as? String ?? ""
        self.addressNumber = data["addressNumber"] as? String ?? ""
        self.addressStreet = data["addressStreet"] as? String ?? ""
        self.unitName = data["unitName"] as? String ?? ""
        self.addressCity = data["addressCity"] as? String ?? ""
        self.addressState = data["addressState"] as? String ?? ""
        self.addressZip = data["addressZip"] as? String ?? ""
        self.addressCountry = data["addressCountry"] as? String ?? ""
        self.profileImageUrl = data["profileImageUrl"] as? String ?? ""
        self.fcmToken = data["fcmToken"] as? String ?? ""
        self.badgeCount = data["badgeCount"] as? Int ?? 0
        if let geoPoint = data["coordinate"] as? GeoPoint {
            self.coordinate = CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
        }
        self.premiumAccount = data["premiumAccount"] as? Bool ?? false
        self.professionalAccount = data["professionalAccount"] as? Bool ?? false
        self.professionalTemplates = data["professionalTemplates"] as? [String] ?? []
        self.OTPVerified = data["OTPVerified"] as? Bool ?? false
        self.creationDate = data["creationDate"] as? Date ?? Date()
        self.userDescription = data["userDescription"] as? String ?? ""
        PrintControl.shared.printMyData("--------retrieving User Data")
    }
    func convertToGeoPoint(coordinate: CLLocationCoordinate2D) -> GeoPoint {
        return GeoPoint(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
}

