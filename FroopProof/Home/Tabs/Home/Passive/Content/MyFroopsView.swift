//
//  MyFroopsView.swift
//  FroopProof
//
//  Created by David Reed on 5/18/23.
//

import SwiftUI

struct MyFroopsView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var navLocationServices = NavLocationServices.shared
    @ObservedObject var froopDataListener = FroopDataListener.shared
    @ObservedObject var timeZoneManager: TimeZoneManager = TimeZoneManager()
    @State private var isLoading = true
    @State private var openFroops: Set<UUID> = []

    @ObservedObject var viewModel: MyFroopsViewModel
    
    @Binding var friendDetailOpen: Bool
    
    @State private var currentIndex: Int = 0
    @State private var thisFroopType: String = ""
    
    var body: some View {
        ZStack(alignment: .top) {
            Rectangle()
                .frame(height: 1200)
                .foregroundColor(.white)
                .opacity(0.1)
            
            if viewModel.selectedTab == 0 {
                homeView
                    .transition(.opacity)
            } else {
                froopsView
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: viewModel.selectedTab)
        .onAppear {
            print("MyFroopsView appeared, displayedFroops count: \(viewModel.displayedFroops.count)")
            print("sortedUniqueFroopsForSelectedFriend count: \(viewModel.sortedUniqueFroopsForSelectedFriend.count)")
            print("sortedFroopsForUser count: \(viewModel.sortedFroopsForUser.count)")
            
            // Simulate a short loading time for smooth transition
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    isLoading = false
                }
            }
        }
    }
    
    var homeView: some View {
        VStack {
            if isLoading {
                ProgressView("Loading Froops...")
            } else if viewModel.sortedUniqueFroopsForSelectedFriend.isEmpty {
                Text("No Froops to display")
                    .transition(.opacity)
            } else {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(viewModel.sortedUniqueFroopsForSelectedFriend) { wrapper in
                        MyCardsView(froopHistory: wrapper.froopHistory, thisFroopType: thisFroopType, friendDetailOpen: $friendDetailOpen)
                            .transition(.opacity)
                            .animation(.easeInOut, value: wrapper.id)
                    }
                }
                .animation(.easeInOut, value: viewModel.sortedUniqueFroopsForSelectedFriend.count)
            }
            Spacer()
        }
        .padding(.bottom, 75)
    }
    
    var froopsView: some View {
        VStack {
            if isLoading {
                ProgressView("Loading Froops...")
            } else if viewModel.sortedFroopsForUser.isEmpty {
                Text("No Froops to display")
                    .transition(.opacity)
            } else {
                ScrollView {
                    LazyVStack(alignment: .center, spacing: 5) {
                        // Future Froops
                        ForEach(viewModel.futureFroops) { wrapper in
                            MyMinCardsViewActive(
                                openFroop: Binding(
                                    get: { openFroops.contains(wrapper.id) },
                                    set: { newValue in
                                        if newValue {
                                            openFroops.insert(wrapper.id)
                                        } else {
                                            openFroops.remove(wrapper.id)
                                        }
                                    }
                                ),
                                froopHistory: wrapper.froopHistory
                            )
                            .id(wrapper.id)
                            .transition(.opacity)
                        }
                        .padding(.top, 10)
                        
                        // Spacer or Divider between future and past Froops
                        if !viewModel.futureFroops.isEmpty && !viewModel.pastFroops.isEmpty {
                            ZStack {
                                Rectangle()
                                    .foregroundColor(.white)
                                    .frame(height: 50)
                                    .ignoresSafeArea()
                                VStack(spacing: 5) {
                                    Divider()
                                    Text("PAST FROOPS")
                                        .font(.system(size: 10))
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color(.black).opacity(0.5))
                                        .padding(.top, 10)
                                }
                                .padding(.vertical, 10)
                            }
                        }
                        
                        // Past Froops
                        ForEach(viewModel.pastFroops) { wrapper in
                            MyMinCardsViewActive(
                                openFroop: Binding(
                                    get: { openFroops.contains(wrapper.id) },
                                    set: { newValue in
                                        if newValue {
                                            openFroops.insert(wrapper.id)
                                        } else {
                                            openFroops.remove(wrapper.id)
                                        }
                                    }
                                ),
                                froopHistory: wrapper.froopHistory
                            )
                            .id(wrapper.id)
                            .transition(.opacity)
                        }
                        .padding(.top, 10)

                        hiddenFroopsToggle
                        if viewModel.showHiddenFroops {
                            hiddenFroopsList
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
//                    .padding(.top, 10)
                    .animation(.easeInOut, value: viewModel.sortedFroopsForUser.count)
                }
            }
            Spacer()
        }
        .animation(.easeInOut, value: viewModel.showHiddenFroops)
    }
    
    var hiddenFroopsToggle: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(.white).opacity(1)
                .frame(width: UIScreen.screenWidth * 0.9, height: 50)
                .shadow(color: Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.2), radius: 4, x: 4, y: 4)
                .shadow(color: Color.white.opacity(0.9), radius: 4, x: -4, y: -4)
            Text(viewModel.showHiddenFroops ?
                 viewModel.sortedHiddenFroopsForUser.isEmpty ? "No Hidden Froops" : "Close Hidden View" :
                    viewModel.sortedHiddenFroopsForUser.isEmpty ? "No Hidden Froops" : "Show Hidden Froops")
            .font(.system(size: 18))
            .fontWeight(.light)
            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.75))
        }
        .padding(.horizontal, UIScreen.screenWidth * 0.05)
        .padding(.vertical, UIScreen.screenWidth * 0.05)
        .onTapGesture {
            viewModel.toggleHiddenFroops()
        }
    }
    
    var hiddenFroopsList: some View {
        ForEach(viewModel.sortedHiddenFroopsForUser) { wrapper in
            MyMinCardsViewActive(
                openFroop: Binding(
                    get: { openFroops.contains(wrapper.id) },
                    set: { newValue in
                        if newValue {
                            openFroops.insert(wrapper.id)
                        } else {
                            openFroops.remove(wrapper.id)
                        }
                    }
                ), froopHistory: wrapper.froopHistory
            )
            .id(wrapper.id)
            .transition(.opacity.combined(with: .slide))
            .animation(.easeInOut, value: wrapper.id)
        }
    }
}


extension MyFroopsViewModel {
    var futureFroops: [FroopHistoryWrapper] {
        let now = Date()
        return sortedFroopsForUser.filter { $0.froopHistory.froop.froopStartTime > now }
    }
    
    var pastFroops: [FroopHistoryWrapper] {
        let now = Date()
        return sortedFroopsForUser.filter { $0.froopHistory.froop.froopStartTime <= now }
    }
}


