//
//  OnboardThree.swift
//  FroopProof
//
//  Created by David Reed on 10/6/24.
//

import SwiftUI
import MapKit
import Firebase
import FirebaseStorage
import Kingfisher


struct OnboardThree: View {
    @ObservedObject var myData = MyData.shared
    @ObservedObject var accountSetupManager = AccountSetupManager.shared
    @FocusState private var focusedField: ProfileNameFocus?
    @State var firstName: String = ""
    @State var lastName: String = ""
    @State private var isKeyboardShown: Bool = false
    @State private var keyboardHeight: CGFloat = 0
    var moveToNext: () -> Void
    var moveToPrevious: () -> Void
    let imageW: Font.Weight = .thin
    let fontS = Font.system(size: 35)
    
    var body: some View {
        ZStack (alignment: .top){
            Rectangle()
                .fill(
                    Color("FroopPink")
                )
                .onAppear {
                    focusedField = .second
                }
            
            VStack {
                Button {
                    moveToPrevious()
                } label: {
                    HStack {
                        Spacer()
                            .frame(width: 5)
                        Image(systemName: "arrow.backward.circle")
                            .font(.system(size: 36))
                            .foregroundColor(.white)
                            .fontWeight(.thin)
                            .padding(.top, 75)
                            .padding(.leading, 20)

                        Spacer()
                    }
                }
                Spacer()
            }
            
            VStack {
                HStack {
                    VStack (alignment: .leading){
                        Text("What is your Last Name?")
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .foregroundColor(Color(.white).opacity(1.0))
                            .padding(.top, 150)
                            .padding(.bottom, 10)
                        Text("This is the name ").froopTextStyle(opacity: 0.85)
                        Text("your friends and ").froopTextStyle(opacity: 0.85)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                        Text("family will see.").froopTextStyle(opacity: 0.85)
                    }
                    Spacer()
                }
                
                    .font(.system(size: 42))
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .multilineTextAlignment(.leading)
                    .padding(.leading, 25)
                
                ZStack (alignment: .leading) {
                    RoundedRectangle(cornerRadius: 25, style: .continuous)
                        .stroke(Color.white, lineWidth: 0.5)
                        .fill(Color(.white).opacity(0.4))
                        .frame(width: UIScreen.screenWidth * 0.8, height: 50)
                    
                    TextField("", text: $myData.lastName)
                        .focused($focusedField, equals: .second)
                        .font(.system(size: 42))
                        .fontWeight(.bold)
                        .foregroundColor(Color(.white).opacity(1.0))
                        .multilineTextAlignment(.leading)
                        .background(.clear)
                        .onSubmit {
                            moveToNext()
                        }
                        .submitLabel(.next)
                        .padding(.leading, 15)

                    Text(MyData.shared.lastName != "" ? "" : "Last Name")
                        .font(.system(size: 42))
                        .fontWeight(.bold)
                        .foregroundColor(Color(.white).opacity(0.5))
                        .multilineTextAlignment(.leading)
                        .background(.clear)
                        .padding(.leading, 15)
                }
                .padding(.leading, UIScreen.screenWidth * 0.1)
                .padding(.trailing, UIScreen.screenWidth * 0.1)
                .padding(.top, 50)
                
                Spacer()
            }
            .ignoresSafeArea()
        }
    }

}

