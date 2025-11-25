//
//  SaveProgressView.swift
//  FroopProof
//
//  Created by David Reed on 6/19/23.
//

import SwiftUI

struct SaveProgressView: View {
    @Binding var progress: Double
    @Binding var status: String
    
    var body: some View {
        VStack {
            Text(status)
            ProgressView(value: progress, total: 100)
                .progressViewStyle(LinearProgressViewStyle())
        }
    }
}


