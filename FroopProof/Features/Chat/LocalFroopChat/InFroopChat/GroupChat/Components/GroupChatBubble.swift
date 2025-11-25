//
//  GroupChatBubble.swift
//  FroopProof
//
//  Created by David Reed on 1/17/24.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import Combine
import UIKit

struct GroupChatBubble<Content>: View where Content: View {
    let direction: ChatBubbleShape.Direction
    let content: () -> Content
    init(direction: ChatBubbleShape.Direction, @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.direction = direction
    }
    
    var body: some View {
        HStack {
            if direction == .right {
                Spacer()
            }
            content().clipShape(ChatBubbleShape(direction: direction))
            if direction == .left {
                Spacer()
            }
        }.padding([(direction == .left) ? .leading : .trailing, .top, .bottom], 20)
            .padding((direction == .right) ? .leading : .trailing, 50)
    }
}
