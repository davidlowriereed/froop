//
//   AnnotationDetailView.swift
//  Design_Layouts
//
//  Created by David Reed on 7/13/23.
//

import SwiftUI

struct _AnnotationDetailView: View {
    var body: some View {
        
        ZStack {
            RoundedRectangle(cornerRadius: 10)
            // .foregroundColor(.black).gradient
                .fill(Color(.black).gradient)
                .opacity(0.7)
                .frame(minWidth: 120, maxWidth: 120, minHeight: 200, maxHeight: 200)
            VStack (alignment: .leading){
                Text("Annotation Title")
                    .foregroundColor(.white)
                    .font(.system(size: 12))
                    .fontWeight(.semibold)
                    .padding(.leading, 5)
                    .padding(.trailing, 5)
                Text("SubTitle")
                    .foregroundColor(.white)
                    .font(.system(size: 10))
                    .fontWeight(.regular)
                    .padding(.top, 1)
                    .padding(.leading, 5)
                    .padding(.trailing, 5)
                
                Text("Ipsum lorum dolores sumpre compre sseder erre es werelkdh")
                    .foregroundColor(.white)
                    .font(.system(size: 10))
                    .fontWeight(.light)
                    .padding(.top, 5)
                    .padding(.leading, 5)
                    .padding(.trailing, 5)
                Spacer()
                
                HStack {
                    Spacer()
                    ZStack {
                        Rectangle()
                            .foregroundColor(.clear)
                            .border(.white, width: 0.5)
                            .frame(width: 50, height: 25)
                        
                        Text("Edit")
                            .foregroundColor(.white)
                            .font(.system(size: 12))
                            .fontWeight(.thin)
                    }
                    Spacer()
                }
                .padding(.bottom, 10)
            }
            .padding(.top, 10)
        }
        .frame(minWidth: 120, maxWidth: 120, minHeight: 200, maxHeight: 200)
    }
}

struct _AnnotationDetailView_Previews: PreviewProvider {
    static var previews: some View {
        _AnnotationDetailView()
    }
}
