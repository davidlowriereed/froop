//
//  ProfileCompletionView.swift
//  FroopProof
//
//  Created by David Reed on 1/19/23.
//

import SwiftUI
import UIKit
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

struct ProfileCompletionView4: View {
    @AppStorage("ProfileCompletionCurrentPage") var ProfileCompletionCurrentPage = 4
    @ObservedObject var userData: UserData
    
    var body: some View {
        NavigationView{
            
            VStack {
                Form {
                    Section(header: Text("Name")) {
                        TextField("First Name", text: $userData.firstName)
                        TextField("Last Name", text: $userData.lastName)
                    }
                    Section(header: Text("Contact")) {
                        TextField("Phone Number", text: $userData.phoneNumber)
                    }
                    Section(header: Text("Address")) {
                        TextField("Address Number", text: $userData.addressNumber)
                        TextField("Address Street", text: $userData.addressStreet)
                        TextField("Unit Name", text: $userData.unitName)
                        TextField("City", text: $userData.addressCity)
                        TextField("State", text: $userData.addressState)
                        TextField("Zip", text: $userData.addressZip)
                        TextField("Country", text: $userData.addressCountry)
                    }
                }
            }
            .navigationTitle("Froop Beta")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button{
                        if ProfileCompletionCurrentPage <= PCtotalPages{
                            ProfileCompletionCurrentPage += 1
                            print(ProfileCompletionCurrentPage)
                        }
                        let db = Firestore.firestore()
                        let currentUserUID = Auth.auth().currentUser?.uid ?? ""
                        let docRef = db.collection("users").document(currentUserUID)
                        
                        
                        docRef.updateData([
                            "firstName": self.userData.firstName,
                            "lastName": self.userData.lastName,
                            "phoneNumber": self.userData.phoneNumber,
                            "addressNumber": self.userData.addressNumber,
                            "addressStreet": self.userData.addressStreet,
                            "unitName": self.userData.unitName,
                            "addressCity": self.userData.addressCity,
                            "addressState": self.userData.addressState,
                            "addressZip": self.userData.addressZip,
                            "addressCountry": self.userData.addressCountry
                        ])
                    }label:{
                        Text("Save")
                        Image(systemName: "square.and.arrow.down.fill")
                    }
                }
            }
        }
    }
}
