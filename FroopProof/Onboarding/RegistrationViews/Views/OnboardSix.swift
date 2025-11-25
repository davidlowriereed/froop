//
//  OnboardFour.swift
//  FroopProof
//
//  Created by David Reed on 9/21/23.
//



import SwiftUI
import MapKit
import Firebase
import FirebaseStorage
import Kingfisher
import FirebaseAuth

struct OnboardSix: View {
    @ObservedObject var myData = MyData.shared
    @ObservedObject var photoData = PhotoData()
//    @ObservedObject var myData = MyData.shared
    @ObservedObject var accountSetupManager = AccountSetupManager.shared
    @State var address: String = ""
    @State var city: String = ""
    @State var state: String = ""
    @State var zipcode: String = ""
    @State private var isKeyboardShown: Bool = false
    @State private var keyboardHeight: CGFloat = 0
    @State private var isSaving = false
    @State var showProfileImagePicker = false
    @State private var showAlert = false
    @State private var avatarImage = UIImage()
    @State private var isProfileImageSelected = false
    @State private var headImage = UIImage(named: "profileImage")!
    @State private var alertMessage = ""
    @State var blankImage = UIImage()
    var moveToPrevious: () -> Void
    @Binding var ProfileCompletionCurrentPage: Int
    @State var profileImageUrl = ""

    let uid = Auth.auth().currentUser?.uid ?? ""
    let imageW: Font.Weight = .thin
    let fontS = Font.system(size: 35)
    
    
    var tempFilePath: String {
        return (DataController.shared.tempDirectory as NSString).appendingPathComponent("tempImage.jpg")
    }
    
    func writeImageToTempDirectory() {
        guard let imageData = avatarImage.jpegData(compressionQuality: 1.0) else {
            print("🚫Error converting image to jpeg data")
            return
        }
        do {
            try imageData.write(to: URL(fileURLWithPath: tempFilePath))
        } catch {
            print("🚫Error saving image to temp path: \(error)")
        }
    }
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color("FroopPink"))
                .ignoresSafeArea()
        
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
            
            
            
            VStack (alignment: .leading){
                
                Text("Select a Profile Image")
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .foregroundColor(Color(.white).opacity(1.0))
                    .padding(.top, 150)
//                Text("Select a Profile Image")
//                    .font(.system(size: 20))
//                    .fontWeight(.bold)
//                    .foregroundColor(Color(.white).opacity(1.0))
//                    .padding(.bottom, 10)
//                    .padding(.top, 350)
                
                Text("This is the image ").froopTextStyle(opacity: 0.85)
                    .padding(.top, 300)

                Text("your friends and ").froopTextStyle(opacity: 0.85)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                Text("family will see.").froopTextStyle(opacity: 0.85)
    
                
                Spacer()
            }

            
            VStack {
                
               
                
                VStack {
                    Button {
                        showProfileImagePicker = true
                        myData.profileImageUrl = ""
                    } label: {
                        HStack {
                            ZStack {
                                
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                                    .frame(width: 155, height: 155)
                                    .foregroundColor(.clear)
                                    .opacity(0.6)
                                
                                Circle()
                                    .frame(width: 151, height: 151)
                                    .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                    .opacity(0.6)
                                
                                KFImage(URL(string: myData.profileImageUrl))
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 150, height: 150)
                                    .clipShape(Circle())
                                    .onTapGesture {
                                        showProfileImagePicker = true
                                    }
                                
                                if isProfileImageSelected {
                                    
                                    Image(uiImage: avatarImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 150, height: 150)
                                        .clipShape(Circle())
                                       

                                } else {
                                    
                                    Image(uiImage: myData.profileImageUrl == "" ? headImage : blankImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 150, height: 150)
                                }
                            }
                        }
                    }
                    Text("Tap to Change")
                        .font(.system(size: 20))
                        .fontWeight(.light)
                        .foregroundColor(.white)
//                        .opacity(0.5)
                }
                Spacer()
            }
            .frame(width: UIScreen.main.bounds.width - 100)
            .padding(.top, 250)
            
            VStack {
                Spacer()
                
                Button {
                    if avatarImage.size.width != 0 {
                        uploadImageToFirebaseForeground { url in
                            MyData.shared.profileImageUrl = url
                            saveUserDataToFirestore()
                            saveProfileAndPerformFirebaseOperations()
                            MyData.shared.setupListener()
                        }
                    } else if myData.profileImageUrl.isEmpty {
                        uploadImageToFirebaseForeground { url in
                            MyData.shared.profileImageUrl = "https://firebasestorage.googleapis.com/v0/b/froop-proof.appspot.com/o/ProfilePic%2Fprofile.png?alt=media&token=c8b47715-371c-4b87-9b02-7b144fd7747d"
                            saveUserDataToFirestore()
                            saveProfileAndPerformFirebaseOperations()
                            MyData.shared.setupListener()
                        }
                        //                            showAlert = true
                        //                            alertMessage = "Please select a profile image."
                    } else {
                        // If there's no new image but a profile image URL already exists, just save user data.
                        saveUserDataToFirestore()
                        saveProfileAndPerformFirebaseOperations()
                        MyData.shared.setupListener()
                    }
                } label: {
                    
                    ZStack {
                        
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color.white, lineWidth: !myData.profileImageUrl.isEmpty ? 2 : 0)
                            .frame(height: 50)
                            .padding(.horizontal, 25)
                        
                        Text(myData.profileImageUrl.isEmpty || isProfileImageSelected ? "Skip" : "Finish")
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(.bottom, 100)
        }
     
        .sheet(isPresented: $showProfileImagePicker, onDismiss: {
            isProfileImageSelected = true
        }, content: {
            PhotoPicker_alt(avatarImage: $avatarImage)
        })

        .ignoresSafeArea()
    }
    
    func SaveProfile() {
        isSaving = true
        PrintControl.shared.printProfile("-ProfileCompletionView4: Function: saveProfile firing")
        if MyData.shared.firstName.isEmpty ||
            MyData.shared.lastName.isEmpty ||
            MyData.shared.phoneNumber.isEmpty ||
            !isProfileImageSelected {
            // Check what fields are missing
            var missingFields: [String] = []
            
            if !isProfileImageSelected {
                   missingFields.append("Required - Profile Picture")
               }
            if MyData.shared.firstName.isEmpty {
                missingFields.append("Required - First Name")
            }
            if MyData.shared.lastName.isEmpty {
                missingFields.append("Required - Last Name")
            }
            if MyData.shared.phoneNumber.isEmpty {
                missingFields.append("Required - Phone Number")
            }
            if avatarImage.size == headImage.size && MyData.shared.profileImageUrl.isEmpty {
                missingFields.append("Required - Profile Picture")
            }
            // Show appropriate alert message
            if missingFields.count == 1 {
                alertMessage = "Please add your \(missingFields[0]) for this device."
            } else {
                let lastField = missingFields.removeLast()
                let fields = missingFields.joined(separator: ", ") + " and " + lastField
                alertMessage = "Please add a \(fields) and your Mobile Number associated with this device."
            }
            showAlert = true
        } else {
            // Validate phone number
            if !isValidPhoneNumber(MyData.shared.phoneNumber) {
                alertMessage = "Please enter a valid phone number."
                showAlert = true
                return
            }
            // Set the froopUserID to the current user's UID
            MyData.shared.froopUserID = FirebaseServices.shared.uid
            
            // Assign the user's correct TimeZone identifier to the timeZone property
            if let location = LocationManager.shared.userLocation {
                let geoCoder = CLGeocoder()
                geoCoder.reverseGeocodeLocation(location) { placemarks, error in
                    if let error = error {
                        PrintControl.shared.printProfile("Error getting location address: \(error.localizedDescription)")
                    } else if let placemarks = placemarks, let placemark = placemarks.first {
                        MyData.shared.timeZone = placemark.timeZone?.identifier ?? TimeZone.current.identifier
                        MyData.shared.geoPoint = GeoPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude) // Set the geoPoint property
                    } else {
                        MyData.shared.timeZone = TimeZone.current.identifier
                        MyData.shared.geoPoint = GeoPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude) // Set the geoPoint property
                    }
                }
            } else {
                MyData.shared.timeZone = TimeZone.current.identifier
            }
            if MyData.shared.profileImageUrl != "" {
                PrintControl.shared.printProfile("Profile Image Already Exists!")
                saveUserDataToFirestore()
            } else {
                uploadImageToFirebase { url in
                    // Update userData with profileImageUrl
                    MyData.shared.profileImageUrl = url
                    saveUserDataToFirestore()
                }
            }
        }
        
        isSaving = false
        ProfileCompletionCurrentPage = 2

    }
    
    private func saveUserDataToFirestore() {
        
        let userRef = db.collection("users").document(uid)
        let userDocumentData: [String: Any] = [
            "froopUserID": uid,
            "firstName": MyData.shared.firstName,
            "lastName": MyData.shared.lastName,
            "phoneNumber": removePhoneNumberFormatting(MyData.shared.phoneNumber),
            "addressNumber": MyData.shared.addressNumber,
            "addressStreet": MyData.shared.addressStreet,
            "unitName": MyData.shared.unitName,
            "addressCity": MyData.shared.addressCity,
            "addressState": MyData.shared.addressState,
            "addressZip": MyData.shared.addressZip,
            "addressCountry": MyData.shared.addressCountry,
            "profileImageUrl": MyData.shared.profileImageUrl,
            "timeZone": MyData.shared.timeZone,
            "coordinate": MyData.shared.geoPoint,
            "premiumAccount": MyData.shared.premiumAccount,
            "professionalAccount": MyData.shared.professionalAccount,
            "professionalTemplates": MyData.shared.professionalTemplates,
            "OTPVerified": MyData.shared.OTPVerified
        ]
        userRef.setData(userDocumentData) { error in
            if let error = error {
                PrintControl.shared.printProfile("Error creating user document: \(error)")
            } else {
                PrintControl.shared.printProfile("User document created")
                
                // Set up required collections and documents
                _ = userRef.collection("myFroops")
                let froopDecisionsRef = userRef.collection("froopDecisions")
                let friendsRef = userRef.collection("friends")
                
                let froopListsRef = froopDecisionsRef.document("froopLists")
                froopListsRef.setData(["placeholder": []], merge: true)
                
                let myArchivedListRef = froopListsRef.collection("myArchivedList").document("placeholder")
                myArchivedListRef.setData(["placeholder": []], merge: true)
                
                let myConfirmedListRef = froopListsRef.collection("myConfirmedList").document("placeholder")
                myConfirmedListRef.setData(["placeholder": []], merge: true)
                
                let myDeclinedListRef = froopListsRef.collection("myDeclinedList").document("placeholder")
                myDeclinedListRef.setData(["placeholder": []], merge: true)
                
                let myInvitesListRef = froopListsRef.collection("myInvitesList").document("placeholder")
                myInvitesListRef.setData(["placeholder": []], merge: true)
                
                let friendListRef = friendsRef.document("friendList")
                friendListRef.updateData([
                    "friendUIDs": FieldValue.arrayUnion([]),
                ])
                
                // Present the next view in the series
                ProfileCompletionCurrentPage = 2
            }
        }
    }
    
    func saveProfileAndPerformFirebaseOperations() {
        guard let currentUserUID = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()
        let usersCollection = db.collection("users")
        let froopUserRef = usersCollection.document("froop")
        let currentUserRef = usersCollection.document(currentUserUID)
        
        // Step 2: Add current user's UID to /users/froop/myFroops/froopOnboarding/invitedFriends/confirmedList.uid
        let froopOnboardingConfirmedListRef = froopUserRef.collection("myFroops").document("froopOnboarding").collection("invitedFriends").document("confirmedList")
        froopOnboardingConfirmedListRef.updateData([
            "uid": FieldValue.arrayUnion([currentUserUID])
        ])
        
        // Step 3: Check if a document exists at /users/'currentUser.uid'/froopDecisions/froopLists/myArchivedList/froopOnboarding
        let myArchivedListRef = currentUserRef.collection("froopDecisions").document("froopLists").collection("myArchivedList").document("froopOnboarding")
        myArchivedListRef.getDocument { document, error in
            if let document = document, document.exists {
                // Document exists, update it if necessary
                // If there's specific data to update, it can be done here.
                // Otherwise, no action is needed since we're just ensuring its existence.
            } else {
                // Document does not exist, create it
                myArchivedListRef.setData([
                    "documentID": "froopOnboarding",
                    "froopHost": "froop",
                    "froopId": "froopOnboarding"
                ])
            }
        }
    }



    
    func removePhoneNumberFormatting(_ phoneNumber: String) -> String {
        let cleanedPhoneNumber = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        return cleanedPhoneNumber
    }
    
    private func checkForExistingFroops(completion: @escaping (Bool) -> Void) {
        PrintControl.shared.printProfile("-ProfileCompletionView4: Function: checkForExistingFroops firing")
        let uid = FirebaseServices.shared.uid
        db.collection("froops").whereField("uid", isEqualTo: uid).getDocuments { (snapshot, error) in
            if let error = error {
                PrintControl.shared.printErrorMessages("Error checking for existing Froops: \(error)")
                completion(false)
                return
            }
            let hasExistingFroops = !snapshot!.documents.isEmpty
            completion(hasExistingFroops)
        }
    }
    
    func uploadImageToFirebaseForeground(completion: @escaping (String) -> Void) {
        let ref = Storage.storage().reference(withPath: "ProfilePic/\(uid).jpg")
        guard let imageData = self.avatarImage.jpegData(compressionQuality: 1.0) else { return }

        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"

        let uploadTask = ref.putData(imageData, metadata: metaData) { metadata, error in
            if let error = error {
                print("🚫Error uploading image: \(error)")
                return
            }
            
            ref.downloadURL { url, error in
                if let url = url {
                    completion(url.absoluteString)
                } else {
                    print("🚫Error fetching URL: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }
    
    func uploadImageToFirebase(completion: @escaping (String) -> Void) {
        PrintControl.shared.printErrorMessages("-ProfileCompletionView4: Function: uploadImageToFirebase firing")
//        print(uid)
        
        // Fetch user data from Firestore
        Firestore.firestore().collection("users").document(uid).getDocument { (document, error) in
//            print("1")
            if let document = document, document.exists {
//                print("2a")
                // If the profileImageUrl already exists, use it
                if let profileImageUrl = document.data()?["profileImageUrl"] as? String {
//                    print("3a")
                    completion(profileImageUrl)
                } else {
//                    print("3b")
                    // If the profileImageUrl does not exist, create a new one
                    let ref = Storage.storage().reference(withPath: "ProfilePic/\(uid).jpg")
                    print(ref)
                    guard let imageData = self.avatarImage.jpegData(compressionQuality: 1.0) else { return }
                    let metaData = StorageMetadata()
                    metaData.contentType = "image/jpeg"
                    
                    // Save the image to a temporary location
                    let tempDir = FileManager.default.temporaryDirectory
                    let tempFilePath = tempDir.appendingPathComponent(UUID().uuidString + ".jpg")
                    do {
                        try imageData.write(to: tempFilePath)
                        
                        // Upload the file to Firebase Storage
                        ref.putFile(from: tempFilePath, metadata: metaData) { metadata, err in
                            // Delete the temporary file
                            try? FileManager.default.removeItem(at: tempFilePath)
                            
                            if let err = err {
                                PrintControl.shared.printErrorMessages("Failed to push image to Storage \(err)")
                                return
                            }
                            
                            ref.downloadURL { url, err in
                                if let err = err {
                                    PrintControl.shared.printErrorMessages("Failed to retrieve downloadURL: \(err)")
                                    return
                                }
                                let urlStr = url?.absoluteString ?? ""
                                PrintControl.shared.printProfile("Successfully stored image with url:  \(urlStr)")
                                PrintControl.shared.printProfile("*******\(urlStr)")
                                // ... [rest of your code]
                            }
                        }
                    } catch {
                        PrintControl.shared.printErrorMessages("Failed to write image data to temporary directory: \(error)")
                    }
                }
            } else {
//                print("2b")
                PrintControl.shared.printErrorMessages("Failed to fetch user data from Firestore: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
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
}
