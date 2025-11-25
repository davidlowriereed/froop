//
//  ChatCardView.swift
//  FroopProof
//
//  Created by David Reed on 11/19/23.
//

import SwiftUI
import Kingfisher

struct FroopChatCardView: View {
    @ObservedObject var chatManager = FroopChatNotificationsManager.shared
    
    var froopConversationAndMessages: ConversationAndMessages
    var appStateManager: AppStateManager {
        return AppStateManager.shared
    }
    
    @Binding var chatViewOpen: Bool
    @Binding var selectedConversation: UserData
    @Binding var selectedChatType: ChatType
    
    var body: some View {
        VStack {
            ZStack {
                Rectangle()
                    .frame(width: UIScreen.screenWidth, height: 80)
                    .foregroundColor(Color(red: 250/255, green: 250/255, blue: 250/255))
                HStack {
                    KFImage(URL(string: otherUserProfileImageUrl))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                        .padding(.leading, 15)
                    VStack (alignment: .leading) {
                        HStack {
                            Text(otherUserName)
                                .font(.system(size: 16))
                                .fontWeight(.regular)
                                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                            Spacer()
                            Text(lastMessageTimestamp)
                                .font(.system(size: 16))
                                .fontWeight(.regular)
                                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)

                        }
                        Text(lastMessageText)
                            .font(.system(size: 18))
                            .fontWeight(.light)
                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                            .padding(.top, 3)
                    }
                    .padding(.leading, 10)
                    .padding(.trailing, 5)
                    Spacer()
                }
            }
        }
        .onTapGesture {
            selectedConversation = otherUser ?? UserData()
            selectedChatType = .oneOnOne
            FroopManager.shared.chatViewOpen = true
            chatManager.holderCon = froopConversationAndMessages
            print("Chat ID:  \(froopConversationAndMessages.id)")
            print("Conversation ID:  \(froopConversationAndMessages.conversation.id)")
            print("HolderCon Chat ID:  \(chatManager.holderCon.id)")
            print("HolderCon Conversation ID:  \(chatManager.holderCon.conversation.id)")

        }
    }
    
    var lastMessageText: String {
           let currentUserUID = FirebaseServices.shared.uid
           let otherMessages = froopConversationAndMessages.messages.filter { $0.senderId != currentUserUID }
           return otherMessages.sorted { $0.timestamp > $1.timestamp }.first?.text ?? "no messages..."
       }
    
    var lastMessageTimestamp: String {
            let lastMessage = getLastMessage()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "h:mm a" // e.g., 12:30 PM
            return dateFormatter.string(from: lastMessage.timestamp)
        }
    
    var otherUserName: String {
        let conversation = froopConversationAndMessages.conversation
        if let otherUserId = getOtherUserId(from: conversation),
           let otherUserData = findUserData(with: otherUserId) {
            return otherUserData.firstName + " " + otherUserData.lastName
        } else {
            return "" // default URL or placeholder
        }
    }

    var otherUserProfileImageUrl: String {
        let conversation = froopConversationAndMessages.conversation
        if let otherUserId = getOtherUserId(from: conversation),
           let otherUserData = findUserData(with: otherUserId) {
            return otherUserData.profileImageUrl
        } else {
            return "" // default URL or placeholder
        }
    }
    
    var otherUserfroopUserID: String {
        let conversation = froopConversationAndMessages.conversation
        if let otherUserId = getOtherUserId(from: conversation),
           let otherUserData = findUserData(with: otherUserId) {
            return otherUserData.froopUserID
        } else {
            return "" // default URL or placeholder
        }
    }
    
    var otherUser: UserData? {
        let conversation = froopConversationAndMessages.conversation
        if let otherUserId = getOtherUserId(from: conversation) {
            return findUserData(with: otherUserId)
        } else {
            return nil // Return nil if the other user is not found
        }
    }
    
    private func getLastMessage() -> Message {
           let currentUserUID = FirebaseServices.shared.uid
           let otherMessages = froopConversationAndMessages.messages.filter { $0.senderId != currentUserUID }
        return otherMessages.sorted { $0.timestamp > $1.timestamp }.first ?? Message(dictionary: [:], id: "")
       }

    private func getOtherUserId(from conversation: Conversation) -> String? {
        let currentUserUID = FirebaseServices.shared.uid
        print("Current User ID: \(currentUserUID)")
        print("User IDs in Conversation: \(conversation.userIds)")
        let otherUserId = conversation.userIds.first(where: { $0 != currentUserUID })
        print("OTHER USER ID: \(String(describing: otherUserId))")
        return otherUserId
    }

    private func findUserData(with uid: String) -> UserData? {
        let confirmedFriends = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.confirmedFriends ?? []
        return confirmedFriends.first(where: { $0.froopUserID == uid })
    }
}



