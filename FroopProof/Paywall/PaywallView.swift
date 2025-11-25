//
//  PaywallView.swift
//  FroopProof
//
//  Created by David Reed on 1/25/24.
//

import SwiftUI
import RevenueCat
import RevenueCatUI


struct PaywallView: View {
    @ObservedObject var manager = PayWallManager.shared

    var body: some View {
        VStack {
            Button("Subscription View") {
                withAnimation(.easeInOut(duration: 0.5)) {
                    manager.showIAPView.toggle()
                }
            }
            .buttonStyle(.borderedProminent)
            .foregroundStyle(Color(red: 50/255, green: 46/255, blue: 62/255))
            .tint(.white)
        }
        
        CustomPayWallView(
            model: $manager.model
            
        )
//        .offset(y: manager.showIAPView ? 0 : UIScreen.main.bounds.height)
        .edgesIgnoringSafeArea(.all)
        .opacity(manager.showIAPView ? 1 : 0)
        .task {
            if manager.showIAPView {
                do {
                    try await manager.fetchPaywallData()
                } catch {
                    print(error.localizedDescription)
                    manager.showDefaultView = true
                }
            }
        }
    }
    
    
}
