//
//  ChatCardView.swift
//  FroopProof
//
//  Created by David Reed on 11/19/23.
//

import SwiftUI
import Kingfisher

struct GlobalChatCardView: View {
    @ObservedObject var chatManager = GlobalChatNotificationsManager.shared
    var conversationAndMessages: ConversationAndMessages
    @Binding var chatViewOpen: Bool
    @Binding var selectedFriend: UserData
    
    var body: some View {
        VStack {
            ZStack {
                Rectangle()
                    .frame(width: UIScreen.screenWidth, height: 80)
                    .foregroundColor(Color(red: 250/255, green: 250/255, blue: 250/255))
                HStack {
                    KFImage(URL(string: otherUserProfileImageUrl))
                        .resizable()
                        .scaledToFill()
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
                            .lineLimit(2)
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
            chatManager.conversationId = conversationAndMessages.conversation.id 
            chatManager.otherUserId = selectedFriend.froopUserID
            chatManager.selectedFriend = selectedFriend
            selectedFriend = otherUser ?? UserData()
            print("🔆🔆🔆notificationsManager's currentConverstion id:  \(chatManager.currentConversation?.id ?? "NO ID FOUND")")
            print("🔆🔆🔆notificationsManager's currentConverstion id:  \(chatManager.conversationId)")

            chatViewOpen = true
            print("😡Selected User Name: \(otherUser?.firstName ?? "😡Didn't Work")")
//            chatManager.holderCon = conversationAndMessages
        }
    }
    
    var lastMessageText: String {
           let currentUserUID = FirebaseServices.shared.uid
           let otherMessages = conversationAndMessages.messages.filter { $0.senderId != currentUserUID }
           return otherMessages.sorted { $0.timestamp > $1.timestamp }.first?.text ?? "no messages..."
       }
    
    var lastMessageTimestamp: String {
            let lastMessage = getLastMessage()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "h:mm a" // e.g., 12:30 PM
            return dateFormatter.string(from: lastMessage.timestamp)
        }
    
    var otherUserName: String {
        let conversation = conversationAndMessages.conversation
        if let otherUserId = getOtherUserId(from: conversation),
           let otherUserData = findUserData(with: otherUserId) {
            return otherUserData.firstName + " " + otherUserData.lastName
        } else {
            return "" // default URL or placeholder
        }
    }

    var otherUserProfileImageUrl: String {
        let conversation = conversationAndMessages.conversation
        if let otherUserId = getOtherUserId(from: conversation),
           let otherUserData = findUserData(with: otherUserId) {
            return otherUserData.profileImageUrl
        } else {
            return "" // default URL or placeholder
        }
    }
    
    var otherUserfroopUserID: String {
        let conversation = conversationAndMessages.conversation
        if let otherUserId = getOtherUserId(from: conversation),
           let otherUserData = findUserData(with: otherUserId) {
            return otherUserData.froopUserID
        } else {
            return "" // default URL or placeholder
        }
    }
    
    var otherUser: UserData? {
        let conversation = conversationAndMessages.conversation
        if let otherUserId = getOtherUserId(from: conversation) {
            return findUserData(with: otherUserId)
        } else {
            return nil // Return nil if the other user is not found
        }
    }
    
    private func getLastMessage() -> Message {
           let currentUserUID = FirebaseServices.shared.uid
           let otherMessages = conversationAndMessages.messages.filter { $0.senderId != currentUserUID }
        return otherMessages.sorted { $0.timestamp > $1.timestamp }.first ?? Message(dictionary: [:], id: "")
       }

    private func getOtherUserId(from conversation: Conversation) -> String? {
        let currentUserUID = FirebaseServices.shared.uid
        return conversation.userIds.first(where: { $0 != currentUserUID })
    }

    private func findUserData(with uid: String) -> UserData? {
        let confirmedFriends = MyData.shared.myFriends
        return confirmedFriends.first(where: { $0.froopUserID == uid })
    }
}



