//
//  FroopDetailsMediaView.swift
//  Design_Layouts
//
//  Created by David Reed on 6/20/23.
//

import SwiftUI

struct FroopDetailsMediaView: View {
    var body: some View {
        VStack (spacing: 0){
            ZStack {
                Rectangle()
                    .frame(height: 50)
                    .foregroundColor(.white)
                VStack {
                    Spacer()
                    
                    HStack (alignment: .center){
                        Text("Archived Media")
                            .foregroundColor(.black)
                            .font(.system(size: 18))
                            .fontWeight(.regular)
                            .opacity(0.7)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 10)
                        Spacer()
                        
                        Text("Open")
                            .foregroundColor(.black)
                            .font(.system(size: 18))
                            .fontWeight(.regular)
                            .opacity(0.7)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 10)
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
                    .foregroundColor(.red)
                    .opacity(0.2)
                HStack (alignment: .top) {
                    ZStack {
                        Image(systemName: "square.fill")
                            .font(.system(size: 75))
                            .foregroundColor(.gray)
                        Text("Upload")
                            .foregroundColor(.white)
                            .font(.system(size: 14))
                        
                    }
                    .padding(.trailing, 10)
                    
                    Divider()
                        .frame(height: 75)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack (spacing: -5) {
                            Image(systemName: "square.fill")
                                .font(.system(size: 75))
                                .foregroundColor(.gray)
                            Image(systemName: "square.fill")
                                .font(.system(size: 75))
                                .foregroundColor(.gray)
                            Image(systemName: "square.fill")
                                .font(.system(size: 75))
                                .foregroundColor(.gray)
                            Image(systemName: "square.fill")
                                .font(.system(size: 75))
                                .foregroundColor(.gray)
                            Image(systemName: "square.fill")
                                .font(.system(size: 75))
                                .foregroundColor(.gray)
                        }
                    }

                }
                .padding(.trailing, 25)
                .padding(.leading, 25)
            }
            Divider()

        }
    }
}

struct FroopDetailsMediaView_Previews: PreviewProvider {
    static var previews: some View {
        FroopDetailsMediaView()
    }
}
