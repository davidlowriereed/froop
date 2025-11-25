//
//  VideoPickerView.swift
//  FroopProof
//
//  Created by David Reed on 1/4/24.
//

import SwiftUI
import PhotosUI
import AVFoundation

struct VideoPickerView: View {
    @ObservedObject var viewModel = DetailsGuestViewModel.shared
    @State private var selectedVideoItems: [PhotosPickerItem] = []
    @State private var isPickerPresented = false
    var onVideoSelected: (URL) -> Void
    
    var body: some View {
        VStack {
            PhotosPicker(
                selection: $selectedVideoItems,
                maxSelectionCount: 1, // Limit to one video
                selectionBehavior: .continuousAndOrdered,
                matching: .videos,
                preferredItemEncoding: .current,
                photoLibrary: .shared()
            ) {
                Text("")
            }
            .photosPickerStyle(.inline) // Set the picker style to inline
            .photosPickerDisabledCapabilities(.selectionActions)
            
            // Hide padding around all edges in the picker UI.
            .photosPickerAccessoryVisibility(.hidden, edges: .all)
            .frame(height: 350) // Set the desired height for the inline picker
            .onChange(of: selectedVideoItems) { oldItem, newItem in
                handleSelectedVideoItem(newItem.first)
            }
        }
    }

    private func handleSelectedVideoItem(_ item: PhotosPickerItem?) {
//        print("handleSelectedVideoItem function firing: 🔥")

        guard let item = item else {
//            print("No item selected")
            DispatchQueue.main.async {
                self.viewModel.selectedVideoURL = nil
                self.viewModel.selectedVideoDuration = nil
                self.viewModel.selectedVideoThumbnail = nil
            }
            return
        }

        // Print item details
//        print("Item Identifier: \(item.itemIdentifier ?? "Unknown")")
//        print("Supported Content Types: \(item.supportedContentTypes.map { $0.identifier })")

        // Load thumbnail as data
        if item.supportedContentTypes.contains(UTType("com.apple.private.photos.thumbnail.standard") ?? UTType.image) {
            item.loadTransferable(type: Data.self) { result in
                switch result {
                case .success(let data?):
                    if let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self.viewModel.selectedVideoThumbnail = image
                        }
                    } else {
                        print("🚫Error: Data could not be converted to UIImage")
                        DispatchQueue.main.async {
                            self.viewModel.selectedVideoThumbnail = nil
                        }
                    }
                case .failure(let error):
                    print("🚫Error loading thumbnail: \(error)")
                    DispatchQueue.main.async {
                        self.viewModel.selectedVideoThumbnail = nil
                    }
                default:
                    break
                }
            }
        }
        
        item.loadTransferable(type: Data.self) { result in
            switch result {
            case .success(let data?):
                print("Video data loaded")
                let tempURL = self.createTemporaryURLForVideo(data: data)
                let asset = AVURLAsset(url: tempURL)

                Task {
                    do {
                        let duration = try await asset.load(.duration)
                        let durationSeconds = CMTimeGetSeconds(duration)
//                        print("Video duration loaded: \(durationSeconds) seconds")

                        if durationSeconds <= 60 {
                            DispatchQueue.main.async {
                                self.viewModel.selectedVideoURL = tempURL
                                self.viewModel.selectedVideoDuration = durationSeconds
//                                print("Video URL and duration set in viewModel")
                            }
                        } else {
//                            print("Video is longer than 1 minute")
                            DispatchQueue.main.async {
                                self.viewModel.selectedVideoURL = nil
                                self.viewModel.selectedVideoDuration = nil
//                                print("Video URL and duration reset in viewModel due to length")
                            }
                        }
                    } catch {
                        print("🚫Error loading video duration: \(error)")
                    }
                }
            case .success(.none):
//                print("No data found for the selected item")
                DispatchQueue.main.async {
                    self.viewModel.selectedVideoURL = nil
                    self.viewModel.selectedVideoDuration = nil
                }
            case .failure(let error):
                print("🚫Error loading video: \(error)")
                DispatchQueue.main.async {
                    self.viewModel.selectedVideoURL = nil
                    self.viewModel.selectedVideoDuration = nil
                }
            }
        }
    }

    private func createTemporaryURLForVideo(data: Data) -> URL {
        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString + ".mov")
        do {
            try data.write(to: tempURL)
        } catch {
            print("🚫Error writing video data to temporary file: \(error)")
        }
        return tempURL
    }
}
