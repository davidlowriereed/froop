//
//  SlideInRibbonView.swift
//  FroopProof
//
//  Created by David Reed on 9/23/24.
//

import SwiftUI

struct SlideInRibbonView: View {
    @Binding var showRibbon: Bool
    @ObservedObject var appStateManager = AppStateManager.shared
    @State private var offset: CGFloat = UIScreen.main.bounds.width * 0.5
    @ObservedObject var onboardingData = OnboardingData.shared
    
    var body: some View {
        GeometryReader { geometry in
            Rectangle()
                .background(.black)
                .opacity(0.4)
            
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color("FroopPink"))
                    .frame(width: UIScreen.main.bounds.width, height: 200)
                    .ignoresSafeArea()
                
                VStack(spacing: 10) {
                    Text("Show guided tooltips?")
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding(.bottom, 20)
                    
                    HStack(spacing: 40) {
                        Button(action: {
                            appStateManager.hasRespondedToRibbon = true
                            
                            switch appStateManager.currentViewID {
                                case .home:
                                    appStateManager.showHomeOnboarding = true
                                    appStateManager.showHomeRibbon = false
                                    // Remove the Firestore update
                                case .friends:
                                    appStateManager.showFriendsOnboarding = true
                                    appStateManager.showFriendsRibbon = false
                                    // Remove the Firestore update
                                default:
                                    break
                            }
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 3, style: .continuous)
                                    .strokeBorder(Color(.white).opacity(1), lineWidth: 0.5)
                                    .frame(width: 75, height: 40)
                                
                                Text("Yes")
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(.clear)
                                
                            }
                        }
                        
                        Button(action: {
                            appStateManager.hasRespondedToRibbon = true
                            
                            switch appStateManager.currentViewID {
                                case .home:
                                    appStateManager.showHomeRibbon = false
                                    appStateManager.showHomeOnboarding = false
                                    appStateManager.showFace = false
                                    appStateManager.showFaceText = false
                                    Task {
                                        await onboardingData.updateOnboarding(for: appStateManager.currentViewID, to: true)
                                    }
                                case .friends:
                                    appStateManager.showFriendsOnboarding = false
                                    appStateManager.showFriendsRibbon = false
                                    appStateManager.showFace = false
                                    appStateManager.showFaceText = false
                                    Task {
                                        await onboardingData.updateOnboarding(for: appStateManager.currentViewID, to: true)
                                    }
                                default:
                                    break
                            }
                            
                            appStateManager.showHomeOnboarding = false
                            Task {
                                await onboardingData.updateOnboarding(for: appStateManager.currentViewID, to: true)
                            }
                        }) {
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 3, style: .continuous)
                                    .strokeBorder(Color(.white).opacity(1), lineWidth: 0.5)
                                    .frame(width: 75, height: 40)
                                
                                Text("No")
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(Color(.clear))
                            }
                        }
                    }
                    .padding(.bottom, 50)
                }
            }
            .frame(width: UIScreen.main.bounds.width * 0.75, height: 100)
            .position(x: geometry.size.width / 2, y: geometry.size.height + 0 + offset)

            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.6, blendDuration: 0)) {
                    offset = -100
                }
            }
        }
    }
}
