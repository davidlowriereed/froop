//
//  FroopHistoryWrapper.swift
//  FroopProof
//
//  Created by David Reed on 9/5/24.
//

import Foundation

class FroopHistoryWrapper: ObservableObject, Identifiable {
    let id: UUID
    @Published var froopHistory: FroopHistory

    init(froopHistory: FroopHistory) {
        self.id = froopHistory.id
        self.froopHistory = froopHistory
    }

    var froopStatus: FroopHistory.FroopStatus {
        get { froopHistory.froopStatus }
        set { froopHistory.froopStatus = newValue }
    }
}
