//
//  OnboardOne.swift
//  Design_Layouts
//
//  Created by David Reed on 9/21/23.
//

import SwiftUI

struct OnboardThree: View {
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
                Text("WHERE DO YOU LIVE?")
                    .font(.system(size: 18))
                    .fontWeight(.semibold)
                    .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255))
                    .padding(.top, UIScreen.main.bounds.height / 2 + 10)
                
                Text("With Froop you will be able to get real time information about your activities while they are happening.")
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
            
            VStack (spacing: 10){
                VStack (alignment: .leading) {
                    Text("STREET ADDRESS")
                        .font(.system(size: 14))
                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                        .foregroundColor(.black)
                        .opacity(0.25)
                        .offset(y: 8)
                    
                    TextField("123 Main Street", text: $address)
                        .font(.system(size: 30))
                        .fontWeight(.thin)
                        .padding(.leading, 15)
                        .padding(.top, 2)
                        .padding(.bottom, 2)
                        .padding(.trailing, 10)
                        .background(.white)
                        .border(.gray, width: 0.25)
                }
                
                VStack (alignment: .leading) {
                    Text("CITY")
                        .font(.system(size: 14))
                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                        .foregroundColor(.black)
                        .opacity(0.25)
                        .offset(y: 8)
                    
                    TextField("Los Angeles", text: $city)
                        .font(.system(size: 30))
                        .fontWeight(.thin)
                        .padding(.leading, 15)
                        .padding(.top, 2)
                        .padding(.bottom, 2)
                        .padding(.trailing, 10)
                        .background(.white)
                        .border(.gray, width: 0.25)
                }
                
                HStack {
                    VStack (alignment: .leading) {
                        Text("STATE")
                            .font(.system(size: 14))
                            .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                            .foregroundColor(.black)
                            .opacity(0.25)
                            .offset(y: 8)
                        
                        TextField("CA", text: $state)
                            .font(.system(size: 30))
                            .fontWeight(.thin)
                            .padding(.leading, 15)
                            .padding(.top, 2)
                            .padding(.bottom, 2)
                            .padding(.trailing, 10)
                            .background(.white)
                            .border(.gray, width: 0.25)
                    }
                    VStack (alignment: .leading) {
                        Text("ZIP CODE")
                            .font(.system(size: 14))
                            .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                            .foregroundColor(.black)
                            .opacity(0.25)
                            .offset(y: 8)
                        
                        TextField("90210", text: $zipcode)
                            .font(.system(size: 30))
                            .fontWeight(.thin)
                            .padding(.leading, 15)
                            .padding(.top, 2)
                            .padding(.bottom, 2)
                            .padding(.trailing, 10)
                            .background(.white)
                            .border(.gray, width: 0.25)
                    }
                }
                
                
                Button () {
                    
                } label: {
                    HStack {
                        Spacer()
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: 75, height: 35)
                                .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255))
                            Text("Save")
                                .font(.system(size: 18))
                                .fontWeight(.regular)
                                .foregroundColor(.white)
                        }
                    }
                }
                Spacer()
            }
            .frame(width: UIScreen.main.bounds.width - 100)
            .padding(.top, 120)
            
        }
        .ignoresSafeArea()
    }
}

#Preview {
    OnboardThree()
}
