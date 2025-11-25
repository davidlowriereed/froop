//
//  FroopGroupChatInputView.swift
//  FroopProof
//
//  Created by David Reed on 1/17/24.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import Combine
import UIKit

struct FroopGroupChatInputView: View {
    @ObservedObject var notificationsManager = NotificationsManager.shared
    @ObservedObject var chatManager = FroopGroupChatNotificationsManager.shared
    var onSend: () -> Void
    @FocusState private var isInputActive: Bool
    var appStateManager: AppStateManager {
        return AppStateManager.shared
    }
    
    var body: some View {
        ZStack {
                Rectangle()
                    .frame(height: 50)
                    .foregroundColor(.clear)
                    .background(.ultraThinMaterial)
                    .ignoresSafeArea()
                    .offset(y: 0)
            HStack {
                TextField("Type a message...", text: $chatManager.messageText, onEditingChanged: { isEditing in
                    notificationsManager.chatEntered = isEditing
                }, onCommit: {
                    self.sendFroopAction()
                    chatManager.chatEntered = false
                    chatManager.messageText = ""
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
                    self.sendFroopAction()
                    chatManager.chatEntered = false
                    chatManager.messageText = ""
                    
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
                .opacity(chatManager.messageText == "" ? 0.0 : 1.0)
            }
            
            
            
            RoundedRectangle(cornerRadius: 25)
                .strokeBorder(Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.5), lineWidth: 1) // Border inside the shape
                .foregroundColor(.white)
            //                .background(Color.white.opacity(0.75)) // Apply the opacity to the background color
                .frame(width: UIScreen.main.bounds.width - 30, height: 40)
            
            
        }
    }
    
    private func sendFroopAction() {
        chatManager.sendGroupMessage(content: chatManager.messageText)
        //        chatManager.chatEntered = false
        chatManager.messageText = ""
        print("Message Count = \(String(describing: appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froopGroupConversationAndMessages.messages.count ?? 0))")
    }
}
