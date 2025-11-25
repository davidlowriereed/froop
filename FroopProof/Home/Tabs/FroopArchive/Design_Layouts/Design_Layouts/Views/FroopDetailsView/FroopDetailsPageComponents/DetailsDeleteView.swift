//
//  DetailsDeleteView.swift
//  Design_Layouts
//
//  Created by David Reed on 8/4/23.
//

import SwiftUI

struct DetailsDeleteView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            Button(action: {
                print("pressed")
                   }) {
                ZStack {
                    Rectangle ()
                        .frame(height: 60)
                        .foregroundColor(colorScheme == .dark ? Color(red: 250/255 , green: 250/255, blue: 255/255) : Color(red: 250/255 , green: 250/255, blue: 255/255))
                    Rectangle ()
                        .frame(width: 250, height: 50)
                        .foregroundColor(colorScheme == .dark ? .clear : .clear)
                        .border(colorScheme == .dark ? .black : .black, width: 0.25)
                    
                    Text("Delete Froop")
                        .foregroundColor(colorScheme == .dark ? .black : .black)
                        .font(.system(size: 18))
                        .fontWeight(.thin)
                }
            }
            
        }
        Divider()
    }
}

struct DetailsDeleteView_Previews: PreviewProvider {
    static var previews: some View {
        DetailsDeleteView()
    }
}
