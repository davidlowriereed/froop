//
//  PCCompletionTitleView.swift
//  FroopProof
//
//  Created by David Reed on 1/19/23.
//

import SwiftUI
import UIKit
import iPhoneNumberField

struct ProfileCompletionTitleView: View {
    @ObservedObject var myData = MyData.shared

    var body: some View {
        ZStack {
            ZStack(alignment: .center) {
                VStack {
                    Spacer()
                    Rectangle()
                        .foregroundColor(.black)
                        .offset(y: 9)
                        .frame(width: UIScreen.screenWidth, height: 10)
                }
                Rectangle()
                    .foregroundColor(Color("FroopPink"))
            }
            ZStack {
                VStack {
                    HStack {
                        AdaptiveImage(
                            light:
                                Image("FroopLogo_Full_White")
                                    .resizable(),
                            dark:
                                Image("FroopLogo_Full_White")
                                    .resizable()
                        )
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 24, alignment: .center)
                        .accessibility(hidden: true)
                        .padding(.top, 100)
                        .padding(.leading, 25)
                        Spacer()
                    }
                    Spacer()
                }
                VStack {
                    (
                        Text("Coordinate with ease, ").froopTextStyle(opacity: 0.75) +
                        Text("connect meaningfully. ").froopTextStyle(opacity: 1.0) +
                        Text("Your events, reimagined with Froop.").froopTextStyle(opacity: 0.75)
                    )
                    .frame(width: UIScreen.screenWidth * 0.9)
                    .padding(.top, UIScreen.screenHeight * 0.3)
                    .font(.system(size: 42))
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .multilineTextAlignment(.leading)
                    .padding(.leading, 25)
                    .padding(.trailing, 25)
                    
                    Spacer()
                }
            }
            .ignoresSafeArea()
        }
        .ignoresSafeArea()
    }
}

struct ProfileCompletionTitleView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileCompletionTitleView()
    }
}

extension Text {
    func froopTextStyle(opacity: Double) -> Text {
        self
            .font(.system(size: 42))
            .fontWeight(.bold)
            .foregroundColor(Color.white.opacity(opacity))
    }
}
