//
//  CardsView.swift
//  Design_Layouts
//
//  Created by David Reed on 8/9/23.
//

import SwiftUI

struct CardsView: View {
    var body: some View {
        VStack(spacing: 15) {
            ForEach(1...25, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.black.opacity(0.05))
                    .frame(height: 75)
            }
        }
        .padding(15)
    }
}

struct SampleCardView_Previews: PreviewProvider {
    static var previews: some View {
        CardsView()
    }
}
