//
//  OnboardOne.swift
//  Design_Layouts
//
//  Created by David Reed on 9/21/23.
//

import SwiftUI

struct OnboardTwo: View {
    @State var phoneNumber: String = ""
    @State var OTPCode: String = ""
    @State private var OTPSent: Bool = false
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
                Text("VERIFY YOUR MOBILE NUMBER")
                    .font(.system(size: 18))
                    .fontWeight(.semibold)
                    .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255))
                    .padding(.top, UIScreen.main.bounds.height / 2 + 10)
                
                Text("Your Mobile Number serves as your 2 factor authentication. ")
                    .font(.system(size: 24))
                    .fontWeight(.light)
                    .foregroundColor(.black)
                    .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                    .padding(.leading, 35)
                    .padding(.trailing, 35)
                    .padding(.top, 25)
                    .multilineTextAlignment(.center)
                
                Text("It is also how users on the platform can look you up or send out invitations.")
                    .font(.system(size: 24))
                    .fontWeight(.light)
                    .foregroundColor(.black)
                    .opacity(0.8)
                    .padding(.leading, 35)
                    .padding(.trailing, 35)
                    .padding(.top, 25)
                    .multilineTextAlignment(.center)
                Spacer()
            }
            VStack (spacing: 40){
                VStack {
                    VStack (alignment: .leading){
                        Text("PHONE NUMBER")
                            .font(.system(size: 14))
                            .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                            .foregroundColor(.black)
                            .opacity(0.25)
                            .offset(y: 8)
                        
                        TextField("(123) 456-7890", text: $phoneNumber)
                            .font(.system(size: 30))
                            .fontWeight(.thin)
                            .padding(.leading, 15)
                            .padding(.top, 2)
                            .padding(.bottom, 2)
                            .padding(.trailing, 10)
                            .background(.white)
                            .border(.gray, width: 0.25)
                    }
                    
                    Button () {
                        OTPSent = true
                    } label: {
                        HStack {
                            Spacer()
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .frame(width: 75, height: 35)
                                    .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255))
                                Text(OTPSent ? "Resend" : "Submit")
                                    .font(.system(size: 18))
                                    .fontWeight(.regular)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    
                }
                
                    VStack {
                        ZStack {
                        VStack (alignment: .leading){
                            Text("VERIFICATION CODE")
                                .font(.system(size: 14))
                                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                                .foregroundColor(.black)
                                .opacity(0.25)
                                .offset(y: 8)
                            
                            Text("Enter OTP Code Here")
                                .font(.system(size: 30))
                                .fontWeight(.thin)
                                .padding(.leading, 15)
                                .padding(.top, 2)
                                .padding(.bottom, 2)
                                .padding(.trailing, 10)
                                .background(.white)
                                .border(.gray, width: 0.25)
                        }
                        .opacity(OTPSent ? 0.0 : 0.25)

                        
                        VStack {
                            VStack (alignment: .leading){
                                Text("VERIFICATION CODE")
                                    .font(.system(size: 14))
                                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                                    .foregroundColor(.black)
                                    .opacity(0.25)
                                    .offset(y: 8)
                                
                                TextField("Enter OTP Code Here", text: $OTPCode)
                                    .font(.system(size: 30))
                                    .fontWeight(.thin)
                                    .padding(.leading, 15)
                                    .padding(.top, 2)
                                    .padding(.bottom, 2)
                                    .padding(.trailing, 10)
                                    .background(.white)
                                    .border(.gray, width: 0.25)
                                
                            }
                            .opacity(OTPSent ? 1.0 : 0.0)
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
                                    Text("Submit")
                                        .font(.system(size: 18))
                                        .fontWeight(.regular)
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .opacity(OTPSent ? 1.0 : 0.0)
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
        OnboardTwo()
    }
