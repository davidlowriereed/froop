//
//  ChannelItemView.swift
//  FroopChatApp
//
//  Created by David Reed on 6/12/24.
//

import SwiftUI

struct SuggestedChannelItemView: View {
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .frame(width: 55, height: 55)
            
            VStack(alignment: .leading, spacing: 3) {
                titleTextView()
                lastMessagePreview()
            }
        }
    }
    
    private func titleTextView() -> some View {
        HStack {
            Text("Qauser12")
                .lineLimit(1)
                .bold()
            
            Spacer()
                
            Text("5:50 PM")
                .foregroundStyle(.gray)
                .font(.system(size: 15))
        }
    }
    
    private func lastMessagePreview() -> some View {
        Text("Hey, welcome")
            .font(.system(size: 16))
            .lineLimit(2)
            .foregroundStyle(.gray)
    }
    
}

#Preview {
    SuggestedChannelItemView()
}
