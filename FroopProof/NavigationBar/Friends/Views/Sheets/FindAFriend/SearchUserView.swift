//
//  SearchUserView.swift
//  FroopProof
//
//  Created by David Reed on 2/23/23.
//

import SwiftUI
import UIKit
import Kingfisher
import Firebase
import FirebaseAuth
import FirebaseFirestore
import iPhoneNumberField
import Combine
import ContactsUI

struct SearchUserView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var navLocationServices = NavLocationServices.shared
    // @ObservedObject var froopDataListener = FroopDataListener.shared
    
    @State private var selectedContact: HashableCNContact?
    @State var isContactPickerActive = false
    @ObservedObject var myData = MyData.shared
    @State private var actionSheetVisible = false
    @State private var navigationLinkValue: HashableCNContact? = nil
    @State private var foundUser: UserData?
    @State private var showTextMessageView = false
    @State private var phoneNumber: String = ""
    @State private var isFocused = false
    @State private var revealed = false
    @State var showContact = false
    @State var callFunc = false
    @State var noFriendFound = false
    @Binding var toUserID: String
    enum FocusField: Hashable {
        case field
        case nofield
    }
    @FocusState private var focusedField: FocusField?
    var friendData: UserData = UserData()
    
    // Declare an instance of FriendViewController to use its functions
    @ObservedObject var friendViewController = FriendViewController.shared
    @State var friendDataList: [UserData] = []
    @State var extractedFriendData: UserData = UserData()
    
    
    var body: some View {
        ZStack (alignment: .top) {
            
            PlaceHolderFindFriendCard()
                .padding(.top, 75)
                .opacity(noFriendFound ? 0.0 : 0.5)

            VStack(alignment: .center)  {
                
                Text("Let's Find Your Friends")
                    .font(.system(size: 20))
                    .fontWeight(.light)
                    .foregroundColor(colorScheme == .dark ? Color(.white) : Color(red: 50/255, green: 46/255, blue: 62/255))
                    .opacity(revealed || noFriendFound ? 0.0 : 0.7)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .padding(.top, 200)
                    .animation(.easeInOut(duration: 0.3), value: revealed)
                    .frame(width: 350)
                
                iPhoneNumberField("Enter phone number", text: $phoneNumber)
                    .flagHidden(true)
                    .flagSelectable(true)
                    .font(UIFont(size: 42, weight: .thin))
                    .maximumDigits(11)
                    .foregroundColor(colorScheme == .dark ? Color(.white) : Color(red: 50/255, green: 46/255, blue: 62/255))
                    .accentColor(Color(red: 249/255, green: 0/255, blue: 98/255))
                    .frame(width: 280, height: 50)
                    .focused($focusedField, equals: .field)
                    .onAppear {focusedField = .field}
                    .multilineTextAlignment(.center)
                    .padding(.top, 25)
                    .onAppear {
                        print("Printing friendDataList from the phoneNumberField:  \(friendDataList)")
                    }
                    .offset(y: -25)
                HStack {
                    Spacer()
                    Button(action: {
                        print("Phone number: \(phoneNumber)")
                        FriendViewController.shared.findFriendsByPhoneNumber(phoneNumber: phoneNumber, uid: MyData.shared) { friendLookUpResultList, error in
                            if let error = error {
                                print("🚫Error finding friends by phone number: \(error.localizedDescription)")
                                return
                            }
                            if friendLookUpResultList.isEmpty {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    noFriendFound = true
                                    revealed = false
                                }
                                print("No friends found with phone number: \(phoneNumber)")
                            } else {
                                FriendViewController.shared.convertListToFriendData(uidList: friendLookUpResultList) { friendDataList, error in
                                    if let error = error {
                                        print("🚫Error converting list to friend data: \(error.localizedDescription)")
                                        return
                                    }
                                    self.friendDataList = friendDataList
                                    extractedFriendData = friendDataList.first ?? UserData()
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        revealed = true
                                    }
                                }
                            }
                        }
                    }) {
                        ZStack {
                            Rectangle()
                                .frame(width: 175, height: 40)
                                .foregroundColor(.clear)
                                .background(.ultraThinMaterial)
                                .border(.gray, width: 0.25)
                            Text("Search")
                                .font(.headline)
                                .foregroundColor(colorScheme == .dark ? Color(.white) : Color(red: 50/255, green: 46/255, blue: 62/255))
                                .font(.system(size: 24))
                                .fontWeight(.medium)
                                .frame(width: 200, height: 40)
                        }
                        
                    }
                    .opacity(noFriendFound ? 0.0 : 1.0)
                 
                    
                    
                    Button(action: {
                        isContactPickerActive = true
                    }) {
                        ZStack {
                            Rectangle()
                                .frame(width: 175, height: 40)
                                .foregroundColor(.clear)
                                .background(.ultraThinMaterial)
                                .border(.gray, width: 0.25)
                            Text("Open Contacts")
                                .font(.headline)
                                .foregroundColor(colorScheme == .dark ? Color(.white) : Color(red: 50/255, green: 46/255, blue: 62/255))
                                .font(.system(size: 24))
                                .fontWeight(.medium)
                                .frame(width: 200, height: 40)
                        }
                    }
                }
                .padding(.top, 25)
                .padding(.leading, 25)
                .padding(.trailing, 25)
                .opacity(noFriendFound ? 0.0 : 1.0)
                .fullScreenCover(isPresented: $isContactPickerActive) {
                    ContactPicker(onPhoneNumberSelected: { phoneNumber in
                        self.phoneNumber = phoneNumber
                    }, selectedContact: $selectedContact)
                }
                Spacer()
            }
            
            .opacity(revealed ? 0.0 : 1.0)
            .padding(.top, 40)
            
            
        TextFriendOutsideFroop(showTextMessageView: $showTextMessageView, noFriendFound: $noFriendFound, phoneNumber: $phoneNumber)
            .padding(.top, 75)
            .opacity(noFriendFound ? 1.0 : 0.0)
        
        FriendSearchCardView(extractedFriendData: $extractedFriendData, friendData: friendData, revealed: $revealed)
            .padding(.top, 75)
            .opacity(revealed ? 1.0 : 0.0)
            .frame(width: UIScreen.screenWidth * 0.95)
            
        }
        .frame(width: UIScreen.screenWidth)
        .ignoresSafeArea(.keyboard)
        .onTapGesture {
            isFocused = false
        }
    }
    
}

struct HashableCNContact: Hashable {
    let contact: CNContact
    var phoneNumber: String?

    init(contact: CNContact, phoneNumber: String? = nil) {
        self.contact = contact
        self.phoneNumber = phoneNumber
    }
}

struct SelectedContactKey: EnvironmentKey {
    static let defaultValue: HashableCNContact? = nil
}

extension EnvironmentValues {
    var selectedContact: HashableCNContact? {
        get { self[SelectedContactKey.self] }
        set { self[SelectedContactKey.self] = newValue }
    }
}


//struct HashableCNContact: Hashable {
//    let contact: CNContact
//    
//    init(contact: CNContact) {
//        // Make a mutable copy of the CNContact
//        let mutableContact = contact.mutableCopy() as! CNMutableContact
//
//        // Format phone numbers
//        let formattedPhoneNumbers = mutableContact.phoneNumbers.map { (labelValue) -> CNLabeledValue<CNPhoneNumber> in
//            let originalPhoneNumber = labelValue.value.stringValue
//            let formattedPhoneNumber = originalPhoneNumber.formattedPhoneNumberC
//            let phoneNumber = CNPhoneNumber(stringValue: formattedPhoneNumber)
//            return CNLabeledValue(label: labelValue.label, value: phoneNumber)
//        }
//
//        // Update phone numbers
//        mutableContact.phoneNumbers = formattedPhoneNumbers
//
//        // Update the contact property
//        self.contact = mutableContact
//    }
//}
