//
//  FroopGroupChatView.swift
//  FroopProof
//
//  Created by David Reed on 7/22/23.


import SwiftUI
import Firebase
import FirebaseFirestore
import Combine
import UIKit

struct FroopGroupChatView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var notificationsManager = NotificationsManager.shared
    @ObservedObject var chatManager = GlobalChatNotificationsManager.shared
    @State private var messageText: String = ""
    @State private var keyboardHeight: CGFloat = 0
    @State private var keyboardHeightPublisher: AnyCancellable?
    @State private var refreshTrigger = false // Add a state variable to trigger updates
    @State var scrollToTop: Bool = false
    private var timer: Timer?
    @State private var chatListener: ListenerRegistration?
    @Namespace var topID
    @Namespace var bottomID
    @State var messages: [Message] = []

    
    var currentConversation: ConversationAndMessages? {
        chatManager.conversationsAndMessages.first { conversationAndMessages in
            // Your condition here
            return conversationAndMessages.id == appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froopGroupConversationAndMessages.id
        } ?? ConversationAndMessages(conversation: Conversation(), messages: [], participants: [])
    }
    
    
    var body: some View {
        ZStack (alignment: .top){
            
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack (spacing: -10) {
                        ForEach(Array(messages.sorted { $0.timestamp < $1.timestamp }.enumerated()), id: \.element) { idx, message in
                            let senderFirstName = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.confirmedFriends
                                .first(where: { $0.froopUserID == message.senderId })?.firstName ?? "Unknown"
                            let senderLastName = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.confirmedFriends
                                .first(where: { $0.froopUserID == message.senderId })?.lastName ?? "Unknown"
                            GroupMessageRow(message: message, senderFirstName: senderFirstName, senderLastName: senderLastName, isCurrentUser: message.senderId == FirebaseServices.shared.uid)
                                .id(idx)
                            
                        }
                    }
                    .rotationEffect(.degrees(180))
                    .onChange(of: messages) { oldValue, newValue in
                        withAnimation(Animation.spring(response: 0.35, dampingFraction: 0.85, blendDuration: 0)) {
                            proxy.scrollTo(messages.count - 1, anchor: .top)
                        }
                        if let conversationAndMessages = currentConversation {
                            notificationsManager.markMessagesAsRead(in: conversationAndMessages)
                            notificationsManager.updateBadgeCountForNewMessage(in: conversationAndMessages)
                        }
                    }
                }
                .rotationEffect(.degrees(180))
                .frame(height: UIScreen.screenHeight * 0.49)
//                .border(Color(red: 255/255, green: 49/255, blue: 97/255), width: 0.5)
            }

            
            VStack {
                Spacer()
                FroopGroupChatInputView(onSend: {
                    sendGroupMessage(content: messageText)
                    messageText = "" // Clear the input field after sending
                })
                .padding(.bottom, keyboardHeight <= 0 ? 35 : keyboardHeight)
                .animation(.smooth(duration: 0.5), value: keyboardHeight)
                .onAppear {
                    setupKeyboardHeightPublisher()
                }
                .onDisappear {
                    keyboardHeightPublisher?.cancel()
                }
            }
            
            .onAppear {
                setupKeyboardHeightPublisher()
            }
        }
        .onAppear {
            setupChatListener()
        }
        .onDisappear {
            chatListener?.remove()
        }
    }
    
    private func setupChatListener() {
        let froopId = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopId ?? ""
        let hostId = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.host.froopUserID ?? ""
        
        let groupChatRef = Firestore.firestore().collection("users").document(hostId)
            .collection("myFroops").document(froopId)
            .collection("chats").document("froopGroupChat")
            .collection("messages")
            .order(by: "timestamp")
        
        chatListener = groupChatRef.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("🚫Error fetching chat messages: \(error?.localizedDescription ?? "")")
                return
            }
            // Process the new messages and update your view model accordingly
            let newMessages = snapshot.documents.compactMap { document in
                Message(document: document)
            }
            // Update the messages in the view model
            DispatchQueue.main.async {
                self.messages = newMessages
            }
        }
    }
        
        
        func scrollToBottom(value: ScrollViewProxy) {
        print("scrollToBottom function firing ⬇️")
            if let lastMessage = currentConversation?.messages.last {
            withAnimation(.easeInOut(duration: 0.5)) {
                value.scrollTo(lastMessage.id, anchor: .bottom)
            }
        }
    }
    
    func setupKeyboardHeightPublisher() {
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
    
    func sendGroupMessage(content: String) {
        guard !content.isEmpty else { return }
        
        let froopId = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopId
        let hostId = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.host.froopUserID
        let uid = FirebaseServices.shared.uid
        let groupChatRef = db.collection("users").document(hostId ?? "")
            .collection("myFroops").document(froopId ?? "")
            .collection("chats").document("froopGroupChat")
            .collection("messages")
        
        // Add the message to the Firestore database
        groupChatRef.addDocument(data: [
            "senderId": uid,
            "text": content,
            "timestamp": FieldValue.serverTimestamp()
        ]) { error in
            if let error = error {
                print("🚫Error sending group message: \(error)")
                return
            }
            print("Group message posted successfully")
            
        }
        
        // Create a local message object
        let message = Message(dictionary: [
            "text": content,
            "senderId": uid,
            "timestamp": Date(), // Using the current date for local display
            "froopId": froopId ?? "",
            "host": hostId ?? ""
        ], id: UUID().uuidString)
        
        // Add the new message to the FroopHistory's group chat messages
        appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froopGroupConversationAndMessages.messages.append(message)
    }
}
