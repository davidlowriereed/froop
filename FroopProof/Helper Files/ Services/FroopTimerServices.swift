//
//  FroopTimerServices.swift
//  FroopProof
//
//  Created by David Reed on 5/30/23.
//

import Foundation
import SwiftUI
import UIKit
import ObjectiveC
import CoreLocation

class TimerServices: ObservableObject {
    static let shared = TimerServices()
    var timer: Timer?
    var annotationTimer: Timer?
    var shouldCallAppStateTransition = true
    var shouldCallupdateUserLocationInFirestore = true
    var shouldUpdateAnnotations = false
    var shouldUpdateFroopHistoryArray = true
    
    init() {
        startTimer()
    }
    
    var annotationManager: AnnotationManager {
        return AnnotationManager.shared
    }
    
    var firebaseServices: FirebaseServices {
        return FirebaseServices.shared
    }
   
    
    func startFroopHistoryArrayTimer() {
        
        guard firebaseServices.isAuthenticated else {
            return
        }
        
        self.annotationTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.annotationTimerFired), userInfo: nil, repeats: true)
    }
    
    func stopFroopHistoryArrayTimer() {
        // Invalidate the timer
        annotationTimer?.invalidate()
        annotationTimer = nil
    }
    
    @objc func froopHistoryArrayTimerFired() {
        // This function will be called every time the timer fires
      
        if shouldUpdateFroopHistoryArray {
            FroopManager.shared.createFroopHistoryArray { froopHistory in
                PrintControl.shared.printFroopHistoryServices("froopHistory created \(froopHistory.count)")
            }
        }
    }
    
    
    func startAnnotationTimer() {
        
        guard firebaseServices.isAuthenticated else {
            return
        }
        
        self.annotationTimer = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(self.annotationTimerFired), userInfo: nil, repeats: true)
    }
    
    func stopAnnotationTimer() {
        // Invalidate the timer
        annotationTimer?.invalidate()
        annotationTimer = nil
    }
    
    @objc func annotationTimerFired() {
        // This function will be called every time the timer fires
      
        if shouldUpdateAnnotations {
            annotationManager.manuallyUpdateAnnotations()
        }
    }
    
    func startTimer() {
        
        guard firebaseServices.isAuthenticated else {
            return
        }
        
        firebaseServices.checkDoc(userID: firebaseServices.uid) { (exists) in
            guard exists else {
                PrintControl.shared.printTime("User document does not exist.")
                return
            }
            // Invalidate any existing timer
            self.timer?.invalidate()
            
            // Create and schedule a new timer
            self.timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.timerFired), userInfo: nil, repeats: true)
        }
    }
    
    func stopTimer() {
        // Invalidate the timer
        timer?.invalidate()
        timer = nil
    }
    
    @objc func timerFired() {
        // This function will be called every time the timer fires
      
        if shouldCallupdateUserLocationInFirestore {
            LocationManager.shared.updateUserLocationInFirestore()
        }
    }
    
    func formatDate(for date: Date) -> String {
        let localDate = TimeZoneManager.shared.convertDateToLocalTime(for: date)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE MMMM dd, yyyy"
        return formatter.string(from: date)
    }
}
