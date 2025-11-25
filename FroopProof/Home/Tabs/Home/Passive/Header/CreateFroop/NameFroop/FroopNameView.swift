//
//  FroopNameView.swift
//  FroopProof
//
//  Created by David Reed on 1/19/23.
//

import SwiftUI
import iPhoneNumberField
import Firebase
import FirebaseFirestore
 
import UIKit



struct FroopNameView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var froopData = FroopData.shared
    @ObservedObject var changeView = ChangeView.shared
    var onFroopNamed: (() -> Void)?
    @State private var showAlert = false
    @State private var froopNameTextFieldValue: String = ""
    @State var animationAmount = 1.0
    @State private var isEditing = false

    
    var body: some View {
            ZStack {
                Rectangle()
                    .fill(Color.gray)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: UIScreen.main.bounds.height / 1, maxHeight: UIScreen.main.bounds.height)
                    .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 1)
                    .onAppear {
                        NavLocationServices.shared.trackUserLocation = true
                    }
                VStack{
                    
                    if isEditing {
                        withAnimation(.easeInOut(duration: 0.6)) {
                            Text("Your Froop name is")
                                .foregroundColor(colorScheme == .dark ? .white : Color(red: 50/255, green: 46/255, blue: 62/255))
                                .fontWeight(.semibold)
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .padding(.top, 150)
                        }
                    } else {
                        withAnimation(.easeInOut(duration: 0.6)) {
                            Text("Tap here to")
                                .foregroundColor(colorScheme == .dark ? .white : Color(red: 50/255, green: 46/255, blue: 62/255))
                                .fontWeight(.semibold)
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .padding(.top, 150)
                        }
                    }
   
                    KeyTextField(placeholder: "Name Your Froop", text: $froopNameTextFieldValue, isEditing: $isEditing)
                        .foregroundColor(colorScheme == .dark ? .white : Color(red: 50/255, green: 46/255, blue: 62/255))
                        .font(.system(size: 50,weight: .thin))
                        .multilineTextAlignment(.center)
                        .padding()
                        .frame(width: 400)
                    
                    Spacer()
                    
                   
                }
                
               
                Button(action: {
                    if froopNameTextFieldValue.isEmpty {
                        showAlert = true
                    } else {
                        froopData.froopName = froopNameTextFieldValue
                        PrintControl.shared.printFroopCreation("FroopData.id\(froopData.id)")
                        PrintControl.shared.printFroopCreation("Self.FroopData.id\(self.froopData.id)")
                        
                        // Dismiss the keyboard
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        
                        // Delay the transition to the next view by 2 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            if changeView.froopIsEditing {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    changeView.pageNumber = changeView.showSummary
                                }
                            } else {
                                changeView.pageNumber += 1
                            }
                        }
                    }
                }) {
                    ZStack {
                        Circle()
                            .foregroundColor(.white)
                            .opacity(1.0)
                            .frame(width: 120, height: 120)
                            .scaleEffect(animationAmount)
                        Circle()
                            .foregroundColor(.gray)
                            .frame(width: 100, height: 100)
                            .scaleEffect(animationAmount)
                        Text("Save")
                            .foregroundColor(.white)
                            .font(.title)
                            .fontWeight(.bold)
                    }
//
                }
                .padding(.top, 450)
                .offset(y: isEditing ? (-50 + calculateOffset(for: DataController.shared.screenSize)) : 0)
                
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Text Field is Empty"), message: Text("Please enter a name for your Froop."), primaryButton: .default(Text("OK")), secondaryButton: .cancel())
                
            }
        
    }
    func calculateOffset(for screenSize: ScreenSizeCategory) -> CGFloat {
        switch screenSize {
            case .size430x932:
                return -0 // This size works
            case .size428x926:
                return -0 // This size works
            case .size414x896:
                return -35 // This size works
            case .size393x852:
                return -35 // Replace with the appropriate value for this screen size
            case .size390x844:
                return -35 // Replace with the appropriate value for this screen size
            case .size375x812:
                return -35 // Replace with the appropriate value for this screen size
            default:
                return 0
        }
    }
}
