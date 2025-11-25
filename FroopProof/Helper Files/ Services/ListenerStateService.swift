//
//  ListenerStateService.swift
//  FroopProof
//
//  Created by David Reed on 10/16/23.
//

import FirebaseFirestore
import Combine

class ListenerStateService: ObservableObject {
    static let shared = ListenerStateService()
    var listenersActiveSubject = PassthroughSubject<Bool, Never>()
    var froopUpdateSubject = PassthroughSubject<Froop, Never>()
    private var timers: [String: Timer] = [:]
    private let queue = DispatchQueue(label: "com.FroopProof.ListenerStateService.queue")


    @Published var froops: [Froop] = []

    @Published var listenersActive = true {
        didSet {
            listenersActiveSubject.send(listenersActive)
        }
    }
    
    ///Listeners
    
    // Dictionary to store listeners by their keys
    private var listeners: [String: ListenerRegistration] = [:] {
        didSet {
            // Print for debugging
            PrintControl.shared.printListeners("Listeners updated. Count: \(listeners.count)")
        }
    }
    
    // Check if the listener for a given key should be created
    func shouldCreateListener(forKey key: String) -> Bool {
        var shouldCreate = false
        queue.sync {
            shouldCreate = listeners[key] == nil
        }
        return shouldCreate
    }
    
    // Add a new listener for a given key
    func addListener(_ listener: ListenerRegistration, forKey key: String) {
        queue.async {
            // Remove existing listener if it exists
            if let existingListener = self.listeners[key] {
                existingListener.remove()
            }
            self.listeners[key] = listener
        }
    }
    
    // Get a listener for a given key
    func getListener(forKey key: String) -> ListenerRegistration? {
        var listener: ListenerRegistration?
        queue.sync {
            listener = listeners[key]
        }
        return listener
    }
    
    // Remove a listener for a given key
    func removeListener(forKey key: String) {
        queue.async {
            self.listeners[key]?.remove()
            self.listeners.removeValue(forKey: key)
        }
    }
    
    func deactivateListeners() {
        removeListener(forKey: "froopsListener")
        listenersActiveSubject.send(false)
    }
    
    func activateListeners() {
        listenToFroops()
        listenersActiveSubject.send(true)
    }
    
    func listenToFroops() {
        let listenerKey = "froopsListener"
        
        // Check if we should create a new listener for the entire collection
        if shouldCreateListener(forKey: listenerKey) {
            // Start listening to Froops collection
            let listener = Firestore.firestore().collection("froops").addSnapshotListener { (snapshot, error) in
                guard let documents = snapshot?.documents else {
                    PrintControl.shared.printListeners("Error fetching documents: \(error!)")
                    return
                }
                
                // Map the Firestore documents to Froop objects
                let newFroops = documents.compactMap { (document) -> Froop? in
                    return Froop(dictionary: document.data())
                }
                
                // Update our published froops property with the new values
                DispatchQueue.main.async {
                    self.froops = newFroops
                    
                    // After updating the froops list, listen to each Froop individually
                    for froop in self.froops {
                        // Adjust this line to include the froop host as an argument
                        self.listenToIndividualFroop(froopId: froop.froopId, froopHost: froop.froopHost)
                    }
                }
            }
            
            // Store the new listener for the entire collection
            addListener(listener, forKey: listenerKey)
        }
    }
    
    func listenToIndividualFroop(froopId: String, froopHost: String) {
        let listenerKey = "froop_\(froopId)"

        // Only create a listener if one doesn't exist for the given Froop ID
        if shouldCreateListener(forKey: listenerKey) {
            let docRef = Firestore.firestore().collection("users").document(froopHost)
                          .collection("myFroops").document(froopId)
            
            let listener = docRef.addSnapshotListener { (documentSnapshot, error) in
                guard let document = documentSnapshot, let data = document.data() else {
                    PrintControl.shared.printListeners("Error fetching or processing document: \(String(describing: error))")
                    return
                }
                
                let updatedFroop = Froop(dictionary: data)
                self.froopUpdateSubject.send(updatedFroop ?? Froop(dictionary: [:]) ?? Froop.emptyFroop())
            }

            // Store the listener by its key
            addListener(listener, forKey: listenerKey)
        }
    }
    
    func registerListener(_ listener: ListenerRegistration, forKey key: String) {
        if shouldCreateListener(forKey: key) {
            listeners[key] = listener
        }
    }
    
    func decommissionAllListeners() {
        for key in listeners.keys {
            removeListener(forKey: key)
        }
    }
    
    
    
    ///Timers
    
    // Start a new timer with a given key
    func startTimer(forKey key: String, timeInterval: TimeInterval, repeats: Bool, block: @escaping (Timer) -> Void) {
        // Invalidate and remove any existing timer with the same key
        timers[key]?.invalidate()
        timers[key] = nil
        
        // Create and store the new timer
        let timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: repeats) { timer in
            block(timer)
        }
        RunLoop.current.add(timer, forMode: .common)
        timers[key] = timer
    }
    
    // Invalidate and remove a timer with a given key
    func invalidateTimer(forKey key: String) {
        timers[key]?.invalidate()
        timers[key] = nil
    }
    
    // Invalidate and remove all timers
    func invalidateAllTimers() {
        for key in timers.keys {
            invalidateTimer(forKey: key)
        }
    }
    
    // Function to deactivate all listeners and timers
    func deactivateAll() {
        decommissionAllListeners()
        invalidateAllTimers()
        FirebaseServices.shared.removeAuthStateDidChangeListener()
    }
}
