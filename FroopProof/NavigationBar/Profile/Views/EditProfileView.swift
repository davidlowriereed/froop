//
//  EditProfileView.swift
//  FroopProof
//
//  Created by David Reed on 1/19/23.
//

import Combine
import SwiftUI
import Foundation
import MapKit
import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import CoreLocation
import Kingfisher
import PhotosUI
import GTMSessionFetcherCore


struct EditProfileView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var myData = MyData.shared
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var userSettings = UserSettings.shared
    @ObservedObject var locationManager = LocationManager.shared
    @ObservedObject var viewModel = DetailsGuestViewModel.shared
    var db = FirebaseServices.shared.db
    var uid = FirebaseServices.shared.uid
    //@ObservedObject var myData = MyData.shared
    @ObservedObject var photoData: PhotoData
    @Binding var showEditView: Bool
    @Binding var showAlert: Bool
    @Binding var alertMessage: String
    
    @State private var isSaving = false
    @State private var showSheet = true
    @State var showProfileImagePicker = false
    @State private var headImage = UIImage(named: "profileImage")!
    
    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    @State private var avatarImage: UIImage? = nil
    
    @State var selectedImage: UIImage?
    @State var urlHolder: String = ""
    @State var existingImageUrl: String = MyData.shared.profileImageUrl
    @State var firstName: String = MyData.shared.firstName
    @State var lastName: String = MyData.shared.lastName
    @State var phoneNumber: String = MyData.shared.phoneNumber
    @State var addressNumber: String = MyData.shared.addressNumber
    @State var addressStreet: String = MyData.shared.addressStreet
    @State var unitName: String = MyData.shared.unitName
    @State var addressCity: String = MyData.shared.addressCity
    @State var addressState: String = MyData.shared.addressState
    @State var addressZip: String = MyData.shared.addressZip
    @State var addressCountry: String = MyData.shared.addressCountry
    @State var currentUploadTask: StorageUploadTask?
    @State var formattedPhoneNumber: String = ""
    @State var blankImage: UIImage = UIImage()

    
    @State var isUploading = false
    
    
    init(photoData: PhotoData, showEditView: Binding<Bool>, showAlert: Binding<Bool>, alertMessage: Binding<String>, urlHolder: String, firstName: String, lastName: String, phoneNumber: String, addressNumber: String, addressStreet: String, unitName: String, addressCity: String, addressState: String, addressZip: String, addressCountry: String, formattedPhoneNumber: String) {
        self.photoData = photoData
        self._showEditView = showEditView
        self._showAlert = showAlert
        self._alertMessage = alertMessage
        self._firstName = State(initialValue: MyData.shared.firstName)
        self._lastName = State(initialValue: MyData.shared.lastName)
        self._phoneNumber = State(initialValue: MyData.shared.phoneNumber)
        self._formattedPhoneNumber = State(initialValue: formatPhoneNumber(MyData.shared.phoneNumber))
        
    }
    
    
    var body: some View {
        NavigationView {
            ZStack (alignment: .top){
                Rectangle()
                    .frame(minWidth: 0,maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    .foregroundColor(.gray)
                    .opacity(0.2)
                    .ignoresSafeArea()
                VStack {
                    ZStack(alignment: .top) {
                        Rectangle()
                            .frame(minWidth: 0,maxWidth: .infinity, minHeight: 175, maxHeight: 175, alignment: .top)
                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                            .opacity(0.5)
                            .ignoresSafeArea()
                            .offset(y: -50)
                        HStack{
                            HStack (alignment: .center){
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 14))
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                    .padding(.trailing, 5)
                                Text("BACK")
                                    .font(.system(size: 14))
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding(.leading, 10)
                            .onTapGesture {
                                showEditView = false
                            }
                            Spacer()
                            
                            
                            Button {
                                if let avatarImage = avatarImage, avatarImage.size.width != 0 {
                                    uploadImageToFirebaseForeground(image: avatarImage) { result in
                                        switch result {
                                            case .success():
                                                getImageUrl(from: Storage.storage().reference(withPath: "ProfilePic/\(uid).jpg")) { result in
                                                    switch result {
                                                        case .success(let url):
                                                            print("Image URL: \(url)")
                                                            MyData.shared.profileImageUrl = url
                                                            print("MyData URL:  \(MyData.shared.profileImageUrl)")
                                                        case .failure(let error):
                                                            print("🚫Error fetching image URL: \(error)")
                                                            // Handle the error, e.g., show an alert
                                                    }
                                                    saveUserDataToFirestore()
                                                }
                                            case .failure(let error):
                                                print("🚫Error during image upload: \(error)")
                                                // Handle the error, maybe show an alert to the user
                                        }
                                    }
                                } else if existingImageUrl.isEmpty {
                                    // Force the user to select an image
                                    showAlert = true
                                    alertMessage = "Please select a profile image."
                                } else {
                                    saveUserDataToFirestore()
                                }
                            } label: {
                                Text("Save")
                                    .foregroundColor(colorScheme == .dark ? .white : .white)
                                    .fontWeight(.medium)
                                Image(systemName: "square.and.arrow.up.fill")
                                .foregroundColor(colorScheme == .dark ? .white : .white)                            }
                            .padding(.trailing, 10)
                        }
                        .offset(y: 0)
                        HStack{
                            Spacer()
                            Button {
                                showProfileImagePicker = true
                                
                            } label: {
                                VStack{
                                    ZStack{
                                        
                                        if MyData.shared.profileImageUrl != "" {
                                            KFImage(URL(string: MyData.shared.profileImageUrl))
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 126, height: 126)
                                                .clipShape(Circle())
                                                .padding()
                                                .onTapGesture {
                                                    showProfileImagePicker = true
                                                    existingImageUrl = ""
                                                }
                                        } else {
                                            Image(uiImage: headImage)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 126, height: 126)
                                                .clipShape(Circle())
                                                .padding()
                                                .onTapGesture {
                                                    showProfileImagePicker = true
                                                    existingImageUrl = ""
                                                }
                                        }
                                        
                                        ZStack {
                                           
                                            Image(uiImage: avatarImage ?? blankImage)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 126, height: 126)
                                                .clipShape(Circle())
                                                .padding()
                                        }
                                    }
                                    
                                    Text("Tap to Edit Profile Picture")
                                        .font(.system(size: 14, weight: .light))
                                        .foregroundColor(.gray)
                                        .offset(y: -10)
                                    Text("or")
                                        .font(.system(size: 14, weight: .light))
                                        .foregroundColor(.gray)
                                        .offset(y: -10)
                                    Text("Change Any Details Below")
                                        .font(.system(size: 14, weight: .light))
                                        .foregroundColor(.gray)
                                        .offset(y: -10)
//                                    onTapGesture {
//                                        saveChanges()
//                                    }
                                }
                                
                                
                                
                                
                                .fullScreenCover(isPresented: $showProfileImagePicker) {
                                    PhotosPicker(
                                        selection: $selectedPhotoItems,
                                        maxSelectionCount: 1,
                                        selectionBehavior: .continuousAndOrdered,
                                        matching: .images,
                                        preferredItemEncoding: .current,
                                        photoLibrary: .shared()
                                    ) {
                                        Text("")
                                    }
                                    .photosPickerStyle(.inline) // Set the picker style to inline
                                                                //                                    .photosPickerDisabledCapabilities(.selectionActions)
                                    
                                    // Hide padding around all edges in the picker UI.
                                    .photosPickerAccessoryVisibility(.visible, edges: .all)
                                    .frame(height: UIScreen.screenHeight * 1) // Set the desired height for the inline picker
                                    .onChange(of: selectedPhotoItems) { oldItem, newItem in
                                        handlePhotoPickerSelection()
                                        withAnimation(.easeInOut(duration: 0.4)) {
                                            showProfileImagePicker = false
                                        }
                                    }
                                    
                                }
                                .padding(.top, -40)
                                
                            }
                            Spacer()
                        }
                        .padding(.top, 50)
                    }
                    
                    Form {
                        Section(header: Text("Name")) {
                            TextField("First Name", text: $myData.firstName)
                            TextField("Last Name", text:  $myData.lastName)
                        }
                    }
                    .scrollContentBackground(.hidden)
                    
                }
                if isSaving {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 255/255, green: 49/255, blue: 97/255)))
                        .scaleEffect(2)
                }
                
            }
        }
        .disabled(isSaving)
    }
    
  
    
    private func handlePhotoPickerSelection() {
        guard let selectedPhotoItem = selectedPhotoItems.first else { return }
        
        selectedPhotoItem.loadTransferable(type: Data.self) { result in
            switch result {
                case .success(let data?):
                    if let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self.avatarImage = image
                        }
                    }
                case .failure(let error):
                    print("🚫Error loading image: \(error)")
                default:
                    break
            }
        }
    }
    
    
    private func saveUserDataToFirestore() {
        print("saving user data")
        isSaving = true
        print("isSaving set to: \(isSaving)")
        let uid = Auth.auth().currentUser?.uid ?? ""
        print("uid: \(uid)")
        let currentPhotoUID = photoData.id
        print("currentPhotoUID: \(photoData.id)")
        let docRef = db.collection("users").document(uid)
        print("urlHolder: \(urlHolder)")
        let docRef2 = db.collection("photos").document("profiles").collection("profilePhotos").document(currentPhotoUID)
//        MyData.shared.profileImageUrl = urlHolder.absoluteString
        docRef.updateData([
            "firstName": MyData.shared.firstName,
            "lastName":  MyData.shared.lastName,
            "phoneNumber":  MyData.shared.phoneNumber,
            "profileImageUrl":  MyData.shared.profileImageUrl,
            "coordinate": MyData.shared.geoPoint
        ])
        
        docRef2.setData([
            "id": self.photoData.id,
            "uid": self.photoData.uid,
            "froopUUID": self.photoData.froopId,
            "url": MyData.shared.profileImageUrl,
            "photoCoord": self.photoData.photoCoord,
            "dateCreated": self.photoData.dateCreated,
            "title": self.photoData.title,
        ])
        
        if LocationManager.shared.locationUpdateTimerOn == true {
            TimerServices.shared.shouldCallupdateUserLocationInFirestore = true
        }
        if AppStateManager.shared.stateTransitionTimerOn == true {
            TimerServices.shared.shouldCallAppStateTransition = true
        }
        fetchUserData()
        isSaving = false
        showEditView = false
    }
    
    func uploadImageToFirebaseForeground(image: UIImage, completion: @escaping (Result<Void, Error>) -> Void) {
        let uid = FirebaseServices.shared.uid
        let ref = Storage.storage().reference(withPath: "ProfilePic/\(uid).jpg")
        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
            completion(.failure(UploadError.imageConversionFailed))
            return
        }
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        // Cancel any existing upload task
        if let currentTask = currentUploadTask {
            print("Cancelling existing upload task")
            currentTask.cancel()
        }
        
        // Start a new upload task
        print("Starting new upload task")
        currentUploadTask = ref.putData(imageData, metadata: metaData) { metadata, error in
            self.currentUploadTask = nil  // Clear the current task reference
            
            if let error = error {
                print("🚫Error uploading image: \(error)")
                completion(.failure(error))
            } else {
                print("Success Uploading Image")
                completion(.success(())) // Indicate success without a specific return value
            }
        }
    }
    
    
    func getImageUrl(from reference: StorageReference, completion: @escaping (Result<String, Error>) -> Void) {
        reference.downloadURL { url, error in
            if let url = url {
                completion(.success(url.absoluteString))
                print("getUmageURL is a success")
            } else if let error = error {
                print("🚫Error fetching URL: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                completion(.failure(UploadError.urlFetchFailed))
            }
        }
    }
    
    func uploadImageToFirebase(completion: @escaping (String) -> Void) {
        print("isUploading before setting to true:  \(isUploading)")
        guard !isUploading else { return }
        isUploading = true
        print("isUploading after setting to true:  \(isUploading)")
        PrintControl.shared.printErrorMessages("-ProfileCompletionView4: Function: uploadImageToFirebase firing")
        let uid = FirebaseServices.shared.uid
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
                    guard let imageData = self.avatarImage?.jpegData(compressionQuality: 1.0) else { return }
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
                                self.isUploading = false
                                return
                            }
                            
                            ref.downloadURL { url, err in
                                if let err = err {
                                    PrintControl.shared.printErrorMessages("Failed to retrieve downloadURL: \(err)")
                                    self.isUploading = false
                                    return
                                }
                                let urlStr = url?.absoluteString ?? ""
                                PrintControl.shared.printProfile("Successfully stored image with url:  \(urlStr)")
                                PrintControl.shared.printProfile("*******\(urlStr)")
                                completion(urlStr)
                                self.isUploading = false
                            }
                        }
                    } catch {
                        PrintControl.shared.printErrorMessages("Failed to write image data to temporary directory: \(error)")
                        self.isUploading = false
                    }
                }
            } else {
                //                print("2b")
                PrintControl.shared.printErrorMessages("Failed to fetch user data from Firestore: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    func fetchUserData() {
        // Get the current user's UID
        guard let userID = Auth.auth().currentUser?.uid else {
            print("🚫Error: No user ID found")
            return
        }
        
        // Reference to the Firestore database
        let db = Firestore.firestore()
        
        // Reference to the user's document in the "users" collection
        let userDocRef = db.collection("users").document(userID)
        
        // Get the user document
        userDocRef.getDocument { document, error in
            if let error = error {
                print("🚫Error fetching user document: \(error)")
                return
            }
            
            guard let document = document, document.exists, let data = document.data() else {
                print("🚫Error: User document does not exist or no data found")
                return
            }
            
            // Map the document data to the MyData object
            MyData.shared.updateProperties(with: data)
            
            if let geoPoint = data["coordinate"] as? GeoPoint {
                MyData.shared.coordinate = CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
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
    
}



