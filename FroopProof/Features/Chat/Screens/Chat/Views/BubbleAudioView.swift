//
//  BubbleAudioView.swift
//  FroopChatApp
//
//  Created by David Reed on 6/13/24.
//

import SwiftUI

struct BubbleAudioView: View {
    let item: MessageItem
    @State private var sliderValue: Double = 0
    @State private var sliderRange: ClosedRange<Double> = 0...20
    
    var body: some View {
        timeStampTextView()
            .padding(.top, 10)
        VStack (alignment: item.horizontalAlignment, spacing: 3) {
            
            HStack {
                playButton()
                Slider(value: $sliderValue, in: sliderRange)
                    .tint(.gray)
                Text("05:40")
                    .foregroundColor(item.direction == .right ? .white : .black)
                    .opacity(0.5)
            }
            .padding(10)
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .padding(.leading, item.direction == .right ? 10 : 15)
            .padding(.trailing, item.direction == .right ? 15 : 10)
            .padding(.top, 5)
            .padding(.bottom, 5)
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
    
    private func playButton() -> some View {
        Button {
            
        } label: {
            Image(systemName: "play.fill")
                .font(.system(size: 16))
                .padding(10)
                .background(item.direction == .right ? .white : .black)
                .clipShape(Circle())
                .foregroundStyle(item.direction == .right ? item.backgroundColor : item.backgroundColor)
        }
    }
    
}

#Preview {
    ScrollView {
        BubbleAudioView(item: .sentPlaceHolder)
        BubbleAudioView(item: .receivedPlaceholder)
    }
    .frame(maxWidth: .infinity)
    .padding(.horizontal)
    .onAppear {
        let thumbImage = UIImage(systemName: "circle.fill")
        UISlider.appearance().setThumbImage(thumbImage, for: .normal)
    }
}
