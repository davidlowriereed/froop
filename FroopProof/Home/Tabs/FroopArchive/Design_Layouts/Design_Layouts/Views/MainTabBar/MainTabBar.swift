//
//  MainTabBar.swift
//  Design_Layouts
//
//  Created by David Reed on 8/4/23.
//

import SwiftUI

enum Tab: String, CaseIterable {
    case house
    case person
    case froop
    case clock
    case message
}

struct SimpleFroopTabBar: View {
    @State private var selectedTab: Tab = .house
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(Tab.allCases, id: \.self) { tab in
                switch tab {
                case .froop:
                    ContentView() // You need to provide this View
                        .tabItem {
                            Image("pink_logo")
                                .resizable()
                                .frame(minWidth: 30, maxWidth: 30)
                                .scaledToFit()
                               
                            Text(tab.rawValue.capitalized)
                        }.tag(tab)

                default:
                    Text(tab.rawValue.capitalized)
                        .tabItem {
                            Image(systemName: tab.rawValue)
                            Text(tab.rawValue.capitalized)
                        }.tag(tab)
                }
            }
        }
    }
}

struct SimpleFroopTabBar_Previews: PreviewProvider {
    static var previews: some View {
        SimpleFroopTabBar()
    }
}
