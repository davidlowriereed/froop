//
//  LoginViewModel.swift
//  FroopProof
//
//  Created by David Reed on 1/18/23.
//

import SwiftUI
import UIKit
import Foundation
import FirebaseAuth
import Firebase
import CryptoKit
import AuthenticationServices
import GoogleSignInSwift
import GoogleSignIn


class LoginViewModel: ObservableObject {
    @ObservedObject var accountManager = AccountSetupManager.shared
    // MARK: View Properties
    @Published var mobileNo: String = ""
    @Published var otpCode: String = ""
    
    @Published var CLIENT_CODE: String = ""
    @Published var showOTPField: Bool = false
    
    // MARK: Error Properties
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    
    // MARK: App Log Status
    @AppStorage("log_status") var logStatus: Bool = false
    
    // MARK: Apple Sign in Properties
    @Published var nonce: String = ""
    
    // MARK: Firebase API's
    func getOTPCode(){
        PrintControl.shared.printLogin("-LoginViewModel: Function: getOTPCode firing")
        UIApplication.shared.closeKeyboard()
        PrintControl.shared.printLogin("Getting OTP Code")
        Task{
            do{
                // MARK: Disable it when testing with Real Device
                Auth.auth().settings?.isAppVerificationDisabledForTesting = true
                
                PrintControl.shared.printLogin("+1\(mobileNo)")
                let formattedMobileNo = self.mobileNo.replacingOccurrences(of: "[()\\- ]", with: "", options: .regularExpression)
                PrintControl.shared.printLogin("Before calling verifyPhoneNumber")
                let code = try await PhoneAuthProvider.provider().verifyPhoneNumber("+1\(formattedMobileNo)", uiDelegate: nil)
                PrintControl.shared.printLogin("After calling verifyPhoneNumber")
                await MainActor.run(body: {
                    CLIENT_CODE = code
                    // MARK: Enabling OTP Field When It's Success
                    withAnimation(.easeInOut){showOTPField = true}
                    PrintControl.shared.printLogin("OTP Code Success")
                })
            }catch{
                await handleError(error: error)
            }
        }
    }
    
    func verifyOTPCode(){
        PrintControl.shared.printLogin("-LoginView: Function: verifyOTPCode firing")
        UIApplication.shared.closeKeyboard()
        PrintControl.shared.printLogin("verifying OTP Code")
        Task{
            do{
                let credential = PhoneAuthProvider.provider().credential(withVerificationID: CLIENT_CODE, verificationCode: otpCode)
                
                try await Auth.auth().signIn(with: credential)
                
                // MARK: User Logged in Successfully
                PrintControl.shared.printLogin("Success!")
                await MainActor.run(body: {
                    withAnimation(.easeInOut){logStatus = true}
                })
            }catch{
                await handleError(error: error)
            }
        }
    }
    
    // MARK: Handling Error
    private func handleError(error: Error)async{
        PrintControl.shared.printLogin("-LoginView: Function: handleError firing")
        await MainActor.run(body: {
            errorMessage = error.localizedDescription
            PrintControl.shared.printErrorMessages("Error in handleError: \(errorMessage)")
            showError = true
        })
    }
    
    // MARK: Apple Sign in API
    func appleAuthenticate(credential: ASAuthorizationAppleIDCredential) {
        guard let token = credential.identityToken else {
            PrintControl.shared.printLogin("Unable to fetch identity token")
            return
        }
        
        guard let tokenString = String(data: token, encoding: .utf8) else {
            PrintControl.shared.printLogin("Unable to serialize token string from data: \(token.debugDescription)")
            return
        }
        
        let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: tokenString, rawNonce: nonce)
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                PrintControl.shared.printLogin("Firebase sign in failed: \(error.localizedDescription)")
                return
            }
            PrintControl.shared.printLogin("Firebase sign in succeeded")
            
            guard let uid = authResult?.user.uid else { return }
            self.checkUserDocumentExists(uid: uid) { exists in
                if exists {
                    DispatchQueue.main.async {
                        self.logStatus = true
                    }
                } else {
                    self.createUserDocument(uid: uid) { error in
                        if error == nil {
                            DispatchQueue.main.async {
                                self.logStatus = true
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func checkUserDocumentExists(uid: String, completion: @escaping (Bool) -> Void) {
        let userDocRef = Firestore.firestore().collection("users").document(uid)
        userDocRef.getDocument { (document, error) in
            if let document = document, document.exists {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    private func createUserDocument(uid: String, completion: @escaping (Error?) -> Void) {
        let userDocRef = Firestore.firestore().collection("users").document(uid)
        userDocRef.setData(["uid": uid, "created_at": FieldValue.serverTimestamp()]) { error in
            completion(error)
        }
    }
    
}


final class Application_utility {
    static var rootViewController: UIViewController {
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            fatalError("Unable to get UIWindowScene")
        }
        
        guard let root = screen.windows.first?.rootViewController else {
            fatalError("Unable to get rootViewController")
        }
        
        return root
    }
}

// MARK: Apple Sign in Helpers
func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashedData = SHA256.hash(data: inputData)
    let hashString = hashedData.compactMap {
        return String(format: "%02x", $0)
    }.joined()
    
    return hashString
}

func randomNonceString(length: Int = 32) -> String {
    precondition(length > 0)
    let charset: Array<Character> =
    Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    var result = ""
    var remainingLength = length
    
    while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
            var random: UInt8 = 0
            let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
            if errorCode != errSecSuccess {
                fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
            }
            return random
        }
        
        randoms.forEach { random in
            if remainingLength == 0 {
                return
            }
            
            if random < charset.count {
                result.append(charset[Int(random)])
                remainingLength -= 1
            }
        }
    }
    
 
    return result
}
