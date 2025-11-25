//
//  DebugView.swift
//  FroopProof
//
//  Created by David Reed on 9/10/24.
//

import SwiftUI

struct DebugView<Content: View>: View {
    let content: Content
    let debugInfo: String

    init(_ debugInfo: String, @ViewBuilder content: () -> Content) {
        self.debugInfo = debugInfo
        self.content = content()
    }

    var body: some View {
        content
            .onAppear {
                print(debugInfo)
            }
    }
}
