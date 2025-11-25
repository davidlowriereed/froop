//
//  DurationEnterView.swift
//  FroopProof
//
//  Created by David Reed on 4/13/23.
//

import SwiftUI

struct DurationEnterView: View {
    @Environment(\.colorScheme) var colorScheme

    @ObservedObject var printControl = PrintControl.shared

    @State private var hour1: String = ""
    @State private var minute1: String = ""
    @State var currentFocus: TextFieldFocus = .none
    @FocusState private var hour1Focus: Bool
    @FocusState private var minute1Focus: Bool
    
    @Binding var dHour: String
    @Binding var dMinute: String
    
    let textScale = 1.0
    
    var body: some View {
        VStack {
            HStack {
                Text("DURATION")
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 12))
                    .fontWeight(.semibold)
                    .foregroundColor(colorScheme == .dark ? .white : Color(red: 50/255, green: 46/255, blue: 62/255))
                    .padding(.leading, 40)
                    .offset(y: 10)
                Spacer()
            }
            ZStack {
                Rectangle()
                    .frame(width: 350, height: 100)
                    .foregroundColor(colorScheme == .dark ? .white : Color(red: 50/255, green: 46/255, blue: 62/255))
                    .opacity(0.25)
                Rectangle()
                    .frame(width: 125, height: 100)
                    .foregroundColor(colorScheme == .dark ? .white : .white)
                    .offset(x: -115)
                    .opacity(hour1Focus ? 0.8 : 0.0)
                Rectangle()
                    .frame(width: 125, height: 100)
                    .foregroundColor(colorScheme == .dark ? .white : .white)
                    .offset(x: 60)
                    .opacity(minute1Focus ? 0.8 : 0.0)
                
                
                
                HStack{
                    Spacer()
                        .padding(.leading, 15)
                    
                    TextField("", text: Binding(
                        get: { dHour },
                        set: { newValue in
                            if newValue.count <= 2 {
                                dHour = newValue
                            } else {
                                dHour = String(newValue.prefix(2))
                            }
                        }
                    ))
                    .multilineTextAlignment(.trailing)
                    .font(.system(size: 80))
                    .fontWeight(.thin)
                    .foregroundColor(colorScheme == .dark ? Color(red: 50/255, green: 46/255, blue: 62/255) : Color(red: 50/255, green: 46/255, blue: 62/255))
                    .frame(minWidth: 100)
                    .lineLimit(1)
                    .focused($hour1Focus)
                    .minimumScaleFactor(textScale)
                    .allowsTightening(true)
                    .keyboardType(.numberPad)
                    
                    
                    Text("hrs")
                        .font(.system(size: 24))
                        .fontWeight(.thin)
                        .foregroundColor(colorScheme == .dark ? Color(red: 50/255, green: 46/255, blue: 62/255) : Color(red: 50/255, green: 46/255, blue: 62/255))
                        .frame(minWidth: 45)
                        .offset(y: 20)
                        .lineLimit(1)
                        .minimumScaleFactor(textScale)
                        .allowsTightening(true)
                    
                    
                    TextField("", text: Binding(
                        get: { dMinute },
                        set: { newValue in
                            if newValue.count <= 2 {
                                dMinute = newValue
                            } else {
                                dMinute = String(newValue.prefix(2))
                            }
                        }
                    ))
                        .multilineTextAlignment(.trailing)
                        .font(.system(size: 80))
                        .fontWeight(.thin)
                        .foregroundColor(colorScheme == .dark ? Color(red: 50/255, green: 46/255, blue: 62/255) : Color(red: 50/255, green: 46/255, blue: 62/255))
                        .frame(minWidth: 100)
                        .focused($minute1Focus)
                        .lineLimit(1)
                        .minimumScaleFactor(textScale)
                        .allowsTightening(true)
                        .keyboardType(.numberPad)
                        
                    
                    Text("min")
                        .font(.system(size: 24))
                        .fontWeight(.thin)
                        .foregroundColor(colorScheme == .dark ? Color(red: 50/255, green: 46/255, blue: 62/255) : Color(red: 50/255, green: 46/255, blue: 62/255))
                        .frame(minWidth: 45)
                        .offset(y: 20)
                        .offset(x: 5)
                        .lineLimit(1)
                        .minimumScaleFactor(textScale)
                        .allowsTightening(true)
                    
                    Spacer()
                        .padding(.trailing, 25)
                }
                
            }
        }
        .ignoresSafeArea(.keyboard)
    }
    
    enum TextFieldFocus {
        case none
        case hour1
        case hour2
        case minute1
        case minute2
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


