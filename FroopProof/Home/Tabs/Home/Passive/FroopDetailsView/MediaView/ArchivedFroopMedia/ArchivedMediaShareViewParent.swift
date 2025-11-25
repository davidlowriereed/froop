//
//  ArchivedMediaShareViewParent.swift
//  FroopProof
//
//  Created by David Reed on 2/8/24.
//

import Foundation
import SwiftUI


struct ArchivedMediaShareViewParent: View {
    @ObservedObject var froopManager = FroopManager.shared
    @ObservedObject var viewModel = MediaGridViewModel.shared
    @ObservedObject var photoViewController = PhotoViewController.shared
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedTab = 0
    @State private var refreshID = UUID()
    
    
    var body: some View {
        ZStack {
            ArchivedMediaShareView()
            
            VStack {
                ZStack {
                    Rectangle()
                        .fill(.white)
                        .frame(height: 135)
                        .border(Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.5), width: 0.5)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 10) {
                            ForEach(viewModel.selectedMedia.reversed(), id: \.id) { media in
                                mediaThumbnailView(for: media)
                                    .transition(.asymmetric(insertion: .slide, removal: .opacity))
                                    .animation(.easeInOut, value: viewModel.selectedMedia)
                            }
                            .onChange(of: viewModel.selectedMedia.count) { oldValue, newValue in
                                if newValue == 1 {
                                    refreshID = UUID()
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(height: 110) // Adjust the height as needed
                }
                .offset(y: viewModel.selectedMedia.isEmpty ? -200 : 0)
                .animation(.easeInOut, value: viewModel.selectedMedia.isEmpty)
                
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    private func mediaThumbnailView(for media: MediaData) -> some View {
        if let image = media.displayImage {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .overlay(UploadProgressOverlay(mediaData: media))
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            
        } else if let thumbnailImage = media.thumbnailImage {
            Image(uiImage: thumbnailImage)
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .overlay(UploadProgressOverlay(mediaData: media))
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            
        }
    }
}

