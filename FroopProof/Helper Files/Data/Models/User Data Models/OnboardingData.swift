import Foundation
import FirebaseFirestore
import FirebaseAuth
import Firebase
import SwiftUI
import Combine

class OnboardingData: ObservableObject, Equatable {
    // MARK: - Singleton & Properties
    static let shared = OnboardingData()
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Published Properties
    @Published var isLoading: Bool = true
    @Published var homeOnboarding: Bool = false
    @Published var friendsOnboarding: Bool = false
    @Published var myProfileOnboarding: Bool = false
    @Published var createFroopTypeOnboarding: Bool = false
    @Published var searchFroopLocationOnboarding: Bool = false
    @Published var setDateFroopOnboarding: Bool = false
    @Published var setTimeFroopOnboarding: Bool = false
    @Published var froopSummaryOnboarding: Bool = false
    @Published var froopManageOnboarding: Bool = false
    @Published var froopOpenCardOnboarding: Bool = false
    @Published var froopDetailsOnboarding: Bool = false
    @Published var froopGlobalChatOnboarding: Bool = false
    
    // MARK: - Internal State
    var documentPath: DocumentReference? {
        guard !uid.isEmpty else { return nil }
        return db.collection("users").document(uid).collection("onboarding").document("onboarding")
    }
    
    var uid: String {
        return Auth.auth().currentUser?.uid ?? ""
    }
    
    // MARK: - Initialization
    private init() {
        setupInitialState()
    }
    
    deinit {
        cleanupListener()
    }
    
    // MARK: - Public Interface
    func updateOnboarding(for viewID: OnboardingViewType, to value: Bool) async {
        guard let propertyName = viewID.propertyName else { return }
        
        guard let docRef = documentPath else {
            PrintControl.shared.printOnboarding("❌ No valid document path")
            return
        }
        
        do {
            try await docRef.updateData([propertyName: value])
            DispatchQueue.main.async { [weak self] in
                if let keyPath = self?.getKeyPath(for: propertyName) {
                    self?[keyPath: keyPath] = value
                }
            }
            PrintControl.shared.printOnboarding("✅ Successfully updated \(propertyName) to \(value)")
        } catch {
            PrintControl.shared.printOnboarding("❌ Failed to update \(propertyName): \(error.localizedDescription)")
        }
    }
    
    // MARK: - Private Methods
    private func setupInitialState() {
        checkAndCreateOnboardingDocument()
        setupListener()
        
        // Setup listener state management
        ListenerStateService.shared.listenersActiveSubject
            .sink { [weak self] isActive in
                if !isActive {
                    self?.cleanupListener()
                }
            }
            .store(in: &cancellables)
    }
    
    private func cleanupListener() {
        listener?.remove()
        listener = nil
    }
    
    private func checkAndCreateOnboardingDocument() {
        guard let docRef = documentPath else {
            PrintControl.shared.printOnboarding("❌ No valid document path")
            return
        }
        
        docRef.getDocument { [weak self] document, error in
            guard let self = self else { return }
            
            if let error = error {
                PrintControl.shared.printOnboarding("❌ Error getting onboarding document: \(error.localizedDescription)")
                return
            }
            
            if let document = document, document.exists {
                PrintControl.shared.printOnboarding("✅ Onboarding document exists")
            } else {
                let defaultData = self.dictionary
                docRef.setData(defaultData) { error in
                    if let error = error {
                        PrintControl.shared.printOnboarding("❌ Error creating onboarding document: \(error.localizedDescription)")
                    } else {
                        PrintControl.shared.printOnboarding("✅ Created onboarding document")
                    }
                }
            }
        }
    }
    
    private func setupListener() {
        guard let docRef = documentPath else { return }
        
        listener = docRef.addSnapshotListener { [weak self] document, error in
            guard let self = self else { return }
            
            if let error = error {
                PrintControl.shared.printOnboarding("❌ Listener error: \(error.localizedDescription)")
                return
            }
            
            if let document = document, document.exists {
                self.updateProperties(with: document.data() ?? [:])
            }
        }
        
        if let listener = listener {
            ListenerStateService.shared.registerListener(listener, forKey: "onboardingDataListener")
        }
    }
    
    private func updateOnboardingProperty(_ propertyName: String, value: Bool) async throws {
        guard let docRef = documentPath else {
            throw OnboardingError.documentPathInvalid
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            docRef.updateData([propertyName: value]) { error in
                if let error = error {
                    continuation.resume(throwing: OnboardingError.updateFailed(error))
                } else {
                    DispatchQueue.main.async { [weak self] in
                        if let keyPath = self?.getKeyPath(for: propertyName) {
                            self?[keyPath: keyPath] = value
                        }
                        continuation.resume()
                    }
                }
            }
        }
    }
    
    private func updateProperties(with data: [String: Any]) {
        DispatchQueue.main.async {
            self.homeOnboarding = data["homeOnboarding"] as? Bool ?? false
            self.friendsOnboarding = data["friendsOnboarding"] as? Bool ?? false
            self.myProfileOnboarding = data["myProfileOnboarding"] as? Bool ?? false
            self.createFroopTypeOnboarding = data["createFroopTypeOnboarding"] as? Bool ?? false
            self.searchFroopLocationOnboarding = data["searchFroopLocationOnboarding"] as? Bool ?? false
            self.setDateFroopOnboarding = data["setDateFroopOnboarding"] as? Bool ?? false
            self.setTimeFroopOnboarding = data["setTimeFroopOnboarding"] as? Bool ?? false
            self.froopSummaryOnboarding = data["froopSummaryOnboarding"] as? Bool ?? false
            self.froopManageOnboarding = data["froopManageOnboarding"] as? Bool ?? false
            self.froopOpenCardOnboarding = data["froopOpenCardOnboarding"] as? Bool ?? false
            self.froopDetailsOnboarding = data["froopDetailsOnboarding"] as? Bool ?? false
            self.froopGlobalChatOnboarding = data["froopGlobalChatOnboarding"] as? Bool ?? false
            
            self.isLoading = false
            AppStateManager.shared.onboardingDataLoaded = true
        }
    }
    
    // MARK: - Helper Methods
    private func getKeyPath(for propertyName: String) -> WritableKeyPath<OnboardingData, Bool>? {
        switch propertyName {
            case "homeOnboarding": return \OnboardingData.homeOnboarding
            case "friendsOnboarding": return \OnboardingData.friendsOnboarding
            case "myProfileOnboarding": return \OnboardingData.myProfileOnboarding
            case "createFroopTypeOnboarding": return \OnboardingData.createFroopTypeOnboarding
            case "searchFroopLocationOnboarding": return \OnboardingData.searchFroopLocationOnboarding
            case "setDateFroopOnboarding": return \OnboardingData.setDateFroopOnboarding
            case "setTimeFroopOnboarding": return \OnboardingData.setTimeFroopOnboarding
            case "froopSummaryOnboarding": return \OnboardingData.froopSummaryOnboarding
            case "froopManageOnboarding": return \OnboardingData.froopManageOnboarding
            case "froopOpenCardOnboarding": return \OnboardingData.froopOpenCardOnboarding
            case "froopDetailsOnboarding": return \OnboardingData.froopDetailsOnboarding
            case "froopGlobalChatOnboarding": return \OnboardingData.froopGlobalChatOnboarding
            default: return nil
        }
    }
    
    var dictionary: [String: Any] {
        return [
            "homeOnboarding": homeOnboarding,
            "friendsOnboarding": friendsOnboarding,
            "myProfileOnboarding": myProfileOnboarding,
            "createFroopTypeOnboarding": createFroopTypeOnboarding,
            "searchFroopLocationOnboarding": searchFroopLocationOnboarding,
            "setDateFroopOnboarding": setDateFroopOnboarding,
            "setTimeFroopOnboarding": setTimeFroopOnboarding,
            "froopSummaryOnboarding": froopSummaryOnboarding,
            "froopManageOnboarding": froopManageOnboarding,
            "froopOpenCardOnboarding": froopOpenCardOnboarding,
            "froopDetailsOnboarding": froopDetailsOnboarding,
            "froopGlobalChatOnboarding": froopGlobalChatOnboarding
        ]
    }
    
    // MARK: - Equatable
    static func == (lhs: OnboardingData, rhs: OnboardingData) -> Bool {
        return lhs.homeOnboarding == rhs.homeOnboarding &&
        lhs.friendsOnboarding == rhs.friendsOnboarding &&
        lhs.myProfileOnboarding == rhs.myProfileOnboarding &&
        lhs.createFroopTypeOnboarding == rhs.createFroopTypeOnboarding &&
        lhs.searchFroopLocationOnboarding == rhs.searchFroopLocationOnboarding &&
        lhs.setDateFroopOnboarding == rhs.setDateFroopOnboarding &&
        lhs.setTimeFroopOnboarding == rhs.setTimeFroopOnboarding &&
        lhs.froopSummaryOnboarding == rhs.froopSummaryOnboarding &&
        lhs.froopManageOnboarding == rhs.froopManageOnboarding &&
        lhs.froopOpenCardOnboarding == rhs.froopOpenCardOnboarding &&
        lhs.froopDetailsOnboarding == rhs.froopDetailsOnboarding &&
        lhs.froopGlobalChatOnboarding == rhs.froopGlobalChatOnboarding
    }
}

// MARK: - Supporting Types
// In OnboardingData.swift, update the OnboardingError enum to include all cases:

enum OnboardingError: LocalizedError {
    case documentPathInvalid
    case updateFailed(Error)
    case userNotAuthenticated
    case notInitialized
    case invalidViewState
    case saveFailed
    
    var errorDescription: String? {
        switch self {
            case .documentPathInvalid:
                return "Invalid document path"
            case .updateFailed(let error):
                return "Failed to update: \(error.localizedDescription)"
            case .userNotAuthenticated:
                return "User is not authenticated"
            case .notInitialized:
                return "Onboarding system not properly initialized"
            case .invalidViewState:
                return "Invalid view state encountered"
            case .saveFailed:
                return "Failed to save onboarding state"
        }
    }
}

// MARK: - Extensions
extension OnboardingViewType {
    var propertyName: String? {
        switch self {
            case .home: return "homeOnboarding"
            case .friends: return "friendsOnboarding"
            case .profile: return "myProfileOnboarding"
            case .createFroopType: return "createFroopTypeOnboarding"
            case .createFroopLocation: return "searchFroopLocationOnboarding"
            case .createFroopDate: return "setDateFroopOnboarding"
            case .createFroopTime: return "setTimeFroopOnboarding"
            case .createFroopSummary: return "froopSummaryOnboarding"
            case .manageFroop: return "froopManageOnboarding"
            case .froopOpenCard: return "froopOpenCardOnboarding"
            case .froopDetails: return "froopDetailsOnboarding"
            case .froopGlobalChat: return "froopGlobalChatOnboarding"
            case .none: return nil
        }
    }
}
