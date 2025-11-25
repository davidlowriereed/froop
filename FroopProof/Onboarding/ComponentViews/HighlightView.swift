//
//  HighlightView.swift
//  FroopProof
//
//  Created by David Reed on 9/10/24.
//

import SwiftUI

struct HighlightView: View {
    let highlight: Highlight
    let geometryProxy: GeometryProxy
    
    // Add these properties for customization
    var dialogOffset: CGPoint = CGPoint(x: 5, y: 50)
    var dialogMaxWidth: CGFloat = 300
    var dialogBackgroundColor: Color = Color.black.opacity(0.7)
    
    var body: some View {
        let highlightRect = geometryProxy[highlight.anchor]
        
        ZStack {
            // Cutout for the highlighted area
            Rectangle()
                .fill(Color.white.opacity(0.01))
                .frame(width: highlightRect.width, height: highlightRect.height)
                .position(x: highlightRect.midX, y: highlightRect.midY)
            
            // Title and subtitle
            VStack(alignment: .leading, spacing: 12) {
                Text(highlight.title)
                    .font(.title2.bold())
                    .foregroundColor(.white)
                
//                Text(highlight.subTitle)
//                    .font(.callout)
//                    .foregroundColor(.white.opacity(0.8))
            }
            .padding()
            .background(dialogBackgroundColor)
            .cornerRadius(10)
            .frame(maxWidth: dialogMaxWidth)
            .position(
                x: geometryProxy.size.width / 2 + dialogOffset.x,
                y: highlightRect.maxY + dialogOffset.y
            )
        }
    }
}
