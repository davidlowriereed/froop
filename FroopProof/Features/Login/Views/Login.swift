//
//  Login2.swift
//  FroopProof
//
//  Created by David Reed on 4/1/23.
//

import SwiftUI
import UIKit
import MapKit
import AuthenticationServices
import GoogleSignIn
import GoogleSignInSwift
import Firebase



struct Login: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var printControl = PrintControl.shared
    
    @StateObject var loginModel: LoginViewModel = .init()
    @State var isKeyboardOpen = false
    @State var isFocused: Bool = false
    @FocusState private var focusedField: FocusField?
    @State var keyboardOff = false
    @State var isKeyboardVisible = false
    
    
    
    enum FocusField: Hashable {
        case phoneNumberTextField
        case none
    }
    
    var body: some View {
        BackgroundView(isKeyboardOpen: $isKeyboardOpen, isKeyboardVisible: $isKeyboardVisible) {
            VStack {
                WelcomeText(isKeyboardVisible: $isKeyboardVisible)
                SignInButton(loginModel: loginModel)
            }
            .ignoresSafeArea(.keyboard)
            .offset(y: isKeyboardVisible ? 150 : 0)
            .animation(.easeInOut(duration: 0.3), value: isKeyboardVisible)
        }
    }
}

struct BackgroundView<Content: View>: View {
    let content: Content
    @Binding var isKeyboardOpen: Bool
    @Binding var isKeyboardVisible: Bool

    init(isKeyboardOpen: Binding<Bool>, isKeyboardVisible: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self._isKeyboardOpen = isKeyboardOpen
        self._isKeyboardVisible = isKeyboardVisible
        self.content = content()
    }

    var body: some View {
        ZStack (alignment: .top) {
            ZStack {
                Image("Background_Froop")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .brightness(-0.25)
                    .edgesIgnoringSafeArea(.all)
                    .ignoresSafeArea()
                    .frame(alignment: .center)
                    .offset(x: -20)
                Rectangle()
                    .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                    .opacity(0.01)
                    .frame(minWidth: 0,maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.all)
                    .ignoresSafeArea()
                    .gesture(
                        TapGesture()
                            .onEnded {
                                isKeyboardOpen = false
                                isKeyboardVisible = false
                            }
                    )
            }
            content
        }
    }
}

struct WelcomeText: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var isKeyboardVisible: Bool
    
    var body: some View {
        VStack {
            Image("froopWhiteIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: isKeyboardVisible ? 50 : 100, alignment: .center)
                .animation(.easeInOut(duration: 0.3), value: isKeyboardVisible)
            
            Text("Welcome to")
                .foregroundColor(colorScheme == .dark ? .white : .white)
                .font(.system(size: 42))
                .fontWeight(.light)
                .lineSpacing(5)
                .multilineTextAlignment(.center)
                .padding(.top, 25)
                .frame(width: 300, height: 40)
                .animation(.easeInOut(duration: 0.3), value: isKeyboardVisible)
            
            Text("Froop!")
                .foregroundColor(colorScheme == .dark ? .white : .white)
                .font(.system(size: 42))
                .fontWeight(.light)
                .lineSpacing(5)
                .multilineTextAlignment(.center)
                .padding(.top, 15)
                .frame(width: 300, height: 40)
                .animation(.easeInOut(duration: 0.3), value: isKeyboardVisible)
            
            (Text("Do Anything, with Anyone,")
                .foregroundColor(colorScheme == .dark ? .white : .white) +
             Text("\nAnywhere" )
                .foregroundColor(colorScheme == .dark ? .white : .white)
            )
            .font(.system(size: 18))
            .fontWeight(.light)
            .multilineTextAlignment(.center)
            .padding(.top, 25)
        }
        .padding(.top,  UIScreen.screenHeight * 0.075)
    }
}

struct SignInButton: View {
    @ObservedObject var loginModel: LoginViewModel

    var body: some View {
        VStack(alignment: .center) {
            Spacer()

            // Use the official Apple Sign In button
            SignInWithAppleButton { (request) in
                loginModel.nonce = randomNonceString()
                request.requestedScopes = [.email, .fullName]
                request.nonce = sha256(loginModel.nonce)
                PrintControl.shared.printLogin("Requesting Apple Sign-In with nonce: \(loginModel.nonce)")
            } onCompletion: { (result) in
                switch result {
                case .success(let user):
                    PrintControl.shared.printLogin("Apple Sign-In success")
                    guard let credential = user.credential as? ASAuthorizationAppleIDCredential else {
                        PrintControl.shared.printLogin("Failed to get credential from Apple Sign-In")
                        return
                    }
                    PrintControl.shared.printLogin("Got Apple credential, starting Firebase authentication")
                    loginModel.appleAuthenticate(credential: credential)

                case .failure(let error):
                    PrintControl.shared.printLogin("Apple Sign-In failed: \(error.localizedDescription)")
                }
            }
            .signInWithAppleButtonStyle(.white)
            .frame(width: UIScreen.screenWidth * 0.4, height: 44)
            .padding(.horizontal, 15)
            .padding(.bottom, UIScreen.screenHeight * 0.1)

          
        }
    }
}


