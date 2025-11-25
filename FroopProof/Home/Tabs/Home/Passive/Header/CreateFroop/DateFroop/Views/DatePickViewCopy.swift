//
//  DatePickViewCopy.swift
//  FroopProof
//
//  Created by David Reed on 12/3/23.
//

import SwiftUI
import UIKit
import Foundation

struct DatePickViewCopy: View {
    
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var dataController = DataController.shared
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var changeView = ChangeView.shared
    // @ObservedObject var froopDataListener = FroopDataListener.shared
    @Binding var transClock: Bool
    @Binding var datePicked: Bool
    @ObservedObject var froopData = FroopData.shared
    @State var selectedDate = Date()
    @State private var isTouched = false
    @State private var shrink: CGFloat = 0

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
        ZStack(alignment: .center) {
            
            DatePickerComponentView(transClock: $transClock, datePicked: $datePicked)
                .padding(.leading, UIScreen.screenWidth * 0.20)
                .opacity(transClock ? 0 : 1)
            
            //MARK:  Custom Bar Navigation for DatePicker
            
            VStack {
                Rectangle()
                    .fill(transClock ? Color(red: 20/255, green: 18/255, blue: 24/255)
                          : Color(red: 50/255, green: 46/255, blue: 62/255))
                    .opacity(1)
                    .frame(width: UIScreen.screenWidth, height: UIScreen.screenHeight * 0.5)
                    .frame(width: UIScreen.screenWidth, height: transClock ? UIScreen.screenHeight * 0.08 : UIScreen.screenHeight * 0.5)
                    .transition(.move(edge: .bottom))
                    .onTapGesture {
                        withAnimation(Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                            datePicked = true
                        }
                    }
                Spacer()
            }
            
            VStack {
                VStack (spacing: 0) {
                    Spacer()
                    Text(datePicked ? selectedDateString : "When is it happening?")
                        .font(.system(size: 32, weight: .thin))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    if datePicked {
                        Text("Confirm Date?")
                            .font(.system(size: 28, weight: .thin))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .frame(width: 225, height: 45)
                            .border(Color.gray, width: 1)
                            .padding(.top)
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    if froopData.froopType != 5009 {
                                        transClock = true
                                    } else {
                                        withAnimation(.easeInOut(duration: 0.5)) {
                                            changeView.pageNumber = 3
                                        }
                                    }
                                }
                            }
                    }
                    Spacer()
                }
                .offset(y: datePicked ? 20 : 0)
                .frame(width: UIScreen.screenWidth - 30, height: UIScreen.screenHeight * 0.5)
                .opacity(transClock ? 0 : 1)
                .animation(Animation.easeInOut(duration: 0.4), value: datePicked)
                Spacer()
            }
        
            VStack {
                if !transClock {
                    Spacer()
                }
                ZStack {
                    Rectangle()
                        .fill(Color(red: 20/255, green: 18/255, blue: 24/255))
                        .opacity(1)
                        .frame(height: 85)
                    
                    HStack {
                        
                        Spacer()
                        
                        ZStack{
                            
                            Text(dateString)
                                .font(.title2)
                                .fontWeight(.light)
                                .opacity(transClock ? 0 : 1)
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .semibold))
                                .multilineTextAlignment(.center)
                            VStack (spacing: 0){
                                Text(selectedDateString)
                                    .font(.title2)
                                    .fontWeight(.light)
                                    .opacity(transClock ? 1 : 0)
                                    .foregroundColor(.white)
                                    .font(.system(size: 16, weight: .semibold))
                                    .multilineTextAlignment(.center)
                                Image(systemName: "chevron.down")
                                    .padding(.top, 5)
                                    .foregroundColor(Color(red: 91/255, green: 92/255, blue: 93/255))
                                    .opacity(transClock ? 1 : 0)
                            }
                            .padding(.top, 0)
                            Rectangle()
                                .fill(Color(red: 50/255, green: 46/255, blue: 62/255))
                                .opacity(0.001)
                                .frame(width: 200, height: transClock ? 150 : 75)
                                .onTapGesture {
                                    withAnimation(.spring()) {
                                        transClock = false
                                    }
                                }
                        }
                        
                        Spacer()
                        
                    }
                }
                .offset(y: !transClock ? -25 : 0)
                .padding(.top, 85)
                Spacer()
            }
//            .offset(y: transClock ? -UIScreen.screenHeight * 0.3 : 0)
          

            TouchCaptureView {
                if !isTouched {
                    isTouched = true
                    datePicked = true
                }
            }
            .background(Color.clear)
            .opacity(isTouched ? 0.0 : 1.0)
        }
        .ignoresSafeArea()
    }
    
    func moveToPreviousMonth() {
        PrintControl.shared.printTime("-DatePickView: Function: moveToPreviousMonth is firing")
        if Calendar.current.component(.month, from: froopData.froopStartTime) == Calendar.current.component(.month, from: Date()) {
            //Don't update the month
        } else {
            let previousMonth = Calendar.current.date(byAdding: .month, value: -1, to: froopData.froopStartTime)
            froopData.froopStartTime = previousMonth ?? froopData.froopStartTime
        }
    }
    
    func moveToNextMonth() {
        PrintControl.shared.printTime("-DatePickView: Function: moveToNextMonth is firing")
        let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: froopData.froopStartTime)
        froopData.froopStartTime = nextMonth ?? froopData.froopStartTime
    }
}


