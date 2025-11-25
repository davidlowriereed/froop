//
//  FroopTypeSummaryView.swift
//  FroopProof
//
//  Created by David Reed on 3/22/24.
//

import SwiftUI

struct FroopTypeSummaryView: View {
    @ObservedObject var froopData = FroopData.shared
    @ObservedObject var changeView = ChangeView.shared

    var body: some View {
        VStack (alignment: .leading) {
            
            Text("TYPE OF FROOP")
                .font(.system(size: 14))
                .fontWeight(.semibold)
                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.9))
//                .padding(.leading, 15)
                .offset(y: 5)
            
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.white)
                    .opacity(0.8)
                    .frame(height: 50)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.25), lineWidth: 0.25)
                    )
//                    .padding(.leading, 15)
//                    .padding(.trailing, 15)
                
                HStack (spacing: 0 ){
                    if let froopType = FroopTypeStore.shared.froopTypes.first(where: { $0.id == froopData.froopType }) {
                        Image(systemName: froopType.imageName)
                            .frame(width: 60, height: 50)
                            .scaledToFill()
                            .font(.system(size: 24))
                            .fontWeight(.medium)
                            .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255 ))
//                            .padding(.leading, 25)
                            .frame(alignment: .center)
                        Text("It's a \(froopType.name)")
                            .font(.system(size: 16))
                            .fontWeight(.medium)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                            .lineLimit(2)
                            .padding(.trailing, 10)
                    }
                    Spacer()
                }
            }
        }
        .frame(width: UIScreen.screenWidth - 40, height: 75)
    }
}

