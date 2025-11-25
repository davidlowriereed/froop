//
//  FriendButtonOnboarding.swift
//  FroopProof
//
//  Created by David Reed on 5/21/24.
//

import SwiftUI

struct FriendButtonOnboarding: View {
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Circle()
                    .foregroundColor(.clear)
                    .frame(width: 45, height: 45)
                    .showCase(
                        order: 1,
                        title: "Here you can access your Friend List and your Profile.",
                        subTitle: "You will need to add Friends before you can Invite them to your Froops.",
                        cornerRadius: 20,
                        style: .continuous
                    )
                    .padding(.top, 53)
                    .padding(.trailing, 15)
            }
            Spacer()
        }
        .ignoresSafeArea()
        
        VStack {
            HStack {
                Spacer()
                Circle()
                    .foregroundColor(.clear)
                    .frame(width: 45, height: 45)
                    .showCase(
                        order: 2,
                        title: "You will need to add Friends before you can Invite them to your Froops.",
                        subTitle: "",
                        cornerRadius: 20,
                        style: .continuous
                    )
                    .padding(.top, 53)
                    .padding(.trailing, 15)
            }
            Spacer()
        }
        .ignoresSafeArea()
    }
}
