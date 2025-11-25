//
//  PremiumBannerDetailsView.swift
//  FroopProof
//
//  Created by David Reed on 3/22/24.
//

import SwiftUI



struct PremiumBannerDetailsView: View {
    @ObservedObject var myData = MyData.shared
    @ObservedObject var payManager = PayWallManager.shared
    @State private var animate = false


    var body: some View {
        GeometryReader { geometry in
            // MARK: BANNER
            if myData.premiumAccount {
                VStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 0)
                            .foregroundStyle(Color(red: 249/255, green: 0/255, blue: 98/255))
                            .frame(width: geometry.size.width * 1, height: 25)
//                            .padding(.horizontal, geometry.size.width * 0.05) // Use relative padding
                        
                        VStack (spacing: 10) {
                            HStack {
                                Spacer()
                                Text("PREMIUM ACCOUNT ACTIVE")
                                    .font(.system(size: 12)) // Use dynamic type
                                    .fontWeight(.bold)
                                    .lineLimit(1)
                                    .foregroundStyle(Color(.white))
                                
                                Spacer()
                            }
                        }
                    }
                }
                .ignoresSafeArea()
            } else {
                VStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 0)
                            .foregroundStyle(.white)
                            .frame(width: geometry.size.width * 1, height: 75)
//                            .padding(.horizontal, geometry.size.width * 0.05) // Use relative padding
                        
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
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 0)
                                .foregroundStyle(Color(red: 249/255, green: 0/255, blue: 96/255))
                                .frame(width: geometry.size.width * 1, height: 75)
//                                .padding(.horizontal, geometry.size.width * 0.05) // Use relative padding
                            
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
                }
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
