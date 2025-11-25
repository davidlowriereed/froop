//
//  Message.swift
//  FroopProof
//
//  Created by David Reed on 7/22/23.


import SwiftUI
import Firebase
import FirebaseFirestore
import Combine
import UIKit


// The chat view
struct FroopChatView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var notificationsManager = NotificationsManager.shared
    @ObservedObject var chatManager = FroopChatNotificationsManager.shared
    @ObservedObject var friendRequestManager = FriendRequestManager.shared
    @State var conversationId: String = ""  // Added this line
    @State private var messageText: String = ""
    let chatPartnerUID: String
    @State private var keyboardHeight: CGFloat = 0
    @State private var keyboardHeightPublisher: AnyCancellable?
    @State var messages: [Message] = []
    @State private var chatListener: ListenerRegistration?
    @State private var isLoading = false


    var currentConversation: ConversationAndMessages? {
        return chatManager.froopConversationsAndMessages.first { froopConversationsAndMessages in
            froopConversationsAndMessages.conversation.userIds.contains(friendRequestManager.selectedFriend.froopUserID)
        }
    }
    
    let db = FirebaseServices.shared.db
    let uid = FirebaseServices.shared.uid
    
    init(chatPartnerUID: String) {
        self.chatPartnerUID = chatPartnerUID
        UITableView.appearance().separatorStyle = .none
    }
    
    var body: some View {
        ZStack {
//            VStack (spacing: 0) {
//                ScrollViewReader { proxy in
//                    ScrollView(showsIndicators: false) {
//                        VStack(spacing: 0) {
//                            ForEach(Array(messages.enumerated()), id: \.element) { idx, message in
//                                MessageRow(message: message, isCurrentUser: message.senderId == notificationsManager.uid)
//                                    .id(idx)
//                            }
//                            .onChange(of: messages) { oldValue, newValue in
//                                withAnimation(Animation.spring(response: 0.35, dampingFraction: 0.85, blendDuration: 0)) {
//                                    proxy.scrollTo(messages.count - 1, anchor: .bottom)
//                                }
//                                if let conversationAndMessages = currentConversation {
//                                    notificationsManager.markMessagesAsRead(in: conversationAndMessages)
//                                    notificationsManager.updateBadgeCountForNewMessage(in: conversationAndMessages)
//                                }
//                            }
//                        }
//                        .padding(.top, 10)
//                        .onAppear() {
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//                                proxy.scrollTo(messages.count - 1, anchor: .bottom)
//                            }
//                        }
//                        .onChange(of: keyboardHeight) { newValue, oldValue in
//                            withAnimation(Animation.spring(response: 0.35, dampingFraction: 0.85, blendDuration: 0)) {
//                                
//                                if newValue != oldValue {
//                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                                        proxy.scrollTo(messages.count - 1, anchor: .bottom)
//                                    }
//                                }
//                            }
//                        }
//                        .onChange(of: notificationsManager.chatEntered) { newValue, oldValue in
//                            if newValue {
//                                proxy.scrollTo(messages.count - 1, anchor: .bottom)
//
//                            }
//                        }
//                    }
//                    .onAppear {
//                        
//                        if let conversationAndMessages = currentConversation {
//                            notificationsManager.markMessagesAsRead(in: conversationAndMessages)
//                            notificationsManager.updateBadgeCountForNewMessage(in: conversationAndMessages)
//                        }
//                    }
//                    
////                    .border(.gray, width: 0.25)
//                    .background(.clear)
//                    .onReceive(notificationsManager.$conversationsAndMessages) { _ in
//                        DispatchQueue.main.async {
//                            proxy.scrollTo(messages.count - 1, anchor: .bottom)
//                        }
//                    }
//                }
//                .padding(.top, 75)
//                .padding(.horizontal, 10)
//                .padding(.bottom, 10)
//                .background(.clear)
//                
//                
//                FroopChatInputView(messageText: $messageText, selectedFriend: friendRequestManager.selectedFriend, conversationId: self.conversationId, onSend: {
//                    chatManager.sendFroopMessage(content: self.messageText, toUserId: friendRequestManager.selectedFriend.froopUserID)
//                }, selectedConversation: friendRequestManager.selectedFriend)
//                .padding(.bottom, notificationsManager.chatEntered ? 10 : 10) // Conditional padding
//            }
//            .padding(.bottom, keyboardHeight - 30) // Adjust bottom padding based on keyboard height
//            .padding(.top, UIScreen.screenHeight * 0.075)
//
//            .animation(.smooth(duration: 0.5), value: keyboardHeight) // Animate the padding change
//            .onAppear {
//                keyboardHeightPublisher = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
//                    .map { notification -> CGFloat in
//                        let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
//                        let screenHeight = UIScreen.main.bounds.height
//                        // Example: 50% of the screen height
//                        let desiredPercentage = 0.4
//                        let percentageHeight = min(keyboardHeight, screenHeight * desiredPercentage)
//                        return percentageHeight
//                    }
//                    .merge(with: NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
//                        .map { _ in CGFloat(0) }
//                    )
//                    .eraseToAnyPublisher()
//                    .sink { [self] newHeight in
//                        self.keyboardHeight = newHeight
//                    }
//            }
//            .onDisappear {
//                keyboardHeightPublisher?.cancel()
//            }
//            .ignoresSafeArea(.keyboard, edges: .bottom) // Allow the view to extend into the keyboard area

        }
        .ignoresSafeArea()
        .onAppear {
            chatManager.loadConversationsForCurrentUser()
            setupKeyboardHeightPublisher()
            self.setupConversation()
            conversationId = currentConversation?.conversation.id ?? ""
            let froopId = AppStateManager.shared.currentFilteredFroopHistory[safe: AppStateManager.shared.aFHI]?.froop.froopId ?? ""
            chatManager.setupActiveFroopChatsListener(froopId: froopId, currentUserUID: uid, selectedFriendUID: friendRequestManager.selectedFriend.froopUserID, conversationId: conversationId) { fetchedMessages in
                self.messages = fetchedMessages
            }
            
        }
        .onDisappear {
            keyboardHeightPublisher?.cancel()
        }
    }
    
    private func setupConversation() {
        guard currentConversation == nil else {
            self.conversationId = currentConversation?.conversation.id ?? ""
            return
        }
        
        isLoading = true
        
        chatManager.findOrCreateFroopConversation(with: friendRequestManager.selectedFriend.froopUserID) { [self] conversationId in
            self.isLoading = false
            self.conversationId = conversationId
            print("ConversationId from FroopChatView\(conversationId)")
            let froopId = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopId ?? ""
            
            // Now, set up the listener and fetch messages for this conversationId
            self.chatManager.setupActiveFroopChatsListener(froopId: froopId, currentUserUID: self.uid, selectedFriendUID: friendRequestManager.selectedFriend.froopUserID, conversationId: conversationId) { fetchedMessages in
                self.messages = fetchedMessages
            }
        }
    }

    
    private func setupChatListener() {
        let froopId = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopId ?? ""
        let hostId = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.host.froopUserID ?? ""
        let conversationId = chatManager.holderCon.conversation.id
        // Adjust the path to point to the correct collection for one-on-one chats
        let chatRef = db.collection("users").document(hostId).collection("myFroops").document(froopId).collection("chats").document(conversationId).collection("messages")
            .order(by: "timestamp")
        
        chatListener = chatRef.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("🚫Error fetching chat messages: \(error?.localizedDescription ?? "")")
                return
            }
            let newMessages = snapshot.documents.compactMap { document in
                Message(document: document)
            }
            DispatchQueue.main.async {
                self.messages = newMessages
            }
        }
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        if (currentConversation?.messages.last) != nil {
            withAnimation(.easeInOut(duration: 0.5)) {
                proxy.scrollTo(messages.count - 1, anchor: .bottom)
            }
        }
    }
    
    private func setupKeyboardHeightPublisher() {
        keyboardHeightPublisher = NotificationCenter.keyboardHeightPublisher
            .sink { newHeight in
                self.keyboardHeight = newHeight
            }
    }
    
}


