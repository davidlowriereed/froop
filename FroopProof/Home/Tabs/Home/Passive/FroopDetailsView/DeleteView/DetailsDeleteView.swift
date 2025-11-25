//
//  DetailsDeleteView.swift
//  FroopProof
//
//  Created by David Reed on 6/21/23.
//

import SwiftUI

struct DetailsDeleteView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var froopManager = FroopManager.shared
    @ObservedObject var myData = MyData.shared
    
    @Binding var froopAdded: Bool
    @Binding var selectedFroopHistory: FroopHistory


    @State private var showingDeleteAlert = false  // New state to control alert appearance
    
    var body: some View {
        ZStack {
            if (FirebaseServices.shared.uid) == froopManager.selectedFroopHistory.froop.froopHost {
                
                Button(action: {
                    self.showingDeleteAlert = true  // Show the alert on button tap
                }) {
                    ZStack {
                        Rectangle ()
                            .frame(height: 110)
                            .foregroundColor(.clear)
                            .background(LinearGradient(gradient: Gradient(colors: [Color(red: 240/255 , green: 240/255, blue: 245/255), Color(red: 250/255 , green: 250/255, blue: 255/255), Color(red: 240/255 , green: 240/255, blue: 245/255)]), startPoint: .top, endPoint: .bottom))
                            .ignoresSafeArea()
                        Rectangle()
                            .frame(width: 250, height: 50)
                            .background(Color.white)
                            .cornerRadius(25)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)  // Makes sure the overlay matches the shape of the rectangle
                                    .stroke(Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.25), lineWidth: 1)
                            )
                       
                        Text("Delete Froop")
                            .foregroundColor(colorScheme == .dark ? Color(red: 50/255, green: 46/255, blue: 62/255) : Color(red: 50/255, green: 46/255, blue: 62/255))
                            .font(.system(size: 18))
                            .fontWeight(.regular)
                    }
                }
                .alert(isPresented: $showingDeleteAlert) { // Alert View
                    Alert(title: Text("Delete Froop"), message: Text("Are you sure you want to delete this Froop?"), primaryButton: .destructive(Text("Delete")) {
                        self.froopManager.friendDetailOpen = false
                        self.froopManager.froopDetailOpen = false
                        PrintControl.shared.printFroopDetails("current User UID \(FirebaseServices.shared.uid)")
                        PrintControl.shared.printFroopDetails("MyData.shared.froopUserID \(MyData.shared.froopUserID)")
                        FroopDataController.shared.deleteFroop(froopId: froopManager.selectedFroopHistory.froop.froopId , froopHost: myData.froopUserID) { closeSheet in
//                            print("Deleting Froop \(String(describing: froopManager.selectedFroopHistory.froop.froopId))")
                            self.froopAdded = true
                            
                        }
                    }, secondaryButton: .cancel())
                }

            } else {
                Rectangle ()
                    .frame(height: 110)
                    .foregroundColor(colorScheme == .dark ? Color(red: 250/255 , green: 250/255, blue: 255/255) : Color(red: 250/255 , green: 250/255, blue: 255/255))
                    .ignoresSafeArea()
            }
        }
    }
}
