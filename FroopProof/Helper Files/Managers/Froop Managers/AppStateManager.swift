//
//  AppStateManager.swift
//  FroopProof
//
//  Created by David Reed on 4/17/23.
//

import SwiftUI
import UIKit
import Combine
import FirebaseFirestore
import FirebaseAuth
import Foundation
import MapKit
import FirebaseAuth

class AppStateManager: ObservableObject {
    static let shared = AppStateManager()
    private var listenerService = ListenerStateService.shared
    @ObservedObject var onboardingData = OnboardingData.shared
    @Published var openGlobalChat: Bool = false
    @Published var mediaTimeStamp: [Date] = []
    var onUpdateMapView: (() -> Void)?
    var db = FirebaseServices.shared.db
    @Published var showCoverScreen = true
    @Published var showFace: Bool = false
    @Published var showFaceText: Bool = false
    @Published var locationAuthorized: Bool = false {
        didSet {
            print("Location authorization changed to: \(locationAuthorized)")
        }
    }
    
    @Published var appState: AppState = .passive
    @Published var appStateToggle: Bool = false
    
    
    @Published var activeFroopId: String?
    @Published var activeFroop: Froop = Froop(dictionary: [:]) ?? Froop.emptyFroop()
    @Published var fetchedFroops: [FroopHistory] = []
    @Published var activeFroops: [Froop] = []
    @Published var chatWith: UserData = UserData()
    @Published var currentOnboardingView: OnboardingViewType?
    @Published var froopMediaData: FroopMediaData = FroopMediaData (
        froopImages: [],
        froopDisplayImages: [],
        froopThumbnailImages: [],
        froopIntroVideo: "",
        froopIntroVideoThumbnail: "",
        froopVideos: [],
        froopVideoThumbnails: []
    )
    @Published var currentViewID: OnboardingViewType = .none
    @Published var inProgressFroop: FroopHistory  = {
        let defaultFroop = Froop(dictionary: [:]) // Provide necessary arguments or default values
        let defaultHost = UserData() // Provide necessary arguments or default values
        let defaultFriends: [UserData] = [] // Or provide default UserData objects
        let defaultImages: [String] = [] // Or provide default strings
        let defaultVideos: [String] = [] // Or provide default strings
        let defaultConversationAndMessages: ConversationAndMessages = ConversationAndMessages(conversation: Conversation(), messages: [], participants: [])
        
        return FroopHistory(
            froop: defaultFroop ?? Froop(dictionary: [:]) ?? Froop.emptyFroop(),
            host: defaultHost,
            invitedFriends: defaultFriends,
            confirmedFriends: defaultFriends,
            declinedFriends: defaultFriends,
            pendingFriends: defaultFriends,
            images: defaultImages,
            videos: defaultVideos,
            froopGroupConversationAndMessages: defaultConversationAndMessages,
            froopMediaData: FroopMediaData(
                froopImages: [],
                froopDisplayImages: [],
                froopThumbnailImages: [],
                froopIntroVideo: "",
                froopIntroVideoThumbnail: "",
                froopVideos: [],
                froopVideoThumbnails: []
            ),
            flightData: ScheduledFlightAPI.FlightDetail.empty())
    }()
    @Published var inProgressFroopHistories: [FroopHistory] = []
    @Published var inProgressFroopHistory: FroopHistory  = {
        let defaultFroop = Froop(dictionary: [:]) // Provide necessary arguments or default values
        let defaultHost = UserData() // Provide necessary arguments or default values
        let defaultFriends: [UserData] = [] // Or provide default UserData objects
        let defaultImages: [String] = [] // Or provide default strings
        let defaultVideos: [String] = [] // Or provide default strings
        let defaultConversationAndMessages: ConversationAndMessages = ConversationAndMessages(conversation: Conversation(), messages: [], participants: [])
        let froopMediaData: FroopMediaData = FroopMediaData(
            froopImages: [],
            froopDisplayImages: [],
            froopThumbnailImages: [],
            froopIntroVideo: "",
            froopIntroVideoThumbnail: "",
            froopVideos: [],
            froopVideoThumbnails: []
        )
        return FroopHistory(
            froop: defaultFroop ?? Froop(dictionary: [:]) ?? Froop.emptyFroop(),
            host: defaultHost,
            invitedFriends: defaultFriends,
            confirmedFriends: defaultFriends,
            declinedFriends: defaultFriends,
            pendingFriends: defaultFriends,
            images: defaultImages,
            videos: defaultVideos,
            froopGroupConversationAndMessages: defaultConversationAndMessages,
            froopMediaData: froopMediaData,
            flightData: ScheduledFlightAPI.FlightDetail.empty())
    }()
    @Published var changeLocation: CLLocationCoordinate2D = CLLocationCoordinate2D()
    @Published var froopTabSelected: FroopTabState = .notSelected
    @Published var activeFroopPins: [ApexAnnotationPin] = []
    @Published var activeHostData: UserData = UserData()
    @Published var activeInvitedFriends: [UserData] = []
    @Published var isDarkStyle: Bool = false
    @Published var activeInvitedUids: [String] = [""]
    @Published var shouldPresentFroopSelection = false
    @Published var froopTypes: [Int: String] = [:]
    @Published var stateTransitionTimerOn: Bool = false
    @Published var isMessageViewPresented = false
    @Published var guestPhoneNumber = ""
    @Published var isAnnotationMade = false
    @Published var isFroopTabUp = true
    @Published var showChatView = false
    @Published var chatViewId: String?
    @Published var selectedTab = 1
    @Published var visualEffectViewOpacity: Double = 0.0
    @Published var parentViewOpacity: Double = 0.0
    @Published var visualEffectViewPresented: Bool = false
    @Published var parentViewPresented: Bool = false
    @Published var hVTimer = Timer.publish(every: 15, on: .main, in: .common).autoconnect()
    @Published var selectedTabTwo: Int = 0
    @Published var profileToggle: Bool = true
    @Published var showAppState: ShowAppState = .passiveView
    @Published var activeFroopHistoryCollection: [FroopHistory] = []
    @Published var currentFilteredFroopHistory: [FroopHistory] = []
    @Published var aFHI: Int = 0 {
        willSet(newVal) {
            print("aFHI will change from \(self.aFHI) to \(newVal)")
            print("Changing from: \(Thread.callStackSymbols)")
        }
        didSet {
            print("aFHI did change from \(oldValue) to \(self.aFHI)")
        }
    }
    @Published var selectFroopSheet: Bool = false
    @Published var mapAppChat: Bool = false
    @Published var infoAppChat: Bool = false
    @Published var archiveAppChat: Bool = false
    @Published var centerCoordinate: CLLocationCoordinate2D?
    @Published var inMapChat: Bool = false
    @Published var activeOrPassiveOnAppear: Bool = true
    @Published var onboarding: Bool = false
    //    @Published var showRibbon: Bool = true
    @Published var hasRespondedToRibbon: Bool = false
    
    @Published var showHomeOnboarding: Bool = false
    @Published var showFriendsOnboarding: Bool = false
    @Published var showMyProfileOnboarding: Bool = false
    @Published var showCreateFroopTypeOnboarding: Bool = false
    @Published var showSearchFroopLocationOnboarding: Bool = false
    @Published var showSetDateFroopOnboarding: Bool = false
    @Published var showSetTimeFroopOnboarding: Bool = false
    @Published var showFroopSummaryOnboarding: Bool = false
    @Published var showFroopManageOnboarding: Bool = false
    @Published var showFroopOpenCardOnboarding: Bool = false
    @Published var showFroopDetailsOnboarding: Bool = false
    @Published var showFroopGlobalChatOnboarding: Bool = false
    @Published var showHomeRibbon: Bool = false
    @Published var showFriendsRibbon: Bool = false
    @Published var showProfileRibbon: Bool = false
    @Published var onboardingDataLoaded: Bool = false
    private var cancellables: Set<AnyCancellable> = []
    
    
    let myConfirmedListCollection: CollectionReference?
    private var uid = FirebaseServices.shared.uid
    private let timerKey = "appStateManagerTimer"
    var timerCancellable: Cancellable?
    var now = Date()
    var timer: Timer?
    var removalTimer: DispatchSourceTimer?
    var froopEndTimers: [String: Timer] = [:]
    var froopManager: FroopManager {
        return FroopManager.shared
    }
    var selectedUserCoordinateCancellable: AnyCancellable?
    var updateTimer: Timer?
    var currentStage: Stage {
        let now = Date()
        if now < currentFilteredFroopHistory[safe: aFHI]?.froop.froopStartTime ?? Date() {
            return .starting
        } else if now > currentFilteredFroopHistory[safe: aFHI]?.froop.froopStartTime ?? Date() && now < currentFilteredFroopHistory[safe: aFHI]?.froop.froopEndTime ?? Date() {
            return .running
        } else if now > currentFilteredFroopHistory[safe: aFHI]?.froop.froopEndTime ?? Date() - (5 * 60) && now < currentFilteredFroopHistory[safe: aFHI]?.froop.froopEndTime ?? Date() {
            return .ending
        } else {
            return .none
        }
    }
    var filteredFroopHistory: [FroopHistory] {
        return froopManager.froopHistory.filter { froopHistory in
            let now = Date()
            let isActive = froopHistory.froop.froopStartTime < now && froopHistory.froop.froopEndTime > now
            let isConfirmed = froopHistory.froopStatus == .confirmed
            return isActive && isConfirmed
        }
    }
    private var stateTransitionTimer: Timer?
    var printControl: PrintControl {
        return PrintControl.shared
    }
    var firebaseServices: FirebaseServices {
        return FirebaseServices.shared
    }
    var froopDataController: FroopDataController {
        return FroopDataController.shared
    }
    var navLocationServices: NavLocationServices {
        return NavLocationServices.shared
    }
    var locationManager: LocationManager {
        return LocationManager.shared
    }
    var confirmedFroops: ConfirmedFroopsList {
        return ConfirmedFroopsList(activeFroops: self.activeFroops)
    }
    
    init() {
        self.chatViewId = ""
        
        // Don't access Firestore or use UID until we're sure the user is authenticated
        if let uid = Auth.auth().currentUser?.uid, !uid.isEmpty {
            self.uid = uid
            myConfirmedListCollection = db.collection("users").document(uid).collection("froopDecisions").document("froopLists").collection("myConfirmedList")
            
            fetchAllFroopTypes()
            startTimer()
            TimerServices.shared.startFroopHistoryArrayTimer()
        } else {
            myConfirmedListCollection = nil
            PrintControl.shared.printErrorMessages("Error: no user is currently signed in.")
        }

    }
    
    
    func startTimer() {
        guard firebaseServices.isAuthenticated else {
            return
        }
        
        self.timer?.invalidate()
        
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.timerFired), userInfo: nil, repeats: true)
        
    }
    
    @objc func timerFired() {
        let now = Date()
        let currentUserUid = FirebaseServices.shared.uid
        
        // Filter active Froops where the current user is confirmed
        let activeFroops = froopManager.froopHistory.filter { froopHistory in
            // Check time constraints
            let isActiveTime = froopHistory.froop.froopStartTime < now && froopHistory.froop.froopEndTime > now
            
            // Check if user is in confirmed friends list
            let isConfirmed = froopHistory.confirmedFriends.contains { userData in
                userData.froopUserID == currentUserUid
            }
            
            // Return true only if both conditions are met
            return isActiveTime && isConfirmed
        }
        
        if !activeFroops.isEmpty {
            currentFilteredFroopHistory = activeFroops
            appState = .active
        } else {
            appState = .passive
        }
        
        PrintControl.shared.printAppState("AppState: \(appState), Active Froops Count: \(activeFroops.count)")
    }
    
    func updateOnboardingState() {
        showHomeRibbon = !onboardingData.homeOnboarding
        print("🔆 homeOnboarding: \(!onboardingData.homeOnboarding)")
        print("🔆 showHomeRibbon: \(showHomeRibbon)")
        
        showFriendsRibbon = !onboardingData.friendsOnboarding
        print("🔆 friendsOnboarding: \(!onboardingData.friendsOnboarding)")
        print("🔆 showFriendsRibbon: \(showFriendsRibbon)")
        
        showProfileRibbon = !onboardingData.myProfileOnboarding
        print("🔆 myProfileOnboarding: \(!onboardingData.myProfileOnboarding)")
        print("🔆 showProfileRibbon: \(showProfileRibbon)")
        
        onboardingDataLoaded = true
    }
    
    func updateRibbonState(for viewID: OnboardingViewType) {
        print("🎯 Starting updateRibbonState")
        print("🎯 Current Firestore state - homeOnboarding: \(onboardingData.homeOnboarding)")
        
        DispatchQueue.main.async {
            switch viewID {
                case .home:
                    // IMPORTANT: Check Firestore state first
                    if self.onboardingData.homeOnboarding {
                        // If onboarding is complete in Firestore, don't show anything
                        self.showHomeRibbon = false
                        self.showHomeOnboarding = false
                        self.hasRespondedToRibbon = false
                        print("🎯 Onboarding complete, hiding all views")
                    } else {
                        // If not complete, show ribbon unless they've responded
                        if !self.hasRespondedToRibbon {
                            self.showHomeRibbon = true
                            self.showHomeOnboarding = false
                        }
                        print("🎯 Onboarding incomplete, showing appropriate view")
                    }
                case .friends:
                    if self.onboardingData.friendsOnboarding {
                        self.showFriendsRibbon = false
                        self.showFriendsOnboarding = false
                        self.hasRespondedToRibbon = false
                    } else {
                        if !self.hasRespondedToRibbon {
                            self.showFriendsRibbon = true
                            self.showFriendsOnboarding = false
                        }
                    }
                default:
                    break
            }
            
            print("🎯 Final State:")
            print("🎯 showHomeRibbon: \(self.showHomeRibbon)")
            print("🎯 showHomeOnboarding: \(self.showHomeOnboarding)")
            print("🎯 hasRespondedToRibbon: \(self.hasRespondedToRibbon)")
        }
    }
    
    
    func updateOnboardingState(for viewID: OnboardingViewType) {
        currentViewID = viewID
        showFace = true
        showFaceText = true
        
        switch viewID {
            case .home:
                showHomeOnboarding = !OnboardingData.shared.homeOnboarding
            case .friends:
                showFriendsOnboarding = !OnboardingData.shared.friendsOnboarding
            case .profile:
                showMyProfileOnboarding = !OnboardingData.shared.myProfileOnboarding
                // Add more cases as needed
            default:
                break
        }
    }
    
    func stopTimer() {
        // Invalidate the timer
        timer?.invalidate()
        timer = nil
    }
    
    func trackUserLocation(_ user: UserData) {
        PrintControl.shared.printAppState("trackUserLocation firing!")
        // Cancel the previous subscription if it exists
        selectedUserCoordinateCancellable?.cancel()
        
        PrintControl.shared.printAppState("Sending coordinate \(user.coordinate)")
        centerCoordinate = user.coordinate
        
        // Create a new subscription for the user's coordinate
        selectedUserCoordinateCancellable = user.$coordinate.sink { [weak self] newCoordinate in
            self?.centerCoordinate = newCoordinate
        }
    }
    
    func findFroopById(froopId: String, completion: @escaping (Bool) -> Void) {
        PrintControl.shared.printAppState("findFroopById firing!")
        var found = false
        PrintControl.shared.printAppState("Starting findFroopById for froopId: \(froopId)")
        
        for froopHistory in currentFilteredFroopHistory {
            if froopHistory.froop.froopId == froopId {
                inProgressFroop = froopHistory
                found = true
                PrintControl.shared.printAppState("FroopId found: \(froopId)")
                break
            }
        }
        
        if !found {
            PrintControl.shared.printAppState("FroopId not found: \(froopId)")
        }
        completion(found)
    }
    
    func fetchHostData(uid: String, completion: @escaping (Result<UserData, Error>) -> Void) {
        DispatchQueue.global().async { //
            PrintControl.shared.printAppState("Starting fetchHostData for uid: \(uid)")
            self.getUserData(uid: uid) { [weak self] result in
                switch result {
                    case .success(let userData):
                        DispatchQueue.main.async {
                            self?.activeHostData = userData
                            PrintControl.shared.printAppState("Successfully fetched host data for uid: \(uid)")
                            completion(.success(userData))
                        }
                    case .failure(let error):
                        DispatchQueue.main.async {
                            PrintControl.shared.printAppState("Failed to fetch host data for uid: \(uid). Error: \(error.localizedDescription)")
                            completion(.failure(error))
                        }
                }
            }
        }
    }
    
    func fetchAllFroopTypes() {
        PrintControl.shared.printAppState("fetchAllFroopTypes firing!")
        let froopTypesRef = db.collection("froopTypes")
        
        froopTypesRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                PrintControl.shared.printErrorMessages("Error fetching froop types: \(error.localizedDescription)")
            } else if let querySnapshot = querySnapshot {
                let froopTypesArray = querySnapshot.documents.compactMap { document -> (Int, String)? in
                    if let typeName = document.get("name") as? String,
                       let typeId = Int(document.documentID) {
                        return (typeId, typeName)
                    } else {
                        return nil
                    }
                }
                self.froopTypes = Dictionary(uniqueKeysWithValues: froopTypesArray)
                //print(self.froopTypes.description)
            }
        }
    }
    
    func getUserData(uid: String, completion: @escaping (Result<UserData, Error>) -> Void) {
        let userDataGroup = DispatchGroup()
        
        guard !uid.isEmpty else {
            completion(.failure(NSError(domain: "UserDataError", code: -2, userInfo: [NSLocalizedDescriptionKey: "UID is empty"])))
            return
        }
        userDataGroup.enter()
        
        let userDocumentRef = self.db.collection("users").document(uid)
        
        userDocumentRef.getDocument { (snapshot, error) in
            defer { userDataGroup.leave() } // This ensures leave() is called no matter how we exit the block
            
            if let error = error {
                completion(.failure(error))
            } else {
                if let snapshot = snapshot, let data = snapshot.data(), let userData = UserData(dictionary: data) {
                    completion(.success(userData))
                    
                } else {
                    let error = NSError(domain: "UserDataError", code: -1, userInfo: [NSLocalizedDescriptionKey: "User document not found or failed to parse"])
                    completion(.failure(error))
                }
            }
        }
        userDataGroup.notify(queue: .main) {
        }
    }
    
    // Add the updateActiveFroop() function
    
    func updateMapView() {
        PrintControl.shared.printAppState("updateMapView firing!")
        DispatchQueue.main.async { [weak self] in
            self?.onUpdateMapView?()
        }
    }
    
    func fetchUserCoordinate(for froopUserID: String, completion: @escaping (Result<CLLocationCoordinate2D, Error>) -> Void) {
        PrintControl.shared.printAppState("fetchUserCoordinate firing!")
        let db = FirebaseServices.shared.db
        let userDocumentRef = db.collection("users").document(froopUserID)
        
        userDocumentRef.getDocument { (document, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                if let document = document, document.exists,
                   let data = document.data(),
                   let currentLocation = data["currentLocation"] as? [String: Any],
                   let latitude = currentLocation["latitude"] as? CLLocationDegrees,
                   let longitude = currentLocation["longitude"] as? CLLocationDegrees {
                    
                    let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    completion(.success(coordinate))
                } else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to parse user document or coordinate not found."])))
                }
            }
        }
    }
}



