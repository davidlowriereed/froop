//
//  ChatInputView.swift
//  FroopProof
//
//  Created by David Reed on 1/17/24.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import Combine
import UIKit


struct ChatInputView: View {
    @Binding var messageText: String
    @ObservedObject var notificationsManager = NotificationsManager.shared
    @ObservedObject var chatManager = GlobalChatNotificationsManager.shared
    let conversationId: String = GlobalChatNotificationsManager.shared.currentConversation?.conversation.id ?? ""
    var onSend: () -> Void
    @FocusState private var isInputActive: Bool

    var body: some View {
        ZStack {
            
            
            HStack {
                TextField("Type a message...", text: $messageText, onEditingChanged: { isEditing in
                    notificationsManager.chatEntered = isEditing
                }, onCommit: {
                        self.sendAction()
                        notificationsManager.chatEntered = false
                        messageText = ""
                })
                .focused($isInputActive)
                .font(.system(size: 16))
                .foregroundColor(.primary)
                .padding(10)
                .background(Color(.clear))
                .cornerRadius(10)
                .padding(.leading, 30)
                .frame(width: UIScreen.main.bounds.width - 75)
                .onAppear {
                    withAnimation(.smooth) {
                        self.isInputActive = true
                    }
                }
                
                Button {
                    if !notificationsManager.conversationsAndMessages.isEmpty {
                        PrintControl.shared.printNotifications("froopConversationsAndMessages \(notificationsManager.conversationsAndMessages[0].id)")
                    } else {
                        // Handle the case where there are no conversations
                        PrintControl.shared.printNotifications("No conversations available")
                    }
                    self.sendAction()
                    notificationsManager.chatEntered = false
                    messageText = ""
                    
                } label: {
                    ZStack {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 35))
                            .fontWeight(.thin)
                            .frame(minWidth: 15, maxWidth: 15)
                            .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255))
                            .padding()
                        Image(systemName: "paperplane.circle")
                            .font(.system(size: 35))
                            .fontWeight(.thin)
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                .padding(.trailing)
                .frame(minHeight: 20, maxHeight: 20)
                .opacity(messageText == "" ? 0.0 : 1.0)
            }
            .padding(.bottom, 35)
            
            RoundedRectangle(cornerRadius: 25)
                .strokeBorder(Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.5), lineWidth: 1) // Border inside the shape
                .foregroundColor(.white)
//                .background(Color.white.opacity(0.75)) // Apply the opacity to the background color
                .frame(width: UIScreen.main.bounds.width - 30, height: 40)
                .offset(y: -17)
            
            
        }
    }
    
    private func sendAction() {
        let currentMessageText = messageText // Capture the current message text
        guard !currentMessageText.isEmpty else {
            print("Message text is empty, not sending.")
            return
        }
        self.chatManager.postMessage(content: currentMessageText, conversationId: chatManager.conversationId, toUserId: chatManager.otherUserId, froopId: nil)
        // Reset input field and close chat entry if needed
        DispatchQueue.main.async {
            self.notificationsManager.chatEntered = false
            self.messageText = ""
            
            
        }
    }
}
