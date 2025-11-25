//
//  FroopLandingView.swift
//  Design_Layouts
//
//  Created by David Reed on 8/9/23.
//

import SwiftUI

import SwiftUI

struct FroopLandingView: View {
    var size: CGSize
    var safeArea: EdgeInsets
    
    @State private var offsetY: CGFloat = 0
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    ProfileHeaderView(offsetY: $offsetY, size: size, safeArea: safeArea)
                        .zIndex(1000)
                    
                    CardsView()
                }
                .id("SCROLLVIEW")
                .background {
                    ScrollDetector { offset in
                        offsetY = -offset
                    } onDraggingEnd: { offset, velocity in
                        /// Resetting to Intial State, if not Completely Scrolled
                        let headerHeight = (size.height * 0.3) + safeArea.top
                        let minimumHeaderHeight = 65 + safeArea.top
                        
                        let targetEnd = offset + (velocity * 45)
                        if targetEnd < (headerHeight - minimumHeaderHeight) && targetEnd > 0 {
                            withAnimation(.interactiveSpring(response: 0.55, dampingFraction: 0.65, blendDuration: 0.65)) {
                                scrollProxy.scrollTo("SCROLLVIEW", anchor: .top)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct FroopLandingView_Previews: PreviewProvider {
    static var previews: some View {
        FroopLandingPage()
    }
}

extension View {
    func moveText(_ progress: CGFloat, _ headerHeight: CGFloat, _ headerWidth: CGFloat, _ minimumHeaderHeight: CGFloat, _ minimumHeaderWidth: CGFloat) -> some View {
        self
            .hidden()
            .overlay {
                GeometryReader { proxy in
                    let rect = proxy.frame(in: .global)
                    let midY = rect.midY
                    let midX = rect.midX
                    /// Half Scaled Text Height (Since Text Scaling will be 0.85 (1 - 0.15))
                    let halfScaledTextHeight = (rect.height * 0.85) / 2
                    let halfScaledTextWidth = (rect.width * 0.85) / 2
                    /// Profile Image
                    let profileImageHeight = (headerHeight * 0.9)
                    let profileImageWidth = (headerWidth * 0.9)
                    /// Since Image Scaling will be 0.3 (1 - 0.7)
                    let scaledImageHeight = profileImageHeight * 0.3
                    let scaledImageWidth = profileImageWidth * 0.3
                    let halfScaledImageHeight = scaledImageHeight / 2
                    let halfScaledImageWidth = scaledImageWidth / 2
                    /// Applied VStack Spacing is 15
                    /// 15 / 0.3 = 4.5 (0.3 -> Image Scaling)
                    let vStackSpacing: CGFloat = 4.5
                    let resizedOffsetY = (midY - (minimumHeaderHeight - halfScaledTextHeight - vStackSpacing - scaledImageHeight))
                    let resizedOffsetX = (midX - (minimumHeaderWidth - halfScaledTextWidth + vStackSpacing + halfScaledImageWidth + scaledImageWidth + 25))
                    
                    self
                        .scaleEffect(1 - (progress * 0.15))
                        .offset(y: -resizedOffsetY * progress)
                        .offset(x: -resizedOffsetX * progress)
                }
            }
    }
    func moveSymbols(_ progress: CGFloat, _ headerHeight: CGFloat, _ headerWidth: CGFloat, _ minimumHeaderHeight: CGFloat, _ minimumHeaderWidth: CGFloat) -> some View {
        self
            .hidden()
            .overlay {
                GeometryReader { proxy in
                    let rect = proxy.frame(in: .global)
                    let midY = rect.midY
                    let midX = rect.midX
                    /// Half Scaled Text Height (Since Text Scaling will be 0.85 (1 - 0.15))
                    let halfScaledTextHeight = (rect.height * 0.85) / 2
                    let halfScaledTextWidth = (rect.width * 0.85) / 2
                    /// Profile Image
                    let profileImageHeight = (headerHeight * 0.9)
                    let profileImageWidth = (headerWidth * 0.9)
                    /// Since Image Scaling will be 0.3 (1 - 0.7)
                    let scaledImageHeight = profileImageHeight * 0.3
                    let scaledImageWidth = profileImageWidth * 0.3
                    let halfScaledImageHeight = scaledImageHeight / 2
                    let halfScaledImageWidth = scaledImageWidth / 2
                    /// Applied VStack Spacing is 15
                    /// 15 / 0.3 = 4.5 (0.3 -> Image Scaling)
                    let vStackSpacing: CGFloat = 4.5
                    let resizedOffsetY = (midY - (minimumHeaderHeight - halfScaledTextHeight - vStackSpacing - scaledImageHeight))
                    let resizedOffsetX = (midX - (minimumHeaderWidth - halfScaledTextWidth + vStackSpacing + halfScaledImageWidth + scaledImageWidth + 300))
                    
                    self
                        .scaleEffect(1 - (progress * 0.15))
                        .offset(y: -resizedOffsetY * progress)
                        .offset(x: -resizedOffsetX * progress)
                }
            }
    }
}
