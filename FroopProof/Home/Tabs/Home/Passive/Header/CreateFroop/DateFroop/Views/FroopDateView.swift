//
//  NewFroopView4.swift
//  FroopProof
//
//  Created by David Reed on 1/19/23.
//

import SwiftUI
import UIKit
import Foundation
import CoreLocation

struct FroopDateView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var printControl = PrintControl.shared
    // @ObservedObject var froopDataListener = FroopDataListener.shared
    @ObservedObject var froopData = FroopData.shared
    @ObservedObject var changeView = ChangeView.shared
    
    @ObservedObject var myData = MyData.shared
    
    @State private var hour1Focus: Bool = false
    @State var currentDate = Date()
    @State var selectedDate = Date()
    @State var startTime: Date = Date()
    @State var endTime: Date = Date()

    let dateFormatter = DateFormatter()
    var dateString: String {
        dateFormatter.dateFormat = "MMMM yyyy"
        return dateFormatter.string(from: self.froopData.froopStartTime)
    }
    var selectedDateString: String {
        dateFormatter.dateFormat = "MMMM dd, yyyy"
        return dateFormatter.string(from: self.froopData.froopStartTime)
    }
    init(froopData: FroopData) {
        self.froopData = froopData
    }

    @State var transClock = false
    @State var datePicked = false
    @State var duraVis = false
    
    var body: some View {
    
        
        ZStack{
            //MARK:  DATE SELECTION

            DatePickViewCopy(transClock: $transClock, datePicked: $datePicked, froopData: froopData)
            //MARK: START / END TIME SELECTION
            TimePickView(transClock: $transClock, datePicked: $datePicked, duraVis: $duraVis, froopData: froopData, changeView: changeView)
        }
        .onChange(of: datePicked) { newValue, _ in
            if newValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    hour1Focus = true
                }
            }
        }
    }
    
    func currentDateInTimeZone(timeZoneIdentifier: String) -> Date {
//        print("-FroopDateView: Function: currentDateInTimeZone")
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: timeZoneIdentifier)
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let dateString = dateFormatter.string(from: now)
        return dateFormatter.date(from: dateString) ?? now
    }
}
