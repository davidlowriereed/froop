//
//  SimpleConversation.swift
//  FroopProof
//
//  Created by David Reed on 1/17/24.
//

import Foundation



struct SimpleConversation: Identifiable {
    let id: String
    let chatMembers: [UserData] = []
    let title: String
}
