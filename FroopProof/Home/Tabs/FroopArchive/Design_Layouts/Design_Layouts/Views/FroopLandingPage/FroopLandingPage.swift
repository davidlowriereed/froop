//
//  FroopLandingPage.swift
//  Design_Layouts
//
//  Created by David Reed on 8/9/23.
//

import SwiftUI

struct FroopLandingPage: View {
    var body: some View {
        GeometryReader {
            let size = $0.size
            let safeArea = $0.safeAreaInsets
            
            FroopLandingView(size: size, safeArea: safeArea)
                .ignoresSafeArea(.all, edges: .top)
        }
    }
}

struct FroopLandingPage_Previews: PreviewProvider {
    static var previews: some View {
        FroopLandingPage()
    }
}
