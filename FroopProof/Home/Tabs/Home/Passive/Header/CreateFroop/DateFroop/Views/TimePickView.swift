//
//  TimePickView.swift
//  FroopProof
//
//  Created by David Reed on 1/25/23.
//

import SwiftUI
import UIKit
import Foundation
import FirebaseAuth


struct TimePickView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var scrollTrig = ScrollTrig.shared
    @ObservedObject var dataController = DataController.shared
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var appStateManager = AppStateManager.shared
    
    // @ObservedObject var froopDataListener = FroopDataListener.shared
    @ObservedObject var myData = MyData.shared
    
    @State var dHour = "01"
    @State var dMinute = "00"
    @State var hour = "" 
    @State var minute = ""
    @State var isPM = false
    @State var dayNight: Bool = true
    @State var showAlert = false
    @State var alertMessage = ""
    
    @Binding var transClock: Bool
    @Binding var datePicked: Bool
    @Binding var  duraVis: Bool
    @ObservedObject var froopData = FroopData.shared
    @ObservedObject var changeView: ChangeView

    let sourceTimeZone = TimeZone(identifier: "UTC")!

    let cal = Calendar.current
    let dateFormatter = DateFormatter()
    var dateString: String {
        dateFormatter.dateFormat = "MMMM yyyy"
        return dateFormatter.string(from: self.froopData.froopStartTime)
    }

    var selectedDateString: String {
        dateFormatter.dateFormat = "MMMM dd, yyyy"
        return dateFormatter.string(from: self.froopData.froopStartTime)
    }

    
    var body: some View {
        ZStack(alignment: .topLeading) {

            VStack{
                ZStack {
                    Rectangle()
                        .foregroundColor(.white)
                        .padding(.top, 125)
                    VStack {
                        ClockView(froopData: froopData)
                            .padding(.bottom, 100)
                        DurationView(froopData: froopData)
                    }
//                    .padding(.top, 80)
                }
                Spacer()
                //MARK: Button
                
               
                
            }
            .opacity(transClock ? 1 : 0)
            
            VStack {
                Spacer()
                ZStack {
                    Rectangle()
                        .fill(transClock ? Color(red: 20/255, green: 18/255, blue: 24/255)
                              : Color(red: 50/255, green: 46/255, blue: 62/255))
                        .opacity(1)
                        .frame(height: transClock ? UIScreen.screenHeight * 0.15 : 1, alignment: .bottom)
                    
                    Button {
                        if froopData.froopDuration == 0 {
                            showAlert = true
                            alertMessage = "A Duration must be set for your Froop."
                        } else {
                            scrollTrig.updateDateFromIndices()
                            if changeView.froopIsEditing {
                                ScrollTrig.shared.firstPositionIndex = 0
                                ScrollTrig.shared.secondPositionIndexA = 0
                                ScrollTrig.shared.secondPositionIndexB = 0
                                ScrollTrig.shared.thirdPositionIndex = 0
                                ScrollTrig.shared.fourthPositionIndex = 0
                                ScrollTrig.shared.fifthPositionIndex = 0
                                ScrollTrig.shared.sixthPositionIndex = 0
                                ScrollTrig.shared.seventhPositionIndex = 0
                                changeView.pageNumber = changeView.showSummary
                            } else {
                                ScrollTrig.shared.firstPositionIndex = 0
                                ScrollTrig.shared.secondPositionIndexA = 0
                                ScrollTrig.shared.secondPositionIndexB = 0
                                ScrollTrig.shared.thirdPositionIndex = 0
                                ScrollTrig.shared.fourthPositionIndex = 0
                                ScrollTrig.shared.fifthPositionIndex = 0
                                ScrollTrig.shared.sixthPositionIndex = 0
                                ScrollTrig.shared.seventhPositionIndex = 0
                                changeView.pageNumber += 1
                            }
                        }
                        
                    } label: {
                        Text("Confirm!")
                            .font(.system(size: 28, weight: .thin))
                            .foregroundColor(colorScheme == .dark ? .white : .white)
                            .multilineTextAlignment(.center)
                            .frame(width: 250, height: 45)
                            .border(Color.gray, width: 1)
                            .padding(.bottom, UIScreen.screenHeight * 0.025)
                    }
                }
            }
            .opacity(transClock ? 1 : 0)
            .ignoresSafeArea()
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Duration Alert"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    func calculateDuration(startTime: Date, endTime: Date) -> (hours: Int, minutes: Int, seconds: Int) {
        PrintControl.shared.printTime("-TimePickView: Function: calculateDuration is firing")
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute, .second], from: startTime, to: endTime)
        return (components.hour ?? 0, components.minute ?? 0, components.second ?? 0)
    }
    
    func convertToLocalTime(date: Date) -> Date {
        PrintControl.shared.printTime("-TimePickView: Function: convertToLocalTime is firing")
        let sourceTimeZone = TimeZone(identifier: "UTC")!
        let destinationTimeZone = TimeZone.current
        
        let sourceOffset = sourceTimeZone.secondsFromGMT(for: date)
        let destinationOffset = destinationTimeZone.secondsFromGMT(for: date)
        let interval = TimeInterval(destinationOffset - sourceOffset)
        
        return date.addingTimeInterval(interval)
    }
    
    func convertToUTC(date: Date) -> Date {
        PrintControl.shared.printTime("-TimePickView: Function: convertToUTC is firing")
        let sourceTimeZone = TimeZone.current
        let destinationTimeZone = TimeZone(identifier: "UTC")!

        let sourceOffset = sourceTimeZone.secondsFromGMT(for: date)
        let destinationOffset = destinationTimeZone.secondsFromGMT(for: date)
        let interval = TimeInterval(destinationOffset - sourceOffset)

        return date.addingTimeInterval(interval)
    }
    
    func updateFroopStartTime() {
        PrintControl.shared.printTime("-TimePickView: Function: updateFroopStartTime is firing")
        guard let hourInt = Int(hour), let minuteInt = Int(minute) else {
            return
        }
        
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: froopData.froopStartTime)
        dateComponents.hour = hourInt % 12 + (dayNight ? 12 : 0) // Convert to 24-hour format
        dateComponents.minute = minuteInt
        
        if let updatedDate = Calendar.current.date(from: dateComponents) {
            froopData.froopStartTime = updatedDate
        }
    }
    
    func updateFroopDuration() {
        PrintControl.shared.printTime("-TimePickView: Function: updateFroopDuration is firing")
        if let hourInt = Int(dHour), let minuteInt = Int(dMinute) {
            let totalSeconds = (hourInt * 60 + minuteInt) * 60
            froopData.froopDuration = totalSeconds
        }
    }
}

