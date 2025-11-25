//
//  GroupMessageRow.swift
//  FroopProof
//
//  Created by David Reed on 1/17/24.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import Combine
import UIKit


struct GroupMessageRow: View {
    let message: Message
    let senderFirstName: String
    let senderLastName: String
    let isCurrentUser: Bool
    


    var body: some View {
        VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 0) {
            if !isCurrentUser {
                Text("\(senderFirstName) \(senderLastName)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .offset(y: 15)
                    .padding(.leading, 30)
            }
            ChatBubble(direction: isCurrentUser ? .right : .left) {
                Text(message.text)
                    .frame(minWidth: 20)
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                .background(isCurrentUser ? Color(red: 249/255, green: 0/255, blue: 98/255) : Color(red: 0/255, green: 133/255, blue: 151/255).opacity(1))            }
        }
    }
}
