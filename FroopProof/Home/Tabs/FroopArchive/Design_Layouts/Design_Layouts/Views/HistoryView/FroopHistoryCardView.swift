//
//  FroopHistoryCardView.swift
//  Design_Layouts
//
//  Created by David Reed on 6/11/23.
//

import SwiftUI

struct FroopHistoryCardView: View {
    var body: some View {
        
        ZStack (alignment: .center) {
            Rectangle()
                .frame(height: 110)
                .foregroundColor(.clear)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.leading, 30)
                .padding(.trailing, 15)
            
            VStack {
                HStack {
                    Text("Saturday, June 23rd, 2023")
                        .frame(maxWidth: 225)
                        .font(.system(size: 12))
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.black)
                        .opacity(0.8)
                        .fontWeight(.light)
                    Spacer()
                }
                
                Spacer()
            }
            .frame(maxHeight: 95)
                 
            HStack (alignment: .center, spacing: 2) {
                
                VStack (alignment: .leading){
                    Circle()
                       
                }
                .frame(width: 65, height: 65)
                .padding(.leading, 20)
                .padding(.top, 15)
        
                
                VStack (alignment: .leading){
                    
                    Text("Froop Title Goes here, event if it's long.")
                        .lineLimit(2)
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                        .opacity(0.8)
                        .fontWeight(.regular)
                        .multilineTextAlignment(.leading)
                        .padding(.top)
                    
                    Text("Hosted by: Jane Doe")
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .font(.system(size: 12))
                        .foregroundColor(.black)
                        .opacity(0.8)
                        .fontWeight(.thin)
                        .padding(.top, 1)
                    
                }
                .frame(maxWidth: 250)
          
            
                
                Divider()
                    .padding(.trailing, 10)
                
                VStack (alignment: .trailing){
                    
                    HStack {
                        Image(systemName: "person.crop.circle")
                            .font(.system(size: 20))
                            .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255 ))
                        Spacer()
                        Text("10")
                            .font(.system(size: 14))
                    }
                    .fontWeight(.light)
                    .foregroundColor(.black)
                    .opacity(0.8)
                    
                    HStack {
                        Image(systemName: "photo.circle")
                            .font(.system(size: 20))
                            .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255 ))
                        Spacer()
                        Text("25")
                            .frame(alignment: .trailing)
                            .font(.system(size: 14))
                    }
                    .fontWeight(.light)
                    .foregroundColor(.black)
                    .opacity(0.8)
                    
                    HStack {
                        Image(systemName: "video.circle")
                            .font(.system(size: 20))
                            .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255 ))
                        Spacer()
                        Text("11")
                            .font(.system(size: 14))
                    }
                    .fontWeight(.light)
                    .foregroundColor(.black)
                    .opacity(0.8)
                    
                }
                .frame(maxWidth: 50)
                
                Spacer()
            }
            .frame(maxHeight: 100)
            .padding(.leading, 15)
            .padding(.trailing, 15)
            
        }
    }
}

struct FroopHistoryCardView_Previews: PreviewProvider {
    static var previews: some View {
        FroopHistoryCardView()
    }
}
