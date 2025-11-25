//
//  FroopSavedTemplates.swift
//  FroopProof
//
//  Created by David Reed on 6/18/23.
//

import SwiftUI

struct FroopSavedTemplates: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var froopManager = FroopManager.shared
    @ObservedObject var changeView = ChangeView.shared
    @ObservedObject var froopData = FroopData.shared

    
    var body: some View {
        ZStack {
            Color.offWhite
            VStack {
                ScrollView {
                    ForEach(froopManager.froopTemplates, id: \.froopId) { froop in
                        FroopCardView(froop: froop, froopData: froopData, froopDetailOpen: $froopManager.froopDetailOpen, invitedFriends: $froopManager.invitedFriends)
                    }
                }
            }
        }
        .ignoresSafeArea()
    }
}
