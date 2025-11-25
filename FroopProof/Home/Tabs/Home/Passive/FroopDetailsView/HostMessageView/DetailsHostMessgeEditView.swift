//
//  DetailsHostMessgeEditView.swift
//  FroopProof
//
//  Created by David Reed on 6/21/23.
//

//
//  DetailsHostMessageView.swift
//  Design_Layouts
//
//  Created by David Reed on 6/20/23.
//

import SwiftUI
import SwiftUIBlurView
import Kingfisher
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import Foundation
import MapKit
import EventKit
import FirebaseCrashlytics
import AVKit
import UIKit
import PhotosUI

struct DetailsHostMessageEditView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var viewModel = DetailsGuestViewModel.shared
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var navLocationServices = NavLocationServices.shared
    // @ObservedObject var froopDataListener = FroopDataListener.shared
    @ObservedObject var myData = MyData.shared
    @ObservedObject var froopManager = FroopManager.shared
    @ObservedObject var friendViewController = FriendViewController.shared
    @ObservedObject var timeZoneManager: TimeZoneManager = TimeZoneManager()
    @ObservedObject var froopData = FroopData.shared
    //    @ObservedObject var friendData: UserData = UserData()
    
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    @Binding var messageEdit: Bool
    
    @State var froopHostMessage: String = ""
    @State private var isEditing = false
    
    var body: some View {
        ZStack (alignment: .top) {
            
            Rectangle()
                .foregroundColor(colorScheme == .dark ? .white : .white)
                .opacity(1)
                .onTapGesture {
                    UIApplication.shared.endEditing()
                    withAnimation(.easeInOut(duration: 0.5)) {
                        viewModel.isPickerPresented = false
                    }
                }
            
            
            VStack (spacing: 5){
                ZStack {
                    VStack {
                        HStack {
                            Spacer()
                            Text("cancel")
                                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.75))
                                .font(.system(size: 16))
                                .fontWeight(.semibold)
                                .onTapGesture {
                                    messageEdit = false
                                    UIApplication.shared.endEditing()
                                    viewModel.resetVideoProperties()
                                }
                                .padding(.bottom, UIScreen.screenHeight * 0.025)
                        }
                        HStack {
                            Text("Create a Host Message Everyone Will See or...")
                                .font(.system(size: 16))
                                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                .opacity(0.7)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        
                        ZStack {
                            VStack {
                                ZStack (alignment: .center) {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.15), lineWidth: 1)
                                        .fill(Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.05))
                                        .frame(height: 170)
                                        .padding(.leading, 5)
                                    
                                    FocusableTextEditor(text: $froopHostMessage, isFirstResponder: isEditing)
                                        .onChange(of: froopHostMessage, initial: false) { _, newValue in
                                            if newValue.count > 150 {
                                                froopHostMessage = String(newValue.prefix(150))
                                            }
                                        }
                                        .font(.system(size: 20))
                                        .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.75))
                                        .lineLimit(4)
                                        .frame(height: 150)
                                        .padding(.leading, 15)
                                        .padding(.trailing, 15)
                                        .onAppear {
                                            self.isEditing = true
                                        }
                                }
                            }
                        }
                    }
                    .padding(.trailing, 25)
                    .padding(.leading, 15)
                }
                
                HStack {
                    Spacer()
                    VStack (alignment: .trailing) {
                        Text("\(150 - froopHostMessage.count)")
                            .font(.system(size: 12))
                            .foregroundColor(froopHostMessage.count > 140 ? .red : .gray)
                            .padding(.trailing, 35)
                            .offset(y: -30)
                    }
                }
                
                VStack (spacing: 7) {
                    HStack {
                        Text("Upload a Video for a Personal Greeting.")
                            .font(.system(size: 16))
                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                            .opacity(0.7)
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    .padding(.trailing, 15)
                    .padding(.leading, 15)
//                    .onChange(of: viewModel.selectedVideoURL) {
//                        print("selectedVideoURL: \(viewModel.selectedVideoURL ?? URL(fileURLWithPath: ""))")
//                    }
//                    .onChange(of: viewModel.uploadProgress) {
//                        print("upload progress: \(String(describing: viewModel.uploadProgress))")
//                    }
                    
                    ZStack (alignment: .center) {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.25), lineWidth: 1)
                            .fill(Color.white)
                            .frame(height: 100)
                            .padding(.trailing, 20)
                            .padding(.leading, 20)
                        VStack {
                            HStack(alignment: .center, spacing: 0) {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(red: 249/255, green: 0/255, blue: 98/255))
                                    .frame(minWidth: 0, maxWidth: (UIScreen.screenWidth - 30) * viewModel.uploadProgress, minHeight: 5, maxHeight: 5)
                               
                                Spacer()
                            }
                            .overlay(
                                HStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.25), lineWidth: 1)
                                    .opacity(viewModel.uploadProgress > 0.0 ? 1.0 : 0.0)
                                    .frame(minWidth: 0, maxWidth: (UIScreen.screenWidth - 30) * viewModel.conversionProgress, minHeight: 5, maxHeight: 5)
                                    Spacer()
                                }
                            )
                        }
                        .offset(y: viewModel.uploadSuccessful ? 55 : 45) // Move down by 10 along the Y axis when upload is successful
                        .offset(x: 4)
                        .opacity(viewModel.uploadSuccessful ? 0 : 1) // Fade away when upload is successful
                        .animation(.easeInOut, value: viewModel.uploadSuccessful) // Apply animation
                        .padding(.horizontal, 20)
                       
                        
                        HStack (alignment: .center) {
                            ZStack (alignment: .center){
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.25), lineWidth: 1)
                                    .fill(Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.15))
                                    .frame(width: 70, height: 70)
                             
                                Image(systemName: "video.square")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.white)
                                    .fontWeight(.light)
                                
                                
                                if let videoURL = viewModel.selectedVideoURL {
                                    // Display the thumbnail or a placeholder
                                    Group {
                                        if let thumbnail = viewModel.videoThumbnail {
                                            Image(uiImage: thumbnail)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 75, height: 75)
                                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                                .overlay(
                                                    // Show progress indicator if isShowingProgressIndicator is true
                                                    viewModel.isPreparingVideo == true || viewModel.isUploadingVideo == true ? ProgressView()
                                                        .frame(width: 75, height: 75)
                                                        .foregroundColor(.white)
                                                        .background(Color.white.opacity(0.75))
                                                        .cornerRadius(10) : nil
                                                )
                                        } else {
                                            // Placeholder or message for when the thumbnail is not available
                                            Text("Missing")
                                                .frame(width: 75, height: 75)
                                                .background(Color.gray)
                                                .cornerRadius(10)
                                        }
                                    }
                                    .onAppear {
                                        // Generate thumbnail when the view appears
                                        viewModel.generateThumbnail(for: videoURL)
                                    }
                                    .onChange(of: videoURL) {
//                                        print("videoURL: \(videoURL)")
                                        // Regenerate thumbnail if the video URL changes
                                        viewModel.generateThumbnail(for: videoURL)
                                    }
                                    .onChange(of: viewModel.videoThumbnail) {
                                        viewModel.isUploadingVideo = false
                                        viewModel.uploadSuccessful = false
                                        viewModel.uploadFailed = false
                                        viewModel.uploadProgress = 0.0
                                    }
                                }
                            }
                            .padding(.leading, 35)
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    if viewModel.isPreparingVideo || viewModel.isUploadingVideo {
//                                        print("not ready to open photoPicker")
                                        return // Exit the onTapGesture early
                                    } else {
                                        viewModel.isPickerPresented = true
                                    }
                                }
                                UIApplication.shared.endEditing()
                            }
                            
                            Spacer()
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                    .frame(height: 30)
                                    .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.75))
                                    .fontWeight(.light)
                                
                                Text(viewModel.isPreparingVideo ? "Preparing Video..." :
                                         viewModel.isUploadingVideo ? "Uploading Video..." :
                                         viewModel.uploadSuccessful ? "Upload Successful" :
                                        viewModel.uploadFailed ? "Upload Failed" :
                                        viewModel.videoThumbnail != nil ? "Start Upload" : "Choose Video")
                                    .font(.system(size: 16))
                                    .foregroundColor(viewModel.selectedVideoURL != nil ? Color(red: 249/255, green: 0/255, blue: 98/255) : Color(red: 50/255, green: 46/255, blue: 62/255))
                                    .opacity(0.7)
                                    .fontWeight(.regular)
                            }
                            .padding(.trailing, 100)
                            .onTapGesture {
//                                print("isShowingProgressIndicator: \(viewModel.isShowingProgressIndicator)")
//                                print("isPickerPresented: \(viewModel.isPickerPresented)")

                                // Check if the video is being prepared or uploaded
                                if viewModel.isPreparingVideo || viewModel.isUploadingVideo {
//                                    print("not ready to open photoPicker")
                                    return // Exit the onTapGesture early
                                } else {
                                    
                                    // If a thumbnail exists, start the upload process
                                    if let selectedVideoURL = viewModel.selectedVideoURL, viewModel.videoThumbnail != nil {
                                        // Immediately hide the picker and show progress indicator
                                        viewModel.isPickerPresented = false
                                        viewModel.isShowingProgressIndicator = true
                                        
                                        // Offload the video upload process to a background thread
                                        DispatchQueue.global(qos: .userInitiated).async {
                                            viewModel.uploadVideo(url: selectedVideoURL, viewModel: viewModel)
                                        }
                                    } else {
                                        // Show the picker
                                        withAnimation(.easeInOut(duration: 0.5)) {
                                            viewModel.isPickerPresented = true
                                        }
                                        UIApplication.shared.endEditing()
                                    }
                                }
                            }
                            
                            .onChange(of: viewModel.uploadSuccessful == true || viewModel.uploadFailed == true) {
                                viewModel.isShowingProgressIndicator = false
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                }
                
                
                HStack {
                    Spacer()
                    Text("Save")
                        .font(.system(size: 16))
                        .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255))
                        .opacity(viewModel.isPickerPresented || viewModel.isPreparingVideo || viewModel.isUploadingVideo ? 0 : 1)
                        .animation(.easeInOut, value: viewModel.isUploadingVideo) // Apply animation
                        .padding(.trailing, 25)
                        .onTapGesture {
                            UIApplication.shared.endEditing()
                            saveMessage()
                            messageEdit = false
                            viewModel.resetVideoProperties()
                        }
                }
                
                .padding(.top, 10)
            }
            .padding(.top, UIScreen.screenHeight * 0.075)
            
            if viewModel.isPickerPresented {
                VStack {
                    Spacer()
                    VideoPickerView(onVideoSelected: { selectedVideoURL in
                       
                    })
                    .frame(height: UIScreen.screenHeight * 0.4)
                }
                .transition(.move(edge: .bottom)) // Define the transition
                .animation(.easeInOut(duration: 0.3), value: viewModel.isPickerPresented) // Animate the transition
            }
        }
    }
    
    func prepareForVideoUpload() {
        UIApplication.shared.endEditing()
        viewModel.isPickerPresented = false
        viewModel.isShowingProgressIndicator = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            viewModel.uploadVideo(url: viewModel.selectedVideoURL ?? URL(fileURLWithPath: ""), viewModel: viewModel)
        }
        
    }
    
    func uploadVideo(_ videoURL: URL, onVideoUploaded: @escaping (URL) -> Void, onUploadComplete: @escaping () -> Void) {
        let froopId = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopId ?? ""
        let froopHost = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.host.froopUserID ?? ""
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let froopMediaAssetsRef = storageRef.child("FroopMediaAssets/\(froopHost)/\(froopId)")
        let videoName = UUID().uuidString
        let videoRef = froopMediaAssetsRef.child("\(videoName).mp4")
        viewModel.isPickerPresented = false
        viewModel.uploadProgress = 0.01
        // Metadata for video upload
        let metaData = StorageMetadata()
        metaData.contentType = "video/mp4"
        
        // Upload task for the video
        let uploadTask = videoRef.putFile(from: videoURL, metadata: metaData) { metadata, error in
            if let error = error {
                print("🚫Error uploading video: \(error)")
                return
            }
            
            videoRef.downloadURL { url, error in
                if let url = url {
                    // Add media URL to document
                    FroopManager.shared.addVideoURLToDocument(
                        froopHost: froopHost,
                        froopId: froopId,
                        videoUrl: url
                    )
                    
                    onVideoUploaded(url)
                    onUploadComplete()
                } else {
                    print("🚫Error fetching URL: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
        
        // Optionally, monitor upload progress
        uploadTask.observe(.progress) { snapshot in
            let percentComplete = Double(snapshot.progress!.completedUnitCount)
            / Double(snapshot.progress!.totalUnitCount)
            DispatchQueue.main.async {
                self.viewModel.uploadProgress = CGFloat(percentComplete)
            }
//            print("Upload is \(percentComplete * 100)% done")
        }
    }
    
    func saveMessage() {
        guard let uid = Auth.auth().currentUser?.uid else {
//            print("No user ID found")
            return
        }
        
        let froopDocRef = Firestore.firestore().collection("users").document(uid).collection("myFroops").document(froopManager.selectedFroopHistory.froop.froopId)
        
        froopDocRef.updateData([
            "froopMessage": froopHostMessage
        ]) { err in
            if let err = err {
                print("🚫Error updating document: \(err)")
            } else {
//                print("Document successfully updated")
                showAlert(title: "Success", message: "Message was saved successfully.")
            }
        }
    }
    
    func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showingAlert = true
    }
}



struct FocusableTextEditor: UIViewRepresentable {
    @Binding var text: String
    var isFirstResponder: Bool = false
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.backgroundColor = UIColor.clear // Make background transparent
        textView.delegate = context.coordinator
        
        // Set text color to dark gray (or any color you prefer) that remains the same in both light and dark mode
        textView.textColor = UIColor(red: 50/255, green: 46/255, blue: 62/255, alpha: 0.75)
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
        if isFirstResponder && !uiView.isFirstResponder {
            uiView.becomeFirstResponder()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: FocusableTextEditor
        
        init(_ parent: FocusableTextEditor) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            self.parent.text = textView.text
        }
    }
}











