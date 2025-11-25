//
//  ProfileHeaderView.swift
//  Design_Layouts
//
//  Created by David Reed on 8/9/23.
//

import SwiftUI

struct ProfileHeaderView: View {
    @Binding var offsetY: CGFloat
    var size: CGSize
    var safeArea: EdgeInsets
    
    private var headerHeight: CGFloat {
        (size.height * 0.5) + safeArea.top
    }
    
    private var headerWidth: CGFloat {
        (size.width * 0.5)
    }
    
    private var minimumHeaderHeight: CGFloat {
        100 + safeArea.top
    }
    
    private var minimumHeaderWidth: CGFloat {
        100
    }
    
    private var progress: CGFloat {
        max(min(-offsetY / (headerHeight - minimumHeaderHeight), 1), 0)
    }
    
    var body: some View {
        GeometryReader { _ in
            ZStack {
                Rectangle()
                    .fill(Color(.white).gradient)
                
                VStack(alignment: .center, spacing: 15) {
                    ProfileImage(progress: progress, headerHeight: headerHeight)
                    HStack {
                        Spacer()
                        Text("David Reed")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .opacity(0.8)
                            .moveText(progress, headerHeight, minimumHeaderHeight, headerWidth, minimumHeaderWidth)
                        Spacer()
                    }
                    
                    HStack (spacing: 30) {
                        Spacer()
                        Image(systemName: "phone.fill")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .opacity(0.8)
                          
                        Image(systemName: "text.bubble.fill")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .opacity(0.8)
                           
                        Image(systemName: "message.fill")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .opacity(0.8)
                        Spacer()
                    }
                    .moveSymbols(progress, headerHeight, minimumHeaderHeight, headerWidth, minimumHeaderWidth)

                    
                    HStack (alignment: .center ){
                        Spacer()
                        
                        Text("Info")
                            .font(.system(size: 16))
                            .fontWeight(.light)
                            .foregroundColor(.black)
                            .opacity(0.8)
                        
                        Divider()
                            .padding(.leading, 15)
                            .padding(.trailing, 15)
                        
                        Text("Friends")
                            .font(.system(size: 16))
                            .fontWeight(.light)
                            .foregroundColor(.black)
                            .opacity(0.8)
                        
                        Divider()
                            .padding(.leading, 15)
                            .padding(.trailing, 15)
                        
                        Text("Froops")
                            .font(.system(size: 16))
                            .fontWeight(.light)
                            .foregroundColor(.black)
                            .opacity(0.8)
                        
                        Spacer()
                    }
                    .offset(y: 25)
                    .padding(.leading, 25)
                    .padding(.trailing, 25)
                    Spacer()
                }
                
                .padding(.top, safeArea.top)
                .padding(.bottom, 15)
            }
            .frame(height: (headerHeight + offsetY) < minimumHeaderHeight ? minimumHeaderHeight : (headerHeight + offsetY), alignment: .bottom)
            .offset(y: -offsetY)
        }
        .frame(height: headerHeight)
    }
}

struct ProfileImage: View {
    var progress: CGFloat
    var headerHeight: CGFloat
    
    var body: some View {
        GeometryReader {
            let rect = $0.frame(in: .global)
            let halfScaledHeight = (rect.height * 0.5) * 0.5
            let midY = rect.midY
            let bottomPadding: CGFloat = -30
            let minimumHeaderHeight = 100
            let resizedOffsetY = (midY - (CGFloat(minimumHeaderHeight) - halfScaledHeight - bottomPadding))
            
            Image("pic")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: rect.width, height: rect.height)
                .clipShape(Circle())
                .scaleEffect(1 - (progress * 0.7), anchor: .leading)
                .offset(x: -(rect.minX - 15) * progress, y: -resizedOffsetY * progress)
        }
        .frame(width: headerHeight * 0.5, height: headerHeight * 0.5)
    }
}

struct ProfileHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
