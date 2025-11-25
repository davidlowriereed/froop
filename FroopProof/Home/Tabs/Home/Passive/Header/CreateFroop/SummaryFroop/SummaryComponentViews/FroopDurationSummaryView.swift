//
//  FroopDurationSummaryView.swift
//  FroopProof
//
//  Created by David Reed on 3/22/24.
//

import SwiftUI

struct FroopDurationSummaryView: View {
    @ObservedObject var froopData = FroopData.shared
    @ObservedObject var changeView = ChangeView.shared

    var editable: Bool {
        if ChangeView.shared.froopTypeData?.viewPositions[2] != 0 {
            return true
        } else {
            return false
        }
    }
    
    var body: some View {
        VStack (alignment: .leading) {
            
            Text("DURATION")
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
                    Image(systemName: "hourglass.tophalf.filled")
                        .frame(width: 60, height: 50)
                        .scaledToFill()
                        .font(.system(size: 24))
                        .fontWeight(.medium)
                        .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255 ))
//                        .padding(.leading, 25)
                        .frame(alignment: .center)
                    Text("Duration: \(formatDuration(durationInSeconds: froopData.froopDuration))")
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                        .lineLimit(2)
                        .padding(.trailing, 10)
                    Spacer()
                }
            }
        }
        .frame(width: UIScreen.screenWidth - 40, height: 75)
        .onTapGesture {
            if editable {
                changeView.pageNumber = changeView.showDate
            }
        }
    }
    
    func formatDuration(durationInSeconds: Int) -> String {
        PrintControl.shared.printFroopCreation("-FroopSummaryView: Function: formatDuration is firing!")
        let hours = durationInSeconds / 3600
        let minutes = (durationInSeconds % 3600) / 60
        
        let hourString = hours == 1 ? "h : " : "h : "
        let minuteString = minutes == 1 ? "m" : "m"
        
        return String(format: "%02d\(hourString) %02d\(minuteString)", hours, minutes)
    }
    
}

