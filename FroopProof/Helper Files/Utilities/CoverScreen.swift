//
//  CoverScreen.swift
//  FroopProof
//
//  Created by David Reed on 9/17/24.
//

import SwiftUI

struct CoverScreen: View {
    @ObservedObject var appStateManager = AppStateManager.shared
    @State private var opacity: Double = 1.0
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            Color("FroopPink").edgesIgnoringSafeArea(.all)
            
            VStack {
                Image("FroopLogo_Full_White")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                    .padding(.top, 30)
            }
        }
        .opacity(opacity)
        .scaleEffect(scale)
        .onChange(of: appStateManager.showCoverScreen) { _, newValue in
            if !newValue {
                animateOut()
            }
        }
        .onAppear {
            // Start a timer when the view appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                animateOut()
            }
        }
    }
    
    private func animateOut() {
        withAnimation(.easeInOut(duration: 0.5)) {
            opacity = 0
            scale = 1.2
        }
        
        // After animation, set showCoverScreen to false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            appStateManager.showCoverScreen = false
        }
    }
}
