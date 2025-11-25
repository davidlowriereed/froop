//
//  UserNotificationsController.swift
//  FroopProof
//
//  Created by David Reed on 4/11/23.
//

import SwiftUI
import UserNotifications

class UserNotificationsController: ObservableObject {
    
    func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                PrintControl.shared.printNotifications("Notification permission granted.")
            } else {
                PrintControl.shared.printNotifications("Notification permission denied.")
            }
        }
    }
    
    func scheduleFroopReminderNotification(froopId: String, froopName: String, froopStartTime: Date) {
        let notificationId = "\(froopId)_froop_reminder_notification"

        // Remove any existing notification with the same ID
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationId])

        // Schedule a new notification
        let content = UNMutableNotificationContent()
        content.title = "Your Froop is starting soon"
        content.body = "Your Froop: \(froopName) will start in 30 minutes."
        content.sound = .default

        let triggerTime = froopStartTime.addingTimeInterval(-30 * 60) // 30 minutes before Froop start time
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: triggerTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(identifier: notificationId, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                PrintControl.shared.printErrorMessages("Error scheduling Froop reminder notification: \(error.localizedDescription)")
            } else {
                PrintControl.shared.printNotifications("Froop reminder notification scheduled.")
            }
        }
    }
    
    
    func scheduleLocationTrackingNotification(froopId: String, froopName: String, froopStartTime: Date) {
        let notificationId = "\(froopId)_location_tracking_notification"
        
        // Remove any existing notification with the same ID
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationId])
        
        // Schedule a new notification
        let content = UNMutableNotificationContent()
        content.title = "Start location tracking for your Froop"
        content.body = "It's time to start tracking your location for your Froop: \(froopName)."
        content.sound = .default
        
        let triggerTime = froopStartTime.addingTimeInterval(-1 * 60 * 60) // 4 hours before Froop start time
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: triggerTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(identifier: notificationId, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                PrintControl.shared.printErrorMessages("Error scheduling location tracking notification: \(error.localizedDescription)")
            } else {
                PrintControl.shared.printNotifications("Location tracking notification scheduled.")
            }
        }
    }
    
        
    
}
