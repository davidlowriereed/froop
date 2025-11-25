//
//  DetailsAddFriendsView.swift
//  FroopProof
//
//  Created by David Reed on 6/21/23.
//

import SwiftUI

struct DetailsAddFriendsView: View {
    
    var body: some View {
        
        VStack {
            HStack {
                ZStack (alignment: .center) {
                    Rectangle()
                        .foregroundColor(.black)
                        .opacity(0.75)
                        .frame(maxWidth: .infinity, maxHeight: 100)
                        .ignoresSafeArea()
                    
                    Button {
                        print("pressed")
                    } label:{
                        HStack (alignment: .center) {
                            Spacer()
                            Image(systemName: "plus")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
//                                .frame(width: 50, height: 50)
                                .padding(.bottom, 25)
                                .padding(.trailing, 0)
                            Text("INVITE PEOPLE")
                                .font(.system(size: 18, weight: .thin))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
//                                .frame(width: 125, height: 50)
                                .padding(.bottom, 25)
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                }
                
            }
        }
        .ignoresSafeArea()
    }
}



struct DetailsAddFriendsView_Previews: PreviewProvider {
    static var previews: some View {
        DetailsAddFriendsView()
    }
}
