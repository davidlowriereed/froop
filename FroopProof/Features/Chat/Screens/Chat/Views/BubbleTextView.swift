//
//  BubbleTextView.swift
//  FroopChatApp
//
//  Created by David Reed on 6/12/24.
//

import SwiftUI

struct BubbleTextView: View {
    let item: MessageItem
    
    var body: some View {
        
        timeStampTextView()
            .padding(.top, 10)
        
        VStack (alignment: item.horizontalAlignment, spacing: 3) {
            Text(item.text)
                .padding(.leading, item.direction == .right ? 20 : 30)
                .padding(.trailing, item.direction == .right ? 30 : 20)
                .padding(.top, 7)
                .padding(.bottom, 7)
                .foregroundColor(item.direction == .right ? .white : .black)
                .background(item.backgroundColor)
                .clipShape(BubbleShapeView(direction: item.direction))
            
            deliveredTextView()
            
        }
        .background(Color.clear)
        .shadow(color: Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0), radius: 7, x: 7, y: 7)
        .frame(maxWidth: .infinity, alignment: item.alignment)
        .padding(.leading, item.direction == .right ? 50 : 5)
        .padding(.trailing, item.direction == .right ? 5 : 50)
        
    }
    
    private func deliveredTextView() -> some View {
        HStack {
            if item.direction == .right {
                Text("Delivered")
                    .font(.system(size: 10))
                    .foregroundStyle(Color(.systemGray))
            }
        }
    }
    
    private func timeStampTextView() -> some View {
        HStack {
            Text("Thu, Jun 6 at 2:24 PM")
                .font(.system(size: 11))
                .foregroundStyle(.gray)
        }
    }
}

#Preview {
    ScrollView {
        BubbleTextView(item: .sentPlaceHolder)
        BubbleTextView(item: .receivedPlaceholder)
    }
    .frame(maxWidth: .infinity)
    .padding(.horizontal)
}
