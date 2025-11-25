//
//  textFriendOutsideFroop.swift
//  FroopProof
//
//  Created by David Reed on 3/12/23.
//

import SwiftUI
import UIKit
import Kingfisher
import MessageUI

struct TextFriendOutsideFroop: View {
    
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var navLocationServices = NavLocationServices.shared
    // @ObservedObject var froopDataListener = FroopDataListener.shared
 
    
    @State private var isMessageViewPresented: Bool = false
    @Binding var showTextMessageView: Bool
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var MVC: MessagesViewController = MessagesViewController()
    @ObservedObject var myData = MyData.shared 
    var timestamp: Date = Date()
    @Binding var noFriendFound: Bool
    @Binding var phoneNumber: String
    @ObservedObject var friendViewController = FriendViewController.shared
    @State private var messageBody: String = "This is the default message body"
    
    @State private var phoneNumbers: [String] = []
    
    var body: some View {
        ZStack (alignment: .top){
            RoundedRectangle(cornerRadius: 10)
                .frame(height: 280)
                .foregroundColor(.white)
                .padding(.leading, 10)
                .padding(.trailing, 10)
            VStack (alignment: .leading) {
                HStack (alignment: .center){
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 80))
                        .frame(width: 80, height: 80)
                        .padding(.leading, 10)
                        .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                        .opacity(0.6)
                    VStack (alignment: .leading) {
                        Text("No Froop Users found ...")
                            .font(.system(size: 20))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                            .frame(alignment: .leading)
                            .padding(.top, 25)
                        Text("Would you like to send an SMS Invitation?")
                            .font(.system(size: 18))
                            .fontWeight(.light)
                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                            .frame(alignment: .leading)
                            .padding(.top, 10)
                        
                        Text("Phone Number: \(formatPhoneNumber(phoneNumber))")
                            .font(.system(size: 18))
                            .fontWeight(.light)
                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                            .frame(alignment: .leading)
                            .padding(.top, 10)
                    }
                    .padding(.leading, 10)
                }
                
                Divider()
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                    .padding(1)
                    .padding(1)
                Text ("Tap below to text your friend.")
                    .font(.system(size: 14))
                    .fontWeight(.regular)
                    .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                    .frame(alignment: .leading)
                    .padding(.leading, 25)
                    .padding(.trailing, 25)
                
                Divider()
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                    .padding(1)
                    .padding(1)
                
                VStack(alignment: .center) {
                    HStack {
                        Button {
                            isMessageViewPresented = true
                        } label: {
                            Text("Send SMS Invite")
                                .font(.system(size: 16))
                                .fontWeight(.medium)
                                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                .frame(width: 150, height: 35)
                                .border(.gray, width: 0.25)
                        }
                        .padding(.leading, 25)
                        
                        Button {
                            noFriendFound = false
                            phoneNumber = ""
                        } label: {
                            Text("Close")
                                .font(.system(size: 16))
                                .fontWeight(.medium)
                                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                .frame(width: 150, height: 35)
                                .border(.gray, width: 0.25)
                            
                        }
                        .padding(.leading, 25)
                        .padding(.trailing, 25)
                    }
                    .padding(.top, 10)
                }
            }
            .padding(.leading, 30)
            .sheet(isPresented: $isMessageViewPresented) {
                MessageView(isPresented: $isMessageViewPresented, phoneNumber: phoneNumber)
            }
            Spacer()
        }
        .frame(maxWidth: UIScreen.screenWidth)
    }
    
    func formatPhoneNumber(_ phoneNumber: String) -> String {
        let cleanedPhoneNumber = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        let mask = "(XXX) XXX-XXXX"
        var result = ""
        var index = cleanedPhoneNumber.startIndex
        for ch in mask where index < cleanedPhoneNumber.endIndex {
            if ch == "X" {
                result.append(cleanedPhoneNumber[index])
                index = cleanedPhoneNumber.index(after: index)
            } else {
                result.append(ch)
            }
        }
        return result
    }
}
