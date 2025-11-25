//
//  NotificationsSheetView.swift
//  FroopProof
//
//  Created by David Reed on 10/3/23.
//

import SwiftUI

struct NotificationsSheetView: View {
    @ObservedObject var dataController = DataController.shared
    var body: some View {
        Button("Show AirDrop Notification") {
            UIApplication.shared.inAppNotification(adaptForDynamicIsland: DataController.shared.toggleDynamicIsland, timeout: 4, swipeToClose: true) {
                HStack {
                    Image(systemName: "wifi")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                    
                    VStack(alignment: .leading, spacing: 2, content: {
                        Text("AirDrop")
                            .font(.caption.bold())
                            .foregroundColor(.white)
                        
                        Text("User Name")
                            .textScale(.secondary)
                            .foregroundColor(.gray)
                    })
                    .padding(.top, 20)
                    
                    Spacer()
                }
                .padding(15)
                .background {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color(red: 50/255, green: 46/255, blue: 62/255))
                }
            }
        }
        .buttonStyle(.bordered)
        .buttonBorderShape(.roundedRectangle(radius: 10))
        .tint(.red)
    }
}


