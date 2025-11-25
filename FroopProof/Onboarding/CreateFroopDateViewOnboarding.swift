//
//  CreateFroopDateViewOnboarding.swift
//  FroopProof
//
//  Created by David Reed on 9/13/24.
//

import SwiftUI

struct CreateFroopDateViewOnboarding: View {
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
                                    title: "Welcome to your Friends and Profile view.  Let me show you around.",
                                    subTitle: "",
                                    cornerRadius: 1,
                                    style: .continuous
                                )
                                .padding(.top, 53)
                                .padding(.trailing, 5)
                                .onAppear {
                                    appStateManager.showFace = true
                                    appStateManager.showFaceText = true
                                }
                            Spacer()
                        }
                    }
                    .padding(.top, UIScreen.screenHeight * 0.4)
                    .ignoresSafeArea()
                  
                    
                    VStack(alignment: .trailing){
                        HStack {
                            Spacer()
                            Circle()
                                .foregroundColor(.clear)
                                .frame(width: 40, height: 40)
                                .showCase(
                                    order: 1,
                                    title: "Adding Friends starts here, to add a friend simply tap the Plus icon.",
                                    subTitle: "",
                                    cornerRadius: 20,
                                    style: .continuous
                                )
                                .padding(.top, 180)
                                .padding(.trailing, 25)
                                .onAppear {
                                    appStateManager.showFace = false
                                    appStateManager.showFaceText = false
                                }
                        }
                        Spacer()
                    }
                    .ignoresSafeArea()
                   
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Circle()
                                .foregroundColor(.clear)
                                .frame(width: 65, height: 45)
                                .showCase(
                                    order: 2,
                                    title: "Friend Invitations show up here.",
                                    subTitle: "",
                                    cornerRadius: 20,
                                    style: .continuous
                                )
                                .padding(.top, 180)
                                .padding(.leading, 8)
                            Spacer()

                        }
                        Spacer()
                    }
                    .ignoresSafeArea()
                    
                    VStack(alignment: .center) {
                        HStack {
                            Spacer()
                            Circle()
                                .foregroundColor(.clear)
                                .frame(width: UIScreen.screenWidth * 0.7, height: 45)
                                .showCase(
                                    order: 3,
                                    title: "To quickly find a Friend, use the search.",
                                    subTitle: "",
                                    cornerRadius: 20,
                                    style: .continuous
                                )
                                .padding(.top, 185)
                                .padding(.trailing, UIScreen.screenWidth * 0.035)
                            Spacer()

                        }
                        Spacer()
                    }
                    .ignoresSafeArea()
                    
                    VStack {
                        HStack {
                            Spacer()
                            Circle()
                                .foregroundColor(.clear)
                                .frame(width: UIScreen.screenWidth * 0.98, height: UIScreen.screenHeight * 0.75)
                                .showCase(
                                    order: 4,
                                    title: "Or you can scroll through your Friends here.",
                                    subTitle: "",
                                    cornerRadius: 20,
                                    style: .continuous
                                )
                                .padding(.top, 225)
//                                .padding(.leading, UIScreen.screenWidth * 0.01)
                                .padding(.trailing, UIScreen.screenWidth * 0.005)

                            Spacer()

                        }
                        Spacer()
                    }
                    .ignoresSafeArea()
                    
                    VStack(alignment: .center) {
                        HStack {
                            Circle()
                                .foregroundColor(.clear)
                                .frame(width: UIScreen.screenWidth * 0.45, height: 45)
                                .showCase(
                                    order: 5,
                                    title: "To access your Profile, tap here.",
                                    subTitle: "",
                                    cornerRadius: 20,
                                    style: .continuous
                                )
                                .padding(.top, 115)
                                .padding(.leading, UIScreen.screenWidth * 0.035)
                            Spacer()

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
                                    order: 6,
                                    title: "Ok, that's it.  There will be more guides to help you as you continue to explore.",
                                    subTitle: "",
                                    cornerRadius: 1,
                                    style: .continuous
                                )
                                .padding(.top, 53)
                                .padding(.trailing, 5)
                                .onAppear {
                                    appStateManager.showFace = true
                                    appStateManager.showFaceText = true
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
            .opacity(onboardingData.friendsOnboarding == false ? 1 : 0)
            .onAppear {
                print("🥎 HomeViewOnboarding Loading")
                print("🥎 homeOnboarding value: \(onboardingData.homeOnboarding)")
            }
        }
    }
}
