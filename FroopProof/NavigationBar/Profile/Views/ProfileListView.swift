//
//  ProfileList.swift
//  FroopProof
//
//  Created by David Reed on 1/19/23.
//

import SwiftUI
import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseCore
import FirebaseStorage
import iPhoneNumberField

struct ProfileListView: View {
    @ObservedObject var locationManager = LocationManager.shared
    @ObservedObject var froopManager = FroopManager.shared
    @ObservedObject var myData = MyData.shared
    @ObservedObject var photoData: PhotoData
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var firebaseServices = FirebaseServices.shared
    @ObservedObject var userSettings = UserSettings.shared
    @ObservedObject var appStateManager = AppStateManager.shared
    @State var showEditView = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    var uid = FirebaseServices.shared.uid
    var db = FirebaseServices.shared.db
    @State private var profileImageUrl: URL?
    
    var body: some View {
        ZStack (alignment: .top){
           
            VStack {
                Rectangle()
                    .fill(.clear)
                    .frame(height: 115)
                VStack (alignment: .leading) {
                    
                    Rectangle()
                        .fill(.clear)
                        .frame(height: 115)
                    
                    Divider()
                    List {
                        Section(header: Text("Name")) {
                            Text(myData.firstName)
                            Text(myData.lastName)
                        }
                    }
                    .environment(\.defaultMinListRowHeight, 5)
                    .font(.subheadline)
                    .frame(maxHeight: 600)
                    .background(.red)
                }
                        
                Spacer()
                HStack {
                    Button {
                        do {
                            ListenerStateService.shared.deactivateAll()
                            appStateManager.showCoverScreen = true
                            print("🧢 showCoverScreen = \(String(describing: appStateManager.showCoverScreen))")
                            try Auth.auth().signOut()

                        } catch {
                            PrintControl.shared.printErrorMessages("Error signing out: \(error.localizedDescription)")
                        }
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 5)
                                .strokeBorder(Color(.black).opacity(0.5), lineWidth: 0.5)
                                .frame(width: 175, height: 40)
                            
                            Text("Log Out")
                                .font(.system(size: 28, weight: .thin))
                                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                .multilineTextAlignment(.center)
                        }
                    }
                    .frame(width: 175, height: 40)
//                    .border(Color(red: 50/255, green: 46/255, blue: 62/255), width: 1)
                    .padding(.top)
                    .padding(.bottom, 50)
                }
                Spacer()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                appStateManager.hasRespondedToRibbon = false
                appStateManager.currentViewID = .profile
                print("Setting currentViewID to .\(appStateManager.currentViewID) in \(String(describing: self))")
            }
        }
        .ignoresSafeArea()
        FroopBaseTView(showEditView: $showEditView)
            .fullScreenCover(isPresented: $showEditView, onDismiss: nil, content: {
                EditProfileView(photoData: photoData, showEditView: self.$showEditView, showAlert: self.$showAlert, alertMessage: self.$alertMessage, urlHolder: MyData.shared.profileImageUrl, firstName: "", lastName: "", phoneNumber: "", addressNumber: "", addressStreet: "", unitName: "", addressCity: "", addressState: "", addressZip: "", addressCountry: "", formattedPhoneNumber: "")
            })
    }
}




