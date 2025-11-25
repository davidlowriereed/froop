//
//  Froop_Base_Template.swift
//  FroopProof
//
//  Created by David Reed on 2/3/23.
//

import SwiftUI
import UIKit
import Firebase
import FirebaseFirestore
 
import FirebaseAuth
import FirebaseCore
import FirebaseStorage
import Kingfisher

struct FroopBaseTView: View {
    @ObservedObject var myData = MyData.shared
    @Binding var showEditView: Bool
    let uid = FirebaseServices.shared.uid
    let db = FirebaseServices.shared.db
    @State private var profileImageUrl: URL?
    
    var body: some View {
        ZStack (alignment: .top){
            Rectangle()
                .frame(minWidth: 0,maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .foregroundColor(.gray)
                .opacity(0.001)
                .ignoresSafeArea()
            
            VStack{
                
                ZStack (alignment: .top){
                    
                    Rectangle()
                        .frame(minWidth: 0,maxWidth: .infinity, minHeight: 125, maxHeight: 125, alignment: .top)
                        .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                        .opacity(0.5)
                        .offset(y: 0)
                    HStack {
                        Rectangle()
                            .frame(height: 126)
                            .foregroundColor(.clear)
                            .opacity(0.001)
                        
                        VStack{
                            KFImage(URL(string: MyData.shared.profileImageUrl))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 126, height: 126)
                                .clipShape(Circle())
                            
                        }
                        VStack {
                            HStack {
                                Spacer()
                                Button {
                                    withAnimation (.easeInOut) {
                                        showEditView = true
                                        TimerServices.shared.shouldCallupdateUserLocationInFirestore = false
                                        TimerServices.shared.shouldCallAppStateTransition = false
                                    }
                                } label: {
                                    Text("Edit")
                                        .foregroundColor(.white)
                                }
                                .padding(.trailing, 25)
                            }
                            Spacer()
                        }
                        .frame(height: 126)
                    }
                    .padding(.top, 20)
                    
                }
            }
        }
    }
}
