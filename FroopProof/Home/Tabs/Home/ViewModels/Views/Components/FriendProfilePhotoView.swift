//
//  FriendProfilePhotoView.swift
//  FroopProof
//
//  Created by David Reed on 2/6/23.
//

import SwiftUI
import Kingfisher

struct FriendProfilePhotoView: View {
    var imageUrl: String
    
    var body: some View {
        ZStack {
            Circle()
                .frame(width: 45, height: 45)
            KFImage(URL(string: imageUrl))
                .resizable()
                .scaledToFill()
                .frame(width: 45, height: 45)
                .clipShape(Circle())
                
            
        }
    }
}


