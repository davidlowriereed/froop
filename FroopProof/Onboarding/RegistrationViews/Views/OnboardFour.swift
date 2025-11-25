
import SwiftUI
import MapKit
import Firebase
import FirebaseStorage
import Kingfisher
import FirebaseAuth

enum ActiveAlert {
    case none, invalidPhoneNumber, verified
}

struct OnboardFour: View {
    @ObservedObject var myData = MyData.shared
    @ObservedObject var accountSetupManager = AccountSetupManager.shared
    @FocusState private var focusedField: ProfileNameFocus?
    @State var phoneNumber: String = ""
    @State var OTPCode: String = ""
    @State private var OTPSent: Bool = false
    @State private var isKeyboardShown: Bool = false
    @State private var keyboardHeight: CGFloat = 0
    @State private var isShowingOTPAlert = false
    @State private var formattedPhoneNumber: String = ""
    @State private var activeAlert: ActiveAlert = .none
    @State private var showAlert: Bool = false
    @State private var alertMessage = ""
    @State private var enteredOTP: String = ""
    @State private var OTPVerified: Bool = false
    var moveToNext: () -> Void
    var moveToPrevious: () -> Void
    
    var otpAlert: Alert {
        Alert(title: Text("Enter OTP"),
              message: Text("Please enter the received OTP code:"),
              primaryButton: .default(Text("Verify"), action: {
            verifyOTP(enteredOTP: enteredOTP)
        }),
              secondaryButton: .cancel()
        )
    }
    
    @AppStorage("ProfileCompletionCurrentPage") var ProfileCompletionCurrentPage = 4
    
    let imageW: Font.Weight = .thin
    let fontS = Font.system(size: 35)
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(
                    Color("FroopPink")
                )
                .onAppear {
//                    focusedField = .third
                }
           
            VStack {
                HStack {
                    Text("Verify mobile number for this device \(UserDefaults.standard.string(forKey: "authVerificationID") ?? "Test")")
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(Color(.white).opacity(1.0))
                        .padding(.top, 150)
                        .padding(.bottom, 10)
                        .padding(.leading, 25)
                    Spacer()
                }
                Spacer()
            }
            
            VStack (spacing: 30){
                
                ///PHONE TEXT FIELD
                VStack (){
                    
                    ZStack (alignment: .leading){
                        
                        RoundedRectangle(cornerRadius: 25, style: .continuous)
                            .stroke(Color.white, lineWidth: 0.5)
                            .fill(Color(.white).opacity(0.4))
                            .frame(width: UIScreen.screenWidth * 0.9, height: 50)
                            .padding(.leading, 40)
                            .padding(.trailing, 40)
                        
                        TextField("", text: $formattedPhoneNumber)
                            .focused($focusedField, equals: .third)
                            .keyboardType(.numberPad)
                            .font(.system(size: 36))
                            .foregroundColor(Color(.white).opacity(1.0))
                            .fontWeight(.bold)
                            .multilineTextAlignment(.leading)
                            .padding(.leading, 55)
                            .padding(.trailing, 55)
                            .background(.clear)
                            .onChange(of: formattedPhoneNumber) { oldValue, newValue in
                                formattedPhoneNumber = newValue.formattedPhoneNumber
                                myData.phoneNumber = removePhoneNumberFormatting(newValue)
                            }
                        
                        Text(formattedPhoneNumber != "" ? "" : "(123) 456-7890")
                            .font(.system(size: 36))
                            .foregroundColor(Color(.white).opacity(0.6))
                            .opacity(0.5)
                            .fontWeight(.bold)
                            .padding(.leading, 55)
                            .padding(.trailing, 55)
                            .background(.clear)
                        
                    }
                    
                    HStack {
                        Spacer()
                        if !myData.OTPVerified && isValidPhoneNumber(formattedPhoneNumber) {
                            Button {
                                print("getting code")
                                focusedField = nil
                                sendOTP(phoneNumber: formattedPhoneNumber)
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.white, lineWidth: 1.0)
                                        .frame(width: 100, height: 35)
                                    Text(OTPSent ? "Resend" : "Get Code")
                                        .font(.system(size: 18))
                                        .fontWeight(.regular)
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    }
                    .padding(.top, 20)
                    .padding(.trailing, 50)
                    .frame(width: UIScreen.screenWidth)
                }
                
                if OTPSent || (formattedPhoneNumber == "(123) 456-7890" && !OTPVerified) {
                    VStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 25, style: .continuous)
                                .stroke(Color.white, lineWidth: 0.5)
                                .fill(Color(.white).opacity(0.4))
                                .frame(width: UIScreen.screenWidth * 0.9, height: 50)
                                .padding(.horizontal, 40)
                            
                            TextField(
                                OTPVerified ? "Verified" : "Enter OTP Code",
                                text: $OTPCode
                            )
                            .focused($focusedField, equals: .fourth)
                            .keyboardType(.numberPad)
                            .font(.system(size: OTPVerified ? 24 : 36))
                            .fontWeight(.bold)
                            .foregroundColor(Color(.white).opacity(1.0))
                            .padding(.horizontal, 55)
                            .background(.clear)
                            .disabled(OTPVerified)
                        }
                    }
                }
                
                if OTPSent || formattedPhoneNumber == "(123) 456-7890" || OTPVerified {
                    HStack {
                        Spacer()
                        Button {
                            if OTPVerified {
                                moveToNext()
                            } else {
                                verifyOTP(enteredOTP: OTPCode)
                            }
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.white, lineWidth: 2)
                                    .frame(width: UIScreen.screenWidth * 0.9, height: 50)
                                    .padding(.horizontal, 40)
                                
                                Text(OTPVerified ? "Next" : "Verify")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                                    .fontWeight(.bold)
                            }
                        }
                        Spacer()
                    }
                }
                
                Spacer()
            }
            .frame(width: UIScreen.main.bounds.width - 100)
            .padding(.top, UIScreen.screenHeight * 0.25)


            ///BUTTONS
            
            VStack {
                Button {
                    moveToPrevious()
                    print("Back Button Tapped")
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
        }
        .onAppear {
            if myData.OTPVerified {
//                moveToNext()
            } else {
//                focusedField = .third
            }
            fetchAndDisplayExistingPhoneNumber()
            formattedPhoneNumber = formatPhoneNumber(myData.phoneNumber)
        }
        .alert(isPresented: $showAlert) {
            switch activeAlert {
                case .invalidPhoneNumber:
                    return Alert(
                        title: Text("Phone Number is invalid"),
                        message: Text("Please enter a valid phone number."),
                        dismissButton: .default(Text("OK"))
                    )
                case .verified:
                    return Alert(
                        title: Text("Verified"),
                        message: Text("Your Phone Number has been Verified, and has been linked to your account. You can proceed with setting up your profile."),
                        dismissButton: .default(Text("OK"))
                    )
                default:
                    return Alert(title: Text("Unexpected Alert"))
            }
        }
        .ignoresSafeArea()
    }
    
    func sendOTP(phoneNumber: String) {
        print("sendOTP Function Firing")
        // Remove non-numeric characters
        let cleanedPhoneNumber = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        let testNumbers = ["3105551111", "3105552222", "3105555555", "3105556666", "3105553333", "3105554444", "3105557777", "3105558888", "1234567890", "3106660000"]

        if testNumbers.contains(cleanedPhoneNumber) {
            print("Using test number")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // Add a small delay
                self.OTPSent = true
                UserDefaults.standard.set("TEST_VERIFICATION_ID", forKey: "authVerificationID")
                self.focusedField = .fourth
            }
            return
        }
        
        // Check if it's the test number
        if cleanedPhoneNumber == "1234567890" {
            print("Using test number")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // Add a small delay
                self.OTPSent = true
                UserDefaults.standard.set("TEST_VERIFICATION_ID", forKey: "authVerificationID")
                self.focusedField = .fourth
            }
            return
        }
        
        // Prepend the country code to get it in E.164 format. Assume 1 as the country code for the USA.
        let e164FormattedNumber = "+1" + cleanedPhoneNumber
        print(e164FormattedNumber)
        
        PhoneAuthProvider.provider().verifyPhoneNumber(e164FormattedNumber, uiDelegate: nil) { (verificationID, error) in
            if let error = error {
                print("Error during OTP verification: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.alertMessage = error.localizedDescription
                    self.activeAlert = .invalidPhoneNumber
                    self.showAlert = true
                }
                return
            }
            // Log success or further details
            print("Verification ID received: \(verificationID ?? "No ID")")
            UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
            DispatchQueue.main.async {
                self.OTPSent = true
                self.isShowingOTPAlert = true
                self.focusedField = .fourth
            }
        }
    }
    
    func verifyOTP(enteredOTP: String) {
        guard let verificationID = UserDefaults.standard.string(forKey: "authVerificationID") else { return }

        // Check if it's the test verification
        if verificationID == "TEST_VERIFICATION_ID" {
            if enteredOTP == "000000" { // Use the correct test OTP
                OTPVerified = true
                myData.OTPVerified = true
                OTPCode = "Verification Confirmed."
            } else {
                // Handle incorrect test OTP
                print("Incorrect test OTP")
            }
            return
        }
        
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: enteredOTP)
        
        if let currentUser = Auth.auth().currentUser {
            currentUser.link(with: credential) { (authResult, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                OTPVerified = true
                myData.OTPVerified = true
                OTPCode = "Verification Confirmed."
            }
        }
    }
    
    func removePhoneNumberFormatting(_ phoneNumber: String) -> String {
        let cleanedPhoneNumber = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        return cleanedPhoneNumber
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
    
    func isValidPhoneNumber(_ phoneNumber: String) -> Bool {
        PrintControl.shared.printLogin("-Login: Function: isValidPhoneNumber firing")
        
        // Strip out non-numeric characters
        let numericOnlyString = phoneNumber.filter { $0.isNumber }

        // Check if it's a test number
        let testNumbers = ["3105551111", "3105552222", "3105555555", "3105556666", "3105553333", "3105554444", "3105557777", "3105558888", "1234567890", "3106660000"]
        
        if testNumbers.contains(numericOnlyString) {
            return true
        }
        
        // Ensure there are exactly 10 digits
        guard numericOnlyString.count == 10 else {
            return false
        }
        
        // Now, verify if the input format matches any of the desired formats
        let phoneNumberPatterns = [
            "^\\(\\d{3}\\) \\d{3}-\\d{4}$",  // (123) 999-9999
            "^\\d{10}$",                    // 1239999999
            "^\\d{3}\\.\\d{3}\\.\\d{4}$",  // 123.999.9999
            "^\\d{3} \\d{3} \\d{4}$"       // 123 999 9999
        ]
        
        return phoneNumberPatterns.contains { pattern in
            let predicate = NSPredicate(format: "SELF MATCHES %@", pattern)
            return predicate.evaluate(with: phoneNumber)
        }
    }
    
    func fetchAndDisplayExistingPhoneNumber() {
        if let existingPhoneNumber = Auth.auth().currentUser?.phoneNumber, !existingPhoneNumber.isEmpty {
            // Remove the country code
            let phoneNumberWithoutCountryCode = existingPhoneNumber.hasPrefix("+1") ? String(existingPhoneNumber.dropFirst(2)) : existingPhoneNumber
            
            // Update state properties
            myData.phoneNumber = phoneNumberWithoutCountryCode
            formattedPhoneNumber = formatPhoneNumber(phoneNumberWithoutCountryCode)
            
            // Update the OTP verification flag
            OTPVerified = true
            myData.OTPVerified = true
        }
    }
    
    private func hideKeyboard() {
        PrintControl.shared.printLogin("-CustomTextFieldOTP: Function: hideKeyboard firing")
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
}

