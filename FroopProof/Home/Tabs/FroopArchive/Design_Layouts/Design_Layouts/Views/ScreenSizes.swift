//
//  ScreenSizes.swift
//  Design_Layouts
//
//  Created by David Reed on 12/1/23.
//

import SwiftUI

struct ScreenSizes: View {
    var body: some View {
        VStack {
            Spacer()
            ZStack {
                Rectangle()
                    .ignoresSafeArea()
                    .frame(height: UIScreen.screenHeight * 0.15)
                Text("Confirm!")
                    .font(.system(size: 32, weight: .thin))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .frame(width: 250, height: 45)
                    .padding(.bottom, UIScreen.screenHeight * 0.05)
            }
        }
    }
}

#Preview {
    ContentView()
}



extension UIScreen{
    static let screenWidth = UIScreen.main.bounds.size.width
    static let screenHeight = UIScreen.main.bounds.size.height
    static let screenSize = UIScreen.main.bounds.size
}
