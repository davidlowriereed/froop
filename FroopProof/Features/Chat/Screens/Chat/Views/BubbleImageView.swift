//
//  BubbleImageView.swift
//  FroopChatApp
//
//  Created by David Reed on 6/13/24.
//

import SwiftUI

struct BubbleImageView: View {
    let item: MessageItem
    
    var body: some View {
        HStack {
            if item.direction == .right { Spacer() }
            
            HStack {
                
                if item.direction == .right { shareButton() }
                
                messageTextView()
                    .shadow(color: Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0), radius: 7, x: 7, y: 7)
                    .overlay{
                        playButton()
                            .opacity(item.type == .video ? 1 : 0)
                    }
                
                if item.direction == .left { shareButton() }
            }
            if item.direction == .left { Spacer() }
        }
        .background(Color.clear)
        .shadow(color: Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0), radius: 7, x: 7, y: 7)
        .frame(maxWidth: .infinity, alignment: item.alignment)
        .padding(.leading, item.direction == .right ? 50 : 5)
        .padding(.trailing, item.direction == .right ? 5 : 50)
    }
    
    private func messageTextView() -> some View {
        VStack (alignment: .leading, spacing: 0) {
            Image(.stub)
                .resizable()
                .scaledToFill()
                .frame(width: 220, height: 180)
                .clipShape(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                )
                .background {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color(.systemGray5))
                    
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(Color(.systemGray5))
                )
                .padding(5)
                .overlay(alignment: .bottomTrailing) {
                    timeStampTextView()
                }
                .padding(.leading, item.direction == .right ? 1 : 5)
                .padding(.trailing, item.direction == .right ? 5 : 1)
            if item.text != "" {
                Text(item.text)
                    .foregroundColor(item.direction == .right ? .white : .black)
                    .padding(.leading, item.direction == .right ? 20 : 30)
                    .padding(.trailing, item.direction == .right ? 30 : 20)
                    .padding(.top, 7)
                    .padding(.bottom, 7)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(width: 220)
                    .background(item.backgroundColor)
                    .clipShape(BubbleShapeView(direction: item.direction))
            }
        }
    }
    
    private func playButton() -> some View {
        Image(systemName: "play.fill")
            .padding()
            .imageScale(.large)
            .foregroundStyle(.white)
            .background(.ultraThinMaterial)
            .clipShape(Circle())
    }
    
    private func shareButton() -> some View {
        Button {
            
        } label: {
            Image(systemName: "arrowshape.turn.up.right.fill")
                .padding(10)
                .foregroundStyle(.white)
                .background(.gray)
                .background(.thinMaterial)
                .clipShape(Circle())
        }
    }
    
    private func timeStampTextView() -> some View {
        HStack {
            Text("11:35 AM")
                .font(.system(size: 12))
                .bold()

            if item.direction == .right {
                Image(systemName: "checkmark")
                    .font(.system(size: 10))
                    .bold()
            }
        }
        .padding(.vertical, 2.5)
        .padding(.horizontal, 8)
        .foregroundStyle(.white)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .padding(12)
    }
    
}

#Preview {
    ScrollView {
        BubbleImageView(item: .sentPlaceHolder)
        BubbleImageView(item: .receivedPlaceholder)
    }
    .frame(maxWidth: .infinity)
    .padding(.horizontal)
    .background(.white)
}
