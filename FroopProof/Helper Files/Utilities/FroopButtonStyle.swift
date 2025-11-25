//
//  FroopButtonStyle.swift
//  FroopProof
//
//  Created by David Reed on 3/29/23.
//

import SwiftUI

struct FroopButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? Color.white : Color.clear)
    }
}
