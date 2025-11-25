//
//  FroopPassiveView2.swift
//  Design_Layouts
//
//  Created by David Reed on 7/7/23.
//

import SwiftUI

struct FroopPassiveView2: View {
    var size: CGSize
    var safeArea: EdgeInsets

    @State private var offsetY: CGFloat = 0
    
    var body: some View {
        ScrollView (.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                HeaderView()
                    .zIndex(1000)
                
                SampleCardsView()
                    .padding(.top, 15)
                   
            }
            .background {
                ScrollDetector { offset in
                    offsetY = -offset
                } onDraggingEnd: { offset, velocity in
                }
            }
        }
    }
        
    @ViewBuilder
    func HeaderView() -> some View {
        let headerHeight = (size.height * 0.35) + safeArea.top
        let minimumHeaderHeight = 40 + safeArea.top
        let progress = max(min(-offsetY / (headerHeight - minimumHeaderHeight), 1), 0)
        
        GeometryReader { geometry in
            let rect = geometry.frame(in: .global)

            ZStack {
                Rectangle()
                    .fill(Color(red: 250/255, green: 250/255, blue: 250/255).gradient)
                    .ignoresSafeArea()
              
                VStack {
                    
                    HStack {
                        Circle()
                            .frame(width: 75)
                            .padding(.leading, 40)
                            .opacity(1.0 - (progress * 2))
                        
                        VStack {
                            HStack {
                                Text("FirstName")
                                    .font(.system(size: 16))
                                    .fontWeight(.light)
                                Text("LastName")
                                    .font(.system(size: 16))
                                    .fontWeight(.light)
                                Spacer()
                            }
                            .opacity(1.0 - (progress * 2))
                            
                            HStack {
                                
                                Text("Lipsum sorum elded tantr emp dum asnd asd keknd allsek dafrn eomndns andjhe djkej djejejd lwieidh")
                                    .lineLimit(3)
                                    .font(.system(size: 14))
                                    .fontWeight(.thin)
                                    .frame(height: 75)
                                    .offset(y: -15)
                                    .opacity(1.0 - (progress * 2))
                                    

                                
                                Spacer()
                            }
                        }
                        .frame(height: 75)
                        .padding(.top, 30)
                        .padding(.trailing, 20)
                        .padding(.leading, 10)
                        Spacer()
                        
                    }
                    
                    HStack {
                        VStack {
                            Text("25")
                            Text("Froops")
                                .fontWeight(.thin)
                        }
                        Spacer()
                        VStack {
                            Text("15")
                            Text("Hosted")
                                .fontWeight(.thin)
                        }
                        Spacer()
                        VStack {
                            Text("10")
                            Text("Invited")
                                .fontWeight(.thin)
                        }
                    }
                    .padding(.leading, 50)
                    .padding(.top, 10)
                    .padding(.trailing, 50)
                    .opacity(1.0 - (progress * 2))

                    HStack {
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: 125, height: 30)
                                .foregroundColor(.black)
                                .opacity(0.5)
                            Text("Add Friends")
                                .foregroundColor(.white)
                                .font(.system(size: 16))
                                .fontWeight(.light)
                        }
                        .opacity(1.0 - (progress * 2))

                        Spacer()
                        ZStack {
                            Circle()
                                .frame(height: 45)
                            Image(systemName: "plus")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                                .fontWeight(.light)
                        }
                        .opacity(1.0 - (progress * 2))

                        Spacer()
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: 125, height: 30)
                                .foregroundColor(.black)
                                .opacity(0.5)
                            Text("Edit Profile")
                                .foregroundColor(.white)
                                .font(.system(size: 16))
                                .fontWeight(.light)
                        }
                        .opacity(1.0 - (progress * 2))

                        
                    }
                    .padding(.leading, 25)
                    .padding(.trailing, 25)
                    .padding(.top, 25)
                    
                    
                    HStack {
                        //Text("\(progress)")
                       Text("SOCIAL FEED")
                            .font(.system(size: 14))
                            .foregroundColor(.blue)
                            .opacity(0.6)
                            .offset(y: 5)
                        
                        Spacer()
                        Image(systemName: "person.3.fill")
                            .foregroundColor(.blue)
                            .padding(.trailing, 5)
                        Image(systemName: "house")
                            .padding(.trailing, 5)
                        
                        Image(systemName: "person")
                            .padding(.trailing, 5)
                        
                        Image(systemName: "globe.americas.fill")
                            .padding(.trailing, 5)
                        
                        Image(systemName: "hourglass.circle")
                    }
                    .padding(.top, 15)
                    .padding(.leading, 25)
                    .padding(.trailing, 25)
                    Spacer()
                }
                .padding(.top, 50)
                //.padding(.bottom)
            }
            .frame(height: (headerHeight + offsetY) < minimumHeaderHeight ? minimumHeaderHeight : (headerHeight + offsetY), alignment: .bottom)
            
            .offset(y: -offsetY)
        }
        .frame(height: headerHeight)
        

    }
    
    @ViewBuilder
    func SampleCardsView() -> some View {
        VStack(spacing: 15) {
            ForEach(1...25, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(.black.opacity(0.05))
                    .frame(height: 75)
            }
        }
    }
    
}


struct FroopPassiveView2_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
