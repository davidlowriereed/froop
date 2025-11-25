//
//  FroopPassiveView.swift
//  FroopProof
//
//  Created by David Reed on 5/18/23.
//

import SwiftUI
import UserNotifications
import FirebaseAuth
import FirebaseFirestore


struct FroopPassiveView: View {
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var navLocationServices = NavLocationServices.shared
    @ObservedObject var timeZoneManager:TimeZoneManager = TimeZoneManager()
    @ObservedObject var onboardingData = OnboardingData.shared

    @ObservedObject var froopManager = FroopManager.shared
    @ObservedObject var changeView = ChangeView()
    @ObservedObject var froopData = FroopData.shared
    
    @State var instanceFroop: FroopHistory
    //    @State var selectedFriend: UserData = UserData()
    @State private var walkthroughScreen: NFWalkthroughScreen? = nil
    @State var showSheet = false
    @State var froopAdded = false
    @State private var sortedIndices: [Int] = []
    @State private var currentIndex: Int = 0
    @State private var now = Date()
    @State private var loadIndex = 0
    @State var friendDetailOpen: Bool = false
    @Binding var globalChat: Bool
    
    var walkthroughView: some View {
        walkthroughScreen
            .environmentObject(changeView)
            .environmentObject(froopData)
    }
    
    var body: some View {
        ZStack {
            
            Text(froopManager.froopHistory.count == 0 ? "Your friend's Froops will show up here if they have decided to share them with their community." : "")
                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                .font(.system(size: 20))
                .fontWeight(.regular)
                .frame(width: 300)
            
            ZStack (alignment: .top){
                Color.white
                VStack {
                    UserDetailView(instanceFroop: instanceFroop, friendDetailOpen: $friendDetailOpen, globalChat: $globalChat)
                        .ignoresSafeArea()
                        .frame(width: UIScreen.screenWidth, height: UIScreen.screenHeight)
                }
            }
            if froopManager.showVideoPlayer {
                CustomVideoPlayerView(videoURLString: froopManager.selectedFroopHistory.froop.froopIntroVideo == "" ? froopManager.videoUrl : froopManager.selectedFroopHistory.froop.froopIntroVideo) {
                    
                    froopManager.showVideoPlayer = false
                }
            }
        }
        .onAppear {
            globalChat = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                appStateManager.hasRespondedToRibbon = false
                appStateManager.currentViewID = .home
                print("🥎 Setting currentViewID to .home")
                print("Setting currentViewID to .\(appStateManager.currentViewID) in \(String(describing: self))")
                appStateManager.updateOnboardingState()
            }
            print("🥎🥎 🥎🥎 Setting currentViewID to .home from .onAppear in FroopPassiveView")
        }
        .fullScreenCover(isPresented: $friendDetailOpen) {
        } content: {
            ZStack {
                VStack {
                    Spacer()
                    FriendDetailView(globalChat: $globalChat)
                    //                        .ignoresSafeArea()
                }
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "xmark")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .blendMode(.difference)
                            .padding(.trailing, 40)
                            .padding(.top, UIScreen.screenHeight * 0.005)
                            .onTapGesture {
                                self.friendDetailOpen = false
                                print("CLEAR TAP MainFriendView 3")
                            }
                    }
                    .frame(alignment: .trailing)
                    Spacer()
                }
            }
        }
        //        .sheet(isPresented: $froopManager.showInviteUrlView) {
        .blurredSheet(.init(.ultraThinMaterial), show: $froopManager.showInviteUrlView) {
        } content: {
            ZStack {
                VStack {
                    CopyableTextView(url: froopManager.selectedFroopHistory.froop.inviteUrl)
                        .padding()
                        .background(.clear)
                        .cornerRadius(8)
                }
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "xmark")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .padding(.trailing, 40)
                            .padding(.top, UIScreen.screenHeight * 0.005)
                            .onTapGesture {
                                froopManager.showInviteUrlView = false
                            }
                    }
                    .frame(alignment: .trailing)
                    Spacer()
                }
            }
        }
    }
    
    func eveningText () -> String {
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        var greeting: String
        if hour < 12 {
            greeting = "Good Morning"
        } else if hour < 17 {
            greeting = "Good Afternoon"
        } else {
            greeting = "Good Evening"
        }
        
        return greeting
    }
    func formatTime(creationTime: Date) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .hour, .day]
        formatter.unitsStyle = .abbreviated
        
        let currentTime = Date()
        let timeSinceCreation = currentTime.timeIntervalSince(creationTime)
        
        let formattedTime = formatter.string(from: timeSinceCreation) ?? ""
        
        return formattedTime
    }
    
}

struct CopyableTextView: View {
    @ObservedObject var froopManager = FroopManager.shared
    let url: String
    @State private var showCopyConfirmation: Bool = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .frame(width: UIScreen.screenWidth - 40, height: UIScreen.screenHeight / 1.5)
                .foregroundStyle(Color(red: 249/255, green: 0/255, blue: 98/255))
                .shadow(color: Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.4), radius: 4, x: 4, y: 4)
            VStack {
                Rectangle()
                    .frame(width: UIScreen.screenWidth - 40, height: UIScreen.screenHeight / 2)
                    .foregroundColor(.white)
                    .padding(.top, 60)
                Spacer()
            }
            
            
            VStack (spacing: 5){
                ZStack {
                    HStack {
                        Text("FROOP INVITE LINK")
                            .foregroundStyle(.white)
                            .font(.headline)
                            .fontWeight(.bold)
                            .padding(.leading, 35)
                            .padding(.trailing, 35)
                        
                    }
                }
                .padding(.top, 30)
                
                VStack(spacing: 5){
                    HStack {
                        Text("Froop Invite Links are an easy way to send invitations to anyone via Texting, Email, or Posting to your Social Media.")
                            .foregroundStyle(Color(red: 50/255, green: 46/255, blue: 62/255))
                            .font(.body)
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    Divider()
                        .foregroundStyle(Color(red: 50/255, green: 46/255, blue: 62/255))
                        .padding()
                    HStack {
                        Text("HERE'S HOW IT WORKS")
                            .foregroundStyle(Color(red: 50/255, green: 46/255, blue: 62/255))
                            .font(.subheadline)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    HStack {
                        Text("If the guest is in your Friend List...")
                            .foregroundStyle(Color(red: 50/255, green: 46/255, blue: 62/255))
                            .font(.callout)
                            .fontWeight(.light)
                        Spacer()
                    }
                    .padding(.leading, 15)
                    .padding(.top, 10)
                    
                    
                    BulletPointTextView(text: "They are added to the Froop's Confirmed List as soon as they accept the invitation.")
                        .padding(.leading, 15)
                        .padding(.top, 10)
                    BulletPointTextView(text: "Status:  They Are Trusted")
                        .padding(.leading, 15)
                        .padding(.top, 10)
                    
                    
                    
                    HStack {
                        Text("If the guest is NOT yet a Friend...")
                            .foregroundStyle(Color(red: 50/255, green: 46/255, blue: 62/255))
                            .font(.callout)
                            .fontWeight(.light)
                        Spacer()
                    }
                    .padding(.leading, 15)
                    .padding(.top, 10)
                    BulletPointTextView(text: "After they have accepted the invitation, you will need to 'Approve' them before they can join your Froop.")
                    
                        .padding(.leading, 15)
                        .padding(.top, 10)
                    BulletPointTextView(text: "Status: Requires Verification")
                    
                        .padding(.leading, 15)
                        .padding(.top, 10)
                    
                    
                    Spacer()
                    
                }
                .padding(.top, 15)
                .padding(.leading, 35)
                .padding(.trailing, 35)
                
                Text("COPY FROOP LINK NOW")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.bottom, 35)
                    
                Spacer()
            }
        }
        .frame(height: UIScreen.screenHeight / 1.5)
        .onTapGesture {
            UIPasteboard.general.string = froopManager.selectedFroopHistory.froop.inviteUrl
            showCopyConfirmation = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                // Hide confirmation after 2 seconds
                showCopyConfirmation = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    froopManager.showInviteUrlView = false
                }
            }
        }
        .overlay(
            Group {
                if showCopyConfirmation {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: 200, height: 100)
                            .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255))
                        Text("Copied!")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(8)
                            .clipShape(Capsule())
                            .transition(.scale.combined(with: .opacity))
                            .zIndex(1)
                    }
                }
            }
        )
        .animation(.easeInOut, value: showCopyConfirmation)
    }
}


struct BulletPointTextView: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: "circle.fill")
                .foregroundStyle(Color(red: 50/255, green: 46/255, blue: 62/255))
                .font(.system(size: 8))
                .opacity(0.25)
                .padding(.top, 3)
            
            Text(text)
                .font(.footnote)
                .foregroundStyle(Color(red: 50/255, green: 46/255, blue: 62/255))
                .fontWeight(.regular)
            Spacer()
        }
    }
}
