//
//  DetailsCalendarView.swift
//  Design_Layouts
//
//  Created by David Reed on 6/20/23.
//

import SwiftUI

struct DetailsCalendarView: View {
    var body: some View {
        ZStack {
            Rectangle()
                .frame(height: 75)
                .foregroundColor(.black)
                .opacity(0.05)
            HStack (alignment: .center) {
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 24))
                    .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255 ))
                    .padding(.trailing, 15)
                
                Text("Tuesday, June 20 at 12:00 PM")
                    .foregroundColor(.black)
                    .opacity(0.7)
                    .font(.system(size: 16))
                    .fontWeight(.semibold)
                
                Spacer()
                
                ZStack {
                    Rectangle()
                        .frame(width: 75, height: 75)
                        .foregroundColor(.clear)
                    VStack  {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 24))
                            .padding(.bottom,1)
                        Text("Confirmed")
                            .fontWeight(.light)
                            .foregroundColor(.black)
                            .opacity(0.7)
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

struct DetailsCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        DetailsCalendarView()
    }
}
