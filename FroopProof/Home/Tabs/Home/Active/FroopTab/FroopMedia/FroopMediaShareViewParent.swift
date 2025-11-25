//
//  FroopMediaShareViewParent.swift
//  FroopProof
//
//  Created by David Reed on 2/6/24.
//

import Foundation
import SwiftUI

struct FroopMediaShareViewParent: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var viewModel = MediaGridViewModel.shared
    @ObservedObject var photoViewController = PhotoViewController.shared
    @State private var selectedTab = 0
    @State private var displayedMediaIDs = Set<UUID>()
    @State private var refreshID = UUID()

    var body: some View {
        ZStack {
            FroopMediaShareView()
            
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
        .opacity(appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopId == nil ? 0.5 : 1)
        .padding(.top, 100)
        .navigationTitle("\(appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopName ?? "")")


    }
    
    @ViewBuilder
    private func mediaThumbnailView(for media: MediaData) -> some View {
        if let image = media.displayImage {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 100, height: 100)
                .overlay(UploadProgressOverlay(mediaData: media))
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 10))
               

        } else if let thumbnailImage = media.thumbnailImage {
            Image(uiImage: thumbnailImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 100, height: 100)
                .overlay(UploadProgressOverlay(mediaData: media))
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 10))
                

        }
    }
}

struct PopInModifier: ViewModifier {
    let isActive: Bool

    func body(content: Content) -> some View {
        content
            .scaleEffect(isActive ? 0.5 : 1)
            .opacity(isActive ? 0 : 1)
            .animation(.easeOut(duration: 0.5), value: isActive)
    }
}

extension View {
    func popIn(if isActive: Bool) -> some View {
        self.modifier(PopInModifier(isActive: isActive))
    }
}


struct UploadProgressOverlay: View {
    @ObservedObject var viewModel = MediaGridViewModel.shared
    @ObservedObject var mediaData: MediaData
    @ObservedObject var mediaManager = MediaManager.shared

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                if mediaData.uploadProgress < 0 && viewModel.isUploading {
                   Text("Processing")
                        .font(.system(size: 12))
                        .foregroundStyle(.white)
                } else {
                    if mediaData.uploadProgress > 0.01 || viewModel.isUploading {
                        Rectangle()
                            .fill(Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.8))
                        // Calculate the height based on upload progress
                            .frame(height: geometry.size.height * CGFloat(1.0 - mediaData.uploadProgress))
                            .transition(.slide)
                        // Apply the new animation modifier
                            .animation(.linear(duration: 0.5), value: mediaData.uploadProgress)
                    }
                    if mediaData.uploadProgress < 0.01 && viewModel.isUploading {
                        Text(String(format: "%.1f %%", mediaManager.conversionProgress * 100))
                            .font(.system(size: 12))
                            .foregroundStyle(.white)
                    } else {
                        Text(String(format: "%.1f %%", mediaData.uploadProgress * 100))
                            .font(.system(size: 12))
                            .foregroundStyle(.white)
                    }
                }
            }
        }
    }
}
