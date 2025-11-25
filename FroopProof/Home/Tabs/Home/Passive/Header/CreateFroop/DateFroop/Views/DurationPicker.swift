//
//  DurationPicker.swift
//  FroopProof
//
//  Created by David Reed on 1/31/23.
//

import SwiftUI

struct DurationPicker: View {
    @Environment(\.colorScheme) var colorScheme
    
    
    @ObservedObject var printControl = PrintControl.shared
   
    // @ObservedObject var froopDataListener = FroopDataListener.shared
   
 
    
    @ObservedObject var froopData = FroopData.shared
    @State private var selectedDay = 0
    @State private var selectedHour = 0
    @State private var selectedMinute = 0
    @State var durationTotal = 0
    
    var days = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]
    var hours = Array(0...23)
    var minutes = [00,15,30,45]
    
    func roundToNearestQuarterHour(_ minutes: Int) -> Int {
        PrintControl.shared.printTime("roundToNearestQuarterHour: Function: roundToNearestQuarterHour is firing!")
        let remainder = minutes % 15
        if remainder == 0 {
            return minutes
        } else if remainder <= 7 {
            return minutes - remainder
        } else {
            return minutes + (15 - remainder)
        }
    }
    
    func updateDurationTotal() {
        PrintControl.shared.printTime("roundToNearestQuarterHour: Function: updateDurationTotal is firing!")
        let roundedMinutes = roundToNearestQuarterHour(selectedMinute)
        self.durationTotal = self.selectedDay * 24 * 60 * 60 + self.selectedHour * 60 * 60 + roundedMinutes * 60
        froopData.froopDuration = self.durationTotal
        PrintControl.shared.printTime(durationTotal.description)
    }
    
    var body: some View {
        VStack (alignment: .center){
            HStack (alignment: .top, spacing: 15){
                
                VStack {
                    ZStack (alignment: .top){
                        Picker(selection: $selectedDay, label: Text("Days")) {
                            ForEach(0..<7) { day in
                                Text("\(day)").font(.system(size: 30, weight: .light))
                            }
                        }
                        .onChange(of: selectedDay, initial: false) { _, _ in
                            self.updateDurationTotal()
                        }

                        .pickerStyle(WheelPickerStyle())
                        .offset(y: 0)
                        
                        Rectangle()
                            .fill(.white)
                            .frame(width: 100, height: 75)
                        
                        Text("Days")
                            .offset(y: 40)
                            .font(.system(size: 24))
                            .fontWeight(.light)
                        
                       
                    }
                }
                .frame(width: 100)
                //.border(.pink)
                Spacer()
                
                VStack {
                    ZStack (alignment: .top){
                        Picker(selection: $selectedHour, label: Text("Hours")) {
                            ForEach(0 ..< 24) { setHour in
                                Text("\(setHour)").font(.system(size: 30, weight: .light))
                                
                            }
                        }
                        .onChange(of: selectedHour, initial: false) { _, _ in
                            self.updateDurationTotal()
                        }
                        
                        .pickerStyle(WheelPickerStyle())
                        .offset(y: 0)
                        
                        Rectangle()
                            .fill(.white)
                            .frame(width: 100, height: 75)
                        
                        Text("Hours")
                            .offset(y: 40)
                            .font(.system(size: 24))
                            .fontWeight(.light)
                        
                        
                    }
                }
                .frame(width: 100)
                //.border(.pink)
                Spacer()

                VStack {
                    ZStack (alignment: .top){
                        Picker(selection: $selectedMinute, label: Text("Minutes")) {
                            ForEach(minutes.indices) { index in
                                Text("\(minutes[index])").font(.system(size: 30, weight: .light))
                            }
                        }
                        .onChange(of: selectedMinute, initial: false) { _, _ in
                            let roundedMinutes = roundToNearestQuarterHour(selectedMinute)
                            self.durationTotal = self.selectedDay * 24 * 60 * 60 + self.selectedHour * 60 * 60 + roundedMinutes * 60
                            froopData.froopDuration = self.durationTotal
                            PrintControl.shared.printTime(durationTotal.description)
                        }

                        .pickerStyle(WheelPickerStyle())
                        .offset(y: 0)
                        .onDisappear {
                            durationTotal = 0
                        }
                        Rectangle()
                            .fill(.white)
                            .frame(width: 100, height: 75)
                        
                        Text("Minutes")
                            .offset(y: 40)
                            .font(.system(size: 24))
                            .fontWeight(.light)
                        
                        
                    }
                }
                .frame(width: 100)
                //.border(.pink)
                Spacer()
            }
            //.border(.orange)
            .padding(.trailing, 50)
            .padding(.top, 50)
        }
    }
}
