//
//  DetailsGuestView.swift
//  Design_Layouts
//
//  Created by David Reed on 6/20/23.
//

import SwiftUI

struct DetailsGuestView: View {
    var body: some View {
        VStack (spacing: 0){
            ZStack {
                Rectangle()
                    .frame(height: 75)
                    .foregroundColor(.white)
                VStack {
                    Spacer()
                    HStack {
                        Text("Invited Guests")
                            .foregroundColor(.black)
                            .opacity(0.5)
                            .font(.system(size: 12))
                            .fontWeight(.semibold)
                        Spacer()
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: 125, height: 25)
                                .foregroundColor(.black)
                                .opacity(0.05)
                            Text("Confirmed Guests")
                                .foregroundColor(.black)
                                .opacity(0.5)
                                .font(.system(size: 12))
                                .fontWeight(.semibold)
                        }
                        Spacer()
                        Text("Declined Guests")
                            .foregroundColor(.black)
                            .opacity(0.5)
                            .font(.system(size: 12))
                            .fontWeight(.semibold)
                    }
                    .padding(.bottom, 10)
                    .padding(.trailing, 25)
                    .padding(.leading, 25)
                }
                .frame(maxHeight: 75)
            }
            
            ZStack {
                Rectangle()
                    .frame(height: 125)
                    .foregroundColor(.black)
                    .opacity(0.05)
                HStack {
                    VStack {
                        Circle()
                            .frame(width: 50)
                            .foregroundColor(.white)
                        Text("Robert D.")
                            .font(.system(size: 12))
                            .fontWeight(.light)
                            .foregroundColor(.black)
                            .opacity(0.5)
                    }
                    Spacer()
                    VStack {
                        Circle()
                            .frame(width: 50)
                            .foregroundColor(.white)
                        Text("Robert D.")
                            .font(.system(size: 12))
                            .fontWeight(.light)
                            .foregroundColor(.black)
                            .opacity(0.5)
                    }
                    Spacer()
                    VStack {
                        Circle()
                            .frame(width: 50)
                            .foregroundColor(.white)
                        Text("Robert D.")
                            .font(.system(size: 12))
                            .fontWeight(.light)
                            .foregroundColor(.black)
                            .opacity(0.5)
                    }
                    Spacer()
                    VStack {
                        Circle()
                            .frame(width: 50)
                            .foregroundColor(.white)
                        Text("Robert D.")
                            .font(.system(size: 12))
                            .fontWeight(.light)
                            .foregroundColor(.black)
                            .opacity(0.5)
                    }
                    Spacer()
                    VStack {
                        Circle()
                            .frame(width: 50)
                            .foregroundColor(.white)
                        Text("Robert D.")
                            .font(.system(size: 12))
                            .fontWeight(.light)
                            .foregroundColor(.black)
                            .opacity(0.5)
                    }
                }
                .padding(.trailing, 25)
                .padding(.leading, 25)
            }
        }
        Divider()
    }
}

struct DetailsGuestView_Previews: PreviewProvider {
    static var previews: some View {
        DetailsGuestView()
    }
}
