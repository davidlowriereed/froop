//
//  NotificationPermissionView.swift
//  FroopProof
//
//  Created by David Reed on 10/15/24.
//

import SwiftUI

struct NotificationPermissionView: View {
    var moveToNext: () -> Void
    var moveToPrevious: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "bell.badge")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("Enable Notifications")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Stay updated with Froop invitations, messages, and important updates.")
                .multilineTextAlignment(.center)
                .padding()
            
            Button(action: requestNotificationPermission) {
                Text("Enable Notifications")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            
            Button(action: { moveToNext() }) {
                Text("Maybe Later")
                    .foregroundColor(.gray)
            }
        }
        .padding()
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    print("Notification permission granted")
                } else {
                    print("Notification permission denied")
                }
                moveToNext()
            }
        }
    }
}
