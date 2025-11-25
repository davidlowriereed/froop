//
//  DetailsTasksAndInformationView.swift
//  Design_Layouts
//
//  Created by David Reed on 6/20/23.
//

import SwiftUI

struct DetailsTasksAndInformationView: View {
    var body: some View {
        ZStack {
            Rectangle()
                .frame(height: 135)
                .foregroundColor(.white)
            VStack {
            
            HStack {
                Text("Tasks and Information")
                    .font(.system(size: 14))
                    .foregroundColor(.black)
                    .opacity(0.7)
                    .fontWeight(.semibold)
                    .padding(.top, 10)
                    .padding(.leading, 25)
                    .padding(.bottom, 15)
                Spacer()
            }
                HStack {
                    VStack {
                        Image(systemName: "list.clipboard.fill")
                            .font(.system(size: 35))
                            .foregroundColor(.black)
                            .opacity(0.7)
                            .fontWeight(.thin)
                            .frame(maxWidth: 50, maxHeight: 40)
                        Text("SignUp")
                            .foregroundColor(.black)
                            .font(.system(size: 14))
                            .fontWeight(.light)
                    }
                    .padding(.trailing, 20)
                    
                    VStack {
                        Image(systemName: "ellipsis.bubble.fill")
                            .font(.system(size: 35))
                            .foregroundColor(.black)
                            .opacity(0.7)
                            .fontWeight(.thin)
                            .frame(maxWidth: 50, maxHeight: 40)
                        Text("Message")
                            .foregroundColor(.black)
                            .font(.system(size: 14))
                            .fontWeight(.light)
                    }
                    .padding(.trailing, 20)
                    
                    VStack {
                        Image(systemName: "info.square.fill")
                            .font(.system(size: 35))
                            .foregroundColor(.black)
                            .opacity(0.7)
                            .fontWeight(.thin)
                            .frame(maxWidth: 50, maxHeight: 40)
                        Text("Details")
                            .foregroundColor(.black)
                            .font(.system(size: 14))
                            .fontWeight(.light)
                    }
                    .padding(.trailing, 20)
                    
                    VStack {
                        Image(systemName: "hazardsign.fill")
                            .font(.system(size: 35))
                            .foregroundColor(.black)
                            .opacity(0.7)
                            .fontWeight(.thin)
                            .frame(maxWidth: 50, maxHeight: 40)
                        Text("Safety")
                            .foregroundColor(.black)
                            .font(.system(size: 14))
                            .fontWeight(.light)
                    }
                    .padding(.trailing, 20)
                }
                Spacer()
            }
            .frame(maxHeight: 135)
        }
        Divider()
    }
}

struct DetailsTasksAndInformationView_Previews: PreviewProvider {
    static var previews: some View {
        DetailsTasksAndInformationView()
    }
}
