//
//  MessageRow.swift
//  FroopProof
//
//  Created by David Reed on 1/17/24.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import Combine
import UIKit


struct MessageRow: View {
    @ObservedObject var chatManager = FroopChatNotificationsManager.shared
    let message: Message
    let isCurrentUser: Bool
    
    var body: some View {
        ChatBubble(direction: isCurrentUser ? .right : .left) {
            Text(message.text)
                .frame(minWidth: 20)
                .font(.system(size: 14))
                .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                .foregroundColor(.white)
                .background(isCurrentUser ? Color(red: 249/255, green: 0/255, blue: 98/255) : Color(red: 0/255, green: 133/255, blue: 151/255).opacity(1))
        }
        .padding(.top, -30)
    }
}
