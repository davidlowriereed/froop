//
//  DetailsMediaView.swift
//  Design_Layouts
//
//  Created by David Reed on 6/20/23.
//

import SwiftUI
import Kingfisher

struct DetailsMediaView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var froopManager = FroopManager.shared
//    @Binding var selectedFroopHistory: FroopHistory
    
    var body: some View {
        VStack (spacing: 0){
            ZStack {
                
                Rectangle()
                    .frame(height: 50)
                    .foregroundColor(Color(red: 250/255 , green: 250/255, blue: 255/255))
                
                VStack {
                    Spacer()
                    
                    HStack (alignment: .center){
                        Text("Archived Media")
                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                            .font(.system(size: 18))
                            .fontWeight(.regular)
                            .opacity(0.7)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 10)
                        Spacer()
                        
                        Text("Open")
                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                            .font(.system(size: 18))
                            .fontWeight(.regular)
                            .opacity(0.7)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 10)
                    }
                    .onTapGesture {
                        froopManager.archivedSelectedTab = 0
                        froopManager.archivedImageViewOpen = true
                        froopManager.numColumn = 1
                    }
                    .padding(.trailing, 25)
                    .padding(.leading, 25)
                }
                .frame(maxHeight: 50)
            }
            Divider()
            
            ZStack {
                Rectangle()
                    .frame(height: 100)
                    .foregroundColor(Color(red: 250/255 , green: 250/255, blue: 255/255))
                
                HStack {
                    Button {
                        if froopManager.selectedFroopHistory.host.froopUserID == "froop" {
                            
                        } else {
                            froopManager.archivedSelectedTab = 1
                            froopManager.archivedImageViewOpen = true
                        }
                    } label: {
                        HStack (alignment: .top) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(.white)
                                    .opacity(0.5)
                                    .frame(width: 65, height: 65)
                                    .shadow(color: Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.4), radius: 4, x: 4, y: 4)
                                    .shadow(color: Color.white.opacity(0.9), radius: 4, x: -4, y: -4)
                                Text(froopManager.selectedFroopHistory.host.froopUserID == "froop" ?  "" : "Upload")
                                    .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                    .font(.system(size: 14))
                            }
                            .padding(.trailing, 10)
                        }
                    }                    
                    .frame(maxWidth: 100)
                    
                    Divider()
                        .frame(height: 75)
                    
                    if froopManager.selectedFroopHistory.froop.froopThumbnailImages.isEmpty {
                        Text("Upload your photos now.")
                            .foregroundColor(.gray)
                            .font(.system(size: 16))
                            .padding()
                            .frame(alignment: .leading)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack (spacing: 5) {
                                ForEach(froopManager.selectedFroopHistory.froop.froopThumbnailImages, id: \.self) { imageUrlString in
                                    if let imageUrl = URL(string: imageUrlString) {
                                        KFImage(imageUrl)
                                            .resizable()
                                            .scaledToFill()  // Use scaledToFill
                                            .frame(width: 75, height: 75)
                                            .clipShape(RoundedRectangle(cornerRadius: 10)) // Clip the image with a rounded rectangle
                                            .onTapGesture {
                                                froopManager.archivedSelectedTab = 0
                                                froopManager.archivedImageViewOpen = true
                                                froopManager.numColumn = 1
                                            }
                                    } else {
                                        Image(systemName: "photo")
                                            .font(.system(size: 75))
                                            .foregroundColor(.gray)
                                            .clipShape(RoundedRectangle(cornerRadius: 10)) // Clip the placeholder image as well
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.trailing, 15)
                .padding(.leading, 15)
            }
            Divider()
        }
    }
}
