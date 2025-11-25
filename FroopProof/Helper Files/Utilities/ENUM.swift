//
//  ENUM.swift
//  FroopProof
//
//  Created by David Reed on 1/17/24.
//

import Foundation
import UIKit
import SwiftUI
import PhotosUI

enum TextFieldFocus {
    case none
    case enumFlightCarrier
    case enumFlightNum
}

enum FieldFocus: Hashable {
    case airlineCode
    case flightNumber
    case airport
//    case flightModifier
}

enum Tab: String, CaseIterable {
    case make
    case froop
    case person
}

enum ChatType {
    case none
    case group
    case oneOnOne
}

enum MediaType: String {
    case image
    case video
}

enum Direction {
    case left
    case right
}

enum FocusField: Hashable {
    case field
    case nofield
    case phoneNumberTextField
    case none
}

enum ChatContext {
    case global
    case activeFroop(hostId: String)
}

enum FroopListStatus {
    case invites
    case confirmed
    case declined
    case archived
}

enum FroopListType {
    case invites, confirmed, declined, archived
    
    var collectionName: String {
        switch self {
        case .invites: return "myInvitesList"
        case .confirmed: return "myConfirmedList"
        case .declined: return "myDeclinedList"
        case .archived: return "myArchivedList"
        }
    }
}

extension FroopListType {
    func toFroopStatus() -> FroopHistory.FroopStatus {
        switch self {
        case .invites: return .invited
        case .confirmed: return .confirmed
        case .declined: return .declined
        case .archived: return .archived
        }
    }
}

enum FriendRequestError: Error {
    case friendRequestExists
}

enum AppState {
    case passive
    case active
}

enum ShowAppState {
    case activeView
    case passiveView
}

enum FroopTabState {
    case selected
    case notSelected
}

enum Stage {
    case starting
    case running
    case ending
    case none
}

enum MediaAsset {
    case phAsset(PHAsset)
    case uiImage(UIImage)
}

enum FroopStatus: String {
    case invited = "invited"
    case confirmed = "confirmed"
    case declined = "declined"
    case archived = "archived"
    case memory = "memory"
    case none = "none"
}

enum MapViewState: Int {
    case noInput
    case searchingForLocation
    case locationSelected
    case tripRequested
    case tripAccepted
    case driverArrived
    case tripInProgress
    case arrivedAtDestination
    case tripCompleted
    case tripCancelled
    case polylineAdded
}

enum DetailsStatus: Int {
    case invited
    case confirmed
    case deleted
    case archived
}

enum FroopState: Int, CustomStringConvertible {
    case noInput
    case froopCreated
    case invitedFriends
    case froopPreGame
    case froopStarted
    case froopInProgress
    case froopCompleted
    case froopArchived
    case froopCancelled
    case froopEdit

    var description: String {
        switch self {
        case .noInput:
            return "No input"
        case .froopCreated:
            return "Froop created"
        case .invitedFriends:
            return "Invited friends"
        case .froopPreGame:
            return "Froop pre-game"
        case .froopStarted:
            return "Froop started"
        case .froopInProgress:
            return "Froop in progress"
        case .froopCompleted:
            return "Froop completed"
        case .froopArchived:
            return "Froop archived"
        case .froopCancelled:
            return "Froop cancelled"
        case .froopEdit:
            return "Froop edit"
        }
    }
    func onStateActivated() {
        PrintControl.shared.printFroopManager("-FroopState: Function: onStateActivated is firing!")
           switch self {
           case .noInput:
               PrintControl.shared.printFroopManager("No noInput activated")
           case .froopCreated:
               PrintControl.shared.printFroopManager("Froop froopCreated activated")
           case .invitedFriends:
               PrintControl.shared.printFroopManager("Froop invitedFriends activated")
           case .froopPreGame:
               PrintControl.shared.printFroopManager("Froop froopPreGame activated")
           case .froopStarted:
               PrintControl.shared.printFroopManager("Froop froopStarted activated")
           case .froopInProgress:
               PrintControl.shared.printFroopManager("Froop froopInProgress activated")
           case .froopCompleted:
               PrintControl.shared.printFroopManager("Froop froopCompleted activated")
           case .froopArchived:
               PrintControl.shared.printFroopManager("Froop froopArchived activated")
           case .froopCancelled:
               PrintControl.shared.printFroopManager("Froop froopCancelled activated")
           case .froopEdit:
               PrintControl.shared.printFroopManager("Froop froopEdit activated")
           }
       }
}

enum RideType: Int, CaseIterable, Identifiable, Codable {
    case setFroopLocation
  
    
    var id: Int { return rawValue }
    
    var description: String {
        switch self {
        case .setFroopLocation: return "Distance"

        }
    }
    
    var imageName: String {
        switch self {
        case .setFroopLocation: return "location.circle"

        }
    }
    
    var baseFare: Double {
        switch self {
        case .setFroopLocation: return 5

        }
    }
    
    func computePrice(for distanceInMeters: Double) -> Double {
       
        let distanceInMiles = distanceInMeters / 1600
        
        switch self {
        case .setFroopLocation: return distanceInMiles

        }
    }
}

enum ScreenSizeCategory: String {
    case size430x932
    case size428x926
    case size414x896
    case size393x852
    case size390x844
    case size375x812
    case unknown
    
    var description: String {
        switch self {
        case .size430x932: return "430x932 pt (1290x2796 px @3x)"
        case .size428x926: return "428x926 pt (1284x2778 px @3x)"
        case .size414x896: return "414x896 pt (828x1792 px @2x)"
        case .size393x852: return "393x852 pt (1179x2556 px @3x)"
        case .size390x844: return "390x844 pt (1170x2532 px @3x)"
        case .size375x812: return "375x812 pt (1125x2436 px @3x)"
        case .unknown: return "Unknown Screen Size"
        }
    }
}

enum UploadError: Error {
    case imageConversionFailed
    case urlFetchFailed
}

enum OnboardingTab: Int, Hashable {
    case first = 1
    case second = 2
    case third = 3
    case fourth = 4
    case fifth = 5
    
    init?(fromInt value: Int) {
        switch value {
            case 1: self = .first
            case 2: self = .second
            case 3: self = .third
            case 4: self = .fourth
            case 5: self = .fifth
            default: return nil
        }
    }
}

enum TripState: Int, Codable {
    
    case driversUnavailable
    case rejectedByDriver
    case rejectedByAllDrivers
    case requested // value has to equal 3 to correspond to mapView tripRequested state
    case accepted
    case driverArrived
    case inProgress
    case arrivedAtDestination
    case complete
    case cancelled
}

enum detailGuestStatus {
    case none, invited, confirmed, declined, inviting
}

enum GuestStatus {
    case none, invited, confirmed, declined, inviting
}

enum FroopTab: Int {
    case info = 1
    case map = 2
    case messages = 3
    case media = 4
    case selection = 5
}

enum ImageType {
    case original, display, thumbnail
}

enum ImageShape {
    case square
    case rectangleTwoToOne
    case rectangleOneToTwo
}


