//
//  TimeEnterView.swift
//  FroopProof
//
//  Created by David Reed on 4/13/23.
//

import SwiftUI
import Combine

struct TimeEnterView: View {
    @Environment(\.colorScheme) var colorScheme
    
    
    @ObservedObject var printControl = PrintControl.shared
   
    // @ObservedObject var froopDataListener = FroopDataListener.shared
   
 
    
    @State private var hour1: String = ""
    @State private var minute1: String = ""
    @Binding var dayNight: Bool
    @State var currentFocus: TextFieldFocus = .none
    @FocusState private var hour1Focus: Bool
    @FocusState private var minute1Focus: Bool
    @Binding var transClock: Bool
    
    @Binding var hour: String
    @Binding var minute: String
    @Binding var isPM: Bool
    
    enum TextFieldFocus {
        case none
        case hour1
        case hour2
        case minute1
        case minute2
    }
    
    let textScale = 1.0
    
    var body: some View {
        VStack {
            HStack {
                Text("TIME")
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 12))
                    .fontWeight(.semibold)
                    .foregroundColor(colorScheme == .dark ? .white : Color(red: 50/255, green: 46/255, blue: 62/255))               
                    .padding(.leading, 40)
                    .offset(y: 10)
                Spacer()
            }
            .onAppear {
                let date1 = Date()
                let formatterH = DateFormatter()
                formatterH.dateFormat = "hh"
                let formatterM = DateFormatter()
                formatterM.dateFormat = "MM"
                let hourString = formatterH.string(from: date1)
                let minuteString = formatterM.string(from: date1)
                hour = hourString
                minute = "00"
            }
            
            ZStack {
                Rectangle()
                    .frame(width: 350, height: 100)
                    .foregroundColor(colorScheme == .dark ? .white : Color(red: 50/255, green: 46/255, blue: 62/255))
                    .opacity(0.25)
                Rectangle()
                    .frame(width: 125, height: 100)
                    .foregroundColor(colorScheme == .dark ? .white : .white)
                    .opacity(hour1Focus ? 0.8 : 0.0)
                    .offset(x: -103)
                
                Rectangle()
                    .frame(width: 125, height: 100)
                    .foregroundColor(colorScheme == .dark ? .white : .white)
                    .opacity(minute1Focus ? 0.8 : 0.0)
                    .offset(x: 50)
                
                HStack {
                    Spacer()
                        .padding(.leading, 15)
                    if (transClock == true) {
                        TextField("00", text: Binding(
                            get: { hour },
                            set: { newValue in
                                hour = newValue
                            }
                        ))
                        .multilineTextAlignment(.trailing)
                        .font(.system(size: 80))
                        .fontWeight(.thin)
                        .foregroundColor(colorScheme == .dark ? Color(red: 50/255, green: 46/255, blue: 62/255) : Color(red: 50/255, green: 46/255, blue: 62/255))
                        .frame(minWidth: 100)
                        .lineLimit(1)
                        .minimumScaleFactor(textScale)
                        .allowsTightening(true)
                        .focused($hour1Focus)
                        .keyboardType(.numberPad)
                        .onTapGesture {
                            customHour1Binding.wrappedValue = ""
                        }
                        .onReceive(Just(hour)) { newValue in
                            if newValue.count > 2 {
                                hour = String(newValue.prefix(2))
                            }
                        }
                    } else {
                        TextField("00", text: Binding(
                            get: { hour },
                            set: { newValue in
                                if newValue.count <= 2 {
                                    hour = newValue
                                } else {
                                    hour = String(newValue.prefix(2))
                                }
                            }
                        ))
                        .multilineTextAlignment(.trailing)
                        .font(.system(size: 80))
                        .fontWeight(.thin)
                        .foregroundColor(colorScheme == .dark ? Color(red: 50/255, green: 46/255, blue: 62/255) : Color(red: 50/255, green: 46/255, blue: 62/255))
                        .frame(minWidth: 100)
                        .lineLimit(1)
                        .minimumScaleFactor(textScale)
                        .allowsTightening(true)
                        .keyboardType(.numberPad)
                        .onTapGesture {
                                customHour1Binding.wrappedValue = ""
                            }
                        .onReceive(Just(hour)) { newValue in
                            if newValue.count > 2 {
                                hour = String(newValue.prefix(2))
                            }
                        }
                    }
                                        
                    Text(":")
                        .multilineTextAlignment(.center)
                        .font(.system(size: 80))
                        .fontWeight(.thin)
                        .foregroundColor(colorScheme == .dark ? Color(red: 50/255, green: 46/255, blue: 62/255) : Color(red: 50/255, green: 46/255, blue: 62/255))
                        .frame(alignment: .top)
                        .offset(y: -12)
                        .lineLimit(1)
                        .minimumScaleFactor(textScale)
                        .allowsTightening(true)
                    
                    
                    
                    TextField("00", text: Binding(
                        get: { minute },
                        set: { newValue in
                            if newValue.count <= 2 {
                                minute = newValue
                            } else {
                                minute = String(newValue.prefix(2))
                            }
                        }
                    ))
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 80))
                    .fontWeight(.thin)
                    .foregroundColor(colorScheme == .dark ? Color(red: 50/255, green: 46/255, blue: 62/255) : Color(red: 50/255, green: 46/255, blue: 62/255))
                    .frame(minWidth: 100)
                    .lineLimit(1)
                    .minimumScaleFactor(textScale)
                    .allowsTightening(true)
                    .focused($minute1Focus)
                    .keyboardType(.numberPad)
                    .onTapGesture {
                        customMinute1Binding.wrappedValue = ""
                    }
                    .onReceive(Just(minute)) { newValue in
                        if newValue.count > 2 {
                            minute = String(newValue.prefix(2))
                        }
                    }
                    
                    VStack {
                        Text(dayNight ? "PM" : "AM")
                            .font(.system(size: 24))
                            .fontWeight(.light)
                            .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255 ))
                            .frame(minWidth: 45)
                            .offset(y: -20)
                            .offset(x: 20)
                            .lineLimit(1)
                            .minimumScaleFactor(textScale)
                            .allowsTightening(true)
                            .onTapGesture {
                                dayNight.toggle()
                            }
                        Text(dayNight ? "AM" : "PM")
                            .font(.system(size: 24))
                            .fontWeight(.thin)
                            .foregroundColor(colorScheme == .dark ? .white : Color(red: 50/255, green: 46/255, blue: 62/255))
                            .opacity(0.3)
                            .frame(minWidth: 45)
                            .offset(y: -20)
                            .offset(x: 20)
                            .lineLimit(1)
                            .minimumScaleFactor(textScale)
                            .allowsTightening(true)
                            .onTapGesture {
                                dayNight.toggle()
                            }
                    }
                    
                    Spacer()
                        .padding(.trailing, 25)
                        .onAppear {
                            DispatchQueue.main.async {
                                hour1Focus = true
                            }
                        }
                }
            }
        }
        
    }
    
    var customHour1Binding: Binding<String> {
        Binding<String>(
            get: { self.hour1 },
            set: { newValue in
                if newValue.isEmpty {
                    self.hour1 = ""
                    return
                }
                
                let trimmedValue = String(newValue.prefix(2))
                
                if let number = Int(trimmedValue), number >= 0 && number <= 12 {
                    self.hour1 = String(number)
                    if trimmedValue.count == 2 {
                        minute1Focus = true
                    }
                } else if let number = Int(trimmedValue), number >= 13 {
                    self.hour1 = ""
                    self.currentFocus = .minute1
                }
            }
        )
    }

    var customMinute1Binding: Binding<String> {
        Binding<String>(
            get: { self.minute1 },
            set: { newValue in
                if newValue.isEmpty {
                    self.minute1 = ""
                    return
                }
                
                let trimmedValue = String(newValue.prefix(2))
                
                if let number = Int(trimmedValue), number >= 0 && number <= 59 {
                    self.minute1 = String(number)
                    self.currentFocus = .minute2
                } else if let number = Int(trimmedValue), number >= 60 {
                    self.minute1 = ""
                    self.currentFocus = .none
                }
            }
        )
    }
}


