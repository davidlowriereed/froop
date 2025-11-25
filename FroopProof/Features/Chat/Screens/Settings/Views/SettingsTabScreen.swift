//
//  SettingsTabScreen.swift
//  FroopChatApp
//
//  Created by David Reed on 6/12/24.
//

import SwiftUI

struct SettingsTabScreen: View {
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            List {
                SetteringsHeaderView()
                Section {
                    SettingsItemView(item: .broadCastLists)
                    SettingsItemView(item: .starredMessages)
                    SettingsItemView(item: .linkedDevices)
                }
                
                Section {
                    SettingsItemView(item: .account)
                    SettingsItemView(item: .privacy)
                    SettingsItemView(item: .chats)
                    SettingsItemView(item: .notifications)
                    SettingsItemView(item: .storage)
                }
                
                Section {
                    SettingsItemView(item: .help)
                    SettingsItemView(item: .tellFriend)
                }
            }
        }
        .navigationTitle("Settings")
        .searchable(text: $searchText)
    }
}

private struct SetteringsHeaderView: View {
    var body: some View {
        Section {
            HStack {
                Circle()
                    .frame(width: 55, height: 55)
                
                userInfoTextView()
            }
        }
    }
    
    private func userInfoTextView() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Qa User 13")
                    .font(.title2)
                
                Spacer()
                
                Image(systemName: "qrcode")
                    .padding(5)
                    .foregroundStyle(.blue)
                    .background(Color(.systemGray5))
                    .clipShape(Circle())
            }
            
            Text("Hey there! I am using this app!")
                .foregroundStyle(.gray)
                .font(.callout)
        }
        .lineLimit(1)
    }
}

#Preview {
    SettingsTabScreen()
}
