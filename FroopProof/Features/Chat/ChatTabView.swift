//
//  MainTabView.swift
//  FroopChatApp
//
//  Created by David Reed on 6/11/24.
//

import SwiftUI

struct ChatTabView: View {
    
    init() {
        makeTabBarOpaque()
        let thumbImage = UIImage(systemName: "circle.fill")
        UISlider.appearance().setThumbImage(thumbImage, for: .normal)
    }

    var body: some View {
        TabView {
//            UpdatesTabScreen()
            Text("One")
                .tabItem {
                    Image(systemName: Tab.updates.icon)
                    Text(Tab.updates.title)
                }

//            CallsTabScreen()
            Text("Two")
                .tabItem {
                    Image(systemName: Tab.calls.icon)
                    Text(Tab.calls.title)
                }

//            CommunityTabScreen()
            Text("Three")
                .tabItem {
                    Image(systemName: Tab.communities.icon)
                    Text(Tab.communities.title)
                }

//            ChannelTabScreen()
            Text("Four")
                .tabItem {
                    Image(systemName: Tab.chats.icon)
                    Text(Tab.chats.title)
                }

//            SettingsTabScreen()
            Text("Five")
                .tabItem {
                    Image(systemName: Tab.settings.icon)
                    Text(Tab.settings.title)
                }
        }
    }

    private func makeTabBarOpaque() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

extension ChatTabView {
    private enum Tab: String {
        case updates,
             calls,
             communities,
             chats,
             settings

        var title: String {
            rawValue.capitalized
        }

        var icon: String {
            switch self {
                case .updates:
                    return "message.circle"
                case .calls:
                    return "phone.fill"
                case .communities:
                    return "person.3.fill"
                case .chats:
                    return "message.fill"
                case .settings:
                    return "gear"
            }
        }
    }
}

extension ChatTabView {
    private func placeholderItemView(_ title: String) -> some View {
        ScrollView {
            VStack {
                ForEach(0..<120) { _ in
                    Text(title)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .frame(height: 120)
                        .background(.green)
                    
                }
            }
        }
        
    }
}

#Preview {
    ChatTabView()
}

