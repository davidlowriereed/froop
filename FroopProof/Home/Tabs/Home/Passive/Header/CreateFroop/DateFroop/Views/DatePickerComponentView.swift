//
//  DatePickerComponentView.swift
//  FroopProof
//
//  Created by David Reed on 4/13/24.
//

import SwiftUI

struct DatePickerComponentView: View {
    @ObservedObject var froopData = FroopData.shared
    @Binding var transClock: Bool
    @Binding var datePicked: Bool
    let designWidth: CGFloat = 320

    var body: some View {
        VStack {
            Spacer()
            VStack {
                Spacer()
                DatePicker(
                    "Froop Date",
                    selection: Binding(
                        get: { froopData.froopStartTime },
                        set: { newValue in
                            let calendar = Calendar.current
                            let dateComponents = calendar.dateComponents([.year, .month, .day], from: newValue)
                            let newDate = calendar.date(from: dateComponents)!
                            froopData.froopStartTime = newDate
                        }
                    ),
                    displayedComponents: .date)
                .frame(width: designWidth, height: designWidth)
                .environment(\.timeZone, TimeZone.current)
                .datePickerStyle(GraphicalDatePickerStyle())
                .transformEffect(.init(scaleX: 0.8, y: 0.8))
                .scaleEffect(UIScreen.screenWidth / designWidth)
                Spacer()
            }
            .frame(height: UIScreen.screenHeight * 0.4)
        }
    }
}
