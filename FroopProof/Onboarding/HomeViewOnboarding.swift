//
//  HomeViewOnboarding.swift
//  FroopProof
//
//  Created by David Reed on 5/21/24.
//

import SwiftUI

struct HomeViewOnboarding: View {
    @ObservedObject var myData = MyData.shared
    @ObservedObject var onboardingData = OnboardingData.shared
    @ObservedObject var appStateManager = AppStateManager.shared
    @State private var highlightOrder: [Int] = []
    @State private var currentHighlight: Int = 0

    var highlight: Highlight?
//    var highlightRect: CGRect
//    var safeArea: EdgeInsets
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                ZStack {
                    VStack(alignment: .center) {
                        DebugView("🐞 Adding highlight with order 0") {
                            Circle()
                                .foregroundColor(.black).opacity(0.8)
                                .frame(width: 1, height: 1)
                                .showCase(
                                    order: 0,
                                    title: "Hi \(MyData.shared.firstName)! Welcome to Froop. Let's get you started.",
                                    subTitle: "",
                                    cornerRadius: 1,
                                    style: .continuous
                                )
                                .padding(.top, 53)
                                .padding(.trailing, 15)
                                .onAppear {
                                    appStateManager.showFace = true
                                    appStateManager.showFaceText = true
                                }
                            
                            
                            Spacer()
                        }
                    }
                    .padding(.top, UIScreen.screenHeight * 0.4)
                    .ignoresSafeArea()
                    
                    VStack(alignment: .center) {
                        DebugView("🐞 Adding highlight with order 1") {
                            Circle()
                                .foregroundColor(.black).opacity(0.8)
                                .frame(width: 1, height: 1)
                                .showCase(
                                    order: 1,
                                    title: "Froop helps you plan and coordinate events with friends.",
                                    subTitle: "",
                                    cornerRadius: 1,
                                    style: .continuous
                                )
                                .padding(.top, 53)
                                .padding(.trailing, 15)
                                .onAppear {
                                    appStateManager.showFaceText = true
                                }
                            Spacer()
                        }
                    }
                    .padding(.top, UIScreen.screenHeight * 0.4)
                    .ignoresSafeArea()
                    
                    VStack(alignment: .center) {
                        DebugView("🐞 Adding highlight with order 2") {
                            Circle()
                                .foregroundColor(.black).opacity(0.8)
                                .frame(width: 1, height: 1)
                                .showCase(
                                    order: 2,
                                    title: "Create events, invite friends, and manage everything in one place.",
                                    subTitle: "",
                                    cornerRadius: 1,
                                    style: .continuous
                                )
                                .padding(.top, 53)
                                .padding(.trailing, 15)
                            
                            Spacer()
                        }
                    }
                    .padding(.top, UIScreen.screenHeight * 0.4)
                    .ignoresSafeArea()
                    
                    VStack(alignment: .center) {
                        DebugView("🐞 Adding highlight with order 3") {
                            Circle()
                                .foregroundColor(.black).opacity(0.8)
                                .frame(width: 1, height: 1)
                                .showCase(
                                    order: 3,
                                    title: "Your events are private - only invited friends can see them.",
                                    subTitle: "",
                                    cornerRadius: 1,
                                    style: .continuous
                                )
                                .padding(.top, 53)
                                .padding(.trailing, 15)
                            
                            Spacer()
                        }
                    }
                    .padding(.top, UIScreen.screenHeight * 0.4)
                    .ignoresSafeArea()
                    
                    VStack(alignment: .center) {
                        DebugView("🐞 Adding highlight with order 4") {
                            Circle()
                                .foregroundColor(.black).opacity(0.8)
                                .frame(width: 1, height: 1)
                                .showCase(
                                    order: 4,
                                    title: "Share locations, chat, and coordinate details with your guests.",
                                    subTitle: "",
                                    cornerRadius: 1,
                                    style: .continuous
                                )
                                .padding(.top, 53)
                                .padding(.trailing, 15)
                           
                            Spacer()
                        }
                    }
                    .padding(.top, UIScreen.screenHeight * 0.4)
                    .ignoresSafeArea()
                                                            
                    VStack(alignment: .center) {
                        HStack(alignment: .center) {
                            Circle()
                                .foregroundColor(.clear)
                                .frame(width: 80, height: 80)
                                .showCase(
                                    order: 5,
                                    title: "Tap here to create a new Froop event.",
                                    subTitle: "",
                                    cornerRadius: 50,
                                    style: .continuous
                                )
                                .padding(.top, UIScreen.screenHeight > 900 ? UIScreen.screenHeight * 0.23 : UIScreen.screenHeight * 0.21)
                                .offset(x: 6)
                        }
                        .onAppear {
                            appStateManager.showFace = false
                            appStateManager.showFaceText = false
                        }
                        Spacer()
                    }
                    .ignoresSafeArea()
                    
                    VStack(alignment: .center) {
                        HStack(alignment: .center) {
                            Circle()
                                .foregroundColor(.clear)
                                .frame(width: 80, height: 80)
                                .showCase(
                                    order: 6,
                                    title: "Each event has its own dashboard for easy coordination.",
                                    subTitle: "",
                                    cornerRadius: 50,
                                    style: .continuous
                                )
                                .padding(.top, UIScreen.screenHeight > 900 ? UIScreen.screenHeight * 0.23 : UIScreen.screenHeight * 0.21)
                                .offset(x: 6)
                        }
                        Spacer()
                    }
                    .ignoresSafeArea()
                                        
                    VStack(alignment: .center) {
                        HStack(alignment: .center) {
                            Circle()
                                .foregroundColor(.clear)
                                .frame(width: 80, height: 80)
                                .showCase(
                                    order: 7,
                                    title: "Look for pink icons - they mark special event types.",
                                    subTitle: "",
                                    cornerRadius: 50,
                                    style: .continuous
                                )
                                .padding(.top, UIScreen.screenHeight > 900 ? UIScreen.screenHeight * 0.23 : UIScreen.screenHeight * 0.21)
                                .offset(x: 6)
                        }
                        Spacer()
                    }
                    .ignoresSafeArea()
                    
                    VStack(alignment: .center) {
                        HStack(alignment: .center) {
                            Circle()
                                .foregroundColor(.clear)
                                .frame(width: UIScreen.screenWidth * 0.98, height: 40)
                                .showCase(
                                    order: 8,
                                    title: "Switch between your content feed and the Froops you manage.",
                                    subTitle: "",
                                    cornerRadius: 10,
                                    style: .continuous
                                )
                                .padding(.top, UIScreen.screenHeight * 0.325)
                        }
                        Spacer()
                    }
                    .ignoresSafeArea()
                    
                    VStack(alignment: .center) {
                        HStack(alignment: .center) {
                            Circle()
                                .foregroundColor(.clear)
                                .frame(width: UIScreen.screenWidth * 0.49, height: 40)
                                .showCase(
                                    order: 9,
                                    title: "See events you're invited to in your home feed.",
                                    subTitle: "",
                                    cornerRadius: 10,
                                    style: .continuous
                                )
                                .padding(.top, UIScreen.screenHeight * 0.325)
                                .padding(.leading, 2)
                            Spacer()
                        }
                        Spacer()
                    }
                    .ignoresSafeArea()
                    
                    VStack(alignment: .center) {
                        HStack(alignment: .center) {
                            Spacer()
                            Circle()
                                .foregroundColor(.clear)
                                .frame(width: UIScreen.screenWidth * 0.48, height: 40)
                                .showCase(
                                    order: 10,
                                    title: "View and manage your created events here.",
                                    subTitle: "",
                                    cornerRadius: 10,
                                    style: .continuous
                                )
                                .padding(.top, UIScreen.screenHeight * 0.325)
                                .padding(.trailing, 2)
                        }
                        Spacer()
                    }
                    .ignoresSafeArea()
                    
                    VStack(alignment: .center) {
                        HStack(alignment: .center) {
                            Spacer()
                            Circle()
                                .foregroundColor(.clear)
                                .frame(width: UIScreen.screenWidth * 0.98, height: UIScreen.screenHeight * 0.6)
                                .showCase(
                                    order: 11,
                                    title: "Your upcoming events will appear in this area.",
                                    subTitle: "",
                                    cornerRadius: 10,
                                    style: .continuous
                                )
                                .padding(.top, UIScreen.screenHeight > 900 ? UIScreen.screenHeight * 0.36 : UIScreen.screenHeight * 0.36)
                        }
                        Spacer()
                    }
                    .ignoresSafeArea()
                    
                    VStack {
                        HStack {
                            Circle()
                                .foregroundColor(.clear)
                                .frame(width: 45, height: 45)
                                .showCase(
                                    order: 12,
                                    title: "Access your event chats and messages here.",
                                    subTitle: "",
                                    cornerRadius: 20,
                                    style: .continuous
                                )
                                .padding(.top, 53)
                                .padding(.leading, 15)
                            Spacer()
                        }
                        Spacer()
                    }
                    .ignoresSafeArea()
                    
                    VStack {
                        HStack {
                            Circle()
                                .foregroundColor(.clear)
                                .frame(width: 55, height: 45)
                                .showCase(
                                    order: 13,
                                    title: "Add friends to start inviting them to events.",
                                    subTitle: "",
                                    cornerRadius: 20,
                                    style: .continuous
                                )
                                .padding(.top, 53)
                                .padding(.leading, 15)
                            Spacer()
                        }
                        Spacer()
                    }
                    .ignoresSafeArea()
                    
                    VStack {
                        HStack {
                            Circle()
                                .foregroundColor(.clear)
                                .frame(width: 45, height: 45)
                                .showCase(
                                    order: 14,
                                    title: "Chat with friends directly from their profiles.",
                                    subTitle: "",
                                    cornerRadius: 20,
                                    style: .continuous
                                )
                                .padding(.top, 53)
                                .padding(.leading, 15)
                            Spacer()
                        }
                        Spacer()
                    }
                    .ignoresSafeArea()
                    
                    VStack (alignment: .trailing){
                        HStack {
                            Spacer()
                            DebugView("🐞 Adding highlight with order 0") {
                                Circle()
                                    .foregroundColor(.clear)
                                    .frame(width: 55, height: 45)
                                    .showCase(
                                        order: 15,
                                        title: "Access your profile and settings here.",
                                        subTitle: "",
                                        cornerRadius: 1,
                                        style: .continuous
                                    )
                                    .padding(.top, 53)
                                    .padding(.trailing, 15)
                            }
                        }
                        Spacer()
                    }
                    .ignoresSafeArea()
                    
                    VStack {
                        HStack {
                            Circle()
                                .foregroundColor(.clear)
                                .frame(width: UIScreen.screenWidth * 0.98, height: 120)
                                .showCase(
                                    order: 16,
                                    title: "See countdown timers for your upcoming events.",
                                    subTitle: "",
                                    cornerRadius: 20,
                                    style: .continuous
                                )
                                .padding(.top, 105)
                        }
                        Spacer()
                    }
                    .ignoresSafeArea()
                    
                    VStack(alignment: .center) {
                        DebugView("🐞 Adding highlight with order 0") {
                            Circle()
                                .foregroundColor(.black).opacity(0.8)
                                .frame(width: 1, height: 1)
                                .showCase(
                                    order: 17,
                                    title: "You're all set! Tap the + button to create your first event.",
                                    subTitle: "",
                                    cornerRadius: 1,
                                    style: .continuous
                                )
                                .padding(.top, 53)
                                .padding(.trailing, 15)
                            VStack {
                                Image(systemName: "face.smiling.inverse")
                                    .foregroundColor(.white)
                                    .font(.system(size: 40))
                                    .frame(width: 25, height: 25)
                                    .opacity(currentHighlight == 14 ? 1.0 : 0.0)
                                    .padding(.top, 10)
                            }
                            Spacer()
                        }
                    }
                    .padding(.top, UIScreen.screenHeight * 0.4)
                    .ignoresSafeArea()
                                
                }
               
            
                .ignoresSafeArea()
            }
            .ignoresSafeArea()
            .opacity(onboardingData.homeOnboarding == false ? 1 : 0)
            .onAppear {
                appStateManager.showHomeRibbon = false
                print("🥎 HomeViewOnboarding Loading")
                print("🥎 homeOnboarding value: \(onboardingData.homeOnboarding)")
            }
        }
    }
}


