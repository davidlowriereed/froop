//
//  TimeTextFieldView.swift
//  FroopProof
//
//  Created by David Reed on 3/3/23.
//

import SwiftUI
import UIKit

struct TimeTextFieldView: View {
    @Environment(\.colorScheme) var colorScheme
    
    
    @ObservedObject var printControl = PrintControl.shared
   
    // @ObservedObject var froopDataListener = FroopDataListener.shared
   
 
    
    @Binding var hour: String
    @Binding var minute: String
    @Binding var isPM: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.5)) {
                    isPM.toggle()
                }
            }, label: {
                Text(isPM ? "PM" : "AM")
                    .font(.system(size: 24))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.white)
                    .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color(red: 50/255, green: 46/255, blue: 62/255), lineWidth: 1)
                    )
            })
            .padding(.trailing, 8)
            
            TextField("00", text: $hour)
                .frame(width: 64)
                .font(.system(size: 48))
                .multilineTextAlignment(.center)
                .keyboardType(.numberPad)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color(red: 50/255, green: 46/255, blue: 62/255), lineWidth: 1)
                )
            
            Text(":")
                .font(.system(size: 48))
            
            TextField("00", text: $minute)
                .frame(width: 64)
                .font(.system(size: 48))
                .multilineTextAlignment(.center)
                .keyboardType(.numberPad)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color(red: 50/255, green: 46/255, blue: 62/255), lineWidth: 1)
                )
        }
    }
}
