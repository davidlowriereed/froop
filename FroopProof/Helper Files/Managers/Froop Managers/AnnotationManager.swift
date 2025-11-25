//
//  AnnotationManager.swift
//  FroopProof
//
//  Created by David Reed on 2/19/24.
//


import Foundation
import SwiftUI
import Combine
import MapKit

class AnnotationManager: ObservableObject {
    static let shared = AnnotationManager()
    @Published var guestAnnotations: [UserData] = []
    private var userDataSubscriptions = [String: AnyCancellable]()
    private var cancellables = Set<AnyCancellable>()
    @Published var currentPinIndex: Int = 0
    @Published var currentGuestIndex: Int = 0
    @Published var currentGuestCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
    @Published var trackingUser: Bool = false

    lazy var mapManager: MapManager = {
        MapManager.shared
    }()
    
    init() {
        setupUserDataListeners()
//        setupDebugTimer()
    }
    
    
    private func setupUserDataListeners() {
        AppStateManager.shared.$currentFilteredFroopHistory
            .map { $0.first?.confirmedFriends ?? [] }
            .assign(to: \.guestAnnotations, on: self)
            .store(in: &cancellables)
    }
    
    func zoomToLocation(_ coordinate: CLLocationCoordinate2D) {
        print("ZOOM TO LOCATION FIRING!")
        print(String(describing: coordinate))
        
        let newRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        withAnimation(.easeInOut(duration: 0.5)) {
            mapManager.cameraPosition = .region(newRegion)
        }
    }
    
    func zoomToGuestLocation(_ coordinate: CLLocationCoordinate2D) {
        print("ZOOM TO LOCATION FIRING!")
        print(String(describing: coordinate))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let newRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
            withAnimation(.easeInOut(duration: 0.5)) {
                self.mapManager.cameraPosition = .region(newRegion)
            }
        }
    }
    
    func manuallyUpdateAnnotations() {
        let updatedGuests = guestAnnotations.map { guest -> UserData in
            if let updatedGuest = AppStateManager.shared.currentFilteredFroopHistory.first?.confirmedFriends.first(where: { $0.froopUserID == guest.froopUserID }) {
                
                // Assuming you want to update the coordinate and potentially other fields
                guest.coordinate = updatedGuest.coordinate
                // Add any other property updates here
            }
            return guest
        }
        DispatchQueue.main.async {
            print("♏️♏️ \(updatedGuests)")
            self.guestAnnotations = updatedGuests
        }
    }
    
    func refreshGuestAnnotations() {
        // Assuming AppStateManager has a method or property to access the current guest list with updated UserData
        let updatedGuests = AppStateManager.shared.currentFilteredFroopHistory.first?.confirmedFriends ?? []
        print("♏️ \(updatedGuests)")
        // Iterate through the local annotations to update their details
        for (index, guestAnnotation) in guestAnnotations.enumerated() {
            if let updatedGuest = updatedGuests.first(where: { $0.froopUserID == guestAnnotation.froopUserID }) {
                // Update the properties you're interested in, such as coordinate
                guestAnnotations[index].coordinate = updatedGuest.coordinate
                // Add any other property updates here
            }
        }
        
        // Notify the UI that the annotations have been updated
        // This can be as simple as reassigning the array to itself if all else fails
        self.guestAnnotations = self.guestAnnotations.map { $0 }
    }
    
    func updateAnnotations(with newAnnotations: [UserData]) {
        print("🍓 Updating annotations: \(newAnnotations)")
        self.guestAnnotations = newAnnotations
    }
    
    func addGuest(guest: UserData) {
        updateAnnotations(with: guestAnnotations + [guest])
    }
    
    func cycleThroughGuests() {
        // This is a simplified example. You'll adjust based on your actual logic for cycling through guests.
        let nextGuests = guestAnnotations.shuffled() // Or any logic to reorder
        updateAnnotations(with: nextGuests)
    }
    
    func cycleToNextPin() {
        guard !MapManager.shared.froopPins.isEmpty else { return }
        currentPinIndex = (currentPinIndex + 1) % MapManager.shared.froopPins.count
    }

    func cycleToNextGuest() {
        guard !guestAnnotations.isEmpty else { return }
        currentGuestIndex = (currentGuestIndex + 1) % guestAnnotations.count
    }
    
}
