//
//  FroopMessagesView.swift
//  FroopProof
//
//  Created by David Reed on 5/8/23.
//

import SwiftUI
import Photos
import FirebaseStorage
import Firebase
import FirebaseAuth
import FirebaseFirestore
import Kingfisher
import SwiftUIBlurView

struct FroopMessagesView: View {
    @ObservedObject var chatManager = FroopChatNotificationsManager.shared
    @ObservedObject var groupChatManager = FroopGroupChatNotificationsManager.shared
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var navLocationServices = NavLocationServices.shared
    @ObservedObject var froopManager = FroopManager.shared
    // @ObservedObject var froopDataListener = FroopDataListener.shared
    @ObservedObject var locationManager = LocationManager.shared
    @State var froopChatViewOpen: Bool = false
    @State var selectedConversation: UserData = UserData()
    @State var selectedChatType: ChatType = .none
    
    let db = FirebaseServices.shared.db
    let uid = FirebaseServices.shared.uid
    
    var userIdsForChat: [String] {
        let confirmedFriends = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.confirmedFriends ?? []
        return confirmedFriends.map { $0.froopUserID }
    }
    
    var filteredFroopHistory: [FroopHistory] {
        return froopManager.froopHistory.filter { (froopHistory: FroopHistory) -> Bool in
            let now = Date()
            return froopHistory.froop.froopStartTime < now && froopHistory.froop.froopEndTime > now
        }
    }
    
    var body: some View {
        
        ZStack {
            FTVBackGroundComponent()
            Rectangle()
                .foregroundColor(.white)
                .ignoresSafeArea()
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 1) {
                        FroopGroupChatCardView(
                            chatViewOpen: $froopChatViewOpen,
                            selectedChatType: $selectedChatType
                        )
                        .shadow(color: Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.2), radius: 7, x: 7, y: 7)
                        .shadow(color: Color.white.opacity(0.7), radius: 7, x: -4, y: -4)
                        
                        ForEach(chatManager.froopConversationsAndMessages) { froopConversationAndMessages in
                            FroopChatCardView(froopConversationAndMessages: froopConversationAndMessages, chatViewOpen: $chatManager.chatViewOpen, selectedConversation: $selectedConversation, selectedChatType: $selectedChatType)
                                .shadow(color: Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.2), radius: 7, x: 7, y: 7)
                                .shadow(color: Color.white.opacity(0.7), radius: 7, x: -4, y: -4)
                        }
                    }
                    .padding(.top, 95)
                }
                .onAppear {
                    print("Froop Conversations and Messages: \(chatManager.froopConversationsAndMessages)")
                    // If you have a specific method to print this in a formatted way, call it here.
                    chatManager.printFroopConversationsAndMessages() // Assuming this method exists and does the formatted printing.
                }
            }
            VStack {
                Rectangle()
                    .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                    .ignoresSafeArea()
                    .frame(height: 100)
                Spacer()
            }
            
            VStack {
                HStack {
                    Spacer()
                    Text("FROOP") 
                        .font(.system(size: 24))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .opacity(0.35)
                        .offset(y: 13)
                    KFImage(URL(string: MyData.shared.profileImageUrl))
                        .resizable()
                        .scaledToFill()
                        .frame(width: 75, height: 75)
                        .clipShape(.circle)
                    Text("CHAT")
                        .font(.system(size: 24))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .opacity(0.35)
                        .offset(y: 13)
 
                    Spacer()
                }
                .padding(.top, 35)
                Spacer()
            }
        }
        .opacity(appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopId == nil ? 0 : 1)
        .padding(.top, 95)
        .onAppear {
            self.chatManager.loadConversationsForCurrentUser()
        }
        .navigationTitle("\(appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopName ?? "")")

        
        .blurredSheet(.init(.ultraThinMaterial), show: $froopManager.chatViewOpen) {
            froopManager.chatViewOpen = false
        } content: {
            ZStack {
                
                VStack {
                    Spacer()
                     if selectedChatType == .group {
                        FroopGroupChatView()
                            .ignoresSafeArea()
                    } else {
                        FroopChatView(chatPartnerUID: selectedConversation.froopUserID)
                            .ignoresSafeArea()
                    }
                }
                

                VStack {
                    ZStack{
                        VStack {
                            Rectangle()
                                .frame(height: UIScreen.screenHeight / 6.9)
                                .foregroundStyle(Color(red: 50/255, green: 46/255, blue: 62/255))

                            Spacer()
                        }
                        .ignoresSafeArea()
                        
                        VStack {
                            HStack {
                                if selectedChatType == .group {
                                    Image("pinkLogo")
                                        .resizable()
                                        .scaledToFit()
                                        .scaleEffect(0.7)
                                        .frame(width: 50, height: 50)
                                        .background(.white)
                                        .clipShape(Circle())
                                        .padding(.leading, 15)
                                } else {
                                    ProfileImage3(selectedFriend: $selectedConversation)
                                }
                                VStack (alignment: .leading){
                                    Text("CHATTING WITH")
                                        .font(.system(size: 12))
                                        .frame(alignment: .leading)
                                    Text(selectedChatType == .group ? "EVERYONE" : "\(selectedConversation.firstName.uppercased()) \(selectedConversation.lastName.uppercased())")
                                }
                                .font(.system(size: 20))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .opacity(0.25)
                                .offset(y: 5)
                                Spacer()
                                
                                Image(systemName: "xmark")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                                    .blendMode(.difference)
                                    .padding(.trailing, 40)
                                    .padding(.top, UIScreen.screenHeight * 0.005)
                                    .onTapGesture {
                                        froopManager.chatViewOpen = false
                                        chatManager.chatViewOpen = false
                                        print("CLEAR TAP MainFriendView 4")
                                    }
                            }
                            .padding(.top, UIScreen.screenHeight * 0.085)
                            .padding(.leading, 25)
                            .onTapGesture {
                                // Call the test print function on tap
                                chatManager.printFroopConversationsAndMessages()
                            }
                            Spacer()
                            
                        }
                    }
                    Spacer()
                }
                .ignoresSafeArea()
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)

        }
    }
}

