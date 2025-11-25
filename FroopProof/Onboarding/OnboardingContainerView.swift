//
//  OnboardingContainerView.swift
//  FroopProof
//
//  Created by David Reed on 9/11/24.
//

import SwiftUI

struct OnboardingContainerView: View {
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var onboardingData = OnboardingData.shared
    @State private var currentState: OnboardingState = .loading
    
    // Encapsulate the onboarding state
    private enum OnboardingState {
        case loading
        case ready
        case error(String)
    }
    
    var body: some View {
        Group {
            if onboardingData.isLoading {
                ProgressView("Loading...")
            } else {
                contentView
                    .id("onboarding-content") // Force stable identity
            }
        }
        .modifier(ShowCaseRoot(
            showHighlights: shouldShowHighlights,
            onFinished: {
                print("🥎 Finished OnBoarding")
                updateOnboardingStatus()
            },
            identifier: "OnboardingContainer"
        ))
        .environment(\.activeShowCaseRoot, "OnboardingContainer")
    }
    
    private var shouldShowHighlights: Bool {
        switch appStateManager.currentViewID {
            case .home:
                return !onboardingData.homeOnboarding && appStateManager.showHomeOnboarding
            case .friends:
                return !onboardingData.friendsOnboarding && appStateManager.showFriendsOnboarding
            default:
                return false
        }
    }
    
    @ViewBuilder
    var contentView: some View {
        ZStack {
            switch appStateManager.currentViewID {
                case .home:
                    if appStateManager.showHomeRibbon {
                        SlideInRibbonView(showRibbon: $appStateManager.showHomeRibbon)
                    } else if appStateManager.showHomeOnboarding && appStateManager.hasRespondedToRibbon {
                        HomeViewOnboarding()
                            .transition(.opacity)
                            .id("home-onboarding-\(appStateManager.showHomeOnboarding)-\(onboardingData.homeOnboarding)")
                    }
                case .friends:
                    if appStateManager.showFriendsRibbon {
                        SlideInRibbonView(showRibbon: $appStateManager.showFriendsRibbon)
                    } else if appStateManager.showFriendsOnboarding && appStateManager.hasRespondedToRibbon {
                        FriendsViewOnboarding()
                            .transition(.opacity)
                            .id("friends-onboarding-\(appStateManager.showFriendsOnboarding)-\(onboardingData.friendsOnboarding)")
                    }
                default:
                    EmptyView()
            }
        }
    }
    @ViewBuilder
    private var homeOnboardingContent: some View {
        if appStateManager.showHomeRibbon {
            SlideInRibbonView(showRibbon: $appStateManager.showHomeRibbon)
                .transition(.move(edge: .bottom))
        } else if appStateManager.showHomeOnboarding && appStateManager.hasRespondedToRibbon {
            HomeViewOnboarding()
                .transition(.opacity)
        }
    }
    
    @ViewBuilder
    private var friendsOnboardingContent: some View {
        if appStateManager.showFriendsRibbon {
            SlideInRibbonView(showRibbon: $appStateManager.showFriendsRibbon)
                .transition(.move(edge: .bottom))
        } else if appStateManager.showFriendsOnboarding && appStateManager.hasRespondedToRibbon {
            FriendsViewOnboarding()
                .transition(.opacity)
        }
    }
    
    @ViewBuilder
    private func errorView(message: String) -> some View {
        VStack {
            Text("Error loading onboarding")
                .font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.gray)
            Button("Retry") {
                initializeOnboarding()
            }
            .padding()
        }
    }
    
    private func initializeOnboarding() {
        // Ensure initialization happens on main thread
        DispatchQueue.main.async {
            do {
                try validateOnboardingState()
                currentState = .ready
            } catch {
                currentState = .error(error.localizedDescription)
            }
        }
    }
    
    private func validateOnboardingState() throws {
        guard onboardingData.isInitialized else {
            throw OnboardingError.notInitialized
        }
    }

    private func handleOnboardingFinished() {
        DispatchQueue.main.async {
            updateOnboardingStatus()
            print("🎯 Onboarding finished successfully")
        }
    }
    
    private func updateOnboardingStatus() {
        switch appStateManager.currentViewID {
            case .home:
                withAnimation {
                    onboardingData.homeOnboarding = true
                    appStateManager.showHomeOnboarding = false
                    appStateManager.showFace = false
                    appStateManager.showFaceText = false
                }
                Task {
                    await onboardingData.updateOnboarding(for: .home, to: true)
                }
            case .friends:
                withAnimation {
                    onboardingData.friendsOnboarding = true
                    appStateManager.showFriendsOnboarding = false
                    appStateManager.showFace = false
                    appStateManager.showFaceText = false
                }
                Task {
                    await onboardingData.updateOnboarding(for: .friends, to: true)
                }
            default:
                break
        }
    }
} 

// MARK: - OnboardingData Extension
extension OnboardingData {
    var isInitialized: Bool {
        guard !uid.isEmpty else { return false }
        guard documentPath != nil else { return false }
        return !isLoading
    }
    
    func saveOnboardingState() async {
        guard let docRef = documentPath else {
            PrintControl.shared.printOnboarding("❌ No valid document path")
            return
        }
        
        do {
            try await docRef.setData(dictionary, merge: true)
            PrintControl.shared.printOnboarding("✅ Successfully saved onboarding state")
        } catch {
            PrintControl.shared.printOnboarding("❌ Failed to save onboarding state: \(error.localizedDescription)")
        }
    }
}


extension HomeViewOnboarding: Equatable {
    static func == (lhs: HomeViewOnboarding, rhs: HomeViewOnboarding) -> Bool {
        // Compare relevant state that should trigger redraws
        return lhs.onboardingData.homeOnboarding == rhs.onboardingData.homeOnboarding &&
               lhs.appStateManager.showHomeOnboarding == rhs.appStateManager.showHomeOnboarding
    }
}
