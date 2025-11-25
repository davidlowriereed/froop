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
import FirebaseFirestoreSwift
import UIKit



struct FroopNameView: View {
    @ObservedObject var changeView: ChangeView
    @ObservedObject var froopData: FroopData
    @Binding var pageNumber: Int
    var onFroopNamed: (() -> Void)?
    @State private var showAlert = false
    @State private var froopNameTextFieldValue: String = ""
    @State var animationAmount = 1.0
    
    
    var body: some View {
        NavigationView {
            ZStack {
                Rectangle()
                    .fill(Color.gray)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: UIScreen.main.bounds.height / 1, maxHeight: UIScreen.main.bounds.height)
                    .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 1)
                
                VStack{
                    Text("Tap here to")
                        .foregroundColor(.black)
                        .fontWeight(.semibold)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(.top, 150)
   
                    TextField("Name Your Froop", text: $froopNameTextFieldValue, axis: .vertical)
                        .foregroundColor(.black)
                        .font(.system(size: 50,weight: .thin))
                        //.lineLimit(nil)
                        //.frame(minWidth: 480, idealWidth: 480, maxWidth: 480)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        //.padding(.top, 20)
                        .padding()
                        .frame(width: 400)
                    Spacer()
                    
                   
                }
               
                Button(action: {
                    if froopNameTextFieldValue.isEmpty {
                        showAlert = true
                    } else {
                        froopData.froopName = froopNameTextFieldValue
                        changeView.pageNumber += 1
                    }
                }) {
                    ZStack {
                        Circle()
                            .foregroundColor(.black)
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
                
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Text Field is Empty"), message: Text("Please enter a name for your Froop."), primaryButton: .default(Text("OK")), secondaryButton: .cancel())
                
            }
        }
    }
}
