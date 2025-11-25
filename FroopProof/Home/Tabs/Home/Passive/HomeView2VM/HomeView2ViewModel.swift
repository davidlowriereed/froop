//
//  HomeViewViewModel.swift
//  FroopProof
//
//  Created by David Reed on 4/1/23.
//

import Foundation
import FirebaseFirestore
import Firebase
import FirebaseAuth
import SwiftUI


class HomeView2ViewModel: ObservableObject {
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var navLocationServices = NavLocationServices.shared
    // @ObservedObject var froopDataListener = FroopDataListener.shared
    @Published var froops: [Froop] = []
    @Published var myInvitesList: [Froop] = []
    @Published var myConfirmedList: [Froop] = []
    @Published var myDeclinedList: [Froop] = []
    @Published var myArchivedList: [Froop] = []
    @Published var froopListStatus: FroopListStatus = .confirmed
    @Published var timeZoneManager:TimeZoneManager = TimeZoneManager()
    @Published var selectedFroopUUID: String = FroopManager.shared.selectedFroopUUID ?? ""
    
    enum FroopListStatus {
        case invites, confirmed, declined, archived, pending
    }
    
    var timeUntilNextFroop: TimeInterval? {
        let now = Date()
        let nextFroops = froops.filter { $0.froopStartTime > now }
        guard let nextFroop = nextFroops.min(by: { $0.froopStartTime < $1.froopStartTime }) else {
            // There are no future Froops, so return nil
            return nil
        }
        return nextFroop.froopStartTime.timeIntervalSince(now)
    }
    
    var countdownText: String {
        if let timeUntilNextFroop = timeUntilNextFroop {
            // Use the formatDuration2 function from the timeZoneManager
            return "Next Froop in: \(timeZoneManager.formatDuration2(durationInMinutes: timeUntilNextFroop + 60))"
        } else {
            return "No future Froops"
        }
    }
    
    var selectedFroop: Froop? {
        let froopId = selectedFroopUUID
        return froops.first(where: { $0.froopId == froopId })
    }
}
