//
//  FroopDateSummaryView.swift
//  FroopProof
//
//  Created by David Reed on 3/22/24.
//

import SwiftUI

struct FroopDateSummaryView: View {
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
            
            Text("DATE")
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
                    Image(systemName: "clock")
                        .frame(width: 60, height: 50)
                        .scaledToFill()
                        .font(.system(size: 24))
                        .fontWeight(.medium)
                        .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255 ))
//                        .padding(.leading, 25)
                        .frame(alignment: .center)
                    Text(formatDate(for: froopData.froopType == 5009 ? froopData.froopStartTime + 7200 : froopData.froopStartTime, in: "America/Los_Angeles"))
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
    func formatDate(for date: Date, in timeZoneIdentifier: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy h:mm a"
        if let timeZone = TimeZone(identifier: timeZoneIdentifier) {
            formatter.timeZone = timeZone
        }
        return formatter.string(from: date)
    }
}
