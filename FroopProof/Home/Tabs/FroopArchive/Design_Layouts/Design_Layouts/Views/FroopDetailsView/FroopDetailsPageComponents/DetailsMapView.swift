//
//  DetailsMapView.swift
//  Design_Layouts
//
//  Created by David Reed on 6/20/23.
//

import SwiftUI

struct DetailsMapView: View {
    var body: some View {
        ZStack {
            Rectangle()
                .frame(height: 75)
                .foregroundColor(.black)
                .opacity(0.05)
            HStack (alignment: .center) {
                Image(systemName: "mappin.and.ellipse")
                    .font(.system(size: 24))
                    .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255 ))
                    .padding(.trailing, 15)
                
                VStack (alignment: .leading){
                    Text("The Drake")
                        .foregroundColor(.black)
                        .opacity(0.7)
                        .font(.system(size: 16))
                        .fontWeight(.semibold)
                    Text("2894 S. Coast Hwy, Laguna Beach, CA 92651, United States")
                        .foregroundColor(.black)
                        .opacity(0.7)
                        .font(.system(size: 12))
                        .lineLimit(2)
                    
                }
                
                Spacer()
                
                ZStack {
                    
                    Image("mapImage")
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: 75, maxHeight: 75)
                    Rectangle()
                        .frame(width: 75, height: 75)
                        .foregroundColor(.black)
                        .opacity(0.4)
                    
                    VStack  {
                        Text("Open")
                            .foregroundColor(.white)
                            .font(.system(size: 16))
                        Text("Map")
                            .foregroundColor(.white)
                            .font(.system(size: 16))
                    }
                    .font(.system(size: 12))
                }
                
            }
            .ignoresSafeArea()
            .padding(.leading, 25)
        }
        Divider()
    }
}

struct DetailsMapView_Previews: PreviewProvider {
    static var previews: some View {
        DetailsMapView()
    }
}
