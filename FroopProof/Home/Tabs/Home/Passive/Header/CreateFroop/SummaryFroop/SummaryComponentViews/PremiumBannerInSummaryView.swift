//
//  PremiumBannerInSummaryView.swift
//  FroopProof
//
//  Created by David Reed on 3/22/24.
//

import SwiftUI



struct PremiumBannerInSummaryView: View {
    @ObservedObject var myData = MyData.shared
    @ObservedObject var payManager = PayWallManager.shared

    @State private var animate = false


    var body: some View {
        GeometryReader { geometry in
            // MARK: BANNER
            if myData.premiumAccount {
                VStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(.white)
                            .shadow(color: Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.2), radius: 7, x: 7, y: 7)
                            .shadow(color: Color.white.opacity(0.7), radius: 7, x: -4, y: -4)
                            .frame(width: geometry.size.width * 0.9, height: 75)
                            .padding(.top, 15)
                            .padding(.horizontal, geometry.size.width * 0.05) // Use relative padding
                        
                        VStack (spacing: 10) {
                            HStack {
                                Text("PREMIUM")
                                    .font(.system(.title2, design: .default)) // Use dynamic type
                                    .fontWeight(.bold)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                                    .foregroundStyle(Color(red: 249/255, green: 0/255, blue: 96/255))
                                    .padding(.horizontal, geometry.size.width * 0.1)
                                    .offset(y: 5)
                                
                                Spacer()
                                Text("Status")
                                    .font(.system(size: 14))
                                    .fontWeight(.regular)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                                    .foregroundStyle(Color(red: 249/255, green: 0/255, blue: 96/255))
                                    .padding(.horizontal, geometry.size.width * 0.1) // Use relative padding
                                    .offset(y: 5)
                                
                                
                            }
                            
                            HStack {
                                Text("ACCOUNT")
                                    .font(.system(.title2, design: .default)) // Use dynamic type
                                    .fontWeight(.bold)
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.5)
                                    .foregroundStyle(.white)
                                    .padding(.trailing, UIScreen.screenWidth * 0.1)
                                    .padding(.leading, UIScreen.screenWidth * 0.1)
                                Spacer()
                                Text("ACTIVE")
                                    .font(.system(size: 20))
                                    .fontWeight(.bold)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                                    .foregroundStyle(Color(red: 249/255, green: 0/255, blue: 96/255))
                                    .padding(.horizontal, geometry.size.width * 0.1) // Use relative padding
                            }
                        }
                        .padding(.top, 10)
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(Color(red: 249/255, green: 0/255, blue: 96/255))
                                .shadow(color: Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.2), radius: 7, x: 7, y: 7)
                                .shadow(color: Color.white.opacity(0.7), radius: 7, x: -4, y: -4)
                                .frame(width: geometry.size.width * 0.9, height: 75)
                                .padding(.top, 15)
                                .padding(.horizontal, geometry.size.width * 0.05) // Use relative padding
                            
                            VStack (spacing: 10) {
                                HStack {
                                    Text("PREMIUM")
                                        .font(.system(.title2, design: .default)) // Use dynamic type
                                        .fontWeight(.bold)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.5)
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, geometry.size.width * 0.1) // Use relative padding
                                        .offset(y: 5)
                                    Spacer()
                                    Text("Status")
                                        .font(.system(size: 14))
                                        .fontWeight(.regular)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.5)
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, geometry.size.width * 0.1) // Use relative padding
                                        .offset(y: 5)
                                    
                                }
                                
                                HStack {
                                    Text("ACCOUNT")
                                        .font(.system(.title2, design: .default)) // Use dynamic type
                                        .fontWeight(.bold)
                                        .lineLimit(2)
                                        .minimumScaleFactor(0.5)
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, geometry.size.width * 0.1) // Use relative padding
                                    
                                    Spacer()
                                    Text("ACTIVE")
                                        .font(.system(size: 20))
                                        .fontWeight(.bold)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.5)
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, geometry.size.width * 0.1) // Use relative padding
                                }
                            }
                            .padding(.top, 10)
                        }
                        .mask(
                            ZStack {
                                SlantedSwipeInObject(width: geometry.size.width, height: 90)
                                    .offset(x: animate ? -geometry.size.width * 1.4 : 0, y: 0)
                            }
                        )
                    }
                    .onAppear {
                        withAnimation(.interpolatingSpring(stiffness: 100, damping: 15).delay(0.5)) {
                            animate = true
                        }
                    }
                    
                    Spacer()
                    Rectangle()
                        .foregroundStyle(Color(red: 50/255, green: 46/255, blue: 62/255))
                        .frame(height: 125)
                        .ignoresSafeArea()
                }
                .padding(.top, UIScreen.screenHeight * 0.025 + 75)
                .ignoresSafeArea()
            } else {
                VStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(.white)
                            .shadow(color: Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.2), radius: 7, x: 7, y: 7)
                            .shadow(color: Color.white.opacity(0.7), radius: 7, x: -4, y: -4)
                            .frame(width: geometry.size.width * 0.9, height: 75)
                            .padding(.top, 15)
                            .padding(.horizontal, geometry.size.width * 0.05) // Use relative padding
                        
                        VStack (spacing: 10) {
                            HStack {
                                Text("GET PREMIUM")
                                    .font(.system(.title2, design: .default)) // Use dynamic type
                                    .fontWeight(.bold)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                                    .foregroundStyle(Color(red: 249/255, green: 0/255, blue: 96/255))
                                    .padding(.horizontal, geometry.size.width * 0.1)
                                    .offset(y: 5)
                                
                                Spacer()
                                Text("FOR ONLY")
                                    .font(.system(size: 14))
                                    .fontWeight(.regular)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                                    .foregroundStyle(Color(red: 249/255, green: 0/255, blue: 96/255))
                                    .padding(.horizontal, geometry.size.width * 0.1) // Use relative padding
                                    .offset(y: 5)
                                
                                
                            }
                            
                            HStack {
                                Text("Unlock all Features")
                                    .font(.system(size: 14))
                                    .fontWeight(.regular)
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.5)
                                    .foregroundStyle(.white)
                                    .padding(.trailing, UIScreen.screenWidth * 0.1)
                                    .padding(.leading, UIScreen.screenWidth * 0.1)
                                Spacer()
                                Text("$49.99 / YEAR")
                                    .font(.system(size: 20))
                                    .fontWeight(.bold)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                                    .foregroundStyle(Color(red: 249/255, green: 0/255, blue: 96/255))
                                    .padding(.horizontal, geometry.size.width * 0.1) // Use relative padding
                            }
                        }
                        .padding(.top, 10)
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(Color(red: 249/255, green: 0/255, blue: 96/255))
                                .shadow(color: Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.2), radius: 7, x: 7, y: 7)
                                .shadow(color: Color.white.opacity(0.7), radius: 7, x: -4, y: -4)
                                .frame(width: geometry.size.width * 0.9, height: 75)
                                .padding(.top, 15)
                                .padding(.horizontal, geometry.size.width * 0.05) // Use relative padding
                            
                            VStack (spacing: 10) {
                                HStack {
                                    Text("GET PREMIUM")
                                        .font(.system(.title2, design: .default)) // Use dynamic type
                                        .fontWeight(.bold)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.5)
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, geometry.size.width * 0.1) // Use relative padding
                                        .offset(y: 5)
                                    Spacer()
                                    Text("FOR ONLY")
                                        .font(.system(size: 14))
                                        .fontWeight(.regular)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.5)
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, geometry.size.width * 0.1) // Use relative padding
                                        .offset(y: 5)
                                    
                                    
                                }
                                
                                HStack {
                                    Text("Unlock all Features")
                                        .font(.system(size: 14))
                                        .fontWeight(.regular)
                                        .lineLimit(2)
                                        .minimumScaleFactor(0.5)
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, geometry.size.width * 0.1) // Use relative padding
                                    
                                    Spacer()
                                    Text("$49.99 / YEAR")
                                        .font(.system(size: 20))
                                        .fontWeight(.bold)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.5)
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, geometry.size.width * 0.1) // Use relative padding
                                    
                                    
                                    
                                }
                            }
                            .padding(.top, 10)
                        }
                        .mask(
                            ZStack {
                                SlantedSwipeInObject(width: geometry.size.width, height: 90)
                                    .offset(x: animate ? -geometry.size.width * 1.4 : 0, y: 0)
                            }
                        )
                    }
                    .onAppear {
                        withAnimation(.interpolatingSpring(stiffness: 100, damping: 15).delay(0.5)) {
                            animate = true
                        }
                    }
                    
                    Spacer()
                    Rectangle()
                        .foregroundStyle(Color(red: 50/255, green: 46/255, blue: 62/255))
                        .frame(height: 125)
                        .ignoresSafeArea()
                }
                .padding(.top, UIScreen.screenHeight * 0.025 + 75)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        payManager.showIAPView.toggle()
                    }
                }
            }
        }
    }
}


struct SlantedSwipeInObject: View {
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: width * 2, y: 0))
            path.addLine(to: CGPoint(x: width * 1.9, y: height)) // Adjust the slant by modifying this multiplier
            path.addLine(to: CGPoint(x: 0, y: height))
            path.closeSubpath()
        }
        .fill(Color.white.opacity(1))
        .frame(width: width, height: height)
    }
}
