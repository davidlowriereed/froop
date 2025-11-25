//
//  MyFroopsViewModel.swift
//  FroopProof
//
//  Created by David Reed on 9/5/24.
//

import SwiftUI
import Combine

class MyFroopsViewModel: ObservableObject {
    @Published var froopHistoryWrappers: [FroopHistoryWrapper] = []
    @Published var areAllCardsExpanded: Bool = false
    @Published var showHiddenFroops: Bool = false
    @Published var selectedTab: Int = 0
    @Published var isFroopFetchingComplete: Bool = false
    
    private let froopManager = FroopManager.shared
    private let appStateManager = AppStateManager.shared
    private let myData = MyData.shared
    private let timeZoneManager = TimeZoneManager()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
        FroopManager.shared.$froopHistory
            .sink { [weak self] froopHistories in
                self?.updateFroops(froopHistories)
            }
            .store(in: &cancellables)
    }
    
    private func setupBindings() {
        FroopManager.shared.$displayFroopHistory
            .sink { [weak self] froopHistories in
                self?.updateFroops(froopHistories)
            }
            .store(in: &cancellables)
    }
    
    func updateFroops(_ froops: [FroopHistory]) {
        DispatchQueue.main.async {
            self.froopHistoryWrappers = froops.map { FroopHistoryWrapper(froopHistory: $0) }
        }
    }
    
    func fetchFroops() {
        print("Fetching Froops")

        FroopManager.shared.createFroopHistoryArray { [weak self] froopHistories in
            self?.updateFroops(froopHistories)
            self?.isFroopFetchingComplete = true
        }
    }
    
    var displayedFroops: [FroopHistoryWrapper] {
        let froops = froopHistoryWrappers.filter { wrapper in
//            print("Checking froop: \(wrapper.froopHistory.froop.froopName), status: \(wrapper.froopHistory.froopStatus)")
            switch wrapper.froopHistory.froopStatus {
                case .invited, .confirmed, .archived, .memory:
                    return true
                case .declined:
                    return wrapper.froopHistory.froop.froopHost == FirebaseServices.shared.uid
                default:
                    return false
            }
        }
//        print("Displayed Froops: \(froops.count)")
        return froops
    }
    
    var sortedFroopsForUser: [FroopHistoryWrapper] {
        let now = Date()
        let uid = FirebaseServices.shared.uid

        let pastFroops = displayedFroops.filter { $0.froopHistory.froop.froopEndTime < now && !$0.froopHistory.froop.hidden.contains(uid) }
        let futureFroops = displayedFroops.filter { $0.froopHistory.froop.froopEndTime >= now && !$0.froopHistory.froop.hidden.contains(uid) }
        
        let sortedPastFroops = pastFroops.sorted { $0.froopHistory.froop.froopEndTime > $1.froopHistory.froop.froopEndTime }
        let sortedFutureFroops = futureFroops.sorted { $0.froopHistory.froop.froopEndTime < $1.froopHistory.froop.froopEndTime }
        
        // Combine and remove duplicates
        var uniqueFroops: [FroopHistoryWrapper] = []
        var seenFroopIds: Set<String> = []
        
        for froop in (sortedFutureFroops + sortedPastFroops) {
            if !seenFroopIds.contains(froop.froopHistory.froop.froopId) {
                uniqueFroops.append(froop)
                seenFroopIds.insert(froop.froopHistory.froop.froopId)
            }
        }
        
        return uniqueFroops
    }
    
    var sortedHiddenFroopsForUser: [FroopHistoryWrapper] {
        let now = Date()
        let uid = FirebaseServices.shared.uid

        let pastFroops = displayedFroops.filter { $0.froopHistory.froop.froopEndTime < now && $0.froopHistory.froop.hidden.contains(uid) }
        let futureFroops = displayedFroops.filter { $0.froopHistory.froop.froopEndTime >= now && $0.froopHistory.froop.hidden.contains(uid) }
        
        let sortedPastFroops = pastFroops.sorted { $0.froopHistory.froop.froopEndTime > $1.froopHistory.froop.froopEndTime }
        let sortedFutureFroops = futureFroops.sorted { $0.froopHistory.froop.froopEndTime < $1.froopHistory.froop.froopEndTime }
        
        return sortedFutureFroops + sortedPastFroops
    }
    
    var sortedUniqueFroopsForSelectedFriend: [FroopHistoryWrapper] {
        var seen = Set<String>()
        return sortedFroopsForSelectedFriend.filter { wrapper in
            guard !seen.contains(wrapper.froopHistory.froop.froopId) else { return false }
            seen.insert(wrapper.froopHistory.froop.froopId)
            return true
        }
    }
    
    var sortedFroopsForSelectedFriend: [FroopHistoryWrapper] {
        return filteredFroopsForSelectedFriend.sorted { $0.froopHistory.froop.froopStartTime > $1.froopHistory.froop.froopStartTime }
    }
    
    var filteredFroopsForSelectedFriend: [FroopHistoryWrapper] {
        return displayedFroops.filter { wrapper in
            !wrapper.froopHistory.images.isEmpty &&
            (wrapper.froopHistory.host.froopUserID == myData.froopUserID ||
             wrapper.froopHistory.confirmedFriends.contains(where: { $0.froopUserID == myData.froopUserID }))
        }
    }
    
    func toggleCardExpansion() {
        areAllCardsExpanded.toggle()
    }
    
    func toggleHiddenFroops() {
        showHiddenFroops.toggle()
    }
    
    func formatDate(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE MMM.dd.yyyy 'at' h:mm a"
        return formatter.string(from: date)
    }
    
    var timeUntilNextFroop: TimeInterval? {
        let now = Date()
        let nextFroops = FroopDataListener.shared.myConfirmedList.filter { $0.froopStartTime > now }
        return nextFroops.min(by: { $0.froopStartTime < $1.froopStartTime })?.froopStartTime.timeIntervalSince(now)
    }
    
    var countdownText: String {
        if let timeUntilNextFroop = timeUntilNextFroop {
            return "Next Froop in: \(timeZoneManager.formatDuration2(durationInMinutes: timeUntilNextFroop + 60))"
        } else {
            if appStateManager.appState == .active {
                return "Froop In Progress!"
            }
            return "No Froops Scheduled"
        }
    }
    
    func eveningText() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        default: return "Good Evening"
        }
    }
    
    func updateSelectedTab(_ tab: Int) {
        selectedTab = tab
    }
}
