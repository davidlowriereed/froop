//
//  DatePickView.swift
//  FroopProof
//
//  Created by David Reed on 1/25/23.
//

//import SwiftUI
//import UIKit
//import Foundation
//
//
//
//struct DatePickView: View {
//    @Environment(\.colorScheme) var colorScheme
//    @ObservedObject var changeView = ChangeView.shared
//    @ObservedObject var dataController = DataController.shared
//    @ObservedObject var printControl = PrintControl.shared
//    // @ObservedObject var froopDataListener = FroopDataListener.shared
//    @Binding var transClock: Bool
//    @Binding var datePicked: Bool
//    @ObservedObject var froopData = FroopData.shared
////    @State var selectedDate = Date()
//    @State private var isTouched = false
//  
//    let dateFormatter = DateFormatter()
//    var dateString: String {
//        dateFormatter.dateFormat = "MMMM yyyy"
//        return dateFormatter.string(from: self.froopData.froopStartTime)
//    }
//    var selectedDateString: String {
//        dateFormatter.dateFormat = "MMMM dd, yyyy"
//        return dateFormatter.string(from: self.froopData.froopStartTime)
//    }
//    
//    var body: some View {
//        ZStack {
//            VStack {
//                ZStack(alignment: .top) {
//                    Rectangle()
//                        .fill(Color(red: 50/255, green: 46/255, blue: 62/255))
//                        .opacity(1)
//                        .frame(width: UIScreen.screenWidth, height: transClock ? UIScreen.screenHeight * 0.075 : UIScreen.screenHeight * 0.45)
//                        .transition(.move(edge: .bottom))
//                        .offset(y: transClock ? -25 : -25)
//                        .ignoresSafeArea()
//                    
//                    VStack {
//                        Text(datePicked ? selectedDateString : "When is it happening?")
//                            .font(.system(size: 32, weight: .thin))
//                            .foregroundColor(.primary)
//                            .frame(maxWidth: UIScreen.screenWidth - 30)
//                            .multilineTextAlignment(.center)
//                            .padding(.top, UIScreen.screenHeight * 0.2)
//                        
//                        if datePicked {
//                            Text("Confirm Date?")
//                                .font(.system(size: 28, weight: .thin))
//                                .foregroundColor(.primary)
//                                .multilineTextAlignment(.center)
//                                .frame(width: 225, height: 45)
//                                .border(Color.gray, width: 1)
//                                .padding(.top)
//                                .onTapGesture {
//                                    withAnimation(.spring()) {
//                                        transClock = true
//                                    }
//                                }
//                        }
//                    }
//                    .opacity(transClock ? 0 : 1)
//                    .animation(Animation.easeInOut(duration: 0.4), value: datePicked)
//                }
//                
//                //MARK:  Custom Bar Navigation for DatePicker
//                ZStack(alignment: .center){
//                    Rectangle()
//                        .fill(Color(red: 50/255, green: 46/255, blue: 62/255))
//                        .opacity(1)
//                        .frame(height: 75)
//                    HStack {
//                        Spacer()
//                        ZStack{
//                            Text(dateString)
//                                .font(.title2)
//                                .fontWeight(.light)
//                                .opacity(transClock ? 0 : 1)
//                                .foregroundColor(.white)
//                                .font(.system(size: 16, weight: .semibold))
//                                .multilineTextAlignment(.center)
//                            VStack{
//                                Text(selectedDateString)
//                                    .font(.title2)
//                                    .fontWeight(.light)
//                                    .opacity(transClock ? 1 : 0)
//                                    .foregroundColor(.white)
//                                    .font(.system(size: 16, weight: .semibold))
//                                    .multilineTextAlignment(.center)
//                                Image(systemName: "chevron.down")
//                                    .padding(.top, 1)
//                                    .foregroundColor(.gray)
//                                    .opacity(transClock ? 1 : 0)
//                            }
//                            .padding(.top, 0)
//                            Rectangle()
//                                .fill(Color(red: 50/255, green: 46/255, blue: 62/255))
//                                .opacity(0.001)
//                                .frame(width: 200, height: 75)
//                                .onTapGesture {
//                                    withAnimation(.spring()) {
//                                        transClock = false
//                                    }
//                                }
//                        }
//                        Spacer()
//                    }
//                }
//                .frame(width: UIScreen.screenWidth, height: 75)
//                
//                .offset(y: transClock ? calculateOffset(for: dataController.screenSize) : -25)
//                
//            }
//           
//            
//            TouchCaptureView {
//                if !isTouched {
//                    isTouched = true
//                    datePicked = true
//                }
//            }
//            .background(Color.clear)
//            .opacity(isTouched ? 0.0 : 1.0)
//        }
//        .offset(y: 0)
////        VStack {
////            Spacer()
////            ZStack (alignment: .top) {
////                
////                DatePicker(
////                    "Froop Date",
////                    selection: Binding(
////                        get: { froopData.froopStartTime },
////                        set: { newValue in
////                            let calendar = Calendar.current
////                            let dateComponents = calendar.dateComponents([.year, .month, .day], from: newValue)
////                            let newDate = calendar.date(from: dateComponents)!
////                            froopData.froopStartTime = newDate
////                        }
////                        
////                    ),
////                    displayedComponents: .date
////                    
////                )
////                .environment(\.timeZone, TimeZone.current)
////                .datePickerStyle(.automatic)
////
////            }
////            .opacity(transClock ? 0 : 1)
////        }
//    }
//    func nextMonth() {
//        PrintControl.shared.printTime("-DatePickView: Function: nextMonth is firing")
//        self.froopData.froopStartTime = Calendar.current.date(byAdding: .month, value: 1, to: self.froopData.froopStartTime) ?? Date()
//    }
//    
//    func moveToNextMonth() {
//        PrintControl.shared.printTime("-DatePickView: Function: moveToNextMonth is firing")
//        let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: froopData.froopStartTime)
//        froopData.froopStartTime = nextMonth ?? froopData.froopStartTime
//    }
//    
//    func moveToPreviousMonth() {
//        PrintControl.shared.printTime("-DatePickView: Function: moveToPreviousMonth is firing")
//        if Calendar.current.component(.month, from: froopData.froopStartTime) == Calendar.current.component(.month, from: Date()) {
//            //Don't update the month
//        } else {
//            let previousMonth = Calendar.current.date(byAdding: .month, value: -1, to: froopData.froopStartTime)
//            froopData.froopStartTime = previousMonth ?? froopData.froopStartTime
//        }
//    }
//    func currentDateComponentsInTimeZone(timeZoneIdentifier: String) -> DateComponents {
//        PrintControl.shared.printTime("-DatePickView: Function: currentDateComponentsInTimeZone is firing")
//        let now = Date()
//        let dateFormatter = DateFormatter()
//        dateFormatter.timeZone = TimeZone(identifier: timeZoneIdentifier)
//        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//        
//        let dateString = dateFormatter.string(from: now)
//        let dateInTimeZone = dateFormatter.date(from: dateString) ?? now
//        
//        let calendar = Calendar.current
//        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: dateInTimeZone)
//        
//        return components
//    }
//    
//    func convertToLocalTime(date: Date) -> Date {
//        PrintControl.shared.printTime("-DatePickView: Function: convertToLocalTime is firing")
//        let sourceTimeZone = TimeZone(identifier: "UTC")!
//        let destinationTimeZone = TimeZone.current
//        
//        let sourceOffset = sourceTimeZone.secondsFromGMT(for: date)
//        let destinationOffset = destinationTimeZone.secondsFromGMT(for: date)
//        let interval = TimeInterval(destinationOffset - sourceOffset)
//        
//        return date.addingTimeInterval(interval)
//    }
//    
//    func calculateOffset(for screenSize: ScreenSizeCategory) -> CGFloat {
//        switch screenSize {
//            case .size430x932:
//                return -325 // This size works
//            case .size428x926:
//                return -325 // This size works
//            case .size414x896:
//                return -315 // This size works
//            case .size393x852:
//                return -275 // Replace with the appropriate value for this screen size
//            case .size390x844:
//                return -300 // Replace with the appropriate value for this screen size
//            case .size375x812:
//                return -295 // Replace with the appropriate value for this screen size
//            default:
//                return 0
//        }
//    }
//}

