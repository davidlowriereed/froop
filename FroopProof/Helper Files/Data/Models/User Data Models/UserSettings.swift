//
//  mySettings.swift
//  FroopProof
//
//  Created by David Reed on 8/3/23.
//

import SwiftUI
import UIKit
import Firebase
import FirebaseFirestore
 
import EventKit
import Photos
import CoreLocation

class UserSettings: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = UserSettings()
    @Published var calendarPermission: Bool = false
    @Published var photoLibraryPermission: Bool = false
    @Published var locateNowPermission: Bool = false
    @Published var trackWhileUsingPermission: Bool = false
    @Published var trackAlwaysPermission: Bool = false
    @Published var textMessagingPermission: Bool = false
    @Published var alertsPermission: Bool = false
    @Published var notificationsPermission: Bool = false

    private var locationManager: CLLocationManager?
  
    override init() {
        super.init()
        checkAllPermissions()
    }
    
    func checkAllPermissions() {
        checkPhotoLibraryPermission()
        checkCalendarPermission()
//        checkLocationPermissions()
        checkNotificationPermissions()
    }
    
    func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        self.photoLibraryPermission = (status == .authorized)
    }
    
    func checkCalendarPermission() {
        let status = EKEventStore.authorizationStatus(for: .event)
        self.calendarPermission = (status == .authorized)
    }
    
    func checkLocationPermissions() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        let status = locationManager?.authorizationStatus

        switch status {
        case .authorizedWhenInUse:
            self.locateNowPermission = true
            self.trackWhileUsingPermission = true
            self.trackAlwaysPermission = false
        case .authorizedAlways:
            self.locateNowPermission = true
            self.trackWhileUsingPermission = true
            self.trackAlwaysPermission = true
        default:
            self.locateNowPermission = false
            self.trackWhileUsingPermission = false
            self.trackAlwaysPermission = false
        }
    }
  
    func checkNotificationPermissions() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.notificationsPermission = settings.authorizationStatus == .authorized

                // Check for specific notification settings
                switch settings.alertSetting {
                case .enabled:
                    // The app is authorized to schedule user notifications.
                        PrintControl.shared.printSettings("Alert setting enabled")
                case .disabled:
                    // The app is not authorized to schedule user notifications.
                        PrintControl.shared.printSettings("Alert setting disabled")
                case .notSupported:
                    // The application does not support this notification type.
                        PrintControl.shared.printSettings("Not supported")
                @unknown default:
                        PrintControl.shared.printSettings("Unknown alert setting")
                }

                switch settings.soundSetting {
                case .enabled:
                        PrintControl.shared.printSettings("Sound setting enabled")
                case .disabled:
                        PrintControl.shared.printSettings("Sound setting disabled")
                case .notSupported:
                        PrintControl.shared.printSettings("Not supported")
                @unknown default:
                        PrintControl.shared.printSettings("Unknown sound setting")
                }

                switch settings.badgeSetting {
                case .enabled:
                        PrintControl.shared.printSettings("Badge setting enabled")
                case .disabled:
                        PrintControl.shared.printSettings("Badge setting disabled")
                case .notSupported:
                        PrintControl.shared.printSettings("Not supported")
                @unknown default:
                        PrintControl.shared.printSettings("Unknown badge setting")
                }
            }
        }
    }
    func openAppSettings() {
        if let appSettings = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
        }
    }
    func requestCalendarAccess(completion: @escaping (Bool) -> Void) {
        let eventStore = EKEventStore()
        
        eventStore.requestAccess(to: .event) { (granted, error) in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    func requestPhotoLibraryAuthorization(completion: @escaping (Bool) -> Void) {
        PrintControl.shared.printMediaManager("-MediaManager: Function: requestPhotoLibraryAuthorization is firing!")
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                completion(status == .authorized)
            }
        }
    }
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                PrintControl.shared.printErrorMessages("Error requesting notification permission: \(error)")
            } else {
                PrintControl.shared.printAppStateSetupListener("Notification permission granted: \(granted)")
            }
        }
    }
}
