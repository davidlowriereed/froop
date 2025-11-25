//
//  IdentifiableFriendData.swift
//  FroopProof
//
//  Created by David Reed on 3/29/23.
//

import SwiftUI

struct IdentifiableFriendData: Identifiable {
    let id = UUID()
    let friendData: UserData
}
