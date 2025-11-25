//
//  MessageItem.swift
//  FroopChatApp
//
//  Created by David Reed on 6/12/24.
//

import Foundation
import SwiftUI

struct MessageItem: Identifiable {
    
    let id = UUID().uuidString
    let text: String
    let type: MessageType
    let direction: BubbleShapeView.MessageDirection
    
    static let sentPlaceHolder = MessageItem(text: "Holy Spagetti", type: .video, direction: .right)
    static let receivedPlaceholder = MessageItem(text: "This is good stuff!", type: .video, direction: .left)
    
    var alignment: Alignment {
        return direction == .left ? .leading : .trailing
    }
    
    var horizontalAlignment: HorizontalAlignment {
        return direction == .left ? .leading : .trailing
    }
    
    var backgroundColor: Color {
        return direction == .right ? Color(red: 30/255, green: 122/255, blue: 255/255) : Color(.systemGray5)
        
    }
    
    static let stubMessages: [MessageItem] = [
        MessageItem(text: "Hi There", type: .text, direction: .right),
        MessageItem(text: "Listen to this", type: .audio, direction: .left),
        MessageItem(text: "Back at you", type: .audio, direction: .right),
        MessageItem(text: "Hey", type: .text, direction: .left),
        MessageItem(text: "How was last night?", type: .text, direction: .right),
        MessageItem(text: "a blast, we took first place in the trivia all stars....   ", type: .text, direction: .left),
        MessageItem(text: "Check it!", type: .video, direction: .left),
        MessageItem(text: "", type: .photo, direction: .right),
        MessageItem(text: "amaze!", type: .text, direction: .right),
        MessageItem(text: "you should have come", type: .text, direction: .left),
        MessageItem(text: "I know, next time!", type: .text, direction: .right)
    ]
}

enum MessageType {
    case text, photo, video, audio
}

