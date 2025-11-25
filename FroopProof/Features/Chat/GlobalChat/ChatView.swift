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


struct ChatView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var notificationsManager = NotificationsManager.shared
    @ObservedObject var chatManager = GlobalChatNotificationsManager.shared
    @ObservedObject var friendRequestManager = FriendRequestManager.shared
    @State var messageText: String = ""
    @State private var keyboardHeight: CGFloat = 0
    @State private var keyboardHeightPublisher: AnyCancellable?
    @State var messages: [Message] = []
    @State private var chatListener: ListenerRegistration?
    @Binding var conversationId: String
    var toUserId: String = ""
    
    init(conversationId: Binding<String>) {
        _conversationId = conversationId
        UITableView.appearance().separatorStyle = .none
    }
    
    var body: some View {
        ZStack {
            VStack (spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            ForEach(Array(chatManager.currentConversation?.messages.enumerated() ?? [].enumerated()), id: \.element) { idx, message in
                                MessageRow(message: message, isCurrentUser: message.senderId == notificationsManager.uid)
                                    .id(idx)
                            }
                            .onChange(of: chatManager.currentConversation?.messages ?? []) { oldValue, newValue in
                                withAnimation(Animation.spring(response: 0.35, dampingFraction: 0.85, blendDuration: 0)) {
                                    proxy.scrollTo((chatManager.currentConversation?.messages.count ?? 0) - 1, anchor: .bottom)
                                }
                                if let conversationAndMessages = chatManager.currentConversation {
                                    chatManager.markMessagesAsRead(in: conversationAndMessages)
                                    chatManager.updateBadgeCountForNewMessage(in: conversationAndMessages)
                                }
                            }
                        }
                        .rotationEffect(.degrees(180))
                        .padding(.top, 10)
                        .onAppear() {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                proxy.scrollTo((chatManager.currentConversation?.messages.count ?? 0) - 1, anchor: .top)
                            }
                        }
                        .onChange(of: keyboardHeight) { newValue, oldValue in
                            withAnimation(Animation.spring(response: 0.35, dampingFraction: 0.85, blendDuration: 0)) {
                                
                                if newValue != oldValue {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        proxy.scrollTo((chatManager.currentConversation?.messages.count ?? 0) - 1, anchor: .bottom)
                                    }
                                }
                            }
                        }
                        .onChange(of: notificationsManager.chatEntered) { newValue, oldValue in
                            if newValue {
                                proxy.scrollTo(messages.count - 1, anchor: .bottom)
                                
                            }
                        }
                    }
                    .rotationEffect(.degrees(180))
                    .onAppear {
                        if let conversationAndMessages = chatManager.currentConversation {
                            notificationsManager.markMessagesAsRead(in: conversationAndMessages)
                            notificationsManager.updateBadgeCountForNewMessage(in: conversationAndMessages)
                        }
                    }
                    .border(.gray, width: 0.25)
                    .background(.clear)
                    .onReceive(notificationsManager.$conversationsAndMessages) { _ in
                        DispatchQueue.main.async {
                            proxy.scrollTo(messages.count - 1, anchor: .bottom)
                        }
                    }
                }
                .padding(.top, 75)
                .padding(.horizontal, 10)
                .padding(.bottom, 10)
                .background(.clear)
                
                ChatInputView(messageText: $messageText, onSend: {
                    notificationsManager.sendMessage(content: self.messageText, toUserId: friendRequestManager.selectedFriend.froopUserID)
                })
                    .padding(.bottom, notificationsManager.chatEntered ? 10 : 10) // Conditional padding
            }
            .padding(.bottom, keyboardHeight - 30) // Adjust bottom padding based on keyboard height
            .animation(.smooth(duration: 0.25), value: keyboardHeight) // Animate the padding change
            .onAppear {
                keyboardHeightPublisher = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
                    .map { notification -> CGFloat in
                        (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
                    }
                    .merge(with: NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
                        .map { _ in CGFloat(0) }
                    )
                    .eraseToAnyPublisher()
                    .sink { [self] newHeight in
                        self.keyboardHeight = newHeight
                    }
            }
            .onDisappear {
                keyboardHeightPublisher?.cancel()
            }
            .ignoresSafeArea(.keyboard, edges: .bottom) // Allow the view to extend into the keyboard area
            
            
            if chatManager.isLoading {
                ProgressView("Loading...")
            }
        }
        .ignoresSafeArea()
        .onAppear {
            print("🔆🔆🔆🔆notificationsManager's currentConverstion id:  \(chatManager.currentConversation?.id ?? "NO ID FOUND")")
            print("🔆🔆🔆🔆notificationsManager's currentConverstion id:  \(chatManager.conversationId)")
            
            setupGlobalChatListener(conversationId: chatManager.conversationId)
            setupKeyboardHeightPublisher()
            chatManager.setupConversation(with: friendRequestManager.selectedFriend.froopUserID)
            
            //            NotificationsManager.shared.printAllConversationAndMessagesDetails()
        }
        .onDisappear {
            chatListener?.remove()
            keyboardHeightPublisher?.cancel()
            
        }
    }
    
    
    private func setupGlobalChatListener(conversationId: String) {
        print("SETUP GLOBAL CHAT FUNCTION FIRING: \(conversationId)")
        // Define the reference to the global chat messages in Firestore
        // Update the following line with the correct path to your global chat messages collection
//        let conversationId = chatManager.currentConversation?.conversation.id ?? ""

        let globalChatRef = Firestore.firestore().collection("chats").document(conversationId).collection("messages").order(by: "timestamp")

        // Set up the listener for the global chat messages
        chatListener = globalChatRef.addSnapshotListener { [self] querySnapshot, error in
            
            if let error = error {
                print("🚫Error fetching global chat messages: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No documents found in global chat messages collection.")
                return
            }
            
            // Process the new messages
            let newMessages = documents.compactMap { document in
                Message(document: document)
            }
            
            // Update the messages array with the new messages
            DispatchQueue.main.async {
                self.messages = newMessages
            }
        }
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        if let lastMessage = chatManager.currentConversation?.messages.last {
            withAnimation(.easeInOut(duration: 0.5)) {
                proxy.scrollTo(lastMessage.id, anchor: .bottom)
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



