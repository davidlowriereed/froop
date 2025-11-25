//
//  OnboardOne.swift
//  Design_Layouts
//
//  Created by David Reed on 9/21/23.
//

import SwiftUI

struct OnboardFour: View {
    @State var address: String = ""
    @State var city: String = ""
    @State var state: String = ""
    @State var zipcode: String = ""
    let imageW: Font.Weight = .thin
    let fontS = Font.system(size: 35)
    var body: some View {
        ZStack {
            VStack {
                
                Rectangle()
                    .fill(Color(red: 235/255, green: 235/255, blue: 250/255))
                    .frame(height: UIScreen.main.bounds.height / 2)
                Spacer()
            }
            
            VStack {
                Text("SELECT A PROFILE IMAGE.")
                    .font(.system(size: 18))
                    .fontWeight(.semibold)
                    .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255))
                    .padding(.top, UIScreen.main.bounds.height / 2 + 10)
                
                Text("Select a picture for your profile.  This is what people will see when you attend.")
                    .font(.system(size: 24))
                    .fontWeight(.light)
                    .foregroundColor(.black)
                    .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                    .padding(.leading, 35)
                    .padding(.trailing, 35)
                    .padding(.top, 25)
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            
            VStack {
                VStack {
                    HStack {
                        Image("ProfileImage")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                    }
                    Text("Tap to Select")
                        .font(.system(size: 20))
                        .fontWeight(.light)
                        .foregroundColor(.black)
                        .opacity(0.5)
                }
                
                Button () {
                    
                } label: {
                    HStack {
                        Spacer()
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: 75, height: 35)
                                .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255))
                            Text("Finish")
                                .font(.system(size: 18))
                                .fontWeight(.regular)
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.top, 50)
                Spacer()
            }
            .frame(width: UIScreen.main.bounds.width - 100)
            .padding(.top, 120)
        }
        .ignoresSafeArea()
    }
}


#Preview {
    OnboardFour()
}
