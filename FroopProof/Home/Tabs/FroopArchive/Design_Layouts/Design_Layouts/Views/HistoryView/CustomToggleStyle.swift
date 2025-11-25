//
//  CustomToggleStyle.swift
//  Design_Layouts
//
//  Created by David Reed on 6/11/23.
//

import SwiftUI

struct CustomToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            
            HStack {
                
                Rectangle()
                    .frame(width: 50, height: 30)
                    .foregroundColor(configuration.isOn ? (Color(red: 249/255, green: 0/255, blue: 98/255 )) : .white)
                    .overlay(
                        Circle()
                            .frame(width: 25, height: 25)
                            .foregroundColor(.black)
                            .opacity(0.4)
                            .offset(x: configuration.isOn ? 10 : -10)
                    )
                    .cornerRadius(15)
                    .onTapGesture {
                        configuration.isOn.toggle()
                    }
                configuration.label
                Spacer()
            }
            .padding(.leading, 25)
        }
    }
}
