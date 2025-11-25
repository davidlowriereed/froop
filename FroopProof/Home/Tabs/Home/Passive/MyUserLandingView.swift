//
//  MyUserPublicView.swift
//  FroopProof
//
//  Created by David Reed on 8/9/23.
//

import SwiftUI

struct MyUserPublicView: View {
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var myData = MyData.shared
    @ObservedObject var dataController = DataController.shared
    @ObservedObject var froopManager = FroopManager.shared
    @ObservedObject var onboardingData = OnboardingData.shared

    @StateObject private var viewModel = MyFroopsViewModel()

    var size: CGSize
    var safeArea: EdgeInsets
    @State var friendsView: Bool = false
    @State var showNotificationSheet: Bool = false
    @Binding var friendDetailOpen: Bool
    @Binding var globalChat: Bool

    init(size: CGSize, safeArea: EdgeInsets, friendDetailOpen: Binding<Bool>, globalChat: Binding<Bool>) {
        UISegmentedControl.appearance().selectedSegmentTintColor = .white
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(red: 50/255, green: 46/255, blue: 62/255, alpha: 1.0)], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.gray], for: .normal)
        self.size = size
        self.safeArea = safeArea
        self._friendDetailOpen = friendDetailOpen
        self._globalChat = globalChat
    }
    
    var body: some View {
        ZStack {
            Color.white
            ScrollViewReader { scrollProxy in
                ZStack {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 5) {
                            MyProfileHeaderView(size: size, safeArea: safeArea, showNotificationSheet: $showNotificationSheet, globalChat: $globalChat, viewModel: viewModel)
                                .zIndex(1000)
                                .ignoresSafeArea(.all)
                            MyFroopsView(viewModel: viewModel, friendDetailOpen: $friendDetailOpen)
                                .transition(.opacity)
                        }
                        .id("SCROLLVIEW")
                        .background {
                            ScrollDetector { offset in
                                DispatchQueue.main.async {
                                    dataController.offsetY = -offset
                                }
                            } onDraggingEnd: { offset, velocity in
                                let headerHeight = (size.height * 0.3) + safeArea.top
                                let minimumHeaderHeight = (size.height * 0.3) + safeArea.top
                                let targetEnd = offset + (velocity * 45)
                                if targetEnd < (headerHeight - minimumHeaderHeight) && targetEnd > 0 {
                                    withAnimation(.interactiveSpring(response: 0.55, dampingFraction: 0.65, blendDuration: 0.65)) {
                                        scrollProxy.scrollTo("SCROLLVIEW", anchor: .top)
                                    }
                                }
                            }
                        }
                    }
                }
                .sheet(isPresented: $showNotificationSheet, content: {
                    NotificationsSheetView()
                })
                .onAppear {
//                    print("Setting currentViewID to .home from .onAppear in MyUserPublicView")
//                    appStateManager.currentViewID = .home
//                    viewModel.fetchFroops()
                }
                .onChange(of: onboardingData.friendsOnboarding) { oldValue, newValue in
                    print("friendsOnboarding changed: \(newValue)")
                }
            }
        }
        .opacity(appStateManager.appState == .passive || !appStateManager.appStateToggle ? 1.0 : 0.0)
    }
}
