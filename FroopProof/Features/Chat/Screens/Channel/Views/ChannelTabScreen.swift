//
//  ChannelTabScreen.swift
//  FroopChatApp
//
//  Created by David Reed on 6/12/24.
//

import SwiftUI

struct ChannelTabScreen: View {
    @State private var searchText = ""
    var body: some View {
        NavigationStack {
            List {
                
                archiveButton()
                
                ForEach(0..<12) { _ in
                    NavigationLink {
                        ChatRoomScreen()
                    } label: {
                        SuggestedChannelItemView()
                    }
                }
                
                inboxFooterView()
                    .listRowSeparator(.hidden)
                
            }
            .navigationTitle("Chats")
            .searchable(text: $searchText)
            .listStyle(.plain)
            .toolbar {
                leadingNavItem()
                
                trailingNavItem()
                
            }
        }
    }
}

extension ChannelTabScreen {
    @ToolbarContentBuilder
    private func leadingNavItem() -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Menu {
                Button {
                    
                } label: {
                    Label("Select Chats", systemImage: "checkmark.circle")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        }
    }
    
    @ToolbarContentBuilder
    private func trailingNavItem() -> some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            aiButton()
            cameraButton()
            newChatButton()
        
        }
    }
    
    private func aiButton() -> some View {
        Button {
            
        } label: {
            ZStack {
                Image(systemName: "circle.fill")
                    .foregroundColor(.pink)
                Image(systemName: "circle.fill")
                    .foregroundColor(.white)
                    .scaleEffect(0.7)
            }
        }
    }
    
    private func cameraButton() -> some View {
        Button {
            
        } label: {
            Image(systemName: "camera")
                .foregroundColor(.black)
        }
    }
    
    private func newChatButton() -> some View {
        Button {
            
        } label: {
            ZStack {
                Image(systemName: "circle.fill")
                    .foregroundColor(.blue)
                Image(systemName: "plus")
                    .foregroundColor(.white)
                    .font(.system(size: 11))
                    .fontWeight(.bold)
            }
        }
    }
    
    private func archiveButton() -> some View {
        Button {
            
        } label: {
            Label("Archived", systemImage: "archivebox.fill")
                .bold()
                .padding()
                .foregroundColor(.gray)
        }
    }
}

private func inboxFooterView() -> some View {
    HStack {
        Image(systemName: "lock.fill")
        (
        Text("Your personal messages are ")
        +
        Text("end-to-end encrypted")
        )
    }
    .foregroundStyle(.gray)
    .font(.caption)
    .padding()
}

#Preview {
    ChannelTabScreen()
}
