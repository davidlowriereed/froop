//
//  DetailsHeaderView.swift
//  Design_Layouts
//
//  Created by David Reed on 6/20/23.
//

import SwiftUI

struct DetailsHeaderView: View {
    var body: some View {
        ZStack {
            Rectangle()
                .frame(height: 165)
                .opacity(0.8)
            
            HStack {
                Circle()
                    .frame(width: 75)
                    .foregroundColor(.white)
                
                VStack (alignment: .leading){
                    Text("Froop Title")
                        .foregroundColor(.white)
                        .font(.system(size: 24))
                    Text("Froop Host")
                        .foregroundColor(.white)
                        .font(.system(size: 14))
                }
                Spacer()
                
                Text ("Edit")
                    .foregroundColor(.white)
                
            }
            .padding(.top, 60)
            .padding(.trailing, 25)
            .padding(.leading, 25)
        }
        Divider()
    }
}

struct DetailsHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        DetailsHeaderView()
    }
}
