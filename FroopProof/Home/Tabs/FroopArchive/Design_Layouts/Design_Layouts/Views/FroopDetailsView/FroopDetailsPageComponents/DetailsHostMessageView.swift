//
//  DetailsHostMessageView.swift
//  Design_Layouts
//
//  Created by David Reed on 6/20/23.
//

import SwiftUI

struct DetailsHostMessageView: View {
    var body: some View {
        VStack (spacing: 0){
            ZStack {
                Rectangle()
                    .frame(height: 50)
                    .foregroundColor(.white)
                VStack {
                    Spacer()
                    
                    HStack (alignment: .center){
                        Text("Message from the Host")
                            .foregroundColor(.black)
                            .font(.system(size: 18))
                            .fontWeight(.regular)
                            .opacity(0.7)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 10)
                        Spacer()
                    }
                    .padding(.trailing, 25)
                    .padding(.leading, 25)
                }
                .frame(maxHeight: 50)
            }
            Divider()
            
            ZStack {
                Rectangle()
                    .frame(height: 100)
                    .foregroundColor(.white)
                    .opacity(0.2)
                HStack (alignment: .top) {
                    ZStack {
                        Rectangle()
                            .frame(maxWidth: 50, maxHeight:75)
                            .foregroundColor(.gray)
                        Image(systemName: "play.circle")
                            .foregroundColor(.white)
                            .font(.system(size: 24))
                    }
                    .padding(.trailing, 10)
                    Text ("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam.")
                        .font(.system(size: 16))
                        .fontWeight(.light)
                    
                    
                }
                .padding(.trailing, 25)
                .padding(.leading, 25)
            }
            
        }
    }
}

struct DetailsHostMessageView_Previews: PreviewProvider {
    static var previews: some View {
        DetailsHostMessageView()
    }
}
