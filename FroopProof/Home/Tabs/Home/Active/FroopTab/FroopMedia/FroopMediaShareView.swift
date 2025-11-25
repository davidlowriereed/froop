
//
//  FroopMediaShare.swift
//  FroopProof
//
//  Created by David Reed on 7/10/23.
//

import SwiftUI

struct FroopMediaShareView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var viewModel = MediaGridViewModel.shared
    @ObservedObject var photoViewController = PhotoViewController.shared
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            ZStack {
                Rectangle()
                    .foregroundColor(.white)
                    .opacity(0.5)
                    .ignoresSafeArea()
                    .background(.ultraThinMaterial)
                
                VStack {
                    Text(selectedTab == 0 ? "Everyone's Shared Photos" : "Upload Media from your Library")
                        .foregroundColor(colorScheme == .dark ? Color(red: 50/255, green: 46/255, blue: 62/255) : Color(red: 50/255, green: 46/255, blue: 62/255))
                        .fontWeight(.semibold)
                        .font(.system(size: 22))
                        .multilineTextAlignment(.center)
                        .padding(.top, 25)
                        .padding(.bottom, 10)
                    Picker("", selection: $selectedTab) {
                        Text("All Froop Images").tag(0)
                        Text("Your Photo Library").tag(1)
                    }
                    .foregroundColor(colorScheme == .dark ? Color(red: 50/255, green: 46/255, blue: 62/255) : Color(red: 50/255, green: 46/255, blue: 62/255))
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    Spacer()
                }
                .padding(.top, 10)
            
                // Horizontal scroll for selected upload items
         
            }
            
            
            
            ZStack {
                VStack {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(height: 125)
                    TabView(selection: $selectedTab) {
                        FroopMediaFeedView()
                            .tag(0)
                        //                        PhotoPickerView()
                        PhotoLibraryView(uploadedMedia: $viewModel.uploadedMedia)
                            .tag(1)
                    }
                    .onChange(of: selectedTab) {
                        if selectedTab == 1 {
                            photoViewController.didTapAdd()
                        }
                    }
                }
            }
            
            
        }
    }
}
